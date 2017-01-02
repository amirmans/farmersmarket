//
//  CartViewController.m
//  TapForAll
//
//  Created by Lalit on 11/17/16.
//
//

#import "CartViewController.h"
#import "DataModel.h"
#import "APIUtility.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "AppDelegate.h"
#import "AddressVC.h"
#import "ActionSheetPicker.h"

@interface CartViewController (){
    NSArray *latestInfoArray;
    ActionSheetDatePicker *datePicker;
}

@property (strong, nonatomic) NSMutableArray *orderItems;
@property (strong, nonatomic) NSString *notesText;
@property (assign) BOOL flagRedeemPoint;
@property (assign) double originalPointsValue;
@property (assign) NSInteger originalNoPoints;
@property (assign) double dollarValueForEachPoints;  //detemined by the points level's ceiling
@property (assign) NSInteger currenPointsLevel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (assign) NSInteger redeemNoPoints;  // number of points being redeemed
@property (assign) double  redeemPointsValue;// value for the points that we are redeeming

@end

@implementation CartViewController
@synthesize orderItems;
@synthesize flagRedeemPoint, originalPointsValue, originalNoPoints,dollarValueForEachPoints,
currenPointsLevel, redeemNoPoints, redeemPointsValue, hud;


//NSString *Note_default_text = @"Add your note here";
double cartSubTotal = 0;            // aka subtotal
NSString *deliveryStartTime;
NSString *deliveryEndTime;
double deliveryAmount = 0.0;
//double totalValue = 0.0;         // Final Total Amount value

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CartViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"CartViewTableViewCell"];
    
    self.title = @"Order";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    orderItems = [[NSMutableArray alloc] init];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.notesText = @"";
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblTitle.text = billBusiness.title;
    
    if([[CurrentBusiness sharedCurrentBusinessManager].business.business_delivery_id integerValue] > 0){
        self.btnDeliverToMe.enabled = YES;
        // Get Delivery info API
        long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
        NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
        NSDictionary *inDataDict = @{@"business_id":business_id};
        NSLog(@"---parameter---%@",inDataDict);
        [[APIUtility sharedInstance] BusinessDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
            NSLog(@"----response : %@",response);
            if(((NSArray *)[response valueForKey:@"data"]).count > 0) {
                NSArray *dataDict = [response valueForKey:@"data"];
                deliveryAmount = [[[dataDict objectAtIndex:0] valueForKey:@"delivery_charge"] doubleValue];
                deliveryStartTime = [[dataDict objectAtIndex:0] valueForKey:@"delivery_start_time"];
                deliveryEndTime = [[dataDict objectAtIndex:0] valueForKey:@"delivery_end_time"];
            }
        }];
    }
    else{
        self.btnDeliverToMe.enabled = NO;
    }
    
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    
    [self paymentSummary];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [self paymentSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _FetchedRecordArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"CartViewTableViewCell";
    CartViewTableViewCell *cell = (CartViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    _currentObject = _FetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = [AppData calculateRoundPrice:val];
//    int rounded_points = [AppData calculateRoundPoints:val];
    
    NSString *v = [NSString stringWithFormat:@"%.f",rounded_down];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$%.2f",rounded_down]];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont boldSystemFontOfSize:25.0]
                      range:NSMakeRange(1, v.length)];
    cell.lbl_Price.attributedText = attString;
    
    
    cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];
    
    cell.btnRemoveItem.tag = indexPath.row;
    cell.btnRemoveItem.section = indexPath.section;
    cell.btnRemoveItem.row = indexPath.row;
    
    [cell.btnRemoveItem addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnAddItem.tag = indexPath.row;
    cell.btnAddItem.section = indexPath.section;
    cell.btnAddItem.row = indexPath.row;
    
    [cell.btnAddItem addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

#pragma mark - User Functions
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
    cartSubTotal = TotalPrice;
    
    NSString *val = [NSString stringWithFormat:@"%.f",cartSubTotal];
    NSLog(@"%@",val);
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$%.2f",cartSubTotal]];
    [attString addAttribute:NSFontAttributeName
                  value:[UIFont boldSystemFontOfSize:25.0]
                  range:NSMakeRange(1, val.length)];
    self.lblSubtotalAmount.attributedText = attString;
    
    NSString *totalPointsStr = [NSString stringWithFormat:@"%ld",(long)cartSubTotal * PointsValueMultiplier];
    self.lblEarnPoints.text = [NSString stringWithFormat:@"EARN %@ Pts",totalPointsStr];
}

#pragma mark - Add and Remove Qty
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
- (void) refreshOrderData{
    [self.FetchedRecordArray removeAllObjects];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    [self.tableView reloadData];
    [self paymentSummary];
}

#pragma mark - Button Actions

- (IBAction)backBUttonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnPickUpFoodClicked:(id)sender {
}

- (IBAction)btnDeliverToMeClicked:(id)sender {
    if(orderItems.count > 0 && deliveryStartTime != nil && deliveryEndTime != nil)
    {
        NSString *time1 = deliveryStartTime;
        NSString *time3 = deliveryEndTime;
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
            NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
            dateFormatter1.dateFormat = @"HH:mm:ss";
            NSDate *startDate = [dateFormatter1 dateFromString:deliveryStartTime];
            NSDate *endDate = [dateFormatter1 dateFromString:deliveryEndTime];
            dateFormatter1.dateFormat = @"hh:mm a";
            NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
            [UIAlertController showErrorAlert:message];
        }
        else if(result == NSOrderedAscending)
        {
            if([date2 compare:date3] == NSOrderedDescending)
            {
                NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
                dateFormatter1.dateFormat = @"HH:mm:ss";
                NSDate *startDate = [dateFormatter1 dateFromString:deliveryStartTime];
                NSDate *endDate = [dateFormatter1 dateFromString:deliveryEndTime];
                dateFormatter1.dateFormat = @"hh:mm a";
                NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
                [UIAlertController showErrorAlert:message];
            }
            else
            {
                AddressVC *delivaryInfoVC = [[AddressVC alloc] initWithNibName:nil bundle:nil];
                delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
                [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
                    NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
                }];
            }
        }
        else
        {
            AddressVC *delivaryInfoVC = [[AddressVC alloc] initWithNibName:nil bundle:nil];
            delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
            [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
                NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
            }];
        }
    }
}

- (IBAction)btnScheduleForLaterClicked:(id)sender {
    
    [self.view endEditing:true];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:now doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSLog(@"%@",selectedDate);
        self.lblPickUpAt.text = [NSString stringWithFormat:@"PICK-UP AT %@",[formatter stringFromDate:selectedDate]];
        self.viewBottomConstraint.constant = 50.0;
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:sender];
    [datePicker showActionSheetPicker];
    
}
- (IBAction)btnPickUpAtContinueClicked:(id)sender {
    self.viewBottomConstraint.constant = 0.0;
}
@end
