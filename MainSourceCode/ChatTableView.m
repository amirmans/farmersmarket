 #import "ChatTableView.h"
#import "DataModel.h"

@implementation ChatTableView

//@synthesize dataModel;

- (void)scrollToNewestMessage {
    // The newest message is at the bottom of the table
    //TODO
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([DataModel sharedDataModelManager].messages.count - 1) inSection:0];
    NSLog(@"indexPath at scrollToNewestMessage is: %i, %i", indexPath.section, indexPath.row);
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)viewWillAppearWithNewMessage {
    // Show a label in the table's footer if there are no messages
    int nMessages = [DataModel sharedDataModelManager].messages.count;
    if (nMessages == 0) {
//		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
//		label.text = NSLocalizedString(@"You have no messages", nil);
//		label.font = [UIFont boldSystemFontOfSize:16.0f];
//		label.textAlignment = UITextAlignmentCenter;
//		label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
//		label.shadowColor = [UIColor whiteColor];
//		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
//		label.backgroundColor = [UIColor clearColor];
//		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//		self.tableFooterView = label;
//		[label release];
        NSLog(@"nMessages = %d", nMessages);
    }
    else {
        [self scrollToNewestMessage];
    }
}

//
//#pragma mark -
//#pragma mark UITableViewDataSource
//
//- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return self.dataModel.messages.count;
//}
//
//- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
//{
//	static NSString* CellIdentifier = @"MessageCellIdentifier";
//
//	MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	if (cell == nil)
//		cell = [[[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//
//	Message* message = [self.dataModel.messages objectAtIndex:indexPath.row];
//	[cell setMessage:message];
//	return cell;
//}
//
//#pragma mark -
//#pragma mark UITableView Delegate
//
//- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
//{
//	// This function is called before cellForRowAtIndexPath, once for each cell.
//	// We calculate the size of the speech bubble here and then cache it in the
//	// Message object, so we don't have to repeat those calculations every time
//	// we draw the cell. We add 16px for the label that sits under the bubble.
//	Message* message = [self.dataModel.messages objectAtIndex:indexPath.row];
//	message.bubbleSize = [SpeechBubbleView sizeForText:message.text];
//	return message.bubbleSize.height + 16;
//}
//
//#pragma mark -
//#pragma mark ComposeDelegate
//
//- (void)didSaveMessage:(Message*)message atIndex:(int)index
//{
//	// This method is called when the user presses Save in the Compose screen,
//	// but also when a push notification is received. We remove the "There are
//	// no messages" label from the table view's footer if it is present, and
//	// add a new row to the table view with a nice animation.
//	if ([self isViewLoaded])
//	{
//		self.tableFooterView = nil;
//		[self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//		[self scrollToNewestMessage];
//	}
//}
//
//#pragma mark -
//#pragma mark Server Communication
//
//- (void)userDidLeave
//{
//	[self.dataModel setJoinedChat:NO];
//
//	// Show the Login screen. This requires the user to join a new
//	// chat room before he can return to the chat screen.
//	LoginViewController* loginController = [[LoginViewController alloc] init];
//	loginController.dataModel = dataModel;
//	[self presentModalViewController:loginController animated:YES];
//	[loginController release];
//}

//- (void)postLeaveRequest
//{
//	// Show an activity spinner that blocks the whole screen
//	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
//	hud.labelText = NSLocalizedString(@"Signing Out", @"");
//
//	// Create the HTTP request object for our URL
//	NSURL* url = [NSURL URLWithString:ServerApiURL];
//	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
//	[request setDelegate:self];
//
//	// Add the POST fields
//	[request setPostValue:@"leave" forKey:@"cmd"];
//	[request setPostValue:[dataModel userID] forKey:@"userID"];
//
//	// This code will be executed when the HTTP request is successful
//	[request setCompletionBlock:^
//	{
//		if ([self isViewLoaded])
//		{
//			[MBProgressHUD hideHUDForView:self animated:YES];
//
//			// If the HTTP response code is not "200 OK", then our server API
//			// complained about a problem. This shouldn't happen, but you never
//			// know. We must be prepared to handle such unexpected situations.
//			if ([request responseStatusCode] != 200)
//			{
//				ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
//			}
//			else
//			{
//				[self userDidLeave];
//			}
//		}
//	}];
//
//	// This code is executed when the HTTP request fails
//	[request setFailedBlock:^
//	{
//		if ([self isViewLoaded])
//		{
//			[MBProgressHUD hideHUDForView:self animated:YES];
//			ShowErrorAlert([[request error] localizedDescription]);
//		}
//	}];
//
//	[request startAsynchronous];
//}
//
//#pragma mark -
//#pragma mark Actions
//
//- (IBAction)exitAction
//{
//	[self postLeaveRequest];
//}
//
//- (IBAction)composeAction
//{
//	// Show the Compose screen
//	ComposeViewController* composeController = [[ComposeViewController alloc] init];
//	composeController.dataModel = dataModel;
//	composeController.delegate = self;
//	[self presentModalViewController:composeController animated:YES];
//	[composeController release];
//}

@end
