//
//  ShoppingCartTableViewController.m
//  TapForAll
//
//  Created by Amir on 1/3/16.
//
//

#import "EventsTableViewController.h"
#import "EventTableViewCell.h"
#import "TapTalkLooks.h"
#import "Consts.h"
#import "DataModel.h"
#import "AppDelegate.h"

@interface EventsTableViewController ()

@end

@implementation EventsTableViewController

@synthesize biz;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)argBiz
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        biz = argBiz;
    }
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    static NSString *CellIdentifier = @"NotificationCell";
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (EventTableViewCell *) currentObject;
                break;
            }
        }
        
        //        [TapTalkLooks setBackgroundImage:cell.contentView];
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
        [TapTalkLooks setToTapTalkLooks:cell.alertMessage isActionButton:NO makeItRound:NO];
    }
    
    // Configure the cell...
    NSDictionary *notification;
    cell.sender.text = [notification objectForKey:@"sender"];
    cell.alertMessage.text = [notification objectForKey:@"alert"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *timeString = [formatter stringFromDate:[notification objectForKey:@"dateTimeRecieved"]];
    cell.dateAdded.text = timeString;
    
    //get image url from notification image name
//    NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:[notification objectForKey:@"imageName"]];
//    NSURL *imageURL = [NSURL URLWithString:imageURLString];
//    [cell.businessNotificationIcon Compatible_setImageWithURL:imageURL placeholderImage:nil];
    
    formatter = nil;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
