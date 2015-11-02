//
//  BusinessListTableViewController.m
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import "BusinessListViewController.h"
#import "BusinessTableViewCell.h"
#import "Consts.h"
#import "TapTalkLooks.h"
#import "DetailBusinessViewController.h"
#import "ListofBusinesses.h"
#import "Business.h"

#import "MyLocationViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>


@interface BusinessListViewController () {

    NSTimer *bizListTimer;
    UISearchController *searchController;
}
@property (atomic, strong) NSTimer *bizListTimer;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results
@end

@implementation BusinessListViewController


@synthesize businessListArray;
@synthesize filteredBusinessListArray;
@synthesize listBusinessesActivityIndicator;
@synthesize bizListTimer;
@synthesize bizTableView;
@synthesize searchController;

- (void)timerCallBack {
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    businessListArray = [businesses businessListArray];
    if (businessListArray.count > 0 ) {
        [bizListTimer invalidate];
        bizListTimer = nil;
        [bizTableView reloadData];
        [listBusinessesActivityIndicator stopAnimating];
    }
        
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
     }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a mutable array to contain products for the search results table.
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    businessListArray = [businesses businessListArray];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    self.searchController.searchBar.delegate = self;
    
    self.bizTableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       self.searchController.searchBar.frame.size.width, 44.0);
    
    self.definesPresentationContext = YES;
    
    // The search bar does not seem to set its size automatically
    // which causes it to have zero height when there is no scope
    // bar. If you remove the scopeButtonTitles above and the
    // search bar is no longer visible make sure you force the
    // search bar to size itself (make sure you do this after
    // you add it to the view hierarchy).
    //[self.searchController.searchBar sizeToFit];
    

    self.searchResults = [NSMutableArray arrayWithCapacity:businessListArray.count];
    
    // The table view controller is in a nav controller, and so the containing nav controller is the 'search results controller'
    //UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
//    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    searchController.searchResultsUpdater = self;
//    searchController.dimsBackgroundDuringPresentation = NO;
//    searchController.hidesNavigationBarDuringPresentation = NO;
//    searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
//    self.bizTableView.tableHeaderView = self.searchController.searchBar;
    
    
    
    
    
    
    if (businessListArray.count <= 0 ) {
        bizListTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    } else {
        [listBusinessesActivityIndicator stopAnimating];
    }

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    filteredBusinessListArray = [[NSMutableArray alloc] initWithCapacity:businessListArray.count];
    UIBarButtonItem *displayMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map view" style:UIBarButtonItemStyleDone target:self action:@selector(displayMapView:)];
    self.navigationItem.rightBarButtonItem = displayMapButton;
    displayMapButton = nil;
    self.title = @"Biz Partners";
    //resizing for different screen size (done by adding constraint and add chosing auto layout in the xib file)
    //happens after viewDidLoad and before viewDidAppear, so I moved the following method to viewDidAppear
//    [TapTalkLooks setBackgroundImage:bizTableView];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TapTalkLooks setBackgroundImage:bizTableView];
}

- (void)displayMapView:(UIBarButtonItem *)button
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    BusinessListTableViewController *listTableView = [[BusinessListTableViewController alloc] initWithNibName:nil bundle:nil];
    MyLocationViewController *myLocation = [[MyLocationViewController alloc] initWithNibName:nil bundle:nil];

    [self.navigationController pushViewController:myLocation animated:YES];
    myLocation = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return filteredBusinessListArray.count;
    }
    
    return businessListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // for some odd reasons when the table is reload after a search row height doesn't get its value from the nib
    // file - so I had to do this - the value should correspond to the value in the cell xib file 
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BusinessListCell";
    static NSString *searchCellIdentifier = @"SearchBusinessListCell";
    BusinessTableViewCell *cell = nil;
    
    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (BusinessTableViewCell *) currentObject;
                break;
            }
        }
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
    }
    
 //    NSLog(@"in business list: business name is: %@ and types are: %@", [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"name"], businessTypes);
    
    NSDictionary *cellDict;
    if (self.searchController.active)
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        cellDict = [filteredBusinessListArray objectAtIndex:indexPath.row];
    }
    else
    {
        cellDict = [businessListArray objectAtIndex:indexPath.row];
    }
    
    // Configure the cell...
    cell.businessNameTextField.text = [cellDict objectForKey:@"name"];
    
    NSString *businessTypes = [cellDict objectForKey:@"businessTypes"];
    if (businessTypes != (id)[NSNull null] && businessTypes != nil )
    {
        cell.businessTypesTextField.text = businessTypes;
    }

    NSString *neighborhood = [cellDict objectForKey:@"neighborhood"];
    if (neighborhood != (id)[NSNull null] && neighborhood != nil )
    {
        cell.neighborhoodTextField.text = neighborhood;
    }
   
    NSString *tmpIconName = [cellDict objectForKey:@"icon"];
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell businessIconImageView] Compatible_setImageWithURL:imageURL placeholderImage:nil];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    Business * biz = nil;
    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        biz = [[Business alloc] initWithDataFromDatabase:[filteredBusinessListArray objectAtIndex:indexPath.row]];
    }
    else
    {
        biz = [[Business alloc] initWithDataFromDatabase:[businessListArray objectAtIndex:indexPath.row]];
    }
    DetailBusinessViewController *detailBizInfo = [[DetailBusinessViewController alloc] initWithBusinessObject:biz];
    [self.navigationController pushViewController:detailBizInfo animated:YES];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredBusinessListArray removeAllObjects]; // First clear the filtered array.
    for (NSDictionary *bizDict in businessListArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(SELF contains[cd] %@)", searchText];
        if ([predicate evaluateWithObject:[bizDict objectForKey:@"name"]])
        {
            [filteredBusinessListArray addObject:bizDict];
        }
    }
    
}

#pragma mark - UISearchDisplayController Delegate Methods

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
//    
//    return YES;
//}


#pragma mark - UISearchResultsUpdating

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.bizTableView reloadData];
}

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark -
#pragma mark === UISearchResultsUpdating ===
#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)arg_searchController
{
    NSString *searchString = arg_searchController.searchBar.text;
//    [[self filterContentForSearchText:[arg_searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    
    
    [self.bizTableView reloadData];
}
















#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
//    [self updateSearchResultsForSearchController:self.searchController];
//}
//

//#pragma mark - Content Filtering
//
//- (void)updateFilteredContentForProductName:(NSString *)productName type:(NSString *)typeName {
//    
//    // Update the filtered array based on the search text and scope.
//    if ((productName == nil) || [productName length] == 0) {
//        // If there is no search string and the scope is "All".
//        if (typeName == nil) {
//            self.searchResults = [self.products mutableCopy];
//        } else {
//            // If there is no search string and the scope is chosen.
//            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
//            for (Product *product in self.products) {
//                if ([product.type isEqualToString:typeName]) {
//                    [searchResults addObject:product];
//                }
//            }
//            self.searchResults = searchResults;
//        }
//        return;
//    }
//    
//    
//    [self.searchResults removeAllObjects]; // First clear the filtered array.
//    
//    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
//     */
//    for (Product *product in self.products) {
//        if ((typeName == nil) || [product.type isEqualToString:typeName]) {
//            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
//            NSRange productNameRange = NSMakeRange(0, product.name.length);
//            NSRange foundRange = [product.name rangeOfString:productName options:searchOptions range:productNameRange];
//            if (foundRange.length > 0) {
//                [self.searchResults addObject:product];
//            }
//        }
//    }
//}

@end
