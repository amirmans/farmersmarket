//
//  CartViewSecondScreenViewController.m
//  TapForAll
//
//  Created by Harry on 1/6/17.
//
//

#import "PaymentSummaryViewController.h"

@interface PaymentSummaryViewController (){
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

@implementation PaymentSummaryViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize redeemPointsVal,hud,dollarValForEachPoints,redeemNoPoint,currentPointsLevel,originalNoPoint
    ,originalPointsVal,flagRedeemPointVal,selectedButtonNumber;
@synthesize currency_symbol;
@synthesize currency_code;
// ui stuff
@synthesize lblDeliveryLabel, lblPromotionLabel, lblDiscountValue, lblPromotionDiscountLabel;

NSInteger currentTipVal = 0;   // Selected Tip Value
NSString *delivery_location;   // Delivery location
double globalPromotnal = 0.0;  // Variable for manage promotional amount with total amount value
double promotionalamt = 0.0;  // Promotional Amount value
double cartTotalValue = 0;            // aka subtotal
double totalVal = 0.0;         // Final Total Amount value
double taxVal = 0.0;         // Final Tax Amount value
double tipAmt = 0.0;          // Tip Amount Value
double deliveryAmountValue; //Delievery amount value in $


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Payment Summary";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;
    flagRedeemPointVal = false;
    originalPointsVal = 0.0;
    originalNoPoint = 0;
    dollarValForEachPoints = 0;  //detemined by the points level's ceiling
    currentPointsLevel  = 0;
    redeemNoPoint  = 0;  // number of points being redeemed
    redeemPointsVal = 0;  // value for the points that we are redeeming
    taxVal = 0.0;
    
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
    
//    if(self.pickupTime != nil){
//        self.lblPickUpTime.hidden = false;
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"hh:mm a"];
//        NSLog(@"%@",[NSString stringWithFormat:@"PICK-UP AT %@",[formatter stringFromDate:self.pickupTime]]);
//        self.lblPickUpTime.text = [NSString stringWithFormat:@"Pickup Time at %@",[formatter stringFromDate:self.pickupTime]];
//    }
//    else
//    {
//        self.lblPickUpTime.hidden = true;
//    }
    if(self.noteText == nil)
    {
        self.noteText = @"";
    }
    
//    if([AppData sharedInstance].consumer_Delivery_Id == nil && [AppData sharedInstance].consumer_Delivery_Location == nil){
//        self.lblDeliveryLocation.hidden = true;
//        NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
//        delivery_location = @"";
//    }
//    else{
//        self.lblDeliveryLocation.hidden = false;
//        self.lblDeliveryLocation.text = @"";
////        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Your Order is delievered at %@",[AppData sharedInstance].consumer_Delivery_Location];
//    }
    
    // Take care of labels
    if ([[CurrentBusiness sharedCurrentBusinessManager].business.promotion_discount_amount length] < 1) {
        _lblPromotionCode.hidden = true;
        lblPromotionLabel.hidden = true;
        lblDiscountValue.hidden = true;
        lblPromotionDiscountLabel.hidden = true;
    } else {
        lblPromotionLabel.hidden = false;
        lblDiscountValue.hidden = false;
        _lblPromotionCode.hidden = false;
        lblPromotionDiscountLabel.hidden = false;
    }
    
//    if(self.lblDeliveryLocation.hidden == true && self.lblPickUpTime.hidden ==true){
//        self.viewDeliveryAndPickup.hidden = true;
//    }
//    else
//    {
//        self.viewDeliveryAndPickup.hidden = false;
//    }
    
    self.lblSubtotalAmount.text = [NSString stringWithFormat:@"%@%@",self.currency_symbol,self.subTotal];
    self.lblEarnedPoint.text = self.earnPts;
    
    NSString *tip10String = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,[self.subTotal doubleValue] * .10];
    NSString *tip15String = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,[self.subTotal doubleValue] * .15];
    NSString *tip20String = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,[self.subTotal doubleValue] * .20];
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
    
    
//    if(deliveryamt > 0)
//    {
//        self.lblDeliveryAmount.hidden = false;
//        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"Delivery Charge: $%.2f",cartTotalValue * deliveryamt];
//        deliveryAmountValue = cartTotalValue * deliveryamt;
//    }
//    else
//    {
//        self.lblDeliveryAmount.hidden = true;
//        deliveryAmountValue = 0.00;
//        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"Delivery Charge: $0.00"];
//    }

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
    
    //needs to be here after paymentSummary that is where deliveryAmountValue gets its value
//    if (deliveryAmountValue < 1) {
//        _lblDeliveryAmount.textColor = [UIColor grayColor];
//        lblDeliveryLabel.textColor = [UIColor grayColor];
//    } else {
//        _lblDeliveryAmount.textColor = [UIColor blackColor];
//        lblDeliveryLabel.textColor = [UIColor blackColor];
//    }
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
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,totalVal];
        }
        else {
            flagRedeemPointVal = false;
            redeemPointsVal = 0.00;
            [self changePointsAndUI:flagRedeemPointVal];
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,totalVal];
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
    MakePaymentViewController *makePaymentVC = [[MakePaymentViewController alloc] initWithNibName:@"MakePaymentViewController" bundle:nil];
    makePaymentVC.finalOrderItems = self.orderItems;
    makePaymentVC.currentTipVal = currentTipVal;
    makePaymentVC.totalVal = totalVal;
    makePaymentVC.subTotalVal = [self.subTotal doubleValue];
    makePaymentVC.taxVal = taxVal;
    makePaymentVC.tipAmt = tipAmt;
    makePaymentVC.promotionalamt = promotionalamt;
    makePaymentVC.pd_charge = deliveryAmountValue;

    makePaymentVC.noteText = self.noteText;
    makePaymentVC.pd_noteText = self.pd_noteText;
    makePaymentVC.restTitle = self.lblTitle.text;
    [self.navigationController pushViewController:makePaymentVC animated:YES];
//    if(defaultCardData != nil){
//        [self postOrderToServer];
//    }
//    else
//    {
//        [AppData showAlert:@"Error" message:@"Please set first any one default card" buttonTitle:@"Ok" viewClass:self];
//    }
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
    
    self.btnNoTip.backgroundColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
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
    self.btnTip10.backgroundColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
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
    self.btnTip15.backgroundColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
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
    self.btnTip20.backgroundColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
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
            self.lblDiscountValue.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,cartTotalValue];
            promotionalamt = cartTotalValue;
        }
        else
        {
            promotionalamt = globalPromotnal;
            self.lblDiscountValue.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,promotionalamt];
        }
        
        if(flagRedeemPointVal){
            [self setInitialPointsValue];
            [self adjustRedeemPointsAndTheirValues];
        }
        else
        {
            totalVal = cartTotalValue + taxVal + tipAmt + deliveryAmountValue - promotionalamt - redeemPointsVal ;
        }
        self.lblSubTotalPrice.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,totalVal];
    }
}
// set total order and price
- (void)paymentSummary {
    totalVal = 0.00;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    cartTotalValue = [self.subTotal doubleValue];
    taxVal = ([self.subTotal doubleValue]*[billBusiness.tax_rate doubleValue])/100;
    self.lblTaxRate.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,taxVal];

    totalVal = [self.subTotal doubleValue] + taxVal + deliveryAmountValue - promotionalamt;
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,totalVal];
    
//    self.lblDeliveryAmount.hidden = false;
    
    if ( ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
        NSMutableArray *corps = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
        short corpIndex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex;
        [AppData sharedInstance].consumerPDTimeChosen = [[corps objectAtIndex:corpIndex] valueForKey:@"delivery_time"];
    }
    NSString *p_time = [AppData sharedInstance].consumerPDTimeChosen;
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    displayFormatter.dateFormat = TIME24HOURFORMAT;
    NSDate *tempDate = [displayFormatter dateFromString:p_time];
    displayFormatter.dateFormat = TIME12HOURFORMAT;
    p_time = [displayFormatter stringFromDate:tempDate];
    
    
    
    if(selectedButtonNumber == 1){
        lblDeliveryLabel.text = @"Service charge:";
        if ([billBusiness.pickup_counter_charge rangeOfString:@"%"].location == NSNotFound)
        {
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f"
                                           ,self.currency_symbol,[billBusiness.pickup_counter_charge doubleValue]];
//            lblDeliveryLabel.textColor = [UIColor blackColor];
        }
        else
        {
            NSString *newStr = [billBusiness.pickup_counter_charge stringByReplacingOccurrencesOfString:@"%" withString:@""];
            double del_charge = [newStr doubleValue];
            deliveryAmountValue = (cartTotalValue * del_charge)/100;
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Pick up from counter at %@",(NSString *)p_time];
    }
    else if(selectedButtonNumber == 2){
        if ([billBusiness.delivery_table_charge rangeOfString:@"%"].location == NSNotFound) {
            deliveryAmountValue = [billBusiness.delivery_table_charge doubleValue];
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        else{
            NSString *newStr = [billBusiness.delivery_table_charge stringByReplacingOccurrencesOfString:@"%" withString:@""];
            double del_charge = [newStr doubleValue];
            deliveryAmountValue = (cartTotalValue * del_charge)/100;
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Delivery to table number %@",[AppData sharedInstance].consumer_Delivery_Location_Id];
    }
    else if(selectedButtonNumber == 3){
        lblDeliveryLabel.text = @"Delivery charge:";
        NSString* consumerDeliveryLocation = [AppData sharedInstance].consumer_Delivery_Location;
        NSString *deliveryLocationCharge = billBusiness.delivery_location_charge;
        if ( ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
            NSMutableArray *corps = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
            short corpIndex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex;
            deliveryLocationCharge = [[corps objectAtIndex:corpIndex] valueForKey:@"delivery_charge"];
            consumerDeliveryLocation = [[corps objectAtIndex:corpIndex] valueForKey:@"delivery_location"];
        }
        
        if ([deliveryLocationCharge rangeOfString:@"%"].location == NSNotFound) {
            deliveryAmountValue = [deliveryLocationCharge doubleValue];
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        else{
            NSString *newStr = [deliveryLocationCharge stringByReplacingOccurrencesOfString:@"%" withString:@""];
            double del_charge = [newStr doubleValue];
            deliveryAmountValue = (cartTotalValue * del_charge)/100;
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Delivery to %@ at %@",consumerDeliveryLocation, p_time];
    }
    else if(selectedButtonNumber == 4){
        if ([billBusiness.pickup_location_charge rangeOfString:@"%"].location == NSNotFound) {
            deliveryAmountValue = [billBusiness.pickup_location_charge doubleValue];
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        else
        {
            NSString *newStr = [billBusiness.pickup_location_charge stringByReplacingOccurrencesOfString:@"%" withString:@""];
            double del_charge = [newStr doubleValue];
            deliveryAmountValue = (cartTotalValue * del_charge)/100;
            self.lblDeliveryAmount.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,deliveryAmountValue];
        }
        self.lblDeliveryLocation.text = [NSString stringWithFormat:@"Pickup at %@ from a parking space.",p_time];
    }
    
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
                        self.lblDiscountValue.hidden = true;
                        self.lblPromotionCode.hidden = true;
//                        self.lblPromotionalText.hidden = true;
                    }
                    else
                    {
                        self.lblDiscountValue.hidden = false;
                        self.lblPromotionCode.hidden = false;
//                        self.lblPromotionalText.hidden = false;
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
                            self.lblPromotionCode.text = [NSString stringWithFormat:@"Promotion Code: %@",[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code];
                            self.lblPromotionCode.adjustsFontSizeToFitWidth = YES;
                        }
                        if(globalPromotnal > cartTotalValue)
                        {
                            self.lblDiscountValue.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,cartTotalValue];
                            promotionalamt = cartTotalValue;
                        }
                        else
                        {
                            promotionalamt = globalPromotnal;
                            self.lblDiscountValue.text = [NSString stringWithFormat:@"%@%@",self.currency_symbol,billBusiness.promotion_discount_amount];
                        }
                    }
 
                    [self paymentSummary];
                }
                else
                {
                    [hud hideAnimated:YES];
                    [self paymentSummary];
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
        }
        else
        {
            [self paymentSummary];
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
        self.lblCurrentPoints.textColor = [UIColor blackColor];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        self.lblCurrentPoints.text = [NSString stringWithFormat:@"%ld points worth %2.0f¢ each.  Redeem some?",(long)totaLAvailablePoints,dollarValForEachPoints*100];
    }
    else {
        dollarValForEachPoints = 0.0;
        self.lblCurrentPoints.textColor = [UIColor lightGrayColor];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
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
        totalVal = [self.subTotal doubleValue] + taxVal + tipAmt - promotionalamt +deliveryAmountValue ;
    }
}

- (void)adjustRedeemPointsAndTheirValues {
    double allAvailablePointsValue = [self calculateValueforGivenPoints:originalNoPoint];
    if ( allAvailablePointsValue <= [self.subTotal doubleValue]) {
        totalVal = [self.subTotal doubleValue] + taxVal - allAvailablePointsValue + tipAmt - promotionalamt + deliveryAmountValue;
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
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %li", redeemNoPoint];
    } else {
        [self revertRedeemPointsAndValuesToOriginal];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %li", redeemNoPoint];
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
