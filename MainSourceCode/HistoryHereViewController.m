//
//  HistoryHereTableViewController.m
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryHereViewController.h"
#import "HistoryHereDetailViewController.h"
#import "HistoryInSimilarPlaces.h"
#import "HistoryCell.h"

@interface HistoryHereViewController () {
@private
    NSArray *historyDates;
}

@property(atomic, retain) NSArray *historyDates;

@end

@implementation HistoryHereViewController

@synthesize tableViewOfHistory, historyData, historyDates, foodRating, servicRating;
@synthesize toolbarNav, m_historyInSimilarPlaceViewController;


- (HistoryInSimilarPlaces *)m_historyInSimilarPlaceViewController {
    if (m_historyInSimilarPlaceViewController == Nil) {
        m_historyInSimilarPlaceViewController = [[HistoryInSimilarPlaces alloc] initWithNibName:nil bundle:nil];
    }
    return m_historyInSimilarPlaceViewController;
}

- (UINavigationController *)toolbarNav {
    if (toolbarNav == Nil) {
        toolbarNav = [[UINavigationController alloc] initWithRootViewController:self.m_historyInSimilarPlaceViewController];
    }

    return toolbarNav;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view addSubview:tableViewOfHistory];
        [self.view addSubview:foodRating];
        [self.view addSubview:servicRating];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"HistoryHere" ofType:@"txt"];

        historyData = [NSDictionary dictionaryWithContentsOfFile:path];
        historyDates = [historyData allKeys];

        NSLog(@"Here is the history of me in this place: %@", historyData);
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    tableViewOfHistory = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Your history here";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
/*    
    [super viewWillAppear:animated];
    //Initialize the toolbar
    toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight-toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    
    //Create a button
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"info" style:UIBarButtonItemStyleBordered target:self action:@selector(info_clicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:infoButton,nil]];
    
    //Add the toolbar as a subview to the navigation controller.
//    [self.navigationController.view addSubview:toolbar];
    [self.view addSubview:toolbar];
*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)showHistoryInSimilarPlaces:(id)sender {

    [self.navigationController presentModalViewController:self.toolbarNav animated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ([historyDates count]);
}

- (HistoryCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellsInHistoryTables";

    HistoryCell * cell = (HistoryCell *)
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:nil options:nil];

        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (HistoryCell *) currentObject;
                break;
            }
        }
    }

    NSString *keyValue = [historyDates objectAtIndex:indexPath.row];
    NSArray *tempArr = [historyData objectForKey:keyValue];
    NSLog(@"History Data %@ for the key %@ is:", tempArr, keyValue);
    NSInteger loopIndex = 0;
    NSString *labelText = @"";
    NSString *detailText = @"";
    while (loopIndex < tempArr.count) {
        if (loopIndex == 0)
            labelText = [tempArr objectAtIndex:loopIndex];
        else if (loopIndex == 1)
            detailText = [tempArr objectAtIndex:loopIndex];
        loopIndex++;
    }
    // Configure the cell...

    [[cell date] setText:keyValue];
    [[cell timeAtPlace] setText:labelText];
    [[cell myNote] setText:detailText];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

    HistoryHereDetailViewController *detailViewController = [[HistoryHereDetailViewController alloc] initWithNibName:nil bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    HistoryCell * cell = (HistoryCell *)
    [tableView cellForRowAtIndexPath:indexPath];
    detailViewController.title = cell.date.text;
    [self.navigationController pushViewController:detailViewController animated:YES];

}


@end
