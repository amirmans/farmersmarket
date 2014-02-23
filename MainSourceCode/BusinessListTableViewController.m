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

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    businessListArray = [businesses businessListArray];

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
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return businessListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BusinessListCell";
    BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    
    // Configure the cell...
    cell.businessNameTextField.text = [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSString *businessTypes = [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"businessTypes"];
    NSLog(@"in business list: business name is: %@ and types are: %@", [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"name"], businessTypes);
    if (businessTypes != (id)[NSNull null] && businessTypes != nil )
    {
        cell.businessTypesTextField.text = businessTypes;
    }

    NSString *neighborhood = [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"neighborhood"];
    if (neighborhood != (id)[NSNull null] && neighborhood != nil )
    {
        cell.neighborhoodTextField.text = neighborhood;
    }
   
    NSString *tmpIconName = [[businessListArray objectAtIndex:indexPath.row] objectForKey:@"icon"];
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
    // Navigation logic may go here, for example:
    Business *biz = [[Business alloc] initWithDataFromDatabase:[businessListArray objectAtIndex:indexPath.row]];
    // Create the next view controller.
    DetailBusinessViewController *detailBizInfo = [[DetailBusinessViewController alloc] initWithBusinessObject:biz];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailBizInfo animated:YES];
}
 


@end
