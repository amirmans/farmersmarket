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
#import "CurrentBusiness.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "TPBusinessDetail.h"
#import "SHMultipleSelect.h"

@interface TotalCartItemController ()

@property (strong, nonatomic) NSMutableArray *orderItems;

@end

@implementation TotalCartItemController

@synthesize itemCartTableView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize orderItems;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Orders";
    orderItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.itemCartTableView.delegate = self;
    self.itemCartTableView.dataSource = self;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);
    
    zero = [NSDecimalNumber zero];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.itemCartTableView.contentInset = UIEdgeInsetsMake(self.itemCartTableView.frame.origin.x, self.itemCartTableView.frame.origin.y, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.itemCartTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self paymentSummary];
}

- (void)didReceiveMemoryWarning {
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
    static NSString *simpleTableIdentifier = @"TotalCartItemCell";
    TotalCartItemCell *cell = (TotalCartItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    _currentObject = _FetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
    
    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = floorf(val * 100) / 100;
    cell.lbl_Price.text = [NSString stringWithFormat:@"$%.2f",rounded_down];
    
    cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];

    cell.btn_minus.tag = indexPath.row;
    cell.btn_minus.section = indexPath.section;
    cell.btn_minus.row = indexPath.row;
    
    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    cell.btn_plus.tag = indexPath.row;
//    cell.btn_plus.section = indexPath.section;
//    cell.btn_plus.row = indexPath.row;
//    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btn_minus.tag = indexPath.row;
    cell.btn_minus.section = indexPath.section;
    cell.btn_minus.row = indexPath.row;
    
    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btn_plus.tag = indexPath.row;
    cell.btn_plus.section = indexPath.section;
    cell.btn_plus.row = indexPath.row;
    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 79;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)MinusButtonClicked:(CustomUIButton *)sender {
    
    NSLog(@"Minus Button Clicked");
    
    NSManagedObject *managedObj = [self.FetchedRecordArray objectAtIndex:sender.row];
    
    TPBusinessDetail *BusinessDetail = [[TPBusinessDetail alloc] init];
    BusinessDetail.price = [managedObj valueForKey:@"price"];
    BusinessDetail.short_description = [managedObj valueForKey:@"product_descrption"];
    BusinessDetail.product_id = [managedObj valueForKey:@"product_id"];
    BusinessDetail.pictures = [managedObj valueForKey:@"product_imageurg"];
    BusinessDetail.name = [managedObj valueForKey:@"productname"];
    BusinessDetail.quantity = [[managedObj valueForKey:@"quantity"] integerValue];
    
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
            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
            NSLog(@"------------");
            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [context deleteObject:obj];
                ItemQty = ItemQty - 1;
                if(ItemQty > 0){
                    NSManagedObject *failedBankInfo = [NSEntityDescription
                                                       insertNewObjectForEntityForName:@"MyCartItem"
                                                       inManagedObjectContext:context];
                    [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
                    [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
                    [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
                    [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
                    [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
                    [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                    NSError *error;
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
    
    TPBusinessDetail *BusinessDetail = [[TPBusinessDetail alloc] init];
    BusinessDetail.price = [managedObj valueForKey:@"price"];
    BusinessDetail.short_description = [managedObj valueForKey:@"product_descrption"];
    BusinessDetail.product_id = [managedObj valueForKey:@"product_id"];
    BusinessDetail.pictures = [managedObj valueForKey:@"product_imageurg"];
    BusinessDetail.name = [managedObj valueForKey:@"productname"];
    BusinessDetail.quantity = [[managedObj valueForKey:@"quantity"] integerValue];
    
//    [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//    [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//    [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//    [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//    [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//    [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];

    
    
    
    SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
    
//    if (BusinessDetail.arrOptions.count > 0) {
//        _dataSource = BusinessDetail.arrOptions;
//        selectedButton = sender;
//        selectedBusinessDetail = BusinessDetail;
//        multipleSelect.delegate = self;
//        multipleSelect.rowsCount = _dataSource.count;
//        [multipleSelect show];
//        
//    }else{
        [self AddItemInCart:BusinessDetail CustomUIButton:sender];
//    }
    
    
    NSLog(@"Plus Button Clicked");
}


- (void)AddItemInCart : (TPBusinessDetail *)BusinessDetail CustomUIButton:(CustomUIButton *)sender {
    
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
            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
            NSLog(@"------------");
            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [context deleteObject:obj];
                ItemQty = ItemQty + 1;
                
                NSManagedObject *failedBankInfo = [NSEntityDescription
                                                   insertNewObjectForEntityForName:@"MyCartItem"
                                                   inManagedObjectContext:context];
                [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
                [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
                [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
                [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
                [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
                [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                break;
            }
        }
        
        if(!itemFound){
            NSManagedObject *failedBankInfo = [NSEntityDescription
                                               insertNewObjectForEntityForName:@"MyCartItem"
                                               inManagedObjectContext:context];
            [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
            [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
            [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
            [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
            [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
            [failedBankInfo setValue:@"1" forKey:@"quantity"];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.row inSection:sender.section];
    [self refreshOrderData];
//    [self addToCartTapped:ip];
//    [self setMyCartValue];
}


#pragma mark - Custom Methods

- (void) refreshOrderData{
    [self.FetchedRecordArray removeAllObjects];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    [self.itemCartTableView reloadData];
    [self paymentSummary];
}

// set total oder and Price
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
        CGFloat rounded_down = floorf(val * 100) / 100;
        TotalPrice += rounded_down;
        [orderItems addObject:dictionary];
    }
    
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$ %.2f",TotalPrice];
    self.lblQty.text = [NSString stringWithFormat:@"%d",QTY];
    self.lblTotalPrice.text = [NSString stringWithFormat:@"$ %.2f",TotalPrice];
    billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",TotalPrice]];
}

#pragma mark - Button Action

- (IBAction) backBUttonClicked: (id) sender;
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnPayButtonClicked:(id)sender {
    
    if ([DataModel sharedDataModelManager].nickname.length < 1) {
        [UIAlertController showErrorAlert:@"You don't have a nickname yet.  Please go to the profile page and get one."];
    }
    else {
        if ([billInDollar compare:zero] ==  NSOrderedDescending) {
            // send the order items to the server
            
//            NSLog(@"%ld",[DataModel sharedDataModelManager].userID);
            NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
            long businessID = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
            NSNumber *business_id = [NSNumber numberWithLongLong:businessID];
            
            NSDictionary *orderInfoDict = [[NSDictionary alloc]initWithObjectsAndKeys:@"save_order",@"cmd", self.orderItems, @"data",userID, @"consumer_id", billInDollar, @"total", business_id, @"business_id", nil];
            [[APIUtility sharedInstance] orderToServer:orderInfoDict server:OrderServerURL completiedBlock:^(NSDictionary *response) {
                NSLog(@"asd");
            }];
            
            BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:billInDollar forBusiness:billBusiness];
            [self.navigationController pushViewController:payBillViewController animated:YES];
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
@end
