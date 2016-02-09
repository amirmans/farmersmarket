//
//  ShowItemsTableViewController.m
//  TapTalk
//
//  Created by Amir on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductItemsTableViewController.h"
#import "ProductItemViewCell.h"
#import "DetailProductItemViewController.h"
#import "Consts.h"
#import "TapTalkLooks.h"
// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>


@interface ProductItemsTableViewController() {
    bool isFiltered;
}

@end


@implementation ProductItemsTableViewController

@synthesize productsAndCategories;
@synthesize productItems;
@synthesize filteredProductItems;
@synthesize searchBar;
@synthesize searchController;
@synthesize searchResults;
@synthesize sections;
@synthesize biz;



#pragma mark - Utility methods
//- (NSDictionary *)itemAtIndexPath:(NSIndexPath *)indexPath
//{
//	NSDictionary *tempDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//    
//	return tempDict;
//}


#pragma mark - init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(Business *)arg_biz
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        biz = arg_biz;
        productsAndCategories = arg_biz.businessProducts;
        sections = [productsAndCategories allKeys];
//        [self initModel]; 
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Category"),
                                                          NSLocalizedString(@"ScopeButtonCapital",@"Item")];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    // The search bar does not seem to set its size automatically
    // which causes it to have zero height when there is no scope
    // bar. If you remove the scopeButtonTitles above and the
    // search bar is no longer visible make sure you force the
    // search bar to size itself (make sure you do this after
    // you add it to the view hierarchy).
    [self.searchController.searchBar sizeToFit];
    
    
//    self.searchResults = [NSMutableArray arrayWithCapacity:businessListArray.count];
    
    
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    //self.tableView.backgroundColor = [UIColor clearColor];
    //self.view.backgroundColor = [UIColor blueColor];
    
    // title set in the caller
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.scrollEnabled = YES;
//    searchDisplayController.delegate = self;
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //resizing for different screen size (done by adding constraint and add chosing auto layout in the xib file)
    //happens after viewDidLoad and before viewDidAppear, so I moved the following method to viewDidAppear
//    [TapTalkLooks setBackgroundImage:self.tableView];
//    [self.tableView setSectionFooterHeight:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [TapTalkLooks setBackgroundImage:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - header and section related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.searchController.active)
        return [sections count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nRows = 0;
    if (self.searchController.active)
    {
        nRows = [filteredProductItems count];
    }
    else
    {   
        nRows = [[productsAndCategories objectForKey:[sections objectAtIndex:section]] count]; 
    }
    
    return nRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // for some odd reason when the table is reload after a search row height doesn't get its value from the nib
    // file - so I had to do this - the value should correspond to the value in the cell xib file
//    return 245;
    return 250;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [TapTalkLooks setBackgroundImage:self.tableView withBackgroundImage:biz.bg_image];
    [TapTalkLooks setFontColorForLabelsInView:self.tableView toColor:[UIColor whiteColor]];
    [TapTalkLooks setFontColorForTextsInView:self.tableView toColor:[UIColor whiteColor]];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [[UILabel alloc] init];
    
    if (self.searchController.active)
    {
        label = nil;
    }
    else {

        NSString *sectionTitle = [self.sections objectAtIndex:section];
        
        // Create label with section title
        label.frame = CGRectMake(80, 0, [sectionTitle length], [self.tableView sectionHeaderHeight]);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:20];
        label.text = sectionTitle;
// zzzzz        label.backgroundColor = [UIColor colorWithRed:(189/255.f) green:(177/255.f) blue:(243/255.f) alpha:1.0f];
        
        /*I also want the header to throw a shadow on the rest of the table*/
        label.layer.shadowColor = [[UIColor orangeColor] CGColor];
        label.layer.shadowOffset = CGSizeMake(0, 0);
        label.layer.shadowOpacity = 0.5f;
        label.layer.shadowRadius = 3.25f;
        label.layer.masksToBounds = NO;
    }
    
   return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchController.active)
        return 0;
    else
        return 32.0f;
}

#pragma mark - Table view data source

- (ProductItemViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductItemCell";
    
    ProductItemViewCell *cell = (ProductItemViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProductItemViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (ProductItemViewCell *) currentObject;
                break;
            }
        }
        
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:YES];
        [TapTalkLooks setFontColorForView:cell.contentView toColor:[UIColor whiteColor]];
    }

    // Configure the cell...
    NSDictionary *cellDict;
    if (self.searchController.active)
    {
        cellDict = [filteredProductItems objectAtIndex:indexPath.row];
    }
    else
    {
        cellDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    NSString *specialDeal = [cellDict objectForKey:@"OnSpecial"];
    if ([specialDeal hasPrefix:@"T"] || [specialDeal hasPrefix:@"Y"])
        [cell.specialLabel setHidden:FALSE];
    else
        [cell.specialLabel setHidden:TRUE];
    cell.title.text = [cellDict objectForKey:@"Name"];
    
    NSArray *runtimeFields;
    NSDictionary *runtimeField1;
    NSString *field_1_name;
    NSString *field_1_value;
    NSDictionary *runtimeField2;
    NSString *field_2_name;
    NSString *field_2_value;

    
    @try {
        runtimeFields = [cellDict objectForKey:@"RuntimeFields"];
        runtimeField1 = [runtimeFields objectAtIndex:0];
        field_1_name = [runtimeField1 objectForKey:@"name"];
        field_1_value = [runtimeField1 objectForKey:@"value"];
        runtimeField2 = [runtimeFields objectAtIndex:1];
        field_2_name = [runtimeField2 objectForKey:@"name"];
        field_2_value = [runtimeField2 objectForKey:@"value"];
    }
    @catch (NSException *exception) {
        // deal with the exception
        NSLog(@"in productitemviewcell, runtime fields are empty for product item %@", [cellDict objectForKey:@"Name"]);
    }
    @finally {
        // optional block of clean-up code
        // executed whether or not an exception occurred
        if ( (field_1_value == nil) || (field_2_value == nil) ) {
            cell.field_1_label.hidden = TRUE;
            cell.field_2_label.hidden = TRUE;
        }
        else {
            cell.field_1_label.text = field_1_name;
            cell.field_1_textview.text = field_1_value;
            cell.field_2_label.text = field_2_name;
            cell.field_2_textview.text = field_2_value;
        }
    }

    //price could be an string or an real number
    if ([[cellDict valueForKey:@"Price"] isKindOfClass:[NSString class]]) {
       [cell.priceTextField setText:[cellDict objectForKey:@"Price"]];
    }
    else {
        NSNumber *priceNumber = [cellDict objectForKey:@"Price"];
        NSString *priceString = [priceNumber stringValue];
        [cell.priceTextField setText:priceString];
    }
    [cell.descriptionTextView setText:[cellDict objectForKey:@"ShortDescription"]];
    
    NSURL *imageURL = [NSURL URLWithString:[cellDict objectForKey:@"Picture"]];
    [cell.productImageView Compatible_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // both has to be cleared?
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    //    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDict;
    if (self.searchController.active)
    {
        tempDict = [filteredProductItems objectAtIndex:indexPath.row];
                     
    }
    else
    {
        tempDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }

    // Navigation logic may go here. Create and push another view controller.
    
    DetailProductItemViewController *detailViewController = [[DetailProductItemViewController alloc] initWithNibName:nil bundle:nil data:tempDict];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

#pragma mark Content Filtering

//- (void)filterContentForSearchText:(NSString*)searchText
//                             scope:(NSString*)scope
//{
//    NSPredicate *resultPredicate = [NSPredicate
//                                    predicateWithFormat:@"SELF contains[cd] %@",
//                                    searchText];
//
//    self.filteredProductItems = [self.productItems filteredArrayUsingPredicate:resultPredicate];
//}
//

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tmpSearched = [[NSMutableArray alloc] init];
    NSString *productName;
    
    for (int sectionNo = 0; sectionNo < self.sections.count; sectionNo++) {
        long nItems = [[productsAndCategories objectForKey:[sections objectAtIndex:sectionNo]] count];
        for (int itemNo = 0; itemNo < nItems; itemNo++)
        {
            NSDictionary *dataDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:sectionNo]] objectAtIndex:itemNo];
            productName = [dataDict objectForKey:@"Name"];
            //we are going for case insensitive search here
            NSRange range = [productName rangeOfString:searchText
                                               options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
                [tmpSearched addObject:dataDict];
        }
        
    }
    
    filteredProductItems = tmpSearched.copy;
    tmpSearched = nil;
}

#pragma mark - UISearchDisplayController Delegate Methods

//-(BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
//    
//    return YES;
//}

- (void)updateSearchResultsForSearchController:(UISearchController *)arg_searchController
{
    NSString *searchString = arg_searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:@"ScopeButtonCountry"];
    //    [[self filterContentForSearchText:[arg_searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    NSLog(@"in updateSearchResultsForSearchController: filtered results: %@***%@", [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]], filteredProductItems);
 //         [self filterContentForSearchText:searchString scope:[self.searchController.searchBar scopeButtonTitles]]);
    
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    
 NSLog(@"in the second updateSearchResultsForSearchController: filtered results: %@***%@", [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]], filteredProductItems);
    
    [self.tableView reloadData];
}



//- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
////    [controller.searchResultsTableView setDelegate:self];
//    [TapTalkLooks setBackgroundImage:controller.searchResultsTableView];
//    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
////    [controller.searchResultsTableView setTableHeaderView:nil];
////    [controller.searchResultsTableView setSectionHeaderHeight:0.0];
//}

@end
