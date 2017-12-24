//#import "ComposeViewController.h"

@class DataModel;

// The main screen of the app. It shows the history of all messages that
// this user has sent and received. It also opens the Compose screen when
// the user wants to send a new message.
@interface ChatTableView : UITableView {
}

//@property (nonatomic, assign) DataModel* dataModel;

//- (IBAction)exitAction;
//- (IBAction)composeAction;
//????
//- (void)viewWillAppearWithNewMessage;
- (void)scrollToNewestMessage;
- (void)reloadDataToChatTable;

@end
