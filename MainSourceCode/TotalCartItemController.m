//  TotalCartItemController.m
//  TapForAll
//  Created by Harry on 2/15/16.

#import "TotalCartItemController.h"
#import "TotalCartItemCell.h"
#import "AppDelegate.h"
#import "AskForSeviceViewController.h"
#import "BillPayViewController.h"
#import "APIUtility.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "TPBusinessDetail.h"
#import "SHMultipleSelect.h"
#import "DeliveryViewController.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"

@interface TotalCartItemController ()
{
    NSString *stringUid;
    NSArray *latestInfoArray;
}
@property (strong, nonatomic) NSMutableArray *orderItems;
@property (strong, nonatomic) NSString *notesText;

//when we make changes to the order, changing subtotal, we set points related value to the original
//rest the flag flagRedeemPoint to false, even ifthe user has chosen to use their points

@property (assign) BOOL flagRedeemPoint;
@property (assign) double originalPointsValue;
@property (assign) NSInteger originalNoPoints;
@property (assign) double dollarValueForEachPoints;  //detemined by the points level's ceiling
@property (assign) NSInteger currenPointsLevel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (assign) NSInteger redeemNoPoints;  // number of points being redeemed
@property (assign) double  redeemPointsValue;// value for the points that we are redeeming

- (float)calculateValueforGivenPoints:(NSInteger)points;
@end

@implementation TotalCartItemController

@synthesize itemCartTableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize orderItems;
@synthesize waitTimeLabel;
@synthesize lblEarnedPoint, lblSubtotalAmount;
@synthesize flagRedeemPoint, originalPointsValue, originalNoPoints,dollarValueForEachPoints,
currenPointsLevel, redeemNoPoints, redeemPointsValue, lblPointsUsed, hud;

NSString *Note_default_text = @"Add your note here";
double tipAmount = 0.0;          // Tip Amount Value
NSInteger currentTipValue = 0;   // Selected Tip Value
double cartTotal = 0;            // aka subtotal
double totalValue = 0.0;         // Final Total Amount value
double deliveryamount = 0.0;     // Delivery Amount value
double promotionalamount = 0.0;  // Promotional Amount value
double globalPromotional = 0.0;  // Variable for manage promotional amount with total amount value
NSString *delivery_start_time;   // Delivery Start Time
NSString *delivery_end_time;     // Delivery End Time
UITextView *alertTextView;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    flagRedeemPoint = false;
    originalPointsValue = 0.0;
    originalNoPoints = 0;
    dollarValueForEachPoints = 0;  //detemined by the points level's ceiling
    currenPointsLevel  = 0;
    redeemNoPoints  = 0;  // number of points being redeemed
    redeemPointsValue = 0;  // value for the points that we are redeeming
    lblPointsUsed.text= @"pts used: 0";
    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    if ([userID intValue] <=0) {
        userID = [NSString stringWithFormat:@"%@",[DataModel sharedDataModelManager].uuid];
    }
    stringUid = [NSString stringWithFormat:@"%@", userID];
    if([[CurrentBusiness sharedCurrentBusinessManager].business.business_delivery_id integerValue] > 0){
        self.deliveryView.hidden = NO;
        self.lblbtnDelivery.text = @"Delivery";
        // Get Delivery info API
        long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
        NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
        NSDictionary *inDataDict = @{@"business_id":business_id};
        NSLog(@"---parameter---%@",inDataDict);
        [[APIUtility sharedInstance] BusinessDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
            NSLog(@"----response : %@",response);
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(postPDInfomationFromServer:)
                                                         name:@"GotPickupDeliveryData"
                                                       object:nil];

        }];
    }
    else{
        self.deliveryView.hidden = YES;
    }
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    NSString *openTime = [CurrentBusiness sharedCurrentBusinessManager].business.opening_time;
    NSString *closeTime = [CurrentBusiness sharedCurrentBusinessManager].business.closing_time;
    BOOL businessIsClosed = false;
    if(openTime == (id)[NSNull null] || closeTime == (id)[NSNull null]) {
        businessIsClosed = true;
    } else if (![[APIUtility sharedInstance] isOpenBussiness:openTime CloseTime:closeTime]) {
        businessIsClosed = true;
    }
    
    if (businessIsClosed) {
        NSString *openCivilianTime = [[APIUtility sharedInstance] getCivilianTime:openTime];
        NSString *waitTime = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
        NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
        NSString *message = [NSString stringWithFormat:@"You may add items to your cart.\nBut if you pay, your order will be ready after the opening time (%@).\n\n%@ after opening.", openCivilianTime, waitTime];
        NSString *title = [NSString stringWithFormat:@"%@ is closed now!", businessName];
        [UIAlertController showInformationAlert:message withTitle:title];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pointsRedeem:)
                                                 name:RedeemPoints
                                               object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.notesText = @"";
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.edgesForExtendedLayout = UIRectEdgeAll;
//    NSString *titleString = [NSString stringWithFormat:@"My Order for %@",billBusiness.shortBusinessName];
    NSString *titleString = [NSString stringWithFormat:@"Order"];
    self.title = titleString;
    orderItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    self.itemCartTableView.delegate = self;
    self.itemCartTableView.dataSource = self;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    
    // Manage Promotion value and delievery button on screen
    if(billBusiness.promotion_discount_amount == nil)
    {
        self.lblPromotionalAmount.hidden = true;
        self.lblPromotionCode.hidden = true;
        self.lblPromotion.hidden = true;
        self.viewLeftLine.hidden = true;
        self.viewRightLine.hidden = true;
        self.lblPromotionalDiscountText.hidden = true;
    }
    else
    {
        self.lblPromotionalAmount.hidden = false;
        self.lblPromotionCode.hidden = false;
        self.lblPromotion.hidden = false;
        self.viewLeftLine.hidden = false;
        self.viewRightLine.hidden = false;
        self.lblPromotionalDiscountText.hidden = false;
        [self checkPromoCodeForUser];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setBorder:self.btnNoTip];
    [self setBorder:self.btnOther];
    [self setBorder:self.btnTip10];
    [self setBorder:self.btnTip15];
    [self setBorder:self.btnTip20];
    self.itemCartTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self paymentSummary];
    [self setInitialPointsValue];
    self.paymentView.layer.borderColor = [UIColor blackColor].CGColor;
    self.paymentView.layer.borderWidth = 2;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNoTip];
    flagRedeemPoint = false;
    [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
    if ([AppData sharedInstance].consumer_Delivery_Id != nil) {
        self.lblDeliveryAmount.hidden = false;
        self.lblDeliveryAmountText.hidden  =false;
        self.lblbtnDelivery.text = [NSString stringWithFormat:@"Delivery to: %@",[AppData sharedInstance].consumer_Delivery_Location];
    }
    else
    {
        self.lblDeliveryAmount.hidden = true;
        self.lblDeliveryAmountText.hidden  =true;
        self.lblbtnDelivery.text = @"Delivery";
    }
    waitTimeLabel.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
    [self getDefaultCardData];
    [self paymentSummary];
}

//Check Promotion Code available
-(void)checkPromoCodeForUser {
    
    if ([DataModel sharedDataModelManager].uuid.length < 1) {
    }
    else {
        if([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code != nil) {
            NSDictionary *inDataDict = @{@"consumer_id":stringUid,
                                         @"cmd":@"did_consumer_used_promotion",
                                         @"business_id":[NSNumber numberWithInt:[CurrentBusiness sharedCurrentBusinessManager].business.businessID],
                                         @"promotion_code":[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code};
            [[APIUtility sharedInstance] CheckConsumerPromoCodeAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                NSLog(@"%@",response);
                if([[response valueForKey:@"status"] integerValue] >= 0){
                    
                    if( ((NSArray *)[response valueForKey:@"data"]).count > 0) {
                        globalPromotional = 0.00;
                        promotionalamount = 0.00;
                        self.lblPromotionalDiscountText.hidden = true;
                        self.lblPromotionalAmount.hidden = true;
                        self.lblPromotionCode.hidden = true;
                        self.lblPromotion.hidden = true;
                        self.viewLeftLine.hidden = true;
                        self.viewRightLine.hidden = true;
                    }
                    else
                    {
                        self.lblPromotionalAmount.hidden = false;
                        self.lblPromotionCode.hidden =false;
                        self.lblPromotionalDiscountText.hidden = false;
                        self.lblPromotion.hidden = false;
                        self.viewLeftLine.hidden = false;
                        self.viewRightLine.hidden = false;
                        NSLog(@"%@", [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code);
                        if(([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code == nil)){
                            globalPromotional = 0.00;
                            promotionalamount = 0.00;
                        }
                        else
                        {
                            double doublePromo = [[CurrentBusiness sharedCurrentBusinessManager].business.promotion_discount_amount doubleValue];
                            globalPromotional = doublePromo;
                            promotionalamount = doublePromo;
                            self.lblPromotionCode.text = [NSString stringWithFormat:@"Code: %@",[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code];
                            self.lblPromotionCode.adjustsFontSizeToFitWidth = YES;
                        }
                        if(globalPromotional > cartTotal)
                        {
                            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
                            promotionalamount = cartTotal;
                        }
                        else
                        {
                            promotionalamount = globalPromotional;
                            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%@",billBusiness.promotion_discount_amount];
                        }
                    }
                    [self paymentSummary];
                }
                else
                {
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [self getDefaultCardData];
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate / DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _FetchedRecordArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"TotalCartItemsTableCell";
    TotalCartItemsTableCell *cell = (TotalCartItemsTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    _currentObject = _FetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = [AppData calculateRoundPrice:val];
    int rounded_points = [AppData calculateRoundPoints:val];
    cell.lbl_Price.text = [NSString stringWithFormat:@"%.2f",rounded_down];
    cell.lbl_Points.text = [NSString stringWithFormat:@"%d Pts",rounded_points];
    cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
    cell.lbl_OrderOption.text = [self.currentObject valueForKey:@"product_option"];
    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];
    NSLog(@"note ---------------- %@",[self.currentObject valueForKey:@"item_note"]);
    cell.btnRemoveItem.tag = indexPath.row;
    cell.btnRemoveItem.section = indexPath.section;
    cell.btnRemoveItem.row = indexPath.row;
    [cell.btnRemoveItem addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnAddItem.tag = indexPath.row;
    cell.btnAddItem.section = indexPath.section;
    cell.btnAddItem.row = indexPath.row;
    [cell.btnAddItem addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// Minus Button click for decrease quantity
- (IBAction)MinusButtonClicked:(CustomUIButton *)sender {
    
    NSManagedObject *managedObj = [self.FetchedRecordArray objectAtIndex:sender.row];
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
    businessDetail.note = [managedObj valueForKey:@"note"];
    businessDetail.item_note = [managedObj valueForKey:@"item_note"];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    NSLog(@"%@",_FetchedRecordArray.description);
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil) {
    }
    else {
        BOOL itemFound = false;
        for (NSManagedObject *obj in results) {
            NSArray *keys = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
            if([[dictionary valueForKey:@"product_order_id"] integerValue] == businessDetail.product_order_id){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [context deleteObject:obj];
                ItemQty = ItemQty - 1;
                if(ItemQty > 0){
                    NSManagedObject *storeManageObject = [NSEntityDescription
                                                          insertNewObjectForEntityForName:@"MyCartItem"
                                                          inManagedObjectContext:context];
                    [storeManageObject setValue:businessDetail.price forKey:@"price"];
                    [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
                    [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
                    [storeManageObject setValue:businessDetail.businessID forKey:@"businessID"];
                    [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
                    [storeManageObject setValue:businessDetail.name forKey:@"productname"];
                    [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
                    [storeManageObject setValue:@(businessDetail.product_order_id) forKey:@"product_order_id"];
                    [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
                    [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
                    [storeManageObject setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                    if ( ([dictionary valueForKey:@"selected_ProductID_array"] != nil) && ([dictionary valueForKey:@"selected_ProductID_array"] != [NSNull null]) ) {
                        [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];
                    }
                    [storeManageObject setValue:[dictionary valueForKey:@"note"] forKey:@"note"];
                    NSError *error;
                    if (![context save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
                else {
                    if (![context save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
                break;
            }
        }
    }
    [self refreshOrderData];
}

// Plus Button Click for Increase Quantity
- (IBAction)PlusButtonClicked:(CustomUIButton *)sender {
    
    NSManagedObject *managedObj = [self.FetchedRecordArray objectAtIndex:sender.row];
    TPBusinessDetail *businessDetail = [[TPBusinessDetail alloc] init];
    businessDetail.price = [managedObj valueForKey:@"price"];
    businessDetail.short_description = [managedObj valueForKey:@"product_descrption"];
    businessDetail.product_id = [managedObj valueForKey:@"product_id"];
    businessDetail.businessID = [managedObj valueForKey:@"businessID"];
    businessDetail.pictures = [managedObj valueForKey:@"product_imageurg"];
    businessDetail.name = [managedObj valueForKey:@"productname"];
    businessDetail.ti_rating = [[managedObj valueForKey:@"ti_rating"] doubleValue];
    businessDetail.quantity = [[managedObj valueForKey:@"quantity"] integerValue];
    businessDetail.product_order_id = [[managedObj valueForKey:@"product_order_id"] integerValue];
    businessDetail.product_option = [managedObj valueForKey:@"product_option"];
    NSLog(@"%@",[managedObj valueForKey:@"item_note"]);
    businessDetail.item_note = [managedObj valueForKey:@"item_note"];
    businessDetail.note = [managedObj valueForKey:@"note"];
    [self AddItemInCart:businessDetail CustomUIButton:sender];
}

- (void) AddItemInCart : (TPBusinessDetail *)businessDetail CustomUIButton:(CustomUIButton *)sender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil) {
    }
    else {
        BOOL itemFound = false;
        for (NSManagedObject *obj in results) {
            NSArray *keys = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
            int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
            ItemQty = ItemQty + 1;
            NSInteger dict_product_order_id = [[dictionary valueForKey:@"product_order_id"] integerValue];
            NSInteger Business_product_order_id = businessDetail.product_order_id;
            if (Business_product_order_id == dict_product_order_id) {
                itemFound = true;
                NSManagedObject *storeManageObject = [NSEntityDescription
                                                      insertNewObjectForEntityForName:@"MyCartItem"
                                                      inManagedObjectContext:context];
                [context deleteObject:obj];
                [storeManageObject setValue:businessDetail.price forKey:@"price"];
                [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
                [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
                [storeManageObject setValue:businessDetail.businessID forKey:@"businessID"];
                [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
                [storeManageObject setValue:businessDetail.name forKey:@"productname"];
                [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
                [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
                [storeManageObject setValue:@(businessDetail.product_order_id) forKey:@"product_order_id"];
                if ( ([dictionary valueForKey:@"selected_ProductID_array"] != nil) && ([dictionary valueForKey:@"selected_ProductID_array"] != [NSNull null]) )
                    [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];
                [storeManageObject setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                [storeManageObject setValue:[dictionary valueForKey:@"note"] forKey:@"note"];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                break;
            }
        }
    }
    [self refreshOrderData];
}

#pragma mark - Stripe Payment

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        
        if(itemNote != nil)
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
    }
    
    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    NSInteger currentRedeemPoints = [self getRedeemNoPoints];
    float redeemPointsDollarValue = [self redeemPointsValue];
    NSString *cardNo = [defaultCardData valueForKey:@"cc_no"];
    if ([self.notesText  isEqual:Note_default_text]) {
        self.notesText = @"";
    }
    if([CurrentBusiness sharedCurrentBusinessManager].business.promotion_code == NULL){
        [CurrentBusiness sharedCurrentBusinessManager].business.promotion_code = @"";
    }
    
    NSDictionary *orderInfoDict= @{@"cmd":@"save_order",@"data":orderItemArray,@"consumer_id":userID,@"total":[NSString stringWithFormat:@"%f",totalValue],
                                   @"business_id":business_id,@"points_redeemed":[NSString stringWithFormat:@"%ld",(long)currentRedeemPoints],
                                   @"points_dollar_amount":[NSString stringWithFormat:@"%f",redeemPointsDollarValue],
                                   @"tip_amount":[NSNumber numberWithDouble:tipAmount], @"subtotal":[NSNumber numberWithDouble:cartTotal], @"tax_amount":[NSNumber numberWithDouble:0.0],
                                   @"cc_last_4_digits":[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)], @"note":self.notesText,
                                   @"consumer_delivery_id":[AppData sharedInstance].consumer_Delivery_Id.length > 0 ? [AppData sharedInstance].consumer_Delivery_Id : @"",
                                   @"delivery_charge_amount":[NSNumber numberWithDouble:deliveryamount],
                                   @"promotion_code":[CurrentBusiness sharedCurrentBusinessManager].business.promotion_code,
                                   @"promotion_discount_amount" : [NSString stringWithFormat:@"%f",promotionalamount]
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
                    receiptVC.tipAmount = tipAmount;
                    receiptVC.subTotal = cartTotal;
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


#pragma mark - Custom Methods
- (void) refreshOrderData{
    [self.FetchedRecordArray removeAllObjects];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    [self.itemCartTableView reloadData];
    [self setNoTip];
    [self changePointsAndUI:false];
    [self setNoTip];
    [self paymentSummary];
}

// set total order and Price
- (void)paymentSummary {
    [orderItems removeAllObjects];
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    int QTY = 0;
    CGFloat TotalPrice = 0.0f;
    for (NSManagedObject *obj in self.FetchedRecordArray) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        QTY += [[dictionary valueForKey:@"quantity"] integerValue];
        CGFloat val = [[dictionary valueForKey:@"price"] floatValue];
        val =  val * [[dictionary valueForKey:@"quantity"] integerValue];
        CGFloat rounded_down = [AppData calculateRoundPrice:val];
        TotalPrice += rounded_down;
        [orderItems addObject:dictionary];
        self.notesText = [dictionary valueForKey:@"note"];
    }
    cartTotal = TotalPrice;
    totalValue = cartTotal;
    self.lblSubtotalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
    self.lblQty.text = [NSString stringWithFormat:@"%d",QTY];
    billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",TotalPrice]];
    NSString *totalPointsStr = [NSString stringWithFormat:@"%ld",(long)cartTotal * PointsValueMultiplier];
    self.lblEarnedPoint.text = [NSString stringWithFormat:@"Earn %@ Pts",totalPointsStr];
    NSString *tip10String = [NSString stringWithFormat:@"$%.2f",cartTotal * .10];
    NSString *tip15String = [NSString stringWithFormat:@"$%.2f",cartTotal * .15];
    NSString *tip20String = [NSString stringWithFormat:@"$%.2f",cartTotal * .20];
    
    if([AppData sharedInstance].consumer_Delivery_Id != nil)
    {
        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal * deliveryamount];
        deliveryamount = cartTotal * deliveryamount;
    }
    else
    {
        deliveryamount = 0.00;
        self.lblDeliveryAmount.text = [NSString stringWithFormat:@"0.00"];
    }
    if(globalPromotional > cartTotal)
    {
        self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
        promotionalamount = cartTotal;
    }
    else
    {
        promotionalamount = globalPromotional;
        self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",promotionalamount];
    }
    totalValue = TotalPrice + deliveryamount - promotionalamount;
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",totalValue];
    [self.btnTip10 setTitle:tip10String forState:UIControlStateNormal];
    [self.btnTip15 setTitle:tip15String forState:UIControlStateNormal];
    [self.btnTip20 setTitle:tip20String forState:UIControlStateNormal];
}

- (void) setInitialPointsValue {
    NSLog(@"%@",[RewardDetailsModel sharedInstance].rewardDict);
    NSDictionary *rewards = [RewardDetailsModel sharedInstance].rewardDict;
    currenPointsLevel = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"points"] integerValue];
    originalNoPoints = [[[rewards valueForKey:@"data"] valueForKey:@"total_available_points"] integerValue];
    originalPointsValue = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"dollar_value"] doubleValue];
    int totaLAvailablePoints = [[[rewards valueForKey:@"data"] valueForKey:@"total_available_points"] intValue];
    if (originalPointsValue > 0) {
        dollarValueForEachPoints = originalPointsValue / currenPointsLevel;
        self.lblCurrentPoints.text = [NSString stringWithFormat:@"%ld points worth %2.0f¢ each.  Redeem some?",(long)totaLAvailablePoints,dollarValueForEachPoints*100];
    }
    else {
        dollarValueForEachPoints = 0.0;
        self.lblCurrentPoints.text = @"You don't have enough points to use";
    }
}

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
        NSString *defaultCardString = [NSString stringWithFormat:@"%@ ENDING IN %@",cardType,trimmedString];
        self.lblDefaultCard.text = defaultCardString;
    }
    else {
        self.lblDefaultCard.text = @"NO DEFAULT CARD!";
    }
}

- (void) setBorder : (UIView *) view {
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
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
    currentTipValue = 0;
    [self calculateTip:currentTipValue];
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
    currentTipValue = 10;
    [self calculateTip:currentTipValue];
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
    currentTipValue = 15;
    [self calculateTip:currentTipValue];
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
    currentTipValue = 20;
    [self calculateTip:currentTipValue];
}

- (void) setOther {
    
    self.btnNoTip.backgroundColor = [UIColor whiteColor];
    self.btnTip10.backgroundColor = [UIColor whiteColor];
    self.btnTip15.backgroundColor = [UIColor whiteColor];
    self.btnTip20.backgroundColor = [UIColor whiteColor];
    self.btnOther.backgroundColor = [UIColor blackColor];
    [self.btnNoTip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip10 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip15 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTip20 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOther setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)calculateTip : (double) tip  {
    
    if(cartTotal > 0) {
        tipAmount = cartTotal* (tip/100);
        if(globalPromotional > cartTotal)
        {
            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
            promotionalamount = cartTotal;
        }
        else
        {
            promotionalamount = globalPromotional;
            self.lblPromotionalAmount.text = [NSString stringWithFormat:@"$%.2f",promotionalamount];
        }
        totalValue = cartTotal + tipAmount + deliveryamount - promotionalamount - redeemPointsValue ;
        self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",totalValue];
        billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",totalValue]];
    }
}


- (float)calculateValueforGivenPoints:(NSInteger)points {
    return points*dollarValueForEachPoints;
}

- (bool)enoughPointsToRedeem {
    NSLog(@"%f",dollarValueForEachPoints);
    if (dollarValueForEachPoints > 0)
        return TRUE;
    else
        return false;
}

- (NSInteger)getRedeemNoPoints {
    if (![self enoughPointsToRedeem])
        return 0;
    
    if (flagRedeemPoint) {
        return redeemNoPoints;
    }
    else {
        return 0;
    }
}

- (void)revertRedeemPointsAndValuesToOriginal {
    redeemNoPoints = 0;
    redeemPointsValue = 0;
    dollarValueForEachPoints = originalPointsValue / currenPointsLevel;
    if(currentTipValue > 0) {
        [self calculateTip:currentTipValue];
    }
    else {
        totalValue = cartTotal + tipAmount - promotionalamount +deliveryamount ;
    }
}

- (void)adjustRedeemPointsAndTheirValues {
    double allAvailablePointsValue = [self calculateValueforGivenPoints:originalNoPoints];
    if ( allAvailablePointsValue <= cartTotal) {
        totalValue = cartTotal - allAvailablePointsValue + tipAmount - promotionalamount + deliveryamount;
        redeemNoPoints = originalNoPoints;
        redeemPointsValue = allAvailablePointsValue;
        dollarValueForEachPoints = redeemPointsValue / redeemNoPoints;
    } else {
        redeemNoPoints = [self pointsNeededForGivenAmount:cartTotal];
        dollarValueForEachPoints = totalValue / redeemNoPoints;
        redeemPointsValue = redeemNoPoints * dollarValueForEachPoints;
        totalValue = tipAmount;
    }
}

- (NSInteger)pointsNeededForGivenAmount:(double)amount {
    if (dollarValueForEachPoints <= 0 ) {
        return 0;
    }
    else {
        return ceil(amount / dollarValueForEachPoints );
    }
}

- (void) pointsRedeem:(NSNotification *) notification
{
    [self btnRedeemPointClicked:self];
    self.btnUsePoints.userInteractionEnabled = false;
}

- (void) openNotesPopupWithText : (NSString *) note {
    [self showAlert:@"Add Note" :@""];
//    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"Add Note"
//                                                        message:@""
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Pay", nil];
//    alertTextView = [UITextView new];
//    alertTextView.delegate = self;
//    alertTextView.text = note;
//    [testAlert setTag:100];
//    [testAlert setValue: alertTextView forKey:@"accessoryView"];
//    [testAlert show];
}

- (void)postPDInfomationFromServer:(NSDictionary *)response {
    if([[response valueForKey:@"status"] integerValue] >= 0)
    {
        if(((NSArray *)[response valueForKey:@"data"]).count > 0) {
            NSArray *dataDict = [response valueForKey:@"data"];
            deliveryamount = [[[dataDict objectAtIndex:0] valueForKey:@"delivery_charge"] doubleValue];
            delivery_start_time = [[dataDict objectAtIndex:0] valueForKey:@"delivery_start_time"];
            delivery_end_time = [[dataDict objectAtIndex:0] valueForKey:@"delivery_end_time"];
        }
    }
    else
    {
        [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    return true;
}

#pragma mark - Button Action
- (IBAction) backBUttonClicked: (id) sender;
{
    [AppData sharedInstance].consumer_Delivery_Id = nil;
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnPayButtonClicked:(id)sender {
    if ([DataModel sharedDataModelManager].uuid.length < 1) {
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:@"We are taking you to the profile page.  Please update your profile info \n then come back to this page." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.tabBarController.selectedIndex = 1;
        }];
        [alert1 addAction:okAction];
        [self presentViewController:alert1 animated:true completion:^{
        }];
    }
    else {
        if ([DataModel sharedDataModelManager].emailAddress.length < 1) {
            UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"" message:@"We are taking you to the profile page.  Please update your profile info \n then come back to this page." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.tabBarController.selectedIndex = 1;
            }];
            [alert2 addAction:okAction];
            [self presentViewController:alert2 animated:true completion:^{
            }];
        }
        if (_FetchedRecordArray.count >  0) {
             if (defaultCardData == nil) {
                BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:billBusiness];
                [AppData sharedInstance].consumer_Delivery_Id = nil;
                [self.navigationController pushViewController:payBillViewController animated:YES];
            }
            else {
                if ( (self.notesText == nil) || (self.notesText == (id)[NSNull null]) )
                    [self openNotesPopupWithText:Note_default_text];
                else if ([self.notesText isEqualToString:@""]) {
                    [self openNotesPopupWithText:Note_default_text];
                }
                else {
                    [self openNotesPopupWithText:self.notesText];
                }
            }
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please select menu items to place an order." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:true completion:^{
            }];
        }
    }
}

- (IBAction)btnCancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnQuestionClicked:(id)sender {
    AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:billBusiness];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

- (void) changePointsAndUI:(BOOL)flag {
    if (flag) {
        [self adjustRedeemPointsAndTheirValues];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_checked"] forState:UIControlStateNormal];
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %ld", redeemNoPoints];
    } else {
        [self revertRedeemPointsAndValuesToOriginal];
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
        self.lblPointsUsed.text = [NSString stringWithFormat:@"pts used: %ld", redeemNoPoints];
    }
}

- (IBAction)btnRedeemPointClicked:(id)sender {
    if ([self enoughPointsToRedeem]) {
        if (flagRedeemPoint == false) {
            flagRedeemPoint = true;
            [self changePointsAndUI:flagRedeemPoint];
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",totalValue];
        }
        else {
            flagRedeemPoint = false;
            [self changePointsAndUI:flagRedeemPoint];
            self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",totalValue];
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

- (IBAction)btnCloseChangeOrderClicked:(id)sender {
}

- (IBAction)btnAddItemClicked:(id)sender {
}

- (IBAction)btnRemoveItemClicked:(id)sender {
    self.changeOrderView.hidden = true;
}

- (IBAction)btnChangePaymentMethodClicked:(id)sender {
    BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:billBusiness];
    [self.navigationController pushViewController:payBillViewController animated:YES];
}

- (IBAction)btnNoTipClicked:(id)sender {
    [self setNoTip];
}

- (IBAction)btnOtherClicked:(id)sender {
    [self setOther];
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

-(int) minutesSinceMidnight:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    return 60 * (int)[components hour] + (int)[components minute];
}

//Set delivery place and time on delivery button click
- (IBAction)btnDeliveryToClicked:(id)sender {
    
    if(orderItems.count > 0 && delivery_start_time != nil && delivery_end_time != nil)
    {
        NSString *time1 = delivery_start_time;
        NSString *time3 = delivery_end_time;
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
        NSLog(@"Time 1 : %@",time1);
        NSLog(@"Time 2 : %@",time3);
        NSString *time2 = [formatter stringFromDate:now];
        
        NSDate *date1= [formatter dateFromString:time1];
        NSDate *date2 = [formatter dateFromString:time2];
        NSDate *date3 = [formatter dateFromString:time3];
        NSComparisonResult result = [date1 compare:date2];
        
        if(result == NSOrderedDescending)
        {
            NSDateFormatter* dateFormatter1 = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//            NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
//            dateFormatter1.dateFormat = @"HH:mm:ss";
            NSDate *startDate = [dateFormatter1 dateFromString:delivery_start_time];
            NSDate *endDate = [dateFormatter1 dateFromString:delivery_end_time];
            dateFormatter1.dateFormat = TIME12HOURFORMAT;
            NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
            [UIAlertController showErrorAlert:message];
        }
        else if(result == NSOrderedAscending)
        {
            if([date2 compare:date3] == NSOrderedDescending)
            {
                NSDateFormatter* dateFormatter1 = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//                NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
//                dateFormatter1.dateFormat = @"HH:mm:ss";
                NSDate *startDate = [dateFormatter1 dateFromString:delivery_start_time];
                NSDate *endDate = [dateFormatter1 dateFromString:delivery_end_time];
                dateFormatter1.dateFormat = TIME12HOURFORMAT;
                NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
                [UIAlertController showErrorAlert:message];
            }
            else
            {
                DeliveryViewController *delivaryInfoVC = [[DeliveryViewController alloc] initWithNibName:nil bundle:nil];
                delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
                [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
                    NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
                }];
            }
        }
        else
        {
            DeliveryViewController *delivaryInfoVC = [[DeliveryViewController alloc] initWithNibName:nil bundle:nil];
            delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
            [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
                NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
            }];
        }
    }
}

- (IBAction)onDeliveryCheckmark_Clicked:(id)sender {
    
    if(self.isDeliveryChecked == NO){
        self.isDeliveryChecked = YES;
        self.delivaryTolable.hidden = NO;
        self.btnDeliveryTo.hidden = NO;
        self.lblbtnDelivery.hidden = NO;
        [self.delivayCheckmark setImage:[UIImage imageNamed:@"ic_checked"] forState:UIControlStateNormal];
    }
    else{
        self.isDeliveryChecked = NO;
        self.delivaryTolable.hidden = YES;
        self.btnDeliveryTo.hidden = YES;
        self.lblbtnDelivery.hidden = YES;
        [self.delivayCheckmark setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnUsePointClicked:(id)sender {
    if ([DataModel sharedDataModelManager].uuid.length < 1) {
        [UIAlertController showErrorAlert:@"Please register on profile page."];
    }
    else {
        [AppData sharedInstance].isFromTotalCart = true;
        [self.tabBarController setSelectedIndex:3];
    }
}

- (IBAction)btnAddNoteClicked:(id)sender {
    [self showAlert:@"Add Note" :@""];
//    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"Add Note"
//                                                        message:@""
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Pay", nil];
//    alertTextView = [UITextView new];
//    alertTextView.text = Note_default_text;
//    [testAlert setTag:100];
//    [testAlert setValue: alertTextView forKey:@"accessoryView"];
//    [testAlert show];
}

#pragma mark - AlertView delegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    if (alertView.tag == 100) {
//        if (buttonIndex == 1) {
//            if ([alertTextView.text  isEqual:Note_default_text]) {
//                self.notesText = @"";
//            }
//            self.notesText = alertTextView.text;
//            [self postOrderToServer];
//        }
//        else if (buttonIndex == 2) {
//            self.notesText = @"";
//            [self postOrderToServer];
//        }
//    }
//}
- (void)showAlert:(NSString *)Title :(NSString *)Message{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle: Title
                                message: Message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                               actionWithTitle:@"Pay"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   UITextField *alertTextField = alert.textFields.firstObject;
                                   NSLog(@"And the text is... %@!", alertTextField.text);
                                   
                                   if ([alertTextField.text  isEqual:Note_default_text]) {
                                       self.notesText = @"";
                                   }
                                   self.notesText = alertTextField.text;
                                   [self postOrderToServer];
                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                       self.notesText = @"";
//                                                       [self postOrderToServer];
                                                   }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
    textField.placeholder = Note_default_text;
        
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];}


@end
