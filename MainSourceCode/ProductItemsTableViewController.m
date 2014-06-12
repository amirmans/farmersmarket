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
@synthesize searchDisplayController;
@synthesize sections;


#pragma mark - Utility methods
//- (NSDictionary *)itemAtIndexPath:(NSIndexPath *)indexPath
//{
//	NSDictionary *tempDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//    
//	return tempDict;
//}


#pragma mark - init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)argProducts
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        productsAndCategories = argProducts;
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
    // title set in the caller 
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.scrollEnabled = YES;
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [TapTalkLooks setBackgroundImage:self.tableView];
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
    if (tableView == self.tableView)
        return [sections count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nRows = 0;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
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
    return 245;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [[UILabel alloc] init];
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        label = nil;
    }
    else {

        NSString *sectionTitle = [self.sections objectAtIndex:section];
        
        // Create label with section title
        label.frame = CGRectMake(80, 0, [sectionTitle length], [self.tableView sectionHeaderHeight]);
        label.textColor = [UIColor blueColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:20];
        label.text = sectionTitle;
        label.backgroundColor = [UIColor clearColor];
        
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
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
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
        
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
//        NSString *specialDeal = [[self itemAtIndexPath:indexPath] objectForKey:@"OnSpecial"];
//        
//        if ([specialDeal hasPrefix:@"T"] || [specialDeal hasPrefix:@"Y"])
//            [cell.specialLabel setHidden:FALSE];
//        else
//            [cell.specialLabel setHidden:TRUE];

    }

    // Configure the cell...
    NSDictionary *cellDict;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
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
    [cell.packageInfoTextView setText:[cellDict objectForKey:@"Package"]];
    [cell.locationTextView setText:[cellDict objectForKey:@"Location"]];
    [cell.priceTextField setText:[cellDict objectForKey:@"Price"]];
    [cell.descriptionTextView setText:[cellDict objectForKey:@"ShortDescription"]];
    
    NSURL *imageURL = [NSURL URLWithString:[cellDict objectForKey:@"Picture"]];
    [cell.productImageView setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];

    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSDictionary *tempDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
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

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
//    [controller.searchResultsTableView setDelegate:self];
    [TapTalkLooks setBackgroundImage:controller.searchResultsTableView];
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    [controller.searchResultsTableView setTableHeaderView:nil];
//    [controller.searchResultsTableView setSectionHeaderHeight:0.0];
}

@end
