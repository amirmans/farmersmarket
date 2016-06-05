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

Business *currentBiz;

// delegate Method for NewNotificationWhileRunning

#pragma mark - Life Cycle
- (void)updateUIWithNewNotification
{
//    notificationsInReverseChronological = [[[DataModel sharedDataModelManager] notifications] mutableCopy];
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        [self.tableView reloadData];
//    });
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.editButtonItem.tintColor = [UIColor whiteColor];
    
    notificationsInReverseChronological = [[NSMutableArray alloc] init];
    
    // for some reason - setting the background color in the nib file didn't work
    self.title = @"Notifications";
    //resizing for different screen size (done by adding constraint and add chosing auto layout in the xib file)
    //happens after viewDidLoad and before viewDidAppear, so I moved the following method to viewDidAppear
//    [TapTalkLooks setBackgroundImage:self.tableView];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    self.tableView.rowHeight = 130; // change this number whenever you change the ui in NotificationTableViewCell
    
//    [self setNotificationsData];
    // we want to show the notifications in the reverse chronological order: the last
    // one should be displayed first
//    notificationsInReverseChronological = [[[[[DataModel sharedDataModelManager] notifications]
//                                             reverseObjectEnumerator] allObjects] mutableCopy];
    

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.businessListArray = [[NSMutableArray alloc] init];
    currentBiz = [CurrentBusiness sharedCurrentBusinessManager].business;

    [self getNotificationForConsumer];
    
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    NSArray *businessArray = [businesses businessListArray];
    
    for (NSDictionary *businessDict in businessArray) {
        Business *biz = [[Business alloc] initWithDataFromDatabase:businessDict];
        [self.businessListArray addObject:biz];
    }
    //    [TapTalkLooks setBackgroundImage:self.tableView];
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
    static NSString *simpleTableIdentifier = @"BusinessNotificationCell";
    BusinessNotificationCell *cell = (BusinessNotificationCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusinessNotificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NotificationDetailModel *notification = [self.notificationsInReverseChronological objectAtIndex:indexPath.row];
    
//    Business *biz1 = [self.notificationsInReverseChronological objectAtIndex:indexPath.row];
    
//    cell.lblOpenCloseDate.text =[[APIUtility sharedInstance]getOpenCloseTime:biz1.opening_time CloseTime:biz1.closing_time];
    
    
    
    
    Business *selectedBusiness;
    
    for (Business *biz in self.businessListArray) {
        if (biz.businessID == notification.business_id) {
            selectedBusiness = biz;
        }
    }
    
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    cell.rateView.rating = 0;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
    
    NSString *tmpIconName = selectedBusiness.iconRelativeURL;
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell imgBusinessIcon] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }

    
    cell.titleLabel.text = selectedBusiness.title;
    cell.subtitleLabel.text = notification.message;
    cell.bussinessType.text = selectedBusiness.businessTypes;
    cell.bussinessAddress.text = selectedBusiness.neighborhood;
    
    cell.distance.text = [NSString stringWithFormat:@"%.1f m",[[AppData sharedInstance]getDistance:selectedBusiness.lat longitude:selectedBusiness.lng]];
    cell.rateView.rating = [selectedBusiness.rating floatValue];
    
    if([[APIUtility sharedInstance]isOpenBussiness:selectedBusiness.opening_time CloseTime:selectedBusiness.closing_time]){
        cell.lblOpenClose.text = @"OPEN NOW";
        cell.lblOpenClose.textColor = [UIColor greenColor];
    }else{
        cell.lblOpenClose.text = @"NOW CLOSED";
        cell.lblOpenClose.textColor = [UIColor redColor];
    }
    
    cell.btnFevorite.tag = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (!notification.isRead)
    {
        cell.notificationBadgeView.backgroundColor = [UIColor redColor];
    }
    else {
        cell.notificationBadgeView.backgroundColor = [UIColor grayColor];
    }
    
    NSDateFormatter *serverDateFormatter = [[NSDateFormatter alloc] init];
    serverDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    serverDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *dateString = notification.time_sent;
    
    NSDate *serverTimeSent = [serverDateFormatter dateFromString:dateString];
    
    NSString *localDateTime = [AppData getTimeDifferentStringFromDataTime:serverTimeSent];
    
    cell.lblSentTime.text = localDateTime;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NotificationDetailModel *notification = [self.notificationsInReverseChronological objectAtIndex:indexPath.row];
        notification.isDelete = true;
        [self saveNotificationForConsumer:notification index:indexPath.row];
        [notificationsInReverseChronological removeObjectAtIndex:indexPath.row];
        [[DataModel sharedDataModelManager] setNotifications:notificationsInReverseChronological];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    NotificationDetailModel *notification = [self.notificationsInReverseChronological objectAtIndex:indexPath.row];
    notification.isRead = true;
    [self saveNotificationForConsumer:notification index:indexPath.row];
    [self.tableView reloadData];
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

- (void) getNotificationForConsumer {
    
    NSString *businessID = [NSString stringWithFormat:@"%d",currentBiz.businessID];
    NSString *consumerID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    
    [notificationsInReverseChronological removeAllObjects];
    [self.tableView reloadData];
    
    [[APIUtility sharedInstance] getNotificationForConsumer:consumerID BusinessID:businessID completiedBlock:^(NSDictionary *response) {
        
        if (![[response valueForKey:@"success"] isEqual: @"NO"]) {
            if ([[response valueForKey:@"status"] integerValue] == 1) {
                NSArray *dataArray = [response valueForKey:@"data"];
                //                previousOrderCount = [dataArray count];
                
                NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *notificationDetail in dataArray) {
                    NotificationDetailModel *notification = [NotificationDetailModel new];
                    
                    notification.business_id = [[notificationDetail valueForKey:@"business_id"] integerValue];
                    notification.consumer_id = [[notificationDetail valueForKey:@"consumer_id"] integerValue];
                    notification.image = [notificationDetail valueForKey:@"image"] ;
                    notification.message = [notificationDetail valueForKey:@"message"];
                    notification.notification_id = [[notificationDetail valueForKey:@"notification_id"] integerValue];
                    notification.time_read = [notificationDetail valueForKey:@"time_read"];
                    notification.time_sent = [notificationDetail valueForKey:@"time_sent"];
                    if ([notification.time_read isEqualToString:@"0000-00-00 00:00:00"]) {
                        notification.isRead = false;
                    }
                    else {
                        notification.isRead = true;
                    }
                    
                    [notificationArray addObject:notification];
                }
                
                notificationsInReverseChronological = notificationArray;
//                if (notificationArray.count > 0) {
//                    notificationsInReverseChronological = [[DataModel sharedDataModelManager] sortNotificationsinReverseChronologicalOrder:notificationArray];
//                }
            }
        }
        [self.tableView reloadData];
    }];
}

- (void) saveNotificationForConsumer : (NotificationDetailModel *) notification index : (NSInteger) index {
    
    NSString *businessID = [NSString stringWithFormat:@"%ld",(long)notification.business_id];
    NSString *consumerID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    
    NSString *readTime = [AppData getUTCFormateDate:[NSDate date]];
    
    NSDictionary *dataDict = @{@"notification_id":[NSString stringWithFormat:@"%ld",(long)notification.notification_id] ,@"message":notification.message,@"image":@"",@"time_sent":notification.time_sent,@"time_read":readTime, @"business_id":businessID,@"is_deleted":[NSString stringWithFormat:@"%d",notification.isDelete]};

//    NSDictionary *param = @{@"cmd":@"save_all_notifications_for_consumer",consumerID:consumerID,@"business_id":businessID, @"notification_id" :[NSString stringWithFormat:@"%ld",notification.notification_id], @"is_read" : [NSString stringWithFormat:@"%d",notification.isRead],@"is_delete":[NSString stringWithFormat:@"%d",notification.isDelete]};
    
    NSDictionary *param = @{@"cmd":@"save_all_notifications_for_consumer",@"consumer_id":consumerID,@"data":@[dataDict]};
    
    [[APIUtility sharedInstance] save_notifications_for_consumer_in_business:param completiedBlock:^(NSDictionary *response) {
        
    }];
}
@end
