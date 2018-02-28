#import "AnimationSettingsViewController.h"
#import "LifeClockController.h"

@interface AnimationSettingsViewController () {
    NSUInteger selectedRow[2];
}

- (IBAction)stepperChanged:(UIStepper *)sender;

@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIStepper *durationStepper;

@end

@implementation AnimationSettingsViewController

@synthesize durationLabel;
@synthesize durationStepper;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)stepperChanged:(UIStepper *)sender {
    if (sender != durationStepper) {
        return;
    }
    
    LifeClockController *lc = [LifeClockController getInstance];
    LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
    
    const NSInteger state = self.tableView.tag;
    
    c.state_animations[state].duration = (unsigned char)durationStepper.value;
    
    lc.configuration = &c;
    
    durationLabel.text = [NSString stringWithFormat:@"%.0lf", durationStepper.value];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (section == 0 && row == 0){
        LifeClockController *lc = [LifeClockController getInstance];
        LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
        
        const NSInteger state = self.tableView.tag;
        
        durationStepper.value = c.state_animations[state].duration;
        selectedRow[0] = c.state_animations[state].scroll_speed;
        selectedRow[1] = c.state_animations[state].animation;
        
        durationLabel.text = [NSString stringWithFormat:@"%.0lf", durationStepper.value];
    }
    
    if (section > 0) {
        if (row == selectedRow[section - 1]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    if(section < 1) {
        return;
    }
    
    NSUInteger row = [indexPath row];

    selectedRow[section - 1] = row;
    
    LifeClockController *lc = [LifeClockController getInstance];
    LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
    
    const NSInteger state = self.tableView.tag;
    
    c.state_animations[state].scroll_speed = selectedRow[0];
    c.state_animations[state].animation = selectedRow[1];
    
    lc.configuration = &c;
    
    [self.tableView reloadData];
}

@end
