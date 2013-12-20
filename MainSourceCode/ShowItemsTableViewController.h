//
//  ShowItemsTableViewController.h
//  TapTalk
//
//  Created by Amir on 2/28/12.
//  Copyright (c) 2012 MyDoosts.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessCustomerProfileManager.h"


@interface ShowItemsTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray *productItems;
    NSMutableArray *filteredProductItems;

    // newly added
    NSDictionary *productsAndCategories;
    NSArray *sections;
    
    UIToolbar *toolbar;

    IBOutlet UISearchBar *searchBar;
    IBOutlet UISearchDisplayController *searchDisplayController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)products;

@property(nonatomic, retain) NSDictionary *productsAndCategories;
@property(atomic, retain) NSArray *productItems;
@property(nonatomic, retain) NSArray *filteredProductItems;
@property(atomic, retain) NSArray *sections;

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
