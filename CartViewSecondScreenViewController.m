//
//  CartViewSecondScreenViewController.m
//  TapForAll
//
//  Created by Harry on 1/6/17.
//
//

#import "CartViewSecondScreenViewController.h"

@interface CartViewSecondScreenViewController (){
    NSString *stringUid;
}

@property (assign) double  redeemPointsVal;// value for the points that we are redeeming
@property (assign) double dollarValForEachPoints;  //detemined by the points level's ceiling
@property (assign) double originalPointsVal;
@property (assign) NSInteger currentPointsLevel;
@property (assign) NSInteger redeemNoPoint;  // number of points being redeemed
@property (assign) NSInteger originalNoPoint;
@property (assign) BOOL flagRedeemPointVal;
@property (nonatomic, strong) MBProgressHUD *hud;
- (float)calculateValueforGivenPoints:(NSInteger)points;

@end

@implementation CartViewSecondScreenViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize redeemPointsVal,hud,dollarValForEachPoints,redeemNoPoint,currentPointsLevel,originalNoPoint,originalPointsVal,flagRedeemPointVal,delivery_startTime,delivery_endTime,deliveryamt;

NSInteger currentTipVal = 0;   // Selected Tip Value
NSString *delivery_location;   // Delivery location
double globalPromotnal = 0.0;  // Variable for manage promotional amount with total amount value
double promotionalamt = 0.0;  // Promotional Amount value
double cartTotalValue = 0;            // aka subtotal
double totalVal = 0.0;         // Final Total Amount value
double tipAmt = 0.0;          // Tip Amount Value
double deliveryAmountValue = 0.00; //Delievery amount value in $

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pay";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    flagRedeemPointVal = false;
    originalPointsVal = 0.0;
    originalNoPoint = 0;
    dollarValForEachPoints = 0;  //detemined by the points level's ceiling
    currentPointsLevel  = 0;
    redeemNoPoint  = 0;  // number of points being redeemed
    redeemPointsVal = 0;  // value for the points that we are redeeming
    
    [self.lblPayNow.layer setBorderWidth:1.0];
    [self.lblPayNow.layer setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1.0] CGColor]];
//    [self.lblPayNow.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.lblPayNow.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.lblPayNow.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.lblPayNow.layer setShadowOpacity:0.3];

    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    if ([userID intValue] <=0) {
        userID = [NSString stringWithFormat:@"%@",[DataModel sharedDataModelManager].uuid];
    }
    stringUid = [NSString stringWithFormat:@"%@", userID];
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblTitle.text = billBusiness.title;
    
    if(self.pickupTime != nil){
        self.lblPickUpTime.hidden = false;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        NSLog(@"%@",[NSString stringWithFormat:@"PICK-UP AT %@",[formatter stringFromDate:self.pickupTime]]);
        self.lblPickUpTime.text = [NSString stringWithFormat:@"Pickup Time at %@",[formatter stringFromDate:self.pickupTime]];
    }
    else
    {
        self.lblPickUpTime.hidden = true;
    }
    if(self.noteText == nil)
    {
        self.noteText = @"";
    }
    if([AppData sharedInstance].consumer_Delivery_Id == nil && [AppData sharedInstance].consumer_Delivery_Location == nil){
        self.lblDeliveryLocation.hidden = true;
        NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
        delivery_location = @"";
    }
    else{
        self.lblDeliveryLocation.hidden = false;
        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Your Order is delievered at %@",[AppData sharedInstance].consumer_Delivery_Location];
    }
    
    if(self.lblDeliveryLocation.hidden == true && self.lblPickUpTime.hidden ==true){
        self.viewDeliveryAndPickup.hidden = true;
    }
    else
    {
        self.viewDeliveryAndPickup.hidden = false;
    }
    
    self.lblSubtotalAmount.text = [NSString stringWithFormat:@"$%@",self.subTotal];
    self.lblEarnedPoint.text = self.earnPts;
    
    NSString *tip10String = [NSString stringWithFormat:@"$%.2f",[self.subTotal doubleValue] * .10];
    NSString *tip15String = [NSString stringWithFormat:@"$%.2f",[self.subTotal doubleValue] * .15];
    NSString *tip20String = [NSString stringWithFormat:@"$%.2f",[self.subTotal doubleValue] * .20];
    [self.btnTip10 setTitle:tip10String forState:UIControlStateNormal];
    [self.btnTip15 setTitle:tip15String forState:UIControlStateNormal];
    [self.btnTip20 setTitle:tip20String forState:UIControlStateNormal];

    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"";
    hud.detailsLabel.text = @"";
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud.bezelView setBackgroundColor:[UIColor orangeColor]];
    hud.bezelView.color = [UIColor orangeColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:hud];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pointsRedeem:)
                                                 name:RedeemPoints
                                               object:nil];
    
    if(deliveryamt > 0)
    {
        self.lblDeliveryAmount.hidden = false;
        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"Delivery Charge: $%.2f",cartTotalValue * deliveryamt];
        deliveryAmountValue = cartTotalValue * deliveryamt;
    }
    else
    {
        self.lblDeliveryAmount.hidden = true;
        deliveryAmountValue = 0.00;
        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"Delivery Charge: $0.00"];
    }

    [self checkPromoCodeForUser];
    [self paymentSummary];
    [self setInitialPointsValue];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNoTip];
    flagRedeemPointVal = false;
    [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
    _waitTimeLabel.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
    [self getDefaultCardData];
    [self paymentSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)backBUttonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNoTipClicked:(id)sender {
    [self setNoTip];
}

- (IBAction)btnTip10Clicked:(id)sender {
    [self setTip10];
}

- (IBAction)btnTip15Clicked:(id)sender {
    [self setTip15];
}

- (IBAction)btnTip20Clicked:(id)sender {
    [self setTip20];
}

- (IBAction)btnRedeemPointClicked:(id)sender {
    if ([self enoughPointsToRedeem]) {
        if (flagRedeemPointVal == false) {
            flagRedeemPointVal = true;
            [self changePointsAndUI:flagRedeemPointVal];
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",totalVal];
        }
        else {
            flagRedeemPointVal = false;
            redeemPointsVal = 0.00;
            [self changePointsAndUI:flagRedeemPointVal];
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",totalVal];
        }
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"You have no points to redeem" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
        }];
    }
}
- (IBAction)btnChangePaymentMethodClicked:(id)sender {
    BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:billBusiness];
    [self.navigationController pushViewController:payBillViewController animated:YES];
}

- (IBAction)btnPayNowClicked:(id)sender {
    if(defaultCardData != nil){
        [self postOrderToServer];
    }
    else
    {
        [AppData showAlert:@"Error" message:@"Please set first any one default card" buttonTitle:@"Ok" viewClass:self];
    }
}

#pragma mark - Custom Functions

- (void) getDefaultCardData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    defaultCardData = [defaults valueForKey:StripeDefaultCard];
    if (defaultCardData != nil) {
        NSString *cardType = [defaultCardData valueForKey:@"card_type"];
        NSString *cardNo = [defaultCardData valueForKey:@"cc_no"];
        if (cardType.length == 0) {
            cardType = @"CARD";
        }
        NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
        NSString *defaultCardString = [NSString stringWithFormat:@"%@ xxxx xxxx xxxx %@",cardType,trimmedString];
        self.lblDefaultCard.text = defaultCardString;
    }
    else {
        self.lblDefaultCard.text = @"NO DEFAULT CARD!";
    }
}
- (void) setNoTip {
    
    self.btnNoTip.backgroundColor = [UIColor blackColor];
    self.btnTip10.backgroundColor = [UIColor whiteColor];
    self.btnTip15.backgroundColor = [UIColor whiteColor];
    self.btnTip20.backgroundColor = [UIColor whiteColor];
    self.btnOther.backgroundColor = [UIColor whiteColor];
    [self.btnNoTip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnTip10 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip15 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip20 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    currentTipVal = 0;
    [self calculateTip:currentTipVal];
}
- (void) setTip10 {
    
    self.btnNoTip.backgroundColor = [UIColor whiteColor];
    self.btnTip10.backgroundColor = [UIColor blackColor];
    self.btnTip15.backgroundColor = [UIColor whiteColor];
    self.btnTip20.backgroundColor = [UIColor whiteColor];
    self.btnOther.backgroundColor = [UIColor whiteColor];
    [self.btnNoTip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip10 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnTip15 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip20 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    currentTipVal = 10;
    [self calculateTip:currentTipVal];
}
- (void) setTip15 {
    
    self.btnNoTip.backgroundColor = [UIColor whiteColor];
    self.btnTip10.backgroundColor = [UIColor whiteColor];
    self.btnTip15.backgroundColor = [UIColor blackColor];
    self.btnTip20.backgroundColor = [UIColor whiteColor];
    self.btnOther.backgroundColor = [UIColor whiteColor];
    [self.btnNoTip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip10 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip15 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnTip20 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    currentTipVal = 15;
    [self calculateTip:currentTipVal];
}
- (void) setTip20 {
    
    self.btnNoTip.backgroundColor = [UIColor whiteColor];
    self.btnTip10.backgroundColor = [UIColor whiteColor];
    self.btnTip15.backgroundColor = [UIColor whiteColor];
    self.btnTip20.backgroundColor = [UIColor blackColor];
    self.btnOther.backgroundColor = [UIColor whiteColor];
    [self.btnNoTip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip10 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip15 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip20 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    currentTipVal = 20;
    [self calculateTip:currentTipVal];
}

- (void)calculateTip : (double) tip  {
    
    if(cartTotalValue > 0) {
        totalVal = 0.00;
        tipAmt = cartTotalValue* (tip/100);
        if(globalPromotnal > cartTotalValue)
        {
            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotalValue];
            promotionalamt = cartTotalValue;
        }
        else
        {
            promotionalamt = globalPromotnal;
            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",promotionalamt];
        }
        
        if(flagRedeemPointVal){
            [self setInitialPointsValue];
            [self adjustRedeemPointsAndTheirValues];
        }
        else
        {
            totalVal = cartTotalValue + tipAmt + deliveryAmountValue - promotionalamt - redeemPointsVal ;
        }
        self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",totalVal];
    }
}
// set total order and Price
- (void)paymentSummary {
    
    totalVal = 0.00;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    cartTotalValue = [self.subTotal doubleValue];

    totalVal = [self.subTotal doubleValue] + deliveryAmountValue - promotionalamt;
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",totalVal];

}
//Check Promotion Code available
-(void)checkPromoCodeForUser {
    
    if ([DataModel sharedDataModelManager].uuid.length < 1) {
        [hud hideAnimated:YES];
    }
    else {
        if([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code != nil) {
            NSDictionary *inDataDict = @{@"consumer_id":stringUid,
                                         @"cmd":@"did_consumer_used_promotion",
                                         @"business_id":[NSNumber numberWithInt:[CurrentBusiness sharedCurrentBusinessManager].business.businessID],
                                         @"promotion_code":[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code};
            [[APIUtility sharedInstance] CheckConsumerPromoCodeAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                NSLog(@"%@",response);
                [hud hideAnimated:YES];
                if([[response valueForKey:@"status"] integerValue] >= 0){
                    
                    if( ((NSArray *)[response valueForKey:@"data"]).count > 0) {
                        globalPromotnal = 0.00;
                        promotionalamt = 0.00;
                        self.lblPromotionalAmount.hidden = true;
                        self.lblPromotionCode.hidden = true;
                        self.lblPromotionalText.hidden = true;
                    }
                    else
                    {
                        self.lblPromotionalAmount.hidden = false;
                        self.lblPromotionCode.hidden = false;
                        self.lblPromotionalText.hidden = false;
                        NSLog(@"%@", [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code);
                        if(([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code == nil)){
                            globalPromotnal = 0.00;
                            promotionalamt = 0.00;
                        }
                        else
                        {
                            double doublePromo = [[CurrentBusiness sharedCurrentBusinessManager].business.promotion_discount_amount doubleValue];
                            globalPromotnal = doublePromo;
                            promotionalamt = doublePromo;
                            self.lblPromotionCode.text = [NSString stringWithFormat:@"Promotional Code: %@",[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code];
                            self.lblPromotionCode.adjustsFontSizeToFitWidth = YES;
                        }
                        if(globalPromotnal > cartTotalValue)
                        {
                            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotalValue];
                            promotionalamt = cartTotalValue;
                        }
                        else
                        {
                            promotionalamt = globalPromotnal;
                            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%@",billBusiness.promotion_discount_amount];
                        }
                    }
                    [self paymentSummary];
                }
                else
                {
                    [hud hideAnimated:YES];
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
        }
        else
        {
            [hud hideAnimated:YES];
        }
    }
}
- (void) setInitialPointsValue {
    NSLog(@"%@",[RewardDetailsModel sharedInstance].rewardDict);
    NSDictionary *rewards = [RewardDetailsModel sharedInstance].rewardDict;
    currentPointsLevel = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"points"] integerValue];
    originalNoPoint = [[[rewards valueForKey:@"data"] valueForKey:@"total_available_points"] integerValue];
    originalPointsVal = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"dollar_value"] doubleValue];
    int totaLAvailablePoints = [[[rewards valueForKey:@"data"] valueForKey:@"total_available_points"] intValue];
    if (originalPointsVal > 0) {
        dollarValForEachPoints = originalPointsVal / currentPointsLevel;
        self.lblCurrentPoints.text = [NSString stringWithFormat:@"%ld points worth %2.0f¢ each.  Redeem some?",(long)totaLAvailablePoints,dollarValForEachPoints*100];
    }
    else {
        dollarValForEachPoints = 0.0;
        self.lblCurrentPoints.text = @"You don't have enough points to use";
    }
}
- (float)calculateValueforGivenPoints:(NSInteger)points {
    return points*dollarValForEachPoints;
}
- (bool)enoughPointsToRedeem {
    NSLog(@"%f",dollarValForEachPoints);
    if (dollarValForEachPoints > 0)
        return TRUE;
    else
        return false;
}
- (NSInteger)getRedeemNoPoints {
    if (![self enoughPointsToRedeem])
        return 0;
    
    if (flagRedeemPointVal) {
        return redeemNoPoint;
    }
    else {
        return 0;
    }
}

- (void)revertRedeemPointsAndValuesToOriginal {
    redeemNoPoint = 0;
    redeemPointsVal = 0;
    dollarValForEachPoints = originalPointsVal / currentPointsLevel;
    if(currentTipVal > 0) {
        [self calculateTip:currentTipVal];
    }
    else {
        totalVal = [self.subTotal doubleValue] + tipAmt - promotionalamt +deliveryAmountValue ;
    }
}

- (void)adjustRedeemPointsAndTheirValues {
    double allAvailablePointsValue = [self calculateValueforGivenPoints:originalNoPoint];
    if ( allAvailablePointsValue <= [self.subTotal doubleValue]) {
        totalVal = [self.subTotal doubleValue] - allAvailablePointsValue + tipAmt - promotionalamt + deliveryAmountValue;
        redeemNoPoint = originalNoPoint;
        redeemPointsVal = allAvailablePointsValue;
        dollarValForEachPoints = redeemPointsVal / redeemNoPoint;
    } else {
        redeemNoPoint = [self pointsNeededForGivenAmount:[self.subTotal doubleValue]];
        dollarValForEachPoints = ([self.subTotal doubleValue] + tipAmt + deliveryAmountValue - promotionalamt) / redeemNoPoint;
        redeemPointsVal = redeemNoPoint * dollarValForEachPoints;
        totalVal = tipAmt;
    }
}

- (NSInteger)pointsNeededForGivenAmount:(double)amount {
    if (dollarValForEachPoints <= 0 ) {
        return 0;
    }
    else {
        return ceil(amount / dollarValForEachPoints );
    }
}

- (void) pointsRedeem:(NSNotification *) notification
{
    [self btnRedeemPointClicked:self];
}

- (void) changePointsAndUI:(BOOL)flag {
    if (flag) {
        [self adjustRedeemPointsAndTheirValues];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_checked"] forState:UIControlStateNormal];
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %ld", redeemNoPoint];
    } else {
        [self revertRedeemPointsAndValuesToOriginal];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %ld", redeemNoPoint];
    }
}

- (void) postOrderToServer {
    
    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    if ([userID intValue] <=0) {
        userID = [NSString stringWithFormat:@"%@",[DataModel sharedDataModelManager].uuid];
    }
    NSMutableArray *orderItemArray = [[NSMutableArray alloc]init];
    for (NSDictionary *product in self.orderItems) {
        NSString *product_id = [product valueForKey:@"product_id"];
        NSString *quantity = [product valueForKey:@"quantity"];
        NSString *options = @"";
        NSString *itemNote = [product valueForKey:@"item_note"];
        NSArray *option_array;
        if ([product valueForKey:@"selected_ProductID_array"] != [NSNull null]) {
            options = [product valueForKey:@"selected_ProductID_array"];
            option_array = [options componentsSeparatedByString:@","];
        }
        else {
            option_array = [[NSArray alloc] init];
        }
        NSString *price = [product valueForKey:@"price"];
        CGFloat rounded_down = [AppData calculateRoundPoints:[price floatValue]];
        NSString *Points = [NSString stringWithFormat:@"$%.2f",rounded_down];
        
        if(![itemNote isEqual:[NSNull null]])
        {
            if([itemNote isEqualToString:@""]){
                NSDictionary *product_orderDict = @{@"product_id":product_id,
                                                    @"quantity":quantity,
                                                    @"options":option_array,
                                                    @"price":price,
                                                    @"points":Points
                                                    };
                [orderItemArray addObject:product_orderDict];
            }else
            {
                NSDictionary *product_orderDict = @{@"product_id":product_id,
                                                    @"quantity":quantity,
                                                    @"options":option_array,
                                                    @"price":price,
                                                    @"item_note":itemNote,
                                                    @"points":Points
                                                    };
                [orderItemArray addObject:product_orderDict];
            }
        }
        else
        {
            NSDictionary *product_orderDict = @{@"product_id":product_id,
                                                @"quantity":quantity,
                                                @"options":option_array,
                                                @"price":price,
                                                @"points":Points
                                                };
            [orderItemArray addObject:product_orderDict];
        }
    }
    
    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    NSInteger currentRedeemPoints = [self getRedeemNoPoints];
    float redeemPointsDollarValue = [self redeemPointsVal];
    NSString *cardNo = [defaultCardData valueForKey:@"cc_no"];
    
    if([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code == NULL){
        [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code = @"";
    }
    NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Id);
    NSDictionary *orderInfoDict= @{@"cmd":@"save_order",@"data":orderItemArray,@"consumer_id":userID,@"total":[NSString stringWithFormat:@"%f",totalVal],
                                   @"business_id":business_id,@"points_redeemed":[NSString stringWithFormat:@"%ld",(long)currentRedeemPoints],
                                   @"points_dollar_amount":[NSString stringWithFormat:@"%f",redeemPointsDollarValue],
                                   @"tip_amount":[NSNumber numberWithDouble:tipAmt], @"subtotal":[NSNumber numberWithDouble:[self.subTotal doubleValue]], @"tax_amount":[NSNumber numberWithDouble:0.0],
                                   @"cc_last_4_digits":[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)], @"note":self.noteText,
                                   @"consumer_delivery_id":[AppData sharedInstance].consumer_Delivery_Id.length > 0 ? [AppData sharedInstance].consumer_Delivery_Id : @"",
                                   @"delivery_charge_amount":[NSNumber numberWithDouble:deliveryamt],
                                   @"promotion_code":[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code,
                                   @"promotion_discount_amount" : [NSString stringWithFormat:@"%f",promotionalamt]
                                   };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:orderInfoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json format of data send to save_order: %@", jsonString);
    }
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"Updating businesses...";
    hud.detailsLabel.text = @"Tap-in is sending order to merchant...";
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud.bezelView setBackgroundColor:[UIColor orangeColor]];
    hud.bezelView.color = [UIColor orangeColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:hud];
    [hud showAnimated:YES];
    
    if ([[orderInfoDict valueForKey:@"business_id"] integerValue] <= 0) {
        [hud hideAnimated:YES];
        hud = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
        }];
    }
    else if([[orderInfoDict valueForKey:@"consumer_id"] integerValue] <= 0)
    {
        [hud hideAnimated:YES];
        hud = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong in login. \n Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
        }];
    }
    else if([orderInfoDict valueForKey:@"cc_last_4_digits"] == nil || [[orderInfoDict valueForKey:@"cc_last_4_digits"] isEqualToString:@""]){
        [hud hideAnimated:YES];
        hud = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"CC info is not correct. Please Re-enter Creditcard details." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
        }];
    }
    else{
        [[APIUtility sharedInstance] orderToServer:orderInfoDict server:OrderServerURL completiedBlock:^(NSDictionary *response) {
            [hud hideAnimated:YES];
            hud = nil;
            if([[response valueForKey:@"status"] integerValue] >= 0)
            {
                if([response valueForKey:@"data"] != nil) {
                    NSDictionary *dataDict = [response valueForKey:@"data"];
                    NSMutableArray *fetchedOrders = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
                    NSMutableArray *fetchedOrderArray = [[NSMutableArray alloc] init];
                    for (NSManagedObject *obj in fetchedOrders) {
                        NSArray *keys = [[[obj entity] attributesByName] allKeys];
                        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
                        [fetchedOrderArray addObject:dictionary];
                    }
                    NSString *cardType = [defaultCardData valueForKey:@"card_type"];
                    NSString *cardNo = [defaultCardData valueForKey:@"cc_no"];
                    NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
                    NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];
                    NSString *expDate =  [NSString stringWithFormat:@"%@/%@",[defaultCardData valueForKey:@"expMonth"],[defaultCardData valueForKey:@"expYear"]];
                    TPReceiptController *receiptVC = [[TPReceiptController alloc] initWithNibName:@"TPReceiptController" bundle:nil];
                    receiptVC.fetchedRecordArray = fetchedOrderArray;
                    receiptVC.order_id = [[dataDict valueForKey:@"order_id"] stringValue];
                    receiptVC.reward_point = [[dataDict valueForKey:@"points"] stringValue];
                    receiptVC.cardType = cardType;
                    receiptVC.cardNumber = cardDisplayNumber;
                    receiptVC.cardExpDate = expDate;
                    NSInteger currentRedeemPoints = [self getRedeemNoPoints];
                    receiptVC.redeem_point = [NSString stringWithFormat:@"%ld",(long)currentRedeemPoints];
                    receiptVC.totalPaid = self.lblSubTotalPrice.text;
                    receiptVC.tipAmount = tipAmt;
                    receiptVC.subTotal = [self.subTotal doubleValue];
                    [self removeAllOrderFromCoreData];
                    
                    [self.navigationController pushViewController:receiptVC animated:YES];
                }
            }
            else
            {
                [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
            }
        }];
    }
}
- (void) removeAllOrderFromCoreData {
    
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject *object in results)
    {
        [managedObjectContext deleteObject:object];
    }
    error = nil;
    [managedObjectContext save:&error];
}
@end
