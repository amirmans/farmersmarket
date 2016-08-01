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

@interface TotalCartItemController ()

@property (strong, nonatomic) NSMutableArray *orderItems;
@property (strong, nonatomic) NSString *notesText;

- (float)calculateTotalPoints:(float)amount;
@end

@implementation TotalCartItemController

@synthesize itemCartTableView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize orderItems;
@synthesize waitTimeLabel;
@synthesize lblEarnedPoint, lblSubtotalAmount;

bool flagRedeemPoint = false;
NSString *Note_default_text = @"Add your note here";

double tipAmount = 0.0;
double cartTotal = 0;
double dollarValue = 0;
double totalValue = 0.0;
NSInteger redeemPoints = 0;
NSInteger current_points_level  = 0;
NSInteger currentTipValue = 0;
bool isPointsUsed = false;
UITextView *alertTextView;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

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

    flagRedeemPoint = false;

    tipAmount = 0.0;
    cartTotal = 0.0;
    dollarValue = 0;
    totalValue = 0.0;
    redeemPoints = 0;
    current_points_level  = 0;
    currentTipValue = 0.0;
    isPointsUsed = false;
    [self setNeedsStatusBarAppearanceUpdate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pointsRedeem:)
                                                 name:RedeemPoints
                                               object:nil];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.notesText = @"";
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;

    self.edgesForExtendedLayout = UIRectEdgeAll;

    NSString *titleString = [NSString stringWithFormat:@"My Order for %@",billBusiness.shortBusinessName];

    self.title = titleString;
    orderItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    self.itemCartTableView.delegate = self;
    self.itemCartTableView.dataSource = self;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);

    NSLog(@"%@",self.FetchedRecordArray);
    redeemPoints = 0;
    zero = [NSDecimalNumber zero];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setBorder:self.btnNoTip];
    [self setBorder:self.btnOther];
    [self setBorder:self.btnTip10];
    [self setBorder:self.btnTip15];
    [self setBorder:self.btnTip20];


//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.itemCartTableView.contentInset = UIEdgeInsetsMake(self.itemCartTableView.frame.origin.x, self.itemCartTableView.frame.origin.y, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.itemCartTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

//    self.itemCartTableView.estimatedRowHeight = 100;
//    self.itemCartTableView.rowHeight = UITableViewAutomaticDimension;

    [self paymentSummary];
    [self setPointsValue];

    self.paymentView.layer.borderColor = [UIColor blackColor].CGColor;
    self.paymentView.layer.borderWidth = 2;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    waitTimeLabel.text = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
    [self getDefaultCardData];
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
//    static NSString *simpleTableIdentifier = @"TotalCartItemCell";
//    TotalCartItemCell *cell = (TotalCartItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//    if (cell == nil)
//    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemCell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//
//    _currentObject = _FetchedRecordArray[indexPath.row];
//    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
//
//    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
//    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
//    CGFloat rounded_down = floorf(val * 100) / 100;
//    cell.lbl_Price.text = [NSString stringWithFormat:@"$%.2f",rounded_down];
//
////    if(![businessDetail.short_description isKindOfClass:[NSNull class]])
////        cell.lbl_description.text = businessDetail.short_description;
////    else
////        cell.lbl_description.text = @"";
////
//
//    cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
//
//    cell.lbl_OrderOption.text = [self.currentObject valueForKey:@"product_option"];
//
//    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];
//
//    cell.btn_minus.tag = indexPath.row;
//    cell.btn_minus.section = indexPath.section;
//    cell.btn_minus.row = indexPath.row;
//
//    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
////    cell.btn_plus.tag = indexPath.row;
////    cell.btn_plus.section = indexPath.section;
////    cell.btn_plus.row = indexPath.row;
////    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//    cell.btn_minus.tag = indexPath.row;
//    cell.btn_minus.section = indexPath.section;
//    cell.btn_minus.row = indexPath.row;
//
//    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//    cell.btn_plus.tag = indexPath.row;
//    cell.btn_plus.section = indexPath.section;
//    cell.btn_plus.row = indexPath.row;
//    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];

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

        cell.btnRemoveItem.tag = indexPath.row;
        cell.btnRemoveItem.section = indexPath.section;
        cell.btnRemoveItem.row = indexPath.row;

        [cell.btnRemoveItem addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        cell.btnAddItem.tag = indexPath.row;
        cell.btnAddItem.section = indexPath.section;
        cell.btnAddItem.row = indexPath.row;
        [cell.btnAddItem addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

//    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    //    cell.btn_plus.tag = indexPath.row;
    //    cell.btn_plus.section = indexPath.section;
    //    cell.btn_plus.row = indexPath.row;
    //    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

//    cell.btn_minus.tag = indexPath.row;
//    cell.btn_minus.section = indexPath.section;
//    cell.btn_minus.row = indexPath.row;
//
//    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//    cell.btn_plus.tag = indexPath.row;
//    cell.btn_plus.section = indexPath.section;
//    cell.btn_plus.row = indexPath.row;
//    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (IBAction)MinusButtonClicked:(CustomUIButton *)sender {

    NSLog(@"Minus Button Clicked");

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

    //    NSLog(@"%@",_managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities);
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];

    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);
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
//            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
//            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
//            NSLog(@"Business P_ID :- %@",businessDetail.product_id);
//            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
//            NSLog(@"------------");

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
                    if ( ([dictionary valueForKey:@"selected_ProductID_array"] != nil) && ([dictionary valueForKey:@"selected_ProductID_array"] != [NSNull null]) )
                    [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];
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

//    [self setMyCartValue];
}

- (IBAction)PlusButtonClicked:(CustomUIButton *)sender {

    NSLog(@"%@", [self.FetchedRecordArray objectAtIndex:sender.row]);
//    TPBusinessDetail *BusinessDetail = [self.FetchedRecordArray objectAtIndex:sender.row];

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
//    [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//    [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//    [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//    [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//    [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//    [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];

//    SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];

//    if (BusinessDetail.arrOptions.count > 0) {
//        _dataSource = BusinessDetail.arrOptions;
//        selectedButton = sender;
//        selectedBusinessDetail = BusinessDetail;
//        multipleSelect.delegate = self;
//        multipleSelect.rowsCount = _dataSource.count;
//        [multipleSelect show];
//
//    }else{
        [self AddItemInCart:businessDetail CustomUIButton:sender];
//    }
    NSLog(@"Plus Button Clicked");
}


//- (void)AddItemInCart : (TPBusinessDetail *)BusinessDetail CustomUIButton:(CustomUIButton *)sender {
//
//    NSManagedObjectContext *context = [self managedObjectContext];
//    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
//    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
//    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
//    NSError *error = nil;
//    NSArray *results = [context executeFetchRequest:request error:&error];
//    if (error != nil) {
//
//    }
//    else {
//        BOOL itemFound = false;
//        for (NSManagedObject *obj in results) {
//            NSArray *keys = [[[obj entity] attributesByName] allKeys];
//            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
//            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
//            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
//            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
//            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
//            NSLog(@"------------");
//            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
//                itemFound = true;
//                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
//                [context deleteObject:obj];
//                ItemQty = ItemQty + 1;
//
//                NSManagedObject *failedBankInfo = [NSEntityDescription
//                                                   insertNewObjectForEntityForName:@"MyCartItem"
//                                                   inManagedObjectContext:context];
//                [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//                [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//                [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//                [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//                [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//                [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
//                NSError *error;
//                if (![context save:&error]) {
//                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//                }
//                break;
//            }
//        }
//        if(!itemFound){
//            NSManagedObject *failedBankInfo = [NSEntityDescription
//                                               insertNewObjectForEntityForName:@"MyCartItem"
//                                               inManagedObjectContext:context];
//            [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//            [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//            [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//            [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//            [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//            [failedBankInfo setValue:@"1" forKey:@"quantity"];
//            NSError *error;
//            if (![context save:&error]) {
//                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//            }
//        }
//    }
//
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.row inSection:sender.section];
//    [self refreshOrderData];
////    [self addToCartTapped:ip];
////    [self setMyCartValue];
//}

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
//            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
//            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
//            NSLog(@"Business P_ID :- %@",businessDetail.product_id);
//            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
//            NSLog(@"------------");
//            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]) {

                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];

                ItemQty = ItemQty + 1;

//                if([BusinessDetail.product_option isEqualToString:@""] || BusinessDetail.product_option == nil) {
//                    itemFound = true;
//                    NSManagedObject *failedBankInfo = [NSEntityDescription
//                                                       insertNewObjectForEntityForName:@"MyCartItem"
//                                                       inManagedObjectContext:context];
//
//                    [context deleteObject:obj];
//                    [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//                    [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//                    [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//                    [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//                    [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//                    [failedBankInfo setValue:BusinessDetail.product_option forKey:@"product_option"];
//                    [failedBankInfo setValue:@[BusinessDetail.product_order_id] forKey:@"product_order_id"];
//                    NSString * selected_ProductID_arrayString = [BusinessDetail.selected_ProductID_array componentsJoinedByString:@","];
//                    [failedBankInfo setValue:selected_ProductID_arrayString forKey:@"selected_ProductID_array"];
//
//                    [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
//
//                    NSError *error;
//
//                    if (![context save:&error]) {
//                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//                    }
//                    break;
//                }
//                else {

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
//                }
//            }
        }
    }
    [self refreshOrderData];
}

#pragma mark - Stripe Payment

//- (void)prepareToGetStripeToken
//{
//    STPCardParams *card = [[STPCardParams alloc] init];
//
//    NSString *cardNo = [defaultCardData valueForKey:@"number"];
//    NSString *expMonth = [defaultCardData valueForKey:@"expMonth"];
//    NSString *expYear = [defaultCardData valueForKey:@"expYear"];
//    NSString *cardCvc = [defaultCardData valueForKey:@"cvc"];
//    //    NSString *cardName = [self getNameFromCardNumber:card.number];
//
//
//    card.number = cardNo;
//    card.expMonth = [expMonth integerValue];
//    card.expYear = [expYear integerValue];
//    card.cvc = cardCvc;
//
//    [self createStripeTokenWithCard:card];
//}

//- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
//                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
//    [[STPAPIClient sharedClient] createTokenWithPayment:payment
//                                             completion:^(STPToken *token, NSError *error) {
//                                                 if (error) {
//                                                     completion(PKPaymentAuthorizationStatusFailure);
//                                                     return;
//                                                 }
//                                                 /*
//                                                  We'll implement this below in "Sending the token to your server".
//                                                  Notice that we're passing the completion block through.
//                                                  See the above comment in didAuthorizePayment to learn why.
//                                                  */
//                                                 [self createBackendChargeWithToken:token completion:completion];
//                                             }];
//}

//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                       didAuthorizePayment:(PKPayment *)payment
//                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
//    /*
//     We'll implement this method below in 'Creating a single-use token'.
//     Note that we've also been given a block that takes a
//     PKPaymentAuthorizationStatus. We'll call this function with either
//     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
//     after all of our asynchronous code is finished executing. This is how the
//     PKPaymentAuthorizationViewController knows when and how to update its UI.
//     */
//    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
//}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)createBackendChargeWithToken:(STPToken *)token
//                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
//    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
//    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
//
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data,
//                                               NSError *error) {
//                               if (error) {
//                                   completion(PKPaymentAuthorizationStatusFailure);
//                               } else {
//                                   completion(PKPaymentAuthorizationStatusSuccess);
//                               }
//                           }];
//}
//
//- (void) createStripeTokenWithCard : (STPCardParams *) card {
//
//    [MBProgressHUD showHUDAddedTo:self.view animated:true];
//
//    [[STPAPIClient sharedClient]createTokenWithCard:card completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
//        if (error) {
//            // Handle error
//            [self handleStripeError:error];
//        } else {
//            // Send off token to your server
//            [self postStripeToken:token];
//        }
//    }];
//}
//
//- (void)postStripeToken:(STPToken *)token
//{
//    NSLog(@"Payment - Received Stripe token %@", token.tokenId);
//    // convert dollars to cents
//    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithString:@"100"];
//
//    NSString *totalString = self.lblSubTotalPrice.text;
//
//    totalString = [totalString stringByReplacingOccurrencesOfString:@"$" withString:@""];
//
//    double doubleTotal = [totalString doubleValue];
//
//    NSDecimalNumber *decimalTotal = [[NSDecimalNumber alloc] initWithDouble:doubleTotal];
//
//    NSDecimalNumber *totalBillInCents= [decimalTotal decimalNumberByMultiplyingBy:cents];
//
//    NSString *amountInCentsString= [totalBillInCents stringValue];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:TapForAllPaymentServer]];
//    request.HTTPMethod = @"POST";
//    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&currency=usd&customerPaymentID=%@&customerPaymentProcessingEmail=%@", token.tokenId, amountInCentsString, billBusiness.paymentProcessingID, billBusiness.paymentProcessingEmail];
//    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
//
//    [MBProgressHUD showHUDAddedTo:self.view animated:true];
//
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:true];
//                               if (error) {
//
//                                   [UIAlertController showErrorAlert:@"Something went BAD - Clean the place or first born?"];
//                               }
//                               else {
//                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                                                   message:@"Paid - Now you're free to move about the country"
//                                                                                  delegate:self
//                                                                         cancelButtonTitle:@"OK"
//                                                                         otherButtonTitles:nil];
//                                   alert.tag = 5;
//                                   [alert show];
//
//                                   [self postOrderToServer];
//                               }
//                           }];
//}
//
//- (void)handleStripeError:(NSError *)error
//{
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
//                                                      message:[error localizedDescription]
//                                                     delegate:nil
//                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
//                                            otherButtonTitles:nil];
//    [message show];
//}

- (void) postOrderToServer {

    NSString *userID = [DataModel sharedDataModelManager].uuid;

    NSMutableArray *orderItemArray = [[NSMutableArray alloc]init];

    for (NSDictionary *product in self.orderItems) {

        NSString *product_id = [product valueForKey:@"product_id"];
        NSString *quantity = [product valueForKey:@"quantity"];
        NSString *options = @"";

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
        NSDictionary *product_orderDict = @{@"product_id":product_id,
                                            @"quantity":quantity,
                                            @"options":option_array,
                                            @"price":price,
                                            @"points":Points
                                            };
        [orderItemArray addObject:product_orderDict];
    }

    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];

//    billDollar = [[NSDecimalNumber alloc] initWithDouble:totalValue];

    NSInteger currentRedeemPoints = [self calculatePointsRedeem];
    NSString *cardNo = [defaultCardData valueForKey:@"number"];
    if ([self.notesText  isEqual:Note_default_text]) {
        self.notesText = @"";
    }

    NSDictionary *orderInfoDict= @{@"cmd":@"save_order",@"data":orderItemArray,@"consumer_id":userID,@"total":[NSString stringWithFormat:@"%f",totalValue],
                                   @"business_id":business_id,@"points_redeemed":[NSString stringWithFormat:@"%ld",(long)currentRedeemPoints],
                                   @"tip_amount":[NSNumber numberWithDouble:tipAmount], @"subtotal":[NSNumber numberWithDouble:cartTotal], @"tax_amount":[NSNumber numberWithDouble:0.0],
                                   @"cc_last_4_digits":[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)], @"note":self.notesText};
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [[APIUtility sharedInstance] orderToServer:orderInfoDict server:OrderServerURL completiedBlock:^(NSDictionary *response) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        if([response valueForKey:@"data"] != nil) {

            NSDictionary *dataDict = [response valueForKey:@"data"];

            NSMutableArray *fetchedOrders = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];

            NSMutableArray *fetchedOrderArray = [[NSMutableArray alloc] init];

            for (NSManagedObject *obj in fetchedOrders) {
                NSArray *keys = [[[obj entity] attributesByName] allKeys];
                NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];

                [fetchedOrderArray addObject:dictionary];
            }
            //            STPCardParams *card = [[STPCardParams alloc] init];


            NSString *cardName = [defaultCardData valueForKey:@"cardName"];

            NSString *cardNo = [defaultCardData valueForKey:@"number"];;

            NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];

            NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];

            NSString *expDate =  [NSString stringWithFormat:@"%@/%@",[defaultCardData valueForKey:@"expMonth"],[defaultCardData valueForKey:@"expYear"]];

            TPReceiptController *receiptVC = [[TPReceiptController alloc] initWithNibName:@"TPReceiptController" bundle:nil];
            receiptVC.fetchedRecordArray = fetchedOrderArray;
            receiptVC.order_id = [[dataDict valueForKey:@"order_id"] stringValue];
            receiptVC.reward_point = [[dataDict valueForKey:@"points"] stringValue];
            receiptVC.cardName = cardName;
            receiptVC.cardNumber = cardDisplayNumber;
            receiptVC.cardExpDate = expDate;
            NSInteger currentRedeemPoints = [self calculatePointsRedeem];
            receiptVC.redeem_point = [NSString stringWithFormat:@"%ld",(long)currentRedeemPoints];
            receiptVC.totalPaid = totalValue;
            receiptVC.tipAmount = tipAmount;
            receiptVC.subTotal = cartTotal;
            [self removeAllOrderFromCoreData];

            [self.navigationController pushViewController:receiptVC animated:YES];
        }
    }];
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
    [self paymentSummary];
    [self setNoTip];
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

//    self.lblSubtotalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
//    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
    cartTotal = TotalPrice;
    totalValue = cartTotal;
    self.lblSubtotalAmount.text = [NSString stringWithFormat:@"$%.2f",cartTotal];
    self.lblQty.text = [NSString stringWithFormat:@"%d",QTY];
//    self.lblTotalPrice.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
    billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",TotalPrice]];

    NSString *totalPointsStr = [NSString stringWithFormat:@"%ld",(long)cartTotal * PointsValueMultiplier];
//    self.lblTotalEarnedPoint.text = [NSString stringWithFormat:@"%@ Pts",total_available_points];
    self.lblEarnedPoint.text = [NSString stringWithFormat:@"%@ Pts",totalPointsStr];
    NSString *tip10String = [NSString stringWithFormat:@"$%.2f",cartTotal * .10];
    NSString *tip15String = [NSString stringWithFormat:@"$%.2f",cartTotal * .15];
    NSString *tip20String = [NSString stringWithFormat:@"$%.2f",cartTotal * .20];

    [self.btnTip10 setTitle:tip10String forState:UIControlStateNormal];
    [self.btnTip15 setTitle:tip15String forState:UIControlStateNormal];
    [self.btnTip20 setTitle:tip20String forState:UIControlStateNormal];
}

- (void) setPointsValue {
    NSLog(@"%@",[RewardDetailsModel sharedInstance].rewardDict);

    NSDictionary *rewards = [RewardDetailsModel sharedInstance].rewardDict;
//    NSLog(@"%@", [[rewards valueForKey:@"data"] valueForKey:@"total_available_points"]);
//    NSLog(@"%@", [[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"dollar_value"]);

    current_points_level = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"points"] integerValue];
    dollarValue = [[[[rewards valueForKey:@"data"] valueForKey:@"current_points_level"] valueForKey:@"dollar_value"] doubleValue];

//    NSString *str_current_points_level =  [NSString stringWithFormat:@"%ld", current_points_level];
//    [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:str_current_points_level];

    // text to let the user know how much points they have to redeem
    self.lblCurrentPoints.text = [NSString stringWithFormat:@"Use %ld points with $%.2f value?",(long)current_points_level,dollarValue];
}

- (void) setFinaleValueFromRedeem {
//    NSString *dollarString = self.lblDollarValue.text;

//    double subTotal = [self.lblSubTotalPrice.text doubleValue];
    if (cartTotal > dollarValue) {
        totalValue = totalValue - dollarValue;
        self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",totalValue];
    }
    else {
        //zzzzzz
        totalValue = tipAmount;
        self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f", totalValue];

    }
}

- (void) getDefaultCardData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults valueForKey:StripeDefaultCard] != nil) {
        defaultCardData = [defaults valueForKey:StripeDefaultCard];
        NSString *cardName = [defaultCardData valueForKey:@"cardName"];
        NSString *cardNo = [defaultCardData valueForKey:@"number"];

        NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
        NSString *defaultCardString = [NSString stringWithFormat:@"WITH %@ ENDING IN %@",cardName,trimmedString];
        self.lblDefaultCard.text = defaultCardString;
    }
    else {
        self.lblDefaultCard.text = @"";
    }
}

- (void) payWithDefaultCard {
    //            NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    //
    //
    //            NSMutableArray *orderItemArray = [[NSMutableArray alloc]init];
    //
    //            for (NSDictionary *product in self.orderItems) {
    //
    //                NSString *product_id = [product valueForKey:@"product_id"];
    //                NSString *quantity = [product valueForKey:@"quantity"];
    //                NSString *options = @"";
    //
    //                NSArray *option_array;
    //                if ([product valueForKey:@"selected_ProductID_array"] != [NSNull null]) {
    //                   options = [product valueForKey:@"selected_ProductID_array"];
    //                    option_array = [options componentsSeparatedByString:@","];
    //                }
    //                else {
    //                    option_array = [[NSArray alloc] init];
    //                }
    //
    //                NSString *price = [product valueForKey:@"price"];
    //                CGFloat rounded_down = floorf([price floatValue] * 100) / 100;
    //                NSString *Points = [NSString stringWithFormat:@"$%.2f",rounded_down];
    //                NSDictionary *product_orderDict = @{@"product_id":product_id,
    //                                                    @"quantity":quantity,
    //                                                    @"options":option_array,
    //                                                    @"price":price,
    //                                                    @"points":Points
    //                                                    };
    //                [orderItemArray addObject:product_orderDict];
    //            }
    //
    //            long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    //            NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    //
    //            NSDecimalNumber *billDollar = [[NSDecimalNumber alloc] initWithDouble:totalValue];
    //
    //            NSDictionary *orderInfoDict= @{@"cmd":@"save_order",@"data":orderItemArray,@"consumer_id":userID,@"total":[NSString stringWithFormat:@"%f",cartTotal],@"business_id":business_id,@"points_redeemed":[NSString stringWithFormat:@"%ld",redeemPoints]};
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

- (void) calculateTip : (double) tip  {

    if(cartTotal > 0) {
//        if(tip > 0) {
            tipAmount = cartTotal* (tip/100);
            totalValue = cartTotal + tipAmount;
//        }
//        else {
//            totalValue = cartTotal;
//        }

        if (flagRedeemPoint == true) {
            [self setFinaleValueFromRedeem];

            NSLog(@"%f",totalValue);
            redeemPoints = totalValue*PointsValueMultiplier;
        }
        else {
            redeemPoints = 0;
        }

        self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$%.2f",totalValue];
        billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",totalValue]];

//        NSInteger totalPoints = cartTotal * PointsValueMultiplier; //zzzz
//        NSString *total_available_points = [NSString stringWithFormat:@"%ld",(long)totalPoints];
//        self.lblTotalEarnedPoint.text = [NSString stringWithFormat:@"%@ Pts",total_available_points] ;
    }
}


- (float)calculateTotalPoints:(float)amount {
    return amount*PointsValueMultiplier;
}

- (NSInteger)calculatePointsRedeem {

    if (flagRedeemPoint) {
        return current_points_level;
    }
    else {
        return 0;
    }

}

- (double) getTotalPrice {
    NSString *totalString = self.lblSubTotalPrice.text;

    totalString = [totalString stringByReplacingOccurrencesOfString:@"$" withString:@""];

    double doubleTotal = [totalString doubleValue];
    return doubleTotal;
}

- (void) pointsRedeem:(NSNotification *) notification
{
    [self btnRedeemPointClicked:self];
    self.btnUsePoints.userInteractionEnabled = false;
}

- (void) openNotesPopupWithText : (NSString *) note {
    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"Add Note"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Pay", nil];
    alertTextView = [UITextView new];
    alertTextView.delegate = self;
    alertTextView.text = note;
    [testAlert setTag:100];
    [testAlert setValue: alertTextView forKey:@"accessoryView"];
    [testAlert show];
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    return true;
}

#pragma mark - Button Action

- (IBAction) backBUttonClicked: (id) sender;
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnPayButtonClicked:(id)sender {

    if ([DataModel sharedDataModelManager].uuid.length < 1) {
        [UIAlertController showErrorAlert:@"Please register on profile page.\nThen you can order."];
    }
    else {
//        if ([billInDollar compare:zero] ==  NSOrderedDescending) {
      if (_FetchedRecordArray.count >  0) {
        // send the order items to the server

            if (defaultCardData == nil) {
                BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:billBusiness];
                [self.navigationController pushViewController:payBillViewController animated:YES];
            }
            else {
//                STPCardParams *card = [[STPCardParams alloc] init];
//
//                card.number = [defaultCardData valueForKey:@"number"];
//                card.expMonth = [[defaultCardData valueForKey:@"expMonth"] integerValue];
//                card.expYear = [[defaultCardData valueForKey:@"expYear"]integerValue];
//                card.cvc = [defaultCardData valueForKey:@"cvc"];
//
//                [self createStripeTokenWithCard:card];
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
    }
}

- (IBAction)btnCancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnQuestionClicked:(id)sender {
    AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:billBusiness];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

- (IBAction)btnRedeemPointClicked:(id)sender {
    if(dollarValue > 0) {

      if (flagRedeemPoint == false) {

        if (dollarValue < cartTotal) {
//          NSString *message = [NSString stringWithFormat:@"You have %ld points, You need more %.f points to redeem",(long)current_points_level,((dollarValue*PointsValueMultiplier) - current_points_level)];
//          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
//         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//          }];
        } else {
          flagRedeemPoint = true;
          [self setFinaleValueFromRedeem]; //zzzzz
          redeemPoints = [self calculateTotalPoints:cartTotal];
          //redeemPoints = [self.lblTotalEarnedPoint.text integerValue];
        }
      }
      else {
        [self.btnRedeemPoint setImage:[UIImage imageNamed:@"ic_unchecked"] forState:UIControlStateNormal];
        flagRedeemPoint = false;
        self.lblSubTotalPrice.text =  [NSString stringWithFormat:@"$%.2f",cartTotal];
        redeemPoints = 0;
        if(currentTipValue > 0) {
          [self calculateTip:currentTipValue];
        }
        else {
          totalValue = cartTotal;
                    //                    self.lblTotalEarnedPoint.text = [NSString stringWithFormat:@"%ld Pts",(long)totalValue*PointsValueMultiplier] ;
        }
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
    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"Add Note"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Pay", nil];
    alertTextView = [UITextView new];
    alertTextView.text = Note_default_text;
    [testAlert setTag:100];
    [testAlert setValue: alertTextView forKey:@"accessoryView"];
    [testAlert show];
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            if ([alertTextView.text  isEqual:Note_default_text]) {
                self.notesText = @"";
            }
            self.notesText = alertTextView.text;
            [self postOrderToServer];

        }
        else if (buttonIndex == 2) {
            self.notesText = @"";
            [self postOrderToServer];
        }
    }
}

@end
