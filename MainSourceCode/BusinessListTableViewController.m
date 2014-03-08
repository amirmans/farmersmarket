//
//  BusinessListTableViewController.m
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import "BusinessListTableViewController.h"
#import "BusinessTableViewCell.h"
#import "TapTalkLooks.h"
#import "DetailBusinessViewController.h"
#import "ListofBusinesses.h"
#import "Business.h"

#import <SDWebImage/UIImageView+WebCache.h>


@interface BusinessListTableViewController ()

@end

@implementation BusinessListTableViewController


@synthesize businessListArray;
@synthesize filteredBusinessListArray;


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

    self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    businessListArray = [businesses businessListArray];
    filteredBusinessListArray = [[NSMutableArray alloc] initWithCapacity:businessListArray.count];
    UIBarButtonItem *displayListButton = [[UIBarButtonItem alloc] initWithTitle:@"Map view" style:UIBarButtonItemStyleDone target:self action:@selector(displayMapView:)];
    self.navigationItem.leftBarButtonItem = displayListButton;
    displayListButton = nil;
    self.title = @"Our Business Partners";
    [TapTalkLooks setBackgroundImage:self.tableView];
}

-(void) displayMapView:(UIBarButtonItem *)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return filteredBusinessListArray.count;
    }
    
    return businessListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // for some odd reason when the table is reload after a search row height doesn't get its value from the nib
    // file - so I had to do this - the value should correspond to the value in the cell xib file 
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BusinessListCell";
    static NSString *searchCellIdentifier = @"SearchBusinessListCell";
    BusinessTableViewCell *cell = nil;
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    }
    else {
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
        
    }
    
 //    NSLog(@"in business list: business name is: %@ and types are: %@", [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"name"], businessTypes);
    
    NSDictionary *cellDict;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
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
        [[cell businessIconImageView] setImageWithURL:imageURL placeholderImage:nil];
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
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        biz = [[Business alloc] initWithDataFromDatabase:[filteredBusinessListArray objectAtIndex:indexPath.row]];
    }
    else {
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

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}



@end
