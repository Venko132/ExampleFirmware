#import "ListViewController.h"
#import "LifeClockController.h"

#define DATE_FORMAT_TAG 1
#define CASE_MATERIAL_TAG 2

@interface ListViewController () {
    NSUInteger selectedRow;
}

@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LifeClockController *lc = [LifeClockController getInstance];
    LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
    
    if (self.tableView.tag == DATE_FORMAT_TAG) {
        selectedRow = c.tz_format;
    } else {
        if (self.tableView.tag == CASE_MATERIAL_TAG) {
            selectedRow = c.case_material;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (row == selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    LifeClockController *lc = [LifeClockController getInstance];
    LIFE_CLOCK_CONFIGURATION c = *lc.configuration;
    
    if (self.tableView.tag == DATE_FORMAT_TAG) {
        c.tz_format = row;
        lc.configuration = &c;
    } else {
        if (self.tableView.tag == CASE_MATERIAL_TAG) {
            c.case_material = row;
            lc.configuration = &c;
        }
    }
    
    selectedRow = row;
    
    [self.tableView reloadData];
}

@end
