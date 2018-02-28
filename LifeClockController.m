#import "LifeClockController.h"

@interface LifeClockController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@end

@implementation LifeClockController {
    CBCentralManager *centralManager;
    CBPeripheral *activePeripheral;
    CBService *activeService;
    CBCharacteristic *rxCharacteristic;
    CBCharacteristic *txCharacteristic;
    LIFE_CLOCK_CONFIGURATION activeConfiguration;
}

@synthesize delegate;
@synthesize connectionState;
//@synthesize configuration;

+ (CBUUID *) serviceUUID {
    return [CBUUID UUIDWithString:@"6f400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) txCharacteristicUUID {
    return [CBUUID UUIDWithString:@"6f400002-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) rxCharacteristicUUID {
    return [CBUUID UUIDWithString:@"6f400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) deviceInformationServiceUUID {
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID {
    return [CBUUID UUIDWithString:@"2A27"];
}

- (void) updateConnectionState:(STATE)newState {
    if (newState == connectionState) {
        return;
    }
    connectionState = newState;
    if (![delegate respondsToSelector:@selector(didChangeConnectionState:)]) {
        return;
    }
    [delegate didChangeConnectionState:connectionState];
}

- (void) updateConfiguration:(const LIFE_CLOCK_CONFIGURATION *)newConfiguration {
    activeConfiguration = *newConfiguration;
    if (![delegate respondsToSelector:@selector(didChangeConfiguration:)]) {
        return;
    }
    [delegate didChangeConfiguration:newConfiguration];
}

- (const LIFE_CLOCK_CONFIGURATION *) configuration {
    return &activeConfiguration;
}

- (void) setConfiguration:(const LIFE_CLOCK_CONFIGURATION *)newConfiguration {
    [self writeConfiguration:newConfiguration];
    [self updateConfiguration:newConfiguration];
}

+ (id) getInstance {
    static dispatch_once_t pred = 0;
    __strong static id _instance = nil;
    dispatch_once(&pred, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id) init {
    if (self = [super init]) {
        connectionState = STATE_IDLE;
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void) dealloc {
}

- (void) connect {
    if (connectionState == STATE_IDLE) {
        NSArray *peripherals = [centralManager retrieveConnectedPeripheralsWithServices:@[self.class.serviceUUID]];
        
        if (peripherals.count < 1) {
            [self updateConnectionState:STATE_SCANNING];
            [centralManager scanForPeripheralsWithServices:@[self.class.serviceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
        } else {
            activePeripheral = [peripherals objectAtIndex:0];
            activePeripheral.delegate = self;
            
            [centralManager connectPeripheral:activePeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES]}];
            
            [self updateConnectionState:STATE_CONNECTED];
            
            [self readConfiguration];
        }
    }
}

- (void) disconnect {
    [self updateConnectionState:STATE_IDLE];
    if (connectionState == STATE_SCANNING) {
        [centralManager stopScan];
    } else {
        if (connectionState == STATE_CONNECTED) {
            [centralManager cancelPeripheralConnection:activePeripheral];
            activePeripheral = nil;
        }
    }
}

- (void) send:(NSData *)data {
    if ((txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) {
        [activePeripheral writeValue:data forCharacteristic:txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    } else {
        if ((txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0) {
            [activePeripheral writeValue:data forCharacteristic:txCharacteristic type:CBCharacteristicWriteWithResponse];
        } else {
            NSLog(@"No write property on TX characteristic, %d.", (int)txCharacteristic.properties);
        }
    }
}

- (void) readConfiguration {
    ble_life_clock_packet_t packet = {BLE_LIFE_CLOCK_VERSION_ONE, BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION_REQUEST, };
    [self send:[NSData dataWithBytes:&packet length:1]];
}

- (void) writeConfiguration:(const LIFE_CLOCK_CONFIGURATION *)newConfiguration {
    ble_life_clock_packet_t packet = {BLE_LIFE_CLOCK_VERSION_ONE, BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION, };
    packet.payload.configuration = *newConfiguration;
    [self send:[NSData dataWithBytes:&packet length:1 + sizeof(packet.payload.configuration)]];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        // enable operations
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [centralManager stopScan];
    
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [centralManager connectPeripheral:activePeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES]}];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self updateConnectionState:STATE_CONNECTED];
    
    [self readConfiguration];

    if ([activePeripheral isEqual:peripheral]) {
        [activePeripheral discoverServices:@[self.class.serviceUUID, self.class.deviceInformationServiceUUID]];
    }
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updateConnectionState:STATE_IDLE];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", error);
        return;
    }
    
    for (CBService *s in [peripheral services]) {
        if ([s.UUID isEqual:self.class.serviceUUID]) {
            NSLog(@"Found correct service");
            activeService = s;
            [activePeripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:activeService];
        } else {
            if ([s.UUID isEqual:self.class.deviceInformationServiceUUID]) {
                [activePeripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error);
        return;
    }
    
    for (CBCharacteristic *c in [service characteristics]) {
        if ([c.UUID isEqual:self.class.rxCharacteristicUUID]) {
            rxCharacteristic = c;
            [activePeripheral setNotifyValue:YES forCharacteristic:rxCharacteristic];
        } else {
            if ([c.UUID isEqual:self.class.txCharacteristicUUID]) {
                txCharacteristic = c;
            } else {
                if ([c.UUID isEqual:self.class.hardwareRevisionStringUUID]) {
                    [activePeripheral readValueForCharacteristic:c];
                }
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    if (characteristic == rxCharacteristic) {
        if (characteristic.value.length < 1) {
            NSLog(@"Received malformed packet, size = %lu", (unsigned long)characteristic.value.length);
            return;
        }
        
        const ble_life_clock_packet_t *p = (ble_life_clock_packet_t *)characteristic.value.bytes;
        
        if (p->version != BLE_LIFE_CLOCK_VERSION_ONE) {
            NSLog(@"Unexpected packet, version = %d", p->version);
            return;
        }
        
        switch (p->type) {
            case BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION:
                if (characteristic.value.length != 1 + sizeof(LIFE_CLOCK_CONFIGURATION)) {
                    NSLog(@"Unexpected packet, size for type %d = %lu", p->type, (unsigned long)characteristic.value.length);
                    return;
                }
                [self updateConfiguration:&p->payload.configuration];
                break;
            case BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION_REQUEST:
                if (characteristic.value.length != 1) {
                    NSLog(@"Unexpected packet, size for type %d = %lu", p->type, (unsigned long)characteristic.value.length);
                    return;
                }
                NSLog(@"Configuration request is not supported on central side");
                return;
            default:
                NSLog(@"Unexpected packet, type = %d", p->type);
                return;
        }
    } else {
        if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID]) {
            NSString *hwRevision = @"";
            const uint8_t *bytes = characteristic.value.bytes;
            for (int i = 0; i < characteristic.value.length; i++) {
                NSLog(@"%x", bytes[i]);
                hwRevision = [hwRevision stringByAppendingFormat:@"0x%02x, ", bytes[i]];
            }
            //[delegate didReadHardwareRevisionString:[hwRevision substringToIndex:hwRevision.length-2]];
        }
    }
}

@end