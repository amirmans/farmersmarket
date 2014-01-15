//
//  ShowItemsTableViewController.m
//  TapTalk
//
//  Created by Amir on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShowItemsTableViewController.h"
#import "ProductItemViewCell.h"
#import "DetailProductItemViewController.h"
#import "TapTalkLooks.h"
// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>


@implementation ShowItemsTableViewController

@synthesize productsAndCategories;
@synthesize productItems;
@synthesize filteredProductItems;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize sections;


#pragma mark - Utility methods
- (NSDictionary *)itemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tempDict = [[self.productsAndCategories objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
	return tempDict;
}


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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.title = @"List of items";
    self.tableView.scrollEnabled = YES;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
//    self.searchBar = tempSearchBar;
//    tempSearchBar = nil;
    self.searchBar.delegate = self; 
//    [self.searchBar sizeToFit];
//    self.tableView.tableHeaderView = self.searchBar;
    
    searchDisplayController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    self.tableView.rowHeight = 245; // change this number whenever you change the ui in ProductItemViewCell
//    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [TapTalkLooks setBackgroundImage:self.tableView];
    [self.tableView setSectionFooterHeight:0];
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
    return [sections count];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [self.sections objectAtIndex:section];
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(80, 0, [sectionTitle length], [self.tableView sectionHeaderHeight]);
    label.textColor = [UIColor blueColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:20];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
//    label.backgroundColor = [UIColor :[UIImage imageNamed:@"retina_wood.png"]];
    
    /*I also want the header to throw a shadow on the rest of the table*/
    label.layer.shadowColor = [[UIColor orangeColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowRadius = 3.25f;
    label.layer.masksToBounds = NO;
    
   return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
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
        NSString *specialDeal = [[self itemAtIndexPath:indexPath] objectForKey:@"OnSpecial"];
        
        if ([specialDeal hasPrefix:@"T"] || [specialDeal hasPrefix:@"Y"])
            [cell.specialLabel setHidden:FALSE];
        else
            [cell.specialLabel setHidden:TRUE];

    }

    // Configure the cell...
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        cell.textLabel.text =
        [self.filteredProductItems objectAtIndex:indexPath.row];
    }
    else
    {
        cell.title.text = [[self itemAtIndexPath:indexPath] objectForKey:@"Name"];
        [cell.packageInfoTextView setText:[[self itemAtIndexPath:indexPath] objectForKey:@"Package"]];
        [cell.locationTextView setText:[[self itemAtIndexPath:indexPath] objectForKey:@"Location"]];
        [cell.priceTextField setText:[[self itemAtIndexPath:indexPath] objectForKey:@"Price"]];
        [cell.descriptionTextView setText:[[self itemAtIndexPath:indexPath] objectForKey:@"ShortDescription"]];
        
        NSURL *imageURL = [NSURL URLWithString:[[self itemAtIndexPath:indexPath] objectForKey:@"Picture"]];
        [cell.productImageView setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];

        NSLog(@"The url for image of this product is: %@",[[self itemAtIndexPath:indexPath] objectForKey:@"Picture"]);
    }

    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate 
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    self.filteredProductItems = [self.productItems filteredArrayUsingPredicate:resultPredicate];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar 
                                                              scopeButtonTitles]objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end
