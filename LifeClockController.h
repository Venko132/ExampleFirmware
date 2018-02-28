#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BLE_LIFE_CLOCK_PROTOCOL_ONLY
#include "ble_life_clock.h"

typedef enum{
    STATE_IDLE = 0,
    STATE_SCANNING,
    STATE_CONNECTED,
}STATE;

typedef ble_life_clock_configuration_t LIFE_CLOCK_CONFIGURATION;

@protocol LifeClockControllerDelegate <NSObject>
@optional
- (void) didChangeConnectionState:(STATE)state;
- (void) didChangeConfiguration:(const LIFE_CLOCK_CONFIGURATION *)configuration;
@end

@interface LifeClockController : NSObject

@property id<LifeClockControllerDelegate> delegate;
@property (nonatomic, readonly) STATE connectionState;
@property (nonatomic, readwrite, getter=configuration, setter=setConfiguration:) const LIFE_CLOCK_CONFIGURATION *configuration;

+ (id) getInstance;

- (void) connect;
- (void) disconnect;

@end
