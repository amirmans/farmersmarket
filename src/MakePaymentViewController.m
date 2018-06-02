//
//  MakePaymentViewController.m
//  TapForAll
//
//  Created by Trushal on 5/20/17.
//
//
#import "UIAlertView+TapTalkAlerts.h"
#import "MakePaymentViewController.h"
#import "cardDetailCollectionCell.h"
//#import "AppData.h"
#import "AppDelegate.h"

@interface MakePaymentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    int selectCardIndex;

    NSString *cardType;
}
@property (assign) double  redeemPointsVal;// value for the points that we are redeeming
@property (assign) double dollarValForEachPoints;  //detemined by the points level's ceiling
@property (assign) double originalPointsVal;
@property (assign) NSInteger currentPointsLevel;
@property (assign) NSInteger redeemNoPoint;  // number of points being redeemed
@property (assign) NSInteger originalNoPoint;
@property (assign) BOOL flagRedeemPointVal;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSString *cardType;
@property (nonatomic, strong) NSString *cardNo;
@property (nonatomic, strong) NSString *uiExpirationDateString;

@property (nonatomic, strong) NSNumber *order_type; //1 or 0 string because it will be inside a nsdictionary

- (float)calculateValueforGivenPoints:(NSInteger)points;

@end

@implementation MakePaymentViewController

@synthesize redeemPointsVal,hud,dollarValForEachPoints,redeemNoPoint,currentPointsLevel,originalNoPoint
    ,originalPointsVal,flagRedeemPointVal,tipAmt,subTotalVal,pd_charge, pd_noteText, order_type
    ,cardType, cardNo, uiExpirationDateString;
@synthesize currency_symbol;
@synthesize currency_code;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    order_type = @0;
    if ( ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
        NSMutableArray *corps = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
        short corpIndex = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex;
        pd_charge = [[[corps objectAtIndex:corpIndex] valueForKey:@"delivery_charge"] doubleValue];
        [AppData sharedInstance].consumerPDMethodChosen = DELIVERY_LOCATION;
        [AppData sharedInstance].consumer_Delivery_Id = [[corps objectAtIndex:corpIndex] valueForKey:@"corp_id"];
        [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
//        self.pd_noteText =@"";
//        [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code = @"";
//        _promotionalamt = 0.0;
        order_type = @1;
    }

    self.title = @"Payment";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName:@"cardDetailCollectionCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cardDetailCollectionCell"];

    //init
//    pd_noteText = @"";
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setInitialPointsValue];
//    [self getDefaultCardData];
//    [self getCCForConsumer];

    NSLocale* currentLocale = [NSLocale currentLocale];
    [[NSDate date] descriptionWithLocale:currentLocale];

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    self.lblPickUpDate.text = [dateFormatter stringFromDate:[NSDate date]];
    NSString* pd_time= [AppData sharedInstance].consumerPDTimeChosen;

    dateFormatter.dateFormat = TIME24HOURFORMAT;
    NSDate *tempDate = [dateFormatter dateFromString:pd_time];
    if (tempDate != nil) {
        dateFormatter.dateFormat = TIME12HOURFORMAT;
        pd_time = [dateFormatter stringFromDate:tempDate];
    }



    if ( [[AppData sharedInstance].consumerPDMethodChosen isEqualToString:PICKUP_COUNTER] ) {
//        _waitTimeLabel.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
        _waitTimeLabel.text = [@"Pick up at " stringByAppendingString:pd_time];
    } else if ( [[AppData sharedInstance].consumerPDMethodChosen isEqualToString:DELIVERY_LOCATION] ) {
        _waitTimeLabel.text = [@"Delivery at " stringByAppendingString:pd_time];
    } else if ( [[AppData sharedInstance].consumerPDMethodChosen isEqualToString:PICKUP_LOCATION]) {
        _waitTimeLabel.text = [@"Bringing your order to you at " stringByAppendingString:pd_time];
    } else if ( [[AppData sharedInstance].consumerPDMethodChosen isEqualToString:DELIVERY_TABLE] ) {
        _waitTimeLabel.text = [@"Pick up at " stringByAppendingString:pd_time];
    }
    //_waitTimeLabel.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
    self.lblTitle.text = self.restTitle;
    self.lblTotalPrice.text = [NSString stringWithFormat:@"%@ %.2f",self.currency_symbol,self.totalVal];

    if (![self enoughPointsToRedeem]){
        self.btnRedeemPoint.enabled = false;
    }
    else{
        self.btnRedeemPoint.enabled = true;
    }
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [self getDefaultCardData];
    [self.collectionView reloadData];
  //  [self getCCForConsumer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Collectionview delegate/datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    cardDetailCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardDetailCollectionCell" forIndexPath:indexPath];

    NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
    NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];

    if([cardType isEqualToString:@"Visa"])
    {
        cell.imgCard.image = [UIImage imageNamed:@"card_VisaCard"];
    }
    else if([cardType isEqualToString:@"Amex"]){
        cell.imgCard.image = [UIImage imageNamed:@"card_AmericanExpressCard"];
    }
    else if([cardType isEqualToString:@"Master Card"]){
        cell.imgCard.image = [UIImage imageNamed:@"card_MasterCard"];
    }
    cell.lblCardNumber.text = cardDisplayNumber;
    cell.lblExpiryDate.text = uiExpirationDateString;
    
    NSLog(@"Here is lblCardNumber read from nsuserdefault %@", cell.lblExpiryDate.text);

    cell.lblCardHolderName.text = @"XXX";

    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // if ([defaults valueForKey:StripeDefaultCard] != nil) {
    //    NSDictionary *defaultCardDict = [defaults objectForKey:StripeDefaultCard];
    //     NSString *defaultCardNumber = [defaultCardDict valueForKey:@"cc_no"];
    //     if ([defaultCardNumber isEqualToString:cardNo]) {
    //         cell.layer.borderWidth = 2.0f;
    //         cell.layer.borderColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0].CGColor;
    //     }
    //     else{
    //         cell.layer.borderWidth = 0.0f;
    //     }
    // }

    cell.layer.borderWidth = 2.0f;
    cell.layer.borderColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0].CGColor;

    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Button Actions
- (IBAction) backBUttonClicked: (id) sender;
{
    [self.navigationController popViewControllerAnimated:true];
    //    [self.navigationController popToRootViewControllerAnimated:true];

}

- (IBAction)btnAddCardCliked:(id)sender {
    CardsViewController *payBillViewController = [[CardsViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:billBusiness];
    //                [AppData sharedInstance].consumer_Delivery_Id = nil;
    payBillViewController.business = [CurrentBusiness sharedCurrentBusinessManager].business;
    [self.navigationController pushViewController:payBillViewController animated:YES];
}

- (IBAction)btnRedeemPointClicked:(id)sender {
    if ([self enoughPointsToRedeem]) {
        if (flagRedeemPointVal == false) {
            flagRedeemPointVal = true;
            [self changePointsAndUI:flagRedeemPointVal];
            self.lblTotalPrice.text =  [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,self.totalVal];
        }
        else {
            flagRedeemPointVal = false;
            redeemPointsVal = 0.00;
            [self changePointsAndUI:flagRedeemPointVal];
            self.lblTotalPrice.text =  [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,self.totalVal];
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

- (IBAction)btnPayNowClicked:(id)sender {
    if(defaultCardData != nil){
        [self postOrderToServer];
    }
    else
    {
        [UIAlertController showAlert:@"Error" message:@"Please set first any one default card" buttonTitle:@"Ok" viewClass:self];
    }
}

#pragma mark - User Functions

- (void) getDefaultCardData {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog (@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    defaultCardData = [defaults valueForKey:StripeDefaultCard];
    if (defaultCardData != nil) {
        cardType = [defaultCardData valueForKey:@"card_type"];
        cardNo = [defaultCardData valueForKey:@"cc_no"];
        if (cardType.length == 0) {
            cardType = @"CARD";
        }

        uiExpirationDateString = [NSString stringWithFormat:@"20%@/%@", [defaultCardData valueForKey:@"expYear"]
                                  , [defaultCardData valueForKey:@"expMonth"]];
        NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
        NSString *defaultCardString = [NSString stringWithFormat:@"%@ xxxx xxxx xxxx %@",cardType,trimmedString];
        self.lblDefaultCard.text = defaultCardString;
    }
    else {
        self.lblDefaultCard.text = @"NO DEFAULT CARD!";
        cardType = @"";
        cardNo = @"";
        uiExpirationDateString = @"";
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
        self.lblCurrentPoints.text = [NSString stringWithFormat:@"%ld points" ,(long)totaLAvailablePoints];
        self.lblRedeemPointText.text = [NSString stringWithFormat:@"%ld points worth %2.0f¢ each.  Redeem some?",(long)totaLAvailablePoints,dollarValForEachPoints*100];
    }
    else {
        dollarValForEachPoints = 0.0;
        self.lblCurrentPoints.textColor = [UIColor lightGrayColor];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
        self.lblCurrentPoints.text = [NSString stringWithFormat:@"%ld points" ,(long)totaLAvailablePoints];
        self.lblRedeemPointText.text = @"You don't have enough points to use";
    }
}

- (float)calculateValueforGivenPoints:(NSInteger)points {
    return points*dollarValForEachPoints;
}

- (bool)enoughPointsToRedeem {
    NSLog(@"dollarValForEachPoint is:%f",dollarValForEachPoints);
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
    if(self.currentTipVal > 0) {
    }
    else {
        self.totalVal = self.subTotalVal + _taxVal + tipAmt - _promotionalamt +pd_charge ;
    }
}

- (void)adjustRedeemPointsAndTheirValues {
    double allAvailablePointsValue = [self calculateValueforGivenPoints:originalNoPoint];
    if ( allAvailablePointsValue <= self.subTotalVal) {
        self.totalVal = self.subTotalVal + self.taxVal - allAvailablePointsValue + self.tipAmt - self.promotionalamt + self.pd_charge;
        redeemNoPoint = originalNoPoint;
        redeemPointsVal = allAvailablePointsValue;
        dollarValForEachPoints = redeemPointsVal / redeemNoPoint;
    } else {
        redeemNoPoint = [self pointsNeededForGivenAmount:self.subTotalVal];
        dollarValForEachPoints = (self.subTotalVal + tipAmt + pd_charge - _promotionalamt) / redeemNoPoint;
        redeemPointsVal = redeemNoPoint * dollarValForEachPoints;
        _totalVal = tipAmt;
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

- (void)changePointsAndUI:(BOOL)flag {
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
    for (NSDictionary *product in self.finalOrderItems) {
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
        NSString *Points = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol,rounded_down];

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
//    NSString *cardNo = [defaultCardData valueForKey:@"cc_no"];

    if([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code == NULL){
        [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code = @"";
    }

    NSDictionary *orderInfoDict= @{@"cmd":@"save_order",@"data":orderItemArray,@"consumer_id":userID,@"total":[NSString stringWithFormat:@"%f",self.totalVal],
                                   @"business_id":business_id,@"points_redeemed":[NSString stringWithFormat:@"%ld",(long)currentRedeemPoints],
                                   @"points_dollar_amount":[NSString stringWithFormat:@"%f",redeemPointsDollarValue],
                                   @"tip_amount":[NSNumber numberWithDouble:tipAmt], @"subtotal":[NSNumber numberWithDouble:self.subTotalVal], @"tax_amount":[NSNumber numberWithDouble:self.taxVal],
                                   @"cc_last_4_digits":[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)]
                                   , @"note":self.self.pd_noteText, @"pd_instruction":self.noteText
                                   , @"consumer_delivery_id":[AppData sharedInstance].consumer_Delivery_Id.length > 0 ? [AppData sharedInstance].consumer_Delivery_Id : @"",
                                   @"delivery_charge_amount":[NSNumber numberWithDouble:self.pd_charge],
                                   @"promotion_code":[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code,
                                   @"promotion_discount_amount" : [NSString stringWithFormat:@"%f",self.promotionalamt],
                                   @"pd_charge_amount": [NSNumber numberWithDouble:self.pd_charge],
                                   @"pd_mode": [AppData sharedInstance].consumerPDMethodChosen.length > 0 ? [AppData sharedInstance].consumerPDMethodChosen : @"",
                                   @"pd_locations_id": [AppData sharedInstance].consumer_Delivery_Location_Id.length > 0 ? [AppData sharedInstance].consumer_Delivery_Location_Id : @"",
                                   @"pd_time": [AppData sharedInstance].consumerPDTimeChosen.length > 0 ? [AppData sharedInstance].consumerPDTimeChosen : @"",
                                   @"order_type":order_type
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
    hud.label.text = @"Sending order information to merchant...";
//    hud.detailsLabel.text = @"Tap-in is sending order to merchant...";
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
        [[APIUtility sharedInstance] callServer:orderInfoDict server:OrderServerURL method:@"POST" completiedBlock:^(NSDictionary *response) {
            [self.hud hideAnimated:YES];
            self->hud = nil;
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

                    NSString *cardType = [self->defaultCardData valueForKey:@"card_type"];
//                    NSString *cardNo = [self->defaultCardData valueForKey:@"cc_no"];
                    NSString *trimmedString=[self.cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
                    NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];
                    NSString *expDate =  [NSString stringWithFormat:@"%@/%@",[self->defaultCardData valueForKey:@"expMonth"],[self->defaultCardData valueForKey:@"expYear"]];
                    TPReceiptController *receiptVC = [[TPReceiptController alloc] initWithNibName:@"TPReceiptController" bundle:nil];
                    receiptVC.fetchedRecordArray = fetchedOrderArray;
                    receiptVC.order_id = [[dataDict valueForKey:@"order_id"] stringValue];
                    receiptVC.reward_point = [[dataDict valueForKey:@"points"] stringValue];
                    receiptVC.cardType = cardType;
                    receiptVC.cardNumber = cardDisplayNumber;
                    receiptVC.cardExpDate = expDate;
                    NSInteger currentRedeemPoints = [self getRedeemNoPoints];
                    receiptVC.redeem_point = [NSString stringWithFormat:@"%ld",(long)currentRedeemPoints];
                    receiptVC.totalPaid = self.lblTotalPrice.text;
                    receiptVC.tipAmount = self.tipAmt;
                    receiptVC.subTotal = self.subTotalVal;
                    receiptVC.receiptPDCharge = self.pd_charge;
                    receiptVC.taxAmount = self.taxVal;

                    [self removeAllOrderFromCoreData];

                    [self.navigationController pushViewController:receiptVC animated:YES];
                }
            }
            else
            {
                [UIAlertController showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
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

#pragma mark - Show Alertbox
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
