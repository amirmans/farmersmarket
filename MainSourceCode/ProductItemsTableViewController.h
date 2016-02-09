//
//  ShowItemsTableViewController.h
//  TapTalk
//
//  Created by Amir on 2/28/12.
//  Copyright (c) 2012 MyDoosts.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "BusinessCustomerProfileManager.h"


@interface ProductItemsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
{
    
    NSArray *productItems;
    NSMutableArray *filteredProductItems;
    // newly added
    NSDictionary *productsAndCategories;
    Business *biz;
    NSArray *sections;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(Business *)arg_biz;

@property(nonatomic, retain) NSDictionary *productsAndCategories;
@property(atomic, retain) NSArray *productItems;
@property(atomic, retain) Business *biz;
@property(nonatomic, retain) NSArray *filteredProductItems;
@property(atomic, retain) NSArray *sections;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results


@end
