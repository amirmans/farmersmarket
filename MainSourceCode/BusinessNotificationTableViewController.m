//
//  BusinessNotificationTableViewController.m
//  TapForAll
//
//  Created by Amir on 12/3/13.
//
//

#import "BusinessNotificationTableViewController.h"
#import "Consts.h"
#import "DataModel.h"
//#import "TapTalkChatMessage.h"
#import "TapTalkLooks.h"
#import "NotificationTableViewCell.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface BusinessNotificationTableViewController ()

@end

@implementation BusinessNotificationTableViewController

@synthesize notificationsInReverseChronological;

// delegate Method for NewNotificationWhileRunning
- (void)updateUIWithNewNotification
{
    notificationsInReverseChronological = [[[DataModel sharedDataModelManager] notifications] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
//    self.tabBarItem.badgeValue = nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        AppDelegate * myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        myAppDelegate.notificationDelegate = self;
                                       
    }
    return self;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TapTalkLooks setBackgroundImage:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // for some reason - setting the background color in the nib file didn't work
    self.title = @"Notification Center";
    //resizing for different screen size (done by adding constraint and add chosing auto layout in the xib file)
    //happens after viewDidLoad and before viewDidAppear, so I moved the following method to viewDidAppear
//    [TapTalkLooks setBackgroundImage:self.tableView];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.tableView.rowHeight = 150; // change this number whenever you change the ui in NotificationTableViewCell
    
    // we want to show the notifications in the reverse chronological order: the last
    // one should be displayed first
//    notificationsInReverseChronological = [[[[[DataModel sharedDataModelManager] notifications]
//                                             reverseObjectEnumerator] allObjects] mutableCopy];
    notificationsInReverseChronological = [[[DataModel sharedDataModelManager] notifications]  mutableCopy];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return notificationsInReverseChronological.count;
}

- (NotificationTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationCell";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (NotificationTableViewCell *) currentObject;
                break;
            }
        }
        
//        [TapTalkLooks setBackgroundImage:cell.contentView];
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
        [TapTalkLooks setToTapTalkLooks:cell.alertMessage isActionButton:NO makeItRound:NO];
    }
    
    // Configure the cell...
    NSDictionary *notification = [notificationsInReverseChronological objectAtIndex:indexPath.row];
    cell.sender.text = [notification objectForKey:@"sender"];
    cell.alertMessage.text = [notification objectForKey:@"alert"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *timeString = [formatter stringFromDate:[notification objectForKey:@"dateTimeRecieved"]];
    cell.dateAdded.text = timeString;
    
    //get image url from notification image name
    NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:[notification objectForKey:@"imageName"]];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    [cell.businessNotificationIcon Compatible_setImageWithURL:imageURL placeholderImage:nil];
 
    formatter = nil;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [notificationsInReverseChronological removeObjectAtIndex:indexPath.row];
        [[DataModel sharedDataModelManager] setNotifications:notificationsInReverseChronological];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */


//TODO
- (void)didSaveMessage:(NSString *)message atIndex:(int)index
{
	// This method is called when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
//TODO	if ([self isViewLoaded])
	{
		self.tableView.tableFooterView = nil;
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//TODO		[self scrollToNewestMessage];
	}
}


@end
