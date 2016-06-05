//
//  TPRewardsController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "TPReceiptController.h"
#import "TotalCartItemCell.h"
#import "AppDelegate.h"

@interface TPReceiptController ()

@end

@implementation TPReceiptController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Receipt";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"< Done" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    self.orderDataArray = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
//    FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    NSLog(@"%ld",(unsigned long)self.fetchedRecordArray.count);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setOrderData];
    [self paymentSummary];
    [self setOrderItemArray];
    [self setBadgeForRewardPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backBUttonClicked: (id) sender;
{
//    [self removeAllOrderFromCoreData];
//    [self.navigationController popViewControllerAnimated:true];
    [self.navigationController popToRootViewControllerAnimated:true];
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderDataArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"TotalCartItemCell";
    TotalCartItemCell *cell = (TotalCartItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    TPBusinessDetail *businessDetail = [self.orderDataArray objectAtIndex:indexPath.row];
//    currentObject = self.fetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [NSString stringWithFormat:@"%ld",(long)businessDetail.quantity] ;
    
    CGFloat val = [businessDetail.price floatValue];
    val =  val * businessDetail.quantity ;
    CGFloat rounded_down = [AppData calculateRoundPrice:val];
    cell.lbl_Price.text = [NSString stringWithFormat:@"$%.2f",rounded_down];
    cell.lbl_Title.text = businessDetail.name;
    cell.lbl_OrderOption.text = businessDetail.short_description;
    cell.btn_minus.hidden = true;
    cell.btn_plus.hidden = true;
    
    cell.btnFavorite.selected = NO;
    
    if (businessDetail.ti_rating > 4.5) {
        cell.btnFavorite.selected = YES;
    }
    else {
        cell.btnFavorite.selected = NO;
    }
    
    cell.btnFavorite.tag = indexPath.row;
    cell.btnFavorite.section = indexPath.section;
    cell.btnFavorite.row = indexPath.row;
    [cell.btnFavorite  addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    return cell;
}

- (IBAction)favoriteButtonClicked:(CustomUIButton *)sender
{
    long uid = [[DataModel sharedDataModelManager] userID];
    NSString *stringUid = [NSString stringWithFormat:@"%ld", uid];

    NSInteger row = sender.row;
    NSString *rating = @"";
    if(sender.selected) {
        sender.selected = false;
        rating = @"0.0";
    }
    else {
        sender.selected = true;
        rating = @"5.0";
    }
    TPBusinessDetail *businessDetail = [self.orderDataArray  objectAtIndex:row];
    businessDetail.ti_rating = [rating doubleValue];
    [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%@",businessDetail.product_id] rating:rating forUser:stringUid];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


// set total oder and Price
- (void)paymentSummary{
    
    managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
//    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    CGFloat TotalPrice = 0.0f;
    
    for (NSDictionary *obj in self.fetchedRecordArray) {
        CGFloat val = [[obj valueForKey:@"price"] floatValue];
        val =  val * [[obj valueForKey:@"quantity"] integerValue];
        CGFloat rounded_down = [AppData calculateRoundPrice:val];
        TotalPrice += rounded_down;
    }
    self.lbl_Total.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
    [self.tableView reloadData];
}

#pragma mark - Custom Methods
- (void) setOrderData {
    [AppData setBusinessBackgroundColor:self.thanyouView];
    self.lblOrderNumber.text = self.order_id;
    self.lblEarnedReward.text = [NSString stringWithFormat:@"You Earned %@ Reward Points!",self.reward_point];
    self.lblRedeemReward.text = [NSString stringWithFormat:@"You Redeem %@ Reward Points!",self.redeem_point];
    self.lblCardDetails.text = [NSString stringWithFormat:@"%@ %@ %@",self.cardName,self.cardNumber,self.cardExpDate];
    self.lblAverageWaitingTime.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
}

- (void)setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) rating forUser: (NSString *) stringUid {
    
    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":stringUid,@"rating":rating,@"id":businessId,@"type":@"2"};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        if ([[response valueForKey:@"success"] isEqualToString:@"YES"]) {
        
        }
    }];
}

- (void) setOrderItemArray {
    
    for (NSManagedObject *managedObj in self.fetchedRecordArray) {
        TPBusinessDetail *businessDetail = [[TPBusinessDetail alloc] init];
        businessDetail.price = [managedObj valueForKey:@"price"];
        businessDetail.businessID = [managedObj valueForKey:@"businessID"];
        businessDetail.short_description = [managedObj valueForKey:@"product_descrption"];
        businessDetail.product_id = [managedObj valueForKey:@"product_id"];
        businessDetail.pictures = [managedObj valueForKey:@"product_imageurg"];
        businessDetail.name = [managedObj valueForKey:@"productname"];
        businessDetail.ti_rating = [[managedObj valueForKey:@"ti_rating"] doubleValue];
        businessDetail.quantity = [[managedObj valueForKey:@"quantity"] integerValue];
        businessDetail.product_order_id = [[managedObj valueForKey:@"product_order_id"] integerValue];
        businessDetail.product_option = [managedObj valueForKey:@"product_option"];
        [self.orderDataArray addObject:businessDetail];
    }
}

- (void) setBadgeForRewardPoint {
    
    [[RewardDetailsModel sharedInstance] getRewardData:[CurrentBusiness sharedCurrentBusinessManager].business completiedBlock:^(NSDictionary *response, bool success) {
        if (success) {
            NSDictionary *reward = response;
            NSLog(@"%@",reward);
            NSString *total_available_points = [[[reward valueForKey:@"data"] valueForKey:@"total_available_points"] stringValue];
            
            [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:total_available_points];

        }
    }];
}

@end
