//
//  BusinessListTableViewController.h
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import <UIKit/UIKit.h>
#import "ServerInteractionManager.h"

@interface BusinessListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    
}

@property (strong, atomic) NSArray *businessListArray;
@property (strong, atomic) NSMutableArray *filteredBusinessListArray;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *listBusinessesActivityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *bizTableView;

@end
