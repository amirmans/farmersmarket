#import "ChatTableView.h"
#import "DataModel.h"
#import "Consts.h"

@implementation ChatTableView

//@synthesize dataModel;

- (void)scrollToNewestMessage {
    // The newest message is at the bottom of the table
    if ([DataModel sharedDataModelManager].messages.count < NumberOfMessagesOnOnePage)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([DataModel sharedDataModelManager].messages.count - 1) inSection:0];
//    NSLog(@"indexPath at scrollToNewestMessage is: %li, %li", indexPath.section, indexPath.row);
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//- (void)viewWillAppearWithNewMessage {
//    // Show a label in the table's footer if there are no messages
//    NSInteger nMessages = [DataModel sharedDataModelManager].messages.count;
//    if (nMessages > 0) {
//        [self scrollToNewestMessage];
//    }
//}

- (void)reloadDataToChatTable {
    [self reloadData];
    [self scrollToNewestMessage];
}


@end
