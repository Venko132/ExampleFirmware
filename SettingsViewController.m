#import "SettingsViewController.h"

#import "LifeClockController.h"
#import "AnimationSettingsViewController.h"

@interface SettingsViewController () <LifeClockControllerDelegate>

- (IBAction)switchToggled:(UISwitch *)sender;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *connectionProgressSpin;
@property (nonatomic, weak) IBOutlet UISwitch *connectSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *usePhoneSettingsSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *use24HoursFormatSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *leftWristConfigurationSwitch;

@end

@implementation SettingsViewController

@synthesize connectionProgressSpin;
@synthesize connectSwitch;
@synthesize usePhoneSettingsSwitch;
@synthesize use24HoursFormatSwitch;
@synthesize leftWristConfigurationSwitch;

- (void) viewDidLoad {
    [super viewDidLoad];

    LifeClockController *lc = [LifeClockController getInstance];
    
    lc.delegate = self;
}

- (IBAction)switchToggled:(UISwitch *)sender
{
    LifeClockController *lc = [LifeClockController getInstance];
    
    if (sender == connectSwitch) {
        if ([sender isOn]){
            if (lc.connectionState == STATE_IDLE) {
                [lc connect];
            }
        } else {
            if (lc.connectionState != STATE_IDLE) {
                [lc disconnect];
            }
        }
        
        return;
    }
    
    if (sender == use24HoursFormatSwitch) {
        LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
        c.time_format = use24HoursFormatSwitch.on ? BLE_LIFE_CLOCK_TIME_FORMAT_24H : BLE_LIFE_CLOCK_TIME_FORMAT_12H;
        lc.configuration = &c;
        return;
    }
    
    if (sender == leftWristConfigurationSwitch) {
        LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
        c.wrist_config = leftWristConfigurationSwitch.on ? BLE_LIFE_CLOCK_WRIST_CONFIGURATION_LEFT_HAND : BLE_LIFE_CLOCK_WRIST_CONFIGURATION_RIGHT_HAND;
        lc.configuration = &c;
        return;
    }
}

- (void) didChangeConnectionState:(STATE)state {
    switch (state) {
        case STATE_IDLE:
            [connectionProgressSpin stopAnimating];
            break;
        case STATE_SCANNING:
            [connectionProgressSpin startAnimating];
            break;
        case STATE_CONNECTED:
            [connectionProgressSpin stopAnimating];
            break;
        default:;
    }
}

- (void) didChangeConfiguration:(const LIFE_CLOCK_CONFIGURATION *)newConfiguration {
    LifeClockController *lc = [LifeClockController getInstance];
    use24HoursFormatSwitch.on = lc.configuration->time_format == BLE_LIFE_CLOCK_TIME_FORMAT_24H;
    leftWristConfigurationSwitch.on = lc.configuration->wrist_config == BLE_LIFE_CLOCK_WRIST_CONFIGURATION_LEFT_HAND;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AnimationSettingsSegue"]) {
        AnimationSettingsViewController *vc = [segue destinationViewController];
        vc.tableView.tag = ((UITableViewCell *)sender).tag;
    }
}

@end
