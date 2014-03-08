//
//  ShowItemsTableViewController.h
//  TapTalk
//
//  Created by Amir on 2/28/12.
//  Copyright (c) 2012 MyDoosts.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessCustomerProfileManager.h"


@interface ProductItemsTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    NSArray *productItems;
    NSMutableArray *filteredProductItems;
    // newly added
    NSDictionary *productsAndCategories;
    NSArray *sections;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)products;

@property(nonatomic, retain) NSDictionary *productsAndCategories;
@property(atomic, retain) NSArray *productItems;
@property(nonatomic, retain) NSArray *filteredProductItems;
@property(atomic, retain) NSArray *sections;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;


@end
