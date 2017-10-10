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

#import "ActionSheetPicker.h"
#import "IQKeyboardManager.h"
#define kOFFSET_FOR_KEYBOARD 80.0

@interface CartViewController (){
    NSArray *latestInfoArray;
    ActionSheetDatePicker *datePicker;
    NSMutableArray *orderItemArray;
    CGSize keyboardSize;
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
@property (assign) NSDate* pickupTime;
@end

@implementation CartViewController
@synthesize orderItems;
@synthesize flagRedeemPoint, originalPointsValue, originalNoPoints,dollarValueForEachPoints,
currenPointsLevel, redeemNoPoints, redeemPointsValue, hud,pickupTime;
@synthesize currency_symbol;
@synthesize currency_code;

NSString *Note_defaultText = @"Note for order(Optional)";
NSString *deliveryStartTime;
NSString *deliveryEndTime;
double cartSubTotal = 0;            // Subtotal Price
double deliveryAmount = 0.0;        // Delivery Amount

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CartViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"CartViewTableViewCell"];
    [self.tableView layoutIfNeeded];
    self.title = @"Order";
    
    self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;
    
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.txtNote.delegate = self;
    [self setPlaceHolderText];
    
    orderItems = [[NSMutableArray alloc] init];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.notesText = @"";
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblTitle.text = billBusiness.title;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    defaultCardData = [defaults valueForKey:StripeDefaultCard];
    
    [self setButtonBorder:self.btnScheduleForLater];
    [self setButtonBorder:self.btnPickUpFood];
    [self setButtonBorder:self.btnDeliverToMe];
    
    if([billBusiness.pickup_later isEqualToString:@"1"]){
        self.btnScheduleForLater.enabled = YES;
        self.lblSchedule.alpha = 1.0;
    }
    else
    {
        self.btnScheduleForLater.enabled = NO;
        self.lblSchedule.alpha = 0.7;
    }
    
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
    
    if([[CurrentBusiness sharedCurrentBusinessManager].business.business_delivery_id integerValue] > 0){
        // Get Delivery info API
        long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
        NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
        NSDictionary *inDataDict = @{@"business_id":business_id};
        NSLog(@"---parameter---%@",inDataDict);
        [[APIUtility sharedInstance] BusinessDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
            NSLog(@"----response : %@",response);
            self.btnDeliverToMe.enabled = YES;
            self.lblDeliver.alpha = 1.0;
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
        self.lblDeliver.alpha = 0.7;
    }
    
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    
    [self paymentSummary];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    defaultCardData = [defaults valueForKey:StripeDefaultCard];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self paymentSummary];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
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
    NSLog(@"%@",[self.currentObject valueForKey:@"item_note"]);
    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = [AppData calculateRoundPrice:val];
    NSUInteger len = [self.currency_symbol length];
    NSString *v = [NSString stringWithFormat:@"%.f",rounded_down];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%.2f",self.currency_symbol,rounded_down]];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont boldSystemFontOfSize:25.0]
                      range:NSMakeRange(len, v.length)];
    cell.lbl_Price.attributedText = attString;
    
    NSString *myString = [self.currentObject valueForKey:@"product_option"];
    NSString *menu_option;
    if ([myString length] > 0) {
        menu_option = [myString substringToIndex:[myString length] - 1];
    }
    
//    NSArray *myFinalString = [myString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
    
    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];
    
    NSLog(@"%@",[self.currentObject valueForKey:@"item_note"]);
    
    NSLog(@"%@",[self.currentObject valueForKey:@"product_option"]);
    
    if(![[self.currentObject valueForKey:@"item_note"] isEqualToString:@""] && [self.currentObject valueForKey:@"item_note"] != nil){
        if([[self.currentObject valueForKey:@"product_option"] isEqualToString:@""]){
            cell.lbl_Description.text = [NSString stringWithFormat:@"Note : %@",[self.currentObject valueForKey:@"item_note"]];
            cell.lbl_Notes.hidden = true;
        }
        else
        {
            cell.lbl_Description.text = menu_option;
            cell.lbl_Notes.text = [NSString stringWithFormat:@"Note : %@",[self.currentObject valueForKey:@"item_note"]];
            cell.lbl_Notes.hidden = false;
        }
    }
    else
    {
        cell.lbl_Description.text = menu_option;
        cell.lbl_Notes.hidden = true;
    }
    
    NSLog(@"note ---------------- %@",[self.currentObject valueForKey:@"item_note"]);
    cell.btnRemoveItem.tag = indexPath.row;
    cell.btnRemoveItem.section = indexPath.section;
    cell.btnRemoveItem.row = indexPath.row;
    
    [cell.btnRemoveItem addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnAddItem.tag = indexPath.row;
    cell.btnAddItem.section = indexPath.section;
    cell.btnAddItem.row = indexPath.row;
    
    [cell.btnAddItem addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.currentObject valueForKey:@"product_option"] isEqualToString:@""] && [self.currentObject valueForKey:@"item_note"] == nil){
        return 80.0;
    }
    else if([[self.currentObject valueForKey:@"product_option"] isEqualToString:@""] && [[self.currentObject valueForKey:@"item_note"] isEqualToString:@""]){
        return 80.0;
    }
    else{
        return UITableViewAutomaticDimension;
    }
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

#pragma mark - TextView Delegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.txtNote.textColor == [UIColor lightGrayColor]) {
        self.txtNote.text = @"";
        self.txtNote.textColor = [UIColor blackColor];
    }
    if ([textView isEqual:self.txtNote])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
    return YES;}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.txtNote.text.length == 0){
        self.txtNote.textColor = [UIColor lightGrayColor];
        self.txtNote.text = Note_defaultText;
        [self.txtNote resignFirstResponder];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if(self.txtNote.text.length == 0){
        self.txtNote.textColor = [UIColor lightGrayColor];
        self.txtNote.text = Note_defaultText;
        [self.txtNote resignFirstResponder];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
#pragma mark - User Functions
-(void)keyboardWillShow:(NSNotification *)notification {
    // Animate the current view out of the way
    
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    //Given size may not account for screen rotation

    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        
//        [self.view setFrame:CGRectMake(0,-115,rect.size.width,rect.size.height)];
        rect.origin.y -= 180;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
//        [self.view setFrame:CGRectMake(0,115,rect.size.width,rect.size.height)];
        rect.origin.y += 180;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    
    self.view.frame = rect;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [UIView commitAnimations];
}

- (void)setPlaceHolderText{
    self.txtNote.text = Note_defaultText;
    self.txtNote.textColor = [UIColor lightGrayColor];
}

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
    }
    cartSubTotal = TotalPrice;
    
    NSString *val = [NSString stringWithFormat:@"%.f",cartSubTotal];
    NSLog(@"%@",val);
     NSUInteger len = [self.currency_symbol length];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%.2f",self.currency_symbol,cartSubTotal]];
    [attString addAttribute:NSFontAttributeName
                  value:[UIFont boldSystemFontOfSize:25.0]
                  range:NSMakeRange(len, val.length)];
    self.lblSubtotalAmount.attributedText = attString;
    NSString *totalPointsStr = [NSString stringWithFormat:@"%ld",(long)cartSubTotal * PointsValueMultiplier];
    self.lblEarnPoints.text = [NSString stringWithFormat:@"EARN %@ Pts",totalPointsStr];
}

- (void)setButtonBorder:(UIButton *) buttonName
{
    [buttonName.layer setBorderWidth:1.0];
    [buttonName.layer setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:102.0/255.0 blue:0.0/255.0 alpha:1.0] CGColor]];
//    [buttonName.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [buttonName.layer setShadowOffset:CGSizeMake(2, 2)];
    [buttonName.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [buttonName.layer setShadowOpacity:0.3];
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
    businessDetail.note = [managedObj valueForKey:@"note"];
    NSLog(@"%@",[managedObj valueForKey:@"item_note"]);
    businessDetail.item_note = [managedObj valueForKey:@"item_note"];
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
                [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
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

- (IBAction)btnContinueClicked:(id)sender {
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
                //                [AppData sharedInstance].consumer_Delivery_Id = nil;
                [self.navigationController pushViewController:payBillViewController animated:YES];
            }
            else {
                if(![self.txtNote.text isEqualToString:@""] && ![self.txtNote.text isEqualToString:Note_defaultText])
                {
                    self.notesText = self.txtNote.text;
                }
                else
                {
                    self.notesText = @"";
                }
                
                OrderDetailViewController *TotalCartItemVC = [[OrderDetailViewController alloc] initWithNibName:@"OrderDetailViewController" bundle:nil];
                TotalCartItemVC.orderItemsOD = self.orderItems;
                TotalCartItemVC.subTotalOD = [NSString stringWithFormat:@"%.2f",cartSubTotal];
                TotalCartItemVC.earnPtsOD = self.lblEarnPoints.text;
                TotalCartItemVC.pd_noteTextOD = self.notesText;
                TotalCartItemVC.pickupTimeOD = self.pickupTime;
                if([AppData sharedInstance].consumer_Delivery_Id != nil){
                    TotalCartItemVC.deliveryamtOD = deliveryAmount;
                    TotalCartItemVC.delivery_startTimeOD = deliveryStartTime;
                    TotalCartItemVC.delivery_endTimeOD = deliveryEndTime;
                }
                
                long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
                NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
                NSDictionary *inDataDict = @{@"business_id":business_id};
                NSLog(@"%@",inDataDict);
                
                [[APIUtility sharedInstance] BusinessDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotDeliveryInfo" object:nil userInfo:response];
                    
                }];

                
                
                
                
                
                
                
                
                
                
                [self.navigationController pushViewController:TotalCartItemVC animated:YES];
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

- (IBAction)btnPickUpFoodClicked:(id)sender {
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
//                [AppData sharedInstance].consumer_Delivery_Id = nil;
                [self.navigationController pushViewController:payBillViewController animated:YES];
            }
            else {
                if(![self.txtNote.text isEqualToString:@""] && ![self.txtNote.text isEqualToString:Note_defaultText])
                {
                    self.notesText = self.txtNote.text;
                }
                else
                {
                    self.notesText = @"";
                }
                CartViewSecondScreenViewController *TotalCartItemVC = [[CartViewSecondScreenViewController alloc] initWithNibName:@"CartViewSecondScreenViewController" bundle:nil];
                TotalCartItemVC.orderItems = self.orderItems;
                TotalCartItemVC.subTotal = [NSString stringWithFormat:@"%.2f",cartSubTotal];
                TotalCartItemVC.earnPts = self.lblEarnPoints.text;
                TotalCartItemVC.noteText = self.notesText;
                TotalCartItemVC.pickupTime = self.pickupTime;
                if([AppData sharedInstance].consumer_Delivery_Id != nil){
                    TotalCartItemVC.deliveryamt = deliveryAmount;
                    TotalCartItemVC.delivery_startTime = deliveryStartTime;
                    TotalCartItemVC.delivery_endTime = deliveryEndTime;
                }
                [self.navigationController pushViewController:TotalCartItemVC animated:YES];
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

- (IBAction)btnDeliverToMeClicked:(id)sender {
    if(deliveryStartTime != nil && deliveryEndTime != nil)
    {
        if(orderItems.count > 0){
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
                NSDateFormatter* dateFormatter1 = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//                NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
//                dateFormatter1.dateFormat = @"HH:mm:ss";
                NSDate *startDate = [dateFormatter1 dateFromString:deliveryStartTime];
                NSDate *endDate = [dateFormatter1 dateFromString:deliveryEndTime];
                dateFormatter1.dateFormat = TIME12HOURFORMAT;
                NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
                [UIAlertController showErrorAlert:message];
            }
            else if(result == NSOrderedAscending)
            {
                if([date2 compare:date3] == NSOrderedDescending)
                {
                    NSDateFormatter* dateFormatter1 = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//                    NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
//                    dateFormatter1.dateFormat = @"HH:mm:ss";
                    NSDate *startDate = [dateFormatter1 dateFromString:deliveryStartTime];
                    NSDate *endDate = [dateFormatter1 dateFromString:deliveryEndTime];
                    dateFormatter1.dateFormat = TIME12HOURFORMAT;
                    NSString *message = [NSString stringWithFormat:@"Not available at this time.  Deliveries only between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
                    [UIAlertController showErrorAlert:message];
                }
                else
                {
//                    DeliveryViewController *delivaryInfoVC = [[DeliveryViewController alloc] initWithNibName:nil bundle:nil];
//                    delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
//                    [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
//                        NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
//                    }];
                }
            }
            else
            {
//                DeliveryViewController *delivaryInfoVC = [[DeliveryViewController alloc] initWithNibName:nil bundle:nil];
//                delivaryInfoVC.latestDeliveryInfo = latestInfoArray;
//                [self.navigationController presentViewController:delivaryInfoVC animated:YES completion:^{
//                    NSLog(@"%@",[AppData sharedInstance].consumer_Delivery_Location);
//                }];
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
    else
    {
        [AppData showAlert:@"" message:@"Delivery Time is Closed Now." buttonTitle:@"OK" viewClass:self];
    }
}

- (IBAction)btnScheduleForLaterClicked:(id)sender {
    
    [self.view endEditing:true];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"hh:mm a"];
    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:now doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSLog(@"%@",selectedDate);
        self.pickupTime = selectedDate;
        self.lblPickUpAt.text = [NSString stringWithFormat:@"PICK-UP AT %@",[formatter stringFromDate:selectedDate]];
        self.viewBottomConstraint.constant = 50.0;
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:sender];
    [datePicker showActionSheetPicker];
    
}
- (IBAction)btnPickUpAtContinueClicked:(id)sender {
    self.viewBottomConstraint.constant = 0.0;
}

- (IBAction)btnAddNoteClicked:(id)sender {
    if([self.txtNote.text isEqualToString:@""]){
        [AppData showAlert:@"Error" message:@"Please enter notes." buttonTitle:@"Ok" viewClass:self];
    }
    else{
        self.notesText = self.txtNote.text;
    }
}
@end
