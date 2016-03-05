//
//  BusinessNotificationTableViewController.m
//  TapForAll
//
//  Created by Amir on 12/3/13.
//
//

#import "BusinessNotificationTableViewController.h"
#import "Consts.h"
#import "DataModel.h"
//#import "TapTalkChatMessage.h"
#import "TapTalkLooks.h"
#import "NotificationTableViewCell.h"
#import "AppDelegate.h"
#import "DetailBusinessVCTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListofBusinesses.h"
#import "Business.h"
#import "APIUtility.h"
#import "AppData.h"

@interface BusinessNotificationTableViewController ()

@end

@implementation BusinessNotificationTableViewController

@synthesize notificationsInReverseChronological;

// delegate Method for NewNotificationWhileRunning

#pragma mark - Life Cycle
- (void)updateUIWithNewNotification
{
    notificationsInReverseChronological = [[[DataModel sharedDataModelManager] notifications] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
//    self.tabBarItem.badgeValue = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        AppDelegate * myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        myAppDelegate.notificationDelegate = self;
                                       
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [TapTalkLooks setBackgroundImage:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.tintColor = [UIColor whiteColor];
    
    notificationsInReverseChronological = [[NSMutableArray alloc] init];
    
    // for some reason - setting the background color in the nib file didn't work
    self.title = @"Notification Center";
    //resizing for different screen size (done by adding constraint and add chosing auto layout in the xib file)
    //happens after viewDidLoad and before viewDidAppear, so I moved the following method to viewDidAppear
//    [TapTalkLooks setBackgroundImage:self.tableView];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.tableView.rowHeight = 120; // change this number whenever you change the ui in NotificationTableViewCell
    
    [self setNotificationsData];
    // we want to show the notifications in the reverse chronological order: the last
    // one should be displayed first
//    notificationsInReverseChronological = [[[[[DataModel sharedDataModelManager] notifications]
//                                             reverseObjectEnumerator] allObjects] mutableCopy];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return notificationsInReverseChronological.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DetailBusinessVCTableViewCell";
    DetailBusinessVCTableViewCell *cell = (DetailBusinessVCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailBusinessVCTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Business *biz1 = [[Business alloc] initWithDataFromDatabase:[self.notificationsInReverseChronological objectAtIndex:indexPath.row]];
    
    cell.lblOpenCloseDate.text =[[APIUtility sharedInstance]getOpenCloseTime:biz1.opening_time CloseTime:biz1.closing_time];
    
    NSString *tmpIconName = biz1.iconRelativeURL;
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell imgBusinessIcon] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
    
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    cell.rateView.rating = 0;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
    
    cell.titleLabel.text = biz1.title;
    cell.subtitleLabel.text = biz1.address;
    cell.bussinessType.text = biz1.businessTypes;
    cell.bussinessAddress.text = biz1.neighborhood;
    
    cell.distance.text = [NSString stringWithFormat:@"%.1f m",[[AppData sharedInstance]getDistance:biz1.lat longitude:biz1.lng]];
    cell.rateView.rating = [biz1.rating floatValue];
    
    if([[APIUtility sharedInstance]isOpenBussiness:biz1.opening_time CloseTime:biz1.closing_time]){
        cell.lblOpenClose.text = @"OPEN NOW";
        cell.lblOpenClose.textColor = [UIColor greenColor];
    }else{
        cell.lblOpenClose.text = @"CLOSE";
        cell.lblOpenClose.textColor = [UIColor redColor];
    }
    
    cell.btnFevorite.tag = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [notificationsInReverseChronological removeObjectAtIndex:indexPath.row];
        [[DataModel sharedDataModelManager] setNotifications:notificationsInReverseChronological];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  120;
}

- (IBAction)FevoriteButtonClicked:(UIButton *) sender
{
//    NSInteger index = sender.tag;
//    Business *business = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:index]];
    
    if(sender.selected) {
//        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"0"];
        sender.selected = false;
    }
    else {
//        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"5"];
        sender.selected = true;
    }
}

#pragma mark - Custom Methods

- (void) setNotificationsData {
    NSDictionary *business1 = @{
                                @"active" : @"1",
                                @"address" : @"Price dropped by 10%",
                                @"bg_image" : @"koi_bg_image.png",
                                @"branch" : @"0",
                                @"businessID" : @"1",
                                @"businessTypes" : @"Mobile Food",
                                @"chat_masters" : @"[{\n    \"id\": \"1234567853\",\n    \"business_name\": \"KOI Fusion\"\n}]",
                                @"chatroom_table" : @"chatitems_koi",
                                @"city" : @"Portland",
                                @"closing_time" : @"13:00:00",
                                @"customerProfileName" : @"mobile food",
                                @"date_added" : @"2015-12-26",
                                @"date_dropped" : @"<null>",
                                @"description" : @"Beta customer",
                                @"email" : @"<null>",
                                @"exclusive" : @"0",
                                @"external_reference_no" : @"<null>",
                                @"hours" : @"",
                                @"icon" : @"KoiFusion_logo.png",
                                @"inquiry_for_product" : @"0",
                                @"lat" : @"45.55409990",
                                @"lng" : @"-122.83644930",
                                @"map_image_url" : @"<null>",
                                @"marketing_statement" : @"Authentic Korean Flavors with a Twist",
                                @"name" : @"KOI Fusion",
                                @"neighborhood" : @"Portland",
                                @"opening_time" : @"11:00:00",
                                @"operating_hours" : @"<null>",
                                @"payment_processing_email" : @"<null>",
                                @"payment_processing_id" : @"<null>",
                                @"phone" : @"415-867-6326",
                                @"pictures" : @"koi_food1.jpg, koi_food2.jpg, koi_food3.jpg, koi_food4.jpg, koi_food5.jpg, koi_food6.jpg",
                                @"rating" : @"4",
                                @"short_name" : @"KOI",
                                @"should_tip" : @"1",
                                @"sms_no" : @"415-867-6326",
                                @"state" : @"OR",
                                @"ti_rating" : @"0",
                                @"validate_chat" : @"0",
                                @"website" : @"http://koifusionpdx.com",
                                @"zipcode" : @"97229",
                                };
    
    NSDictionary *business2 = @{
                                @"active" : @"1",
                                @"address" : @"Every thing at flat 15% discount",
                                @"bg_image" : @"koi_bg_image.png",
                                @"branch" : @"0",
                                @"businessID" : @"1",
                                @"businessTypes" : @"Mobile Food",
                                @"chat_masters" : @"[{\n    \"id\": \"1234567853\",\n    \"business_name\": \"KOI Fusion\"\n}]",
                                @"chatroom_table" : @"chatitems_koi",
                                @"city" : @"Portland",
                                @"closing_time" : @"13:00:00",
                                @"customerProfileName" : @"mobile food",
                                @"date_added" : @"2015-12-26",
                                @"date_dropped" : @"<null>",
                                @"description" : @"Beta customer",
                                @"email" : @"<null>",
                                @"exclusive" : @"0",
                                @"external_reference_no" : @"<null>",
                                @"hours" : @"",
                                @"icon" : @"KoiFusion_logo.png",
                                @"inquiry_for_product" : @"0",
                                @"lat" : @"45.55409990",
                                @"lng" : @"-122.83644930",
                                @"map_image_url" : @"<null>",
                                @"marketing_statement" : @"Authentic Korean Flavors with a Twist",
                                @"name" : @"Grocery",
                                @"neighborhood" : @"Portland",
                                @"opening_time" : @"11:00:00",
                                @"operating_hours" : @"<null>",
                                @"payment_processing_email" : @"<null>",
                                @"payment_processing_id" : @"<null>",
                                @"phone" : @"415-867-6326",
                                @"pictures" : @"koi_food1.jpg, koi_food2.jpg, koi_food3.jpg, koi_food4.jpg, koi_food5.jpg, koi_food6.jpg",
                                @"rating" : @"4",
                                @"short_name" : @"KOI",
                                @"should_tip" : @"1",
                                @"sms_no" : @"415-867-6326",
                                @"state" : @"OR",
                                @"ti_rating" : @"0",
                                @"validate_chat" : @"0",
                                @"website" : @"http://koifusionpdx.com",
                                @"zipcode" : @"97229",
                                };

    
    [notificationsInReverseChronological addObject:business1];
    [notificationsInReverseChronological addObject:business2];
    
    NSLog(@"%ld",[notificationsInReverseChronological count]);
    
//    notificationsInReverseChronological = [[[DataModel sharedDataModelManager] notifications]  mutableCopy];
    [self.tableView reloadData];

}


//TODO
- (void)didSaveMessage:(NSString *)message atIndex:(int)index
{
	// This method is called when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
//TODO	if ([self isViewLoaded])
	{
		self.tableView.tableFooterView = nil;
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//TODO		[self scrollToNewestMessage];
	}
}


@end
