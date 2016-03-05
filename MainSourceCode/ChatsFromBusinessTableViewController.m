//
//  ChatsFromBusinessTableViewController.m
//  TapForAll
//
//  Created by Amir on 3/23/14.
//
//

#import "SpeechBubbleView.h"
#import "TapTalkChatMessage.h"
#import "DataModel.h"
#import "MessageTableViewCell.h"
#import "ChatsFromBusinessTableViewController.h"
//#import "LoginViewController.h"
#import "MBProgressHUD.h"


@interface ChatsFromBusinessTableViewController () {
    
    TapTalkChatMessage *ttChatMessage;
    UIBarButtonItem *toggleUpdatingBusinessChatMessages;
}

@property(strong, nonatomic) IBOutlet UIBarButtonItem *toggleUpdatingBusinessChatMessages;

- (void)doToggleUpdatingBusinessChatMessages;

@end

@implementation ChatsFromBusinessTableViewController


@synthesize toggleUpdatingBusinessChatMessages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        ttChatMessage = [[TapTalkChatMessage alloc] initWithDelegate:self];
//        if ([DataModel sharedDataModelManager].businessMessages != nil) {
//            [[DataModel sharedDataModelManager].businessMessages removeAllObjects];
//        }
        
    }
    return self;
}

- (void)methodThatCallsScrollToRow {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([DataModel sharedDataModelManager].businessMessages.count - 1) inSection:0];
   [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollToNewestMessage {
    // The newest message is at the bottom of the table
    if ([DataModel sharedDataModelManager].businessMessages.count < NumberOfMessagesOnOnePage)
        return;
    //    NSLog(@"indexPath at scrollToNewestMessage is: %i, %i", indexPath.section, indexPath.row);
    [self performSelector:@selector(methodThatCallsScrollToRow) withObject:nil afterDelay:2.5];
}


- (void)reloadDataToBizChatTable {
    [self.tableView reloadData];
    
    if ([DataModel sharedDataModelManager].businessMessages.count > NumberOfMessagesOnOnePage) {
        self.navigationItem.rightBarButtonItem = toggleUpdatingBusinessChatMessages;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self scrollToNewestMessage];
}


- (void)viewWillAppear:(BOOL)animated {    
    [super viewWillAppear:animated];
    self.title = [DataModel sharedDataModelManager].shortBusinessName;
    [[DataModel sharedDataModelManager] buildBusinessChatMessages];
    [self scrollToNewestMessage];

}

- (void)doToggleUpdatingBusinessChatMessages {
    // take care of Title
    if ([DataModel sharedDataModelManager].shouldDownloadChatMessages) {
        toggleUpdatingBusinessChatMessages.title = @"Start";
    } else {
        toggleUpdatingBusinessChatMessages.title = @"Stop";
    }
    // take care of data - inside this method shouldDownloadChatMessages
    [ttChatMessage doToggleUpdatingChatMessages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *loadToggleButtonTitle;
    if ([DataModel sharedDataModelManager].shouldDownloadChatMessages) {
        loadToggleButtonTitle = @"Start";
    } else {
        loadToggleButtonTitle = @"Stop";
    }

    if ([DataModel sharedDataModelManager].businessMessages.count > NumberOfMessagesOnOnePage) {
        toggleUpdatingBusinessChatMessages = [[UIBarButtonItem alloc]
                                              initWithTitle:loadToggleButtonTitle
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(doToggleUpdatingBusinessChatMessages)];
        self.navigationItem.rightBarButtonItem = toggleUpdatingBusinessChatMessages;
        
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    toggleUpdatingBusinessChatMessages = [[UIBarButtonItem alloc]
//                                  initWithTitle:@"Stop"
//                                  style:UIBarButtonItemStyleBordered
//                                  target:self
//                                  action:@selector(doToggleUpdatingBusinessChatMessages)];
//    self.navigationItem.rightBarButtonItem = toggleUpdatingBusinessChatMessages;
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    toggleUpdatingBusinessChatMessages = nil;
    ttChatMessage = nil;

    [super viewDidUnload];
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
    return ([DataModel sharedDataModelManager].businessMessages.count);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This function is called before cellForRowAtIndexPath, once for each cell.
    // We calculate the size of the speech bubble here and then cache it in the
    // Message object, so we don't have to repeat those calculations every time
    // we draw the cell. We add 16px for the label that sits under the bubble.
    NSDictionary *tempMessage = [[DataModel sharedDataModelManager].businessMessages objectAtIndex:indexPath.row];
    [ttChatMessage setValuesFrom:tempMessage];
    //TODO: cleanup
    ttChatMessage.bubbleSize = [SpeechBubbleView sizeForText:ttChatMessage.textChat];
    
    return ttChatMessage.bubbleSize.height + 16;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    MessageTableViewCell *cell = (MessageTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //TapTalkChatMessage* message = [[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row];
    [ttChatMessage setValuesFrom:[[DataModel sharedDataModelManager].businessMessages objectAtIndex:indexPath.row]];
//    NSString *bizNameForChat = [[[DataModel sharedDataModelManager].chat_masters objectAtIndex:indexPath.row] objectForKey:@"business_name"];
    [cell insertMessage:ttChatMessage forBusiness:@""];
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
