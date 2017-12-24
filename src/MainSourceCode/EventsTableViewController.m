//
//  ShoppingCartTableViewController.m
//  TapForAll
//
//  Created by Amir on 1/3/16.
//
//

#import "EventsTableViewController.h"
#import "EventTableViewCell.h"
#import "TapTalkLooks.h"
#import "Consts.h"
#import "DataModel.h"
#import "AppDelegate.h"
#import <EventKitUI/EventKitUI.h>

@interface EventsTableViewController ()
{
    NSMutableArray *eventArray;
}

@end


@implementation EventsTableViewController

@synthesize biz;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)argBiz
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        biz = argBiz;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    eventArray = [[NSMutableArray alloc] init];
    
    self.title = @"Events";
    
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    [self addEventData];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backBUttonClicked: (id) sender; {
    [self.navigationController popViewControllerAnimated:true];
//    [self.navigationController popToRootViewControllerAnimated:true];
}


- (void) addEventData {
    NSDictionary *dict1 = @{@"title":@"Event 1",@"distance":@"APR 10, 7PM-10PM",@"discription":@"Event 1 ASDASDASDASDASDASDASDJN ASDNASJBDASBDASB CDAS CDASDBASDBASJBDAS DASBDJASD AS ASDBASDAS DAS DABJSDN ASD ASBD AS ASJBD AS DAS DASD ASDAS DASD ASDBASBDAS DAS DASBD",@"eventImage":@"",@"location":@"New york"};
    NSDictionary *dict2 = @{@"title":@"Event 2",@"distance":@"APR 10, 7PM-10PM",@"discription":@"Event 2 Discription",@"eventImage":@"",@"location":@"London"};
    NSDictionary *dict3 = @{@"title":@"Event 3",@"distance":@"APR 10, 7PM-10PM",@"discription":@"Event 3 Discription",@"eventImage":@"",@"location":@"Miami"};
    NSDictionary *dict4 = @{@"title":@"Event 4",@"distance":@"APR 10, 7PM-10PM",@"discription":@"Event 4 Discription",@"eventImage":@"",@"location":@"Miami"};
    
    [eventArray addObject:dict1];
    [eventArray addObject:dict2];
    [eventArray addObject:dict3];
    [eventArray addObject:dict4];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [eventArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    static NSString *CellIdentifier = @"NotificationCell";
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EventTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (EventTableViewCell *) currentObject;
                break;
            }
        }
    }
    
    NSDictionary *eventDict = [eventArray objectAtIndex:indexPath.row];
    
    cell.lblEventTitle.text = [eventDict valueForKey:@"title"];
    cell.lblDateTime.text = [eventDict valueForKey:@"distance"];
    cell.lblDiscription.text = [eventDict valueForKey:@"discription"];

    [cell.btnEmail setTitle:biz.email forState:UIControlStateNormal];
    
    cell.btnLocation.tag = indexPath.row;
    [cell.btnLocation addTarget:self action:@selector(btnLocationClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnAddToCalendar.tag = indexPath.row;
    [cell.btnAddToCalendar addTarget:self action:@selector(btnAddToCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return 300;
}

-(void)btnLocationClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    NSDictionary *eventDict = [eventArray objectAtIndex:index];
    NSString *location = [eventDict valueForKey:@"location"];
    
    NSString *urlString =[NSString stringWithFormat:@"http://maps.apple.com/?q=%@",[location stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void)btnAddToCalendarClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    NSDictionary *eventDict = [eventArray objectAtIndex:index];

    EKEventStore *store = [[EKEventStore alloc] init];
    
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // iOS 6
        [store requestAccessToEntityType:EKEntityTypeEvent
                              completion:^(BOOL granted, NSError *error) {
                                  if (granted)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                          [self createEventAndPresentViewController:store];
                                          [self createEventAndPresentViewController:store calendarEvent:eventDict];
                                      });
                                  }
                              }];
    }
}

- (void)createEventAndPresentViewController:(EKEventStore *)store calendarEvent : (NSDictionary *) eventDict
{
    EKEvent *event = [self createEvent:store calendarEvent:eventDict];
    
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.event = event;
    controller.eventStore = store;
    controller.editViewDelegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (EKEvent *)createEvent:(EKEventStore *)store calendarEvent : (NSDictionary *) eventDict {
    NSString *title = [eventDict valueForKey:@"title"];
//    NSString *distance = [eventDict valueForKey:@"distance"];
    NSString *discription = [eventDict valueForKey:@"discription"];
    NSString *location = [eventDict valueForKey:@"location"];
    
    // try to find an event
    
    EKEvent *event = [EKEvent eventWithEventStore:store];

    event.title = title;
    event.notes = discription;
    event.location = location;
    event.calendar = [store defaultCalendarForNewEvents];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.hour = 4;
    event.startDate = [calendar dateByAddingComponents:components
                                                toDate:[NSDate date]
                                               options:0];
    components.hour = 1;
    event.endDate = [calendar dateByAddingComponents:components
                                              toDate:event.startDate
                                             options:0];
    
    return event;
}


- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
