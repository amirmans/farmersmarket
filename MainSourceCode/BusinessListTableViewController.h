//
//  BusinessListTableViewController.h
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import <UIKit/UIKit.h>
#import "ServerInteractionManager.h"

@interface BusinessListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    
}

@property (strong, atomic) NSArray *businessListArray;
@property (strong, atomic) NSMutableArray *filteredBusinessListArray;

@end
