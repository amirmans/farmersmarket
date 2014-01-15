//
//  BusinessNotificationTableViewController.h
//  TapForAll
//
//  Created by Amir on 12/3/13.
//
//

#import <UIKit/UIKit.h>
#import "NewNotificationProtocol.h"


@interface BusinessNotificationTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NewNotificationProtocol> {
    
    NSMutableArray *notificationsInReverseChronological;
    
}

@property (nonatomic, retain) NSArray *notificationsInReverseChronological;

- (void)didSaveMessage:(NSString *)message atIndex:(int)index;

@end
