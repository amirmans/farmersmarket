//
//  BusinessListTableViewController.h
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import <UIKit/UIKit.h>
#import "ServerInteractionManager.h"

@interface BusinessListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (strong, atomic) NSArray *businessListArray;

@end
