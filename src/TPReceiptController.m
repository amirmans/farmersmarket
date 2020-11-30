//
//  TPRewardsController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "TPReceiptController.h"
#import "TotalCartItemCell.h"
#import "CurrentBusiness.h"
#import "AppDelegate.h"
#import "Business.h"

@interface TPReceiptController ()
{
    Business *BusinessData;
}
@end


@implementation TPReceiptController

@synthesize totalPaid, tipAmount, subTotal, lblTextFromPayConfirmation, lbl_thankYou, lblBusinessName, lbl_emailSentShortly
     , taxAmount, lbl_alertWhenReady
    , tf_tax_amt;

@synthesize currency_symbol;
@synthesize currency_code;


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppData sharedInstance].Current_Selected_Tab = @"0";
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    BusinessData = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;

    if ([DataModel sharedDataModelManager].emailAddress.length < 1) {
        lbl_emailSentShortly.hidden = true;
    } else {
        lbl_emailSentShortly.hidden = false;
    }
    
    if ( ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
        lbl_alertWhenReady.hidden = true;
    } else {
        lbl_alertWhenReady.hidden = false;
    }
    
    self.title = @"Confirmation";
    lblBusinessName.textAlignment = NSTextAlignmentCenter;
    [lblBusinessName setNumberOfLines:0];
    [lblBusinessName sizeToFit];
    lblBusinessName.text = [NSString stringWithFormat:@"%@", [CurrentBusiness sharedCurrentBusinessManager].business.businessName];
    
    lbl_thankYou.textAlignment = NSTextAlignmentCenter;
    [lbl_thankYou setNumberOfLines:0];
    [lbl_thankYou sizeToFit];
    lbl_thankYou.text = [NSString stringWithFormat:@"%@ thanks you for order #%@",
                         [CurrentBusiness sharedCurrentBusinessManager].business.businessName,self.order_id];
    

    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"< Continue shopping" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    self.orderDataArray = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
//    FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    NSLog(@"%ld",(unsigned long)self.fetchedRecordArray.count);
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setOrderData];
    [self paymentSummary];
    [self setOrderItemArray];
    [self setBadgeForRewardPoint];
    
    NSString *my_sms_no = [CurrentBusiness sharedCurrentBusinessManager].business.sms_no;
    if ((my_sms_no == nil) || (my_sms_no == (id)[NSNull null]))
    {
        lblTextFromPayConfirmation.hidden = true;
    }
    else {
        lblTextFromPayConfirmation.hidden = false;
        [lblTextFromPayConfirmation.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [lblTextFromPayConfirmation setTitle:[NSString stringWithFormat:@"Text %@, if you have questions!",
                                              [CurrentBusiness sharedCurrentBusinessManager].business.shortBusinessName] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backBUttonClicked: (id) sender;
{
//    [self removeAllOrderFromCoreData];
//    [self.navigationController popViewControllerAnimated:true];
    BusinessData.promotion_code = nil;
    BusinessData.promotion_message = nil;
    BusinessData.promotion_discount_amount = nil;
    [CurrentBusiness sharedCurrentBusinessManager].business.promotion_discount_amount = nil;
    [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code = nil;
    [CurrentBusiness sharedCurrentBusinessManager].business.promotion_message = nil;
    [AppData sharedInstance].consumer_Delivery_Id = nil;
    [AppData sharedInstance].consumer_Delivery_Location = nil;
//    [self.navigationController popToRootViewControllerAnimated:true];
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderDataArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
//    if (section == [tableView numberOfSections] - 1)  {
//            if (_receiptPDCharge > 0)
//            {
//                footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width-2, 10)];
//                footer.backgroundColor = [UIColor clearColor];
//
//                UILabel *lbl = [[UILabel alloc]initWithFrame:footer.frame];
//                [lbl setFont:[UIFont systemFontOfSize:12]];
//                lbl.backgroundColor = [UIColor clearColor];
//                lbl.text = [NSString localizedStringWithFormat:@"Delivery charge: $ %.2f   ", _receiptPDCharge];;
//                lbl.textAlignment = NSTextAlignmentRight;
//                [footer addSubview:lbl];
//
//                return footer;
//            }
//    }
//
//    return footer;
//}

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
    cell.lbl_Price.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,rounded_down];
    
    
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
    // TODO
//    self.lbl_Total.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
//    self.lbl_Total.text = [NSString stringWithFormat:@"$%.2f",totalPaid];
    self.lblServiceCharge.text = [NSString localizedStringWithFormat:@"$ %.2f" , self.receiptPDCharge];;
    self.lblTipAmount.text = [NSString localizedStringWithFormat:@"$ %.2f",self.tipAmount];
    self.tf_tax_amt.text = [NSString localizedStringWithFormat:@"$ %.2f",self.taxAmount];
    self.lbl_Total.text = self.totalPaid;
    
    [self.tableView reloadData];
}

#pragma mark - Custom Methods
- (void) setOrderData {
//    [AppData setBusinessBackgroundColor:self.thanyouView];
    self.lblOrderNumber.text = self.order_id;
    self.lblEarnedReward.text = [NSString stringWithFormat:@"You Earned %@ Reward Points!",self.reward_point];
    self.lblRedeemReward.text = [NSString stringWithFormat:@"You Redeemed %@ Reward Points!",self.redeem_point];
    self.lblCardDetails.text = [NSString stringWithFormat:@"%@ %@ %@",self.cardType,self.cardNumber,self.cardExpDate];
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
    
    [[RewardDetailsModel sharedInstance] getRewardData:[CurrentBusiness sharedCurrentBusinessManager].business completiedBlock:^(NSDictionary *response) {
        if (1) {
            NSDictionary *reward = response;
            NSLog(@"%@",reward);
            NSString *total_available_points = [[[reward valueForKey:@"data"] valueForKey:@"total_available_points"] stringValue];
            
            [[self.tabBarController.tabBar.items objectAtIndex:Points_Tabbar_Position] setBadgeValue:total_available_points];

        }
    }];
}

- (IBAction)btnTextFromPayConfirmation:(id)sender {
    NSString *my_sms_no = [CurrentBusiness sharedCurrentBusinessManager].business.sms_no;
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = [NSString stringWithFormat:@"For order #%@:", self.order_id];
        
        controller.recipients = [NSArray arrayWithObjects:my_sms_no, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    controller = nil;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//    UIAlertView *alert;
    NSString *tempStr = @"Your text to ";
    NSString *confirmationTitle = [tempStr stringByAppendingString:[CurrentBusiness sharedCurrentBusinessManager].business.shortBusinessName];
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            [self showAlert:confirmationTitle :@"Message was not sent because of an unknown Error"];
//            alert = [[UIAlertView alloc] initWithTitle:@"confirmationTitle" message:@"Message was not sent because of an unknown Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            alert = nil;
            break;
        case MessageComposeResultSent:
            [self showAlert:confirmationTitle :@"Message was sent."];
//            alert = [[UIAlertView alloc] initWithTitle:confirmationTitle message:@"Message was sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            alert = nil;
            break;
        default:
            break;
    }
//    alert = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlert:(NSString *)Title :(NSString *)Message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:Title
                                 message:Message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self dismissViewControllerAnimated:true completion:nil];
                               }];
    
    [alert addAction:OKButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}



@end
