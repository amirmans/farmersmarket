//
//  OrderDetailViewController.m
//  TapForAll
//
//  Created by Trushal on 4/7/17.
//
//

#import "PickupDeliveryOptionsViewController.h"
#import "APIUtility.h"
//#import "AppData.h"
#import "ActionSheetPicker.h"
#import "NYAlertViewController.h"
#import "IQKeyboardManager.h"
#define kOFFSET_FOR_KEYBOARD 80.0


@interface PickupDeliveryOptionsViewController ()<UITextViewDelegate>{
    NSArray *deliveryLocation;
    ActionSheetDatePicker *datePicker;
    NSString *deliveryStartTime;
    NSString *deliveryEndTime;
    NSNumber *deliveryTimeInterval;
    NSNumber *deliveryLeadTime;
    NSNumber *tableMinNo;
    NSNumber *tableMaxNo;
    NSMutableArray *tableNoArr;
    NSDateFormatter *formatter2;
    NSTimeZone *tz;
    NSString *uploadTime;
    NSString *stringUId;
    CGSize keyboardSize;
    Business *biz;
}
@property (strong, nonatomic) NSString *notesTextOrderDetail;
@property (strong, nonatomic) NSDateFormatter *formatter;
//@property (assign) BOOL flagRedeemPointOD;
//@property (assign) double originalPointsValueOD;
//@property (assign) NSInteger originalNoPointsOD;
//@property (assign) double dollarValueForEachPointsOD;  //detemined by the points level's ceiling
//@property (assign) NSInteger currenPointsLevelOD;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimeZone *tz;
//@property (assign) NSInteger redeemNoPointsOD;  // number of points being redeemed
//@property (assign) double  redeemPointsValueOD;// value for the points that we are redeeming
@property(nonatomic, strong) NSString *placeHolderForText;


@end

@implementation PickupDeliveryOptionsViewController
@synthesize orderItemsOD;
@synthesize /*flagRedeemPointOD, originalPointsValueOD, originalNoPointsOD, dollarValueForEachPointsOD,currenPointsLevelOD,redeemNoPointsOD, redeemPointsValueOD,*/ hud,pickupTimeOD, formatter, tz, placeHolderForText;

NSNumber *delivery_time_intervalOD;
NSDate *setMinPickerTimeOD;


- (void)triggerAction:(NSNotification *)notification {
    NSDictionary *response = notification.userInfo;
    if([[response valueForKey:@"status"] integerValue] >= 0)
    {
        if(((NSArray *)[response valueForKey:@"table"]).count > 0) {
            
            NSArray *tableDict = [response valueForKey:@"table"];
            self.lblBusinessNote.text = [tableDict valueForKey:@"message_to_consumers"];
            tableMinNo = [tableDict valueForKey:@"table_no_min"];
            tableMaxNo = [tableDict valueForKey:@"table_no_max"];
            for (int i = [tableMinNo intValue]; i <= [tableMaxNo intValue]; i++) {
                [tableNoArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        if(((NSArray *)[response valueForKey:@"location_info"]).count > 0) {
            NSArray *locationDict = [response valueForKey:@"location_info"];
            self.lblBusinessNote.text = [locationDict valueForKey:@"message_to_consumers"];
//            NSLog(@"%@",tableDict);
            deliveryStartTime = [locationDict valueForKey:@"delivery_start_time"];
            deliveryEndTime = [locationDict valueForKey:@"delivery_end_time"];
            deliveryTimeInterval = [locationDict valueForKey:@"delivery_time_interval_in_minutes"];
            deliveryLeadTime = [locationDict valueForKey:@"delivery_lead_time_in_minutes"];
            
            self.locationArray = [[locationDict valueForKey:@"locations"] mutableCopy];

            for (int i = 0 ; i < self.locationArray.count ; i++) {
                [self.locationNameArray addObject:[self.locationArray[i] objectForKey:@"location_name"]];
            }
//            NSLog(@"%@",tableMinNo);
//            NSLog(@"%@",tableMaxNo);

//            self.btnCounterPickupTime.enabled = YES;
//            if(biz.pickup_counter_later == 0){
//                self.btnCounterPickupTime.enabled = NO;
//            }
//            else{
//                self.btnCounterPickupTime.enabled = YES;
//            }
        }
    }
    else{
        [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
    }

    [HUD hideAnimated:YES];

}

#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Carry out/Delivery";
    placeHolderForText = @"Instructions...";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tableNoArr = [[NSMutableArray alloc] init];

    biz = [CurrentBusiness sharedCurrentBusinessManager].business;
    tz= [NSTimeZone localTimeZone];
    formatter = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
    [formatter setTimeZone:tz];

    formatter2 = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
    [formatter2 setTimeZone:tz];

    self.locationArray = [[NSMutableArray alloc]init];
    self.locationNameArray = [[NSMutableArray alloc]init];

    long uid = [[DataModel sharedDataModelManager] userID];
    if (uid <= 0) {
        [UIAlertController showErrorAlert:@"Please register on profile page to set your favorites. \nYou can order them next time around."];
        return;
    }

    stringUId = [NSString stringWithFormat:@"%ld", uid];

    self.btnOk.enabled = false;
    //---------- Buisness delivery info ---------//
    self.btnCounterPickupTime.enabled = NO;

    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    NSDictionary *inDataDict = @{@"business_id":business_id};
    NSLog(@"%@",inDataDict);

    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(triggerAction:) name:@"GotDeliveryInfo" object:nil];

    [HUD showAnimated:YES];

    //---------- Set Button enable/disable ------//
//    Business *bis = [CurrentBusiness sharedCurrentBusinessManager].business;
    NSInteger  counterVal = [biz.pickup_counter_charge intValue];
    NSInteger  tableVal = [biz.delivery_table_charge intValue];
    NSInteger  locationVal = [biz.delivery_location_charge intValue];
    NSInteger  parkingVal = [biz.pickup_location_charge intValue];
//    NSString *openingTime = bis.opening_time;
//    NSString *closingTime = bis.closing_time;
    self.btnCounter.enabled = NO;
    self.viewCounter.hidden = YES;
    self.viewTable.hidden = YES;
    self.viewDesignationLocation.hidden = YES;
    self.viewParking.hidden = YES;
    
    if(counterVal != -1){
        self.btnCounter.enabled = YES;
        self.viewCounter.hidden = NO;
        
        NSDate *startTime = [self getPDStartTime:PickUpAtCounter];
        NSString *startTimeStr = [formatter2 stringFromDate:startTime];
        [self.btnDesignationLocationPickUp setTitle:startTimeStr forState:UIControlStateNormal];
        [self.btnCounterPickupTime setTitle:startTimeStr forState:UIControlStateNormal];
        self.btnOk.enabled = true;
    }
    if(parkingVal != -1){
        self.btnParking.enabled = YES;
    }


    if(tableVal != -1){
        self.btnTable.enabled = YES;

    }
    if(locationVal != -1){
        self.btnDesignatedLocation.enabled = YES;
        
        NSDate *startTime = [self getPDStartTime:DeliveryToLocation];
        NSString *startTimeStr = [formatter2 stringFromDate:startTime];
        [self.btnDesignationLocationPickUp setTitle:startTimeStr forState:UIControlStateNormal];
    }

    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setTimeZone:tz];
    [displayFormatter setDateFormat:@"h:mm a"];

//    NSLog(@"Local timezone is: %@",  tzName);

//    NSDate *dateOpeningTime = [formatter dateFromString:openingTime];
//    NSDate *dateClosingTime = [formatter dateFromString:closingTime];
//    NSDate *now = [NSDate date];
//    NSDate *dateNow = [now dateByAddingTimeInterval:[biz.process_lead_time integerValue]*60];
//    NSString *nowString =  [formatter stringFromDate:now];
//    NSDate *dateNow = [formatter dateFromString:nowString];


//    NSDate *dateFromString = [dateFormatter dateFromString:openingTime];
//   [ddateFormatter setDateFormat:TIME12HOURFORMAT];
//    openingTime = [dateFormatter stringFromDate:dateFromString];

//    NSComparisonResult result = [dateOpeningTime compare:dateNow];
//
//    if(result == NSOrderedDescending) // opening time is in future.  Display opening time
//    {
//        NSString *titleTime = [displayFormatter stringFromDate:dateOpeningTime];
//        [self.btnParkingPickUp setTitle:titleTime forState:UIControlStateNormal];
//        [self.btnDesignationLocationPickUp setTitle:titleTime forState:UIControlStateNormal];
////        NSLog(@"%ld",(long)biz.pickup_counter_later);
//
//        [self.btnCounterPickupTime setTitle:titleTime forState:UIControlStateNormal];
//        self.btnOk.enabled = true;
//    }
//    else if(result == NSOrderedAscending) // "now" is in future of opening time  - display now
//    {
//        NSComparisonResult result2 = [dateNow compare:dateClosingTime];
//        if(result2 == NSOrderedAscending)
//        {
//            if([dateNow compare:dateClosingTime] == NSOrderedDescending) // Closing time in is in future of
//            {
//                NSString *titleTime = [displayFormatter stringFromDate:dateOpeningTime];
//                [self.btnParkingPickUp setTitle:titleTime forState:UIControlStateNormal];
//                [self.btnDesignationLocationPickUp setTitle:titleTime forState:UIControlStateNormal];
//                NSLog(@"%ld",(long)biz.pickup_counter_later);
//                [self.btnCounterPickupTime setTitle:titleTime forState:UIControlStateNormal];
//                self.btnOk.enabled = true;
//            }
//            else {
//                if (bis.pickup_later) {
////                   NSDate *newDate = [now dateByAddingTimeInterval:60 * [deliveryTimeInterval intValue]]; // Add XXX seconds to *now
////                    NSString *currentTime = [formatter stringFromDate:newDate];
////                    dateNow = newDate;
//                }
//                else {
//
//                }
//
//                NSString *titleTime = [displayFormatter stringFromDate:dateOpeningTime];
//
//                [self.btnParkingPickUp setTitle:titleTime forState:UIControlStateNormal];
//                [self.btnDesignationLocationPickUp setTitle:titleTime forState:UIControlStateNormal];
//                NSLog(@"%ld",(long)biz.pickup_counter_later);
//                [self.btnCounterPickupTime setTitle:titleTime forState:UIControlStateNormal];
//                self.btnOk.enabled = true;
//            }
//        }
//        else if(result2 == NSOrderedDescending)
//        {
//
////            NSString *currentTime = [formatter stringFromDate:openingTime];
//            NSString *titleTime = [displayFormatter stringFromDate:dateOpeningTime];
//            [self.btnParkingPickUp setTitle:titleTime forState:UIControlStateNormal];
//            [self.btnDesignationLocationPickUp setTitle:titleTime forState:UIControlStateNormal];
////            NSLog(@"%ld",(long)biz.pickup_counter_later);
//            [self.btnCounterPickupTime setTitle:titleTime forState:UIControlStateNormal];
//            self.btnOk.enabled = true;
//        }
//    }
//    else
//    {
//        NSLog(@"date1 is equal to date2");
//        NSString *titleTime = [displayFormatter stringFromDate:dateOpeningTime];
//
//        [self.btnParkingPickUp setTitle:titleTime forState:UIControlStateNormal];
//        [self.btnDesignationLocationPickUp setTitle:titleTime forState:UIControlStateNormal];
//        NSLog(@"%ld",(long)biz.pickup_counter_later);
//        [self.btnCounterPickupTime setTitle:titleTime forState:UIControlStateNormal];
//        self.btnOk.enabled = true;
//    }


//    deliveryLocation = self.locationNameArray;
//    [_btnLocation setTitle:deliveryLocation[0] forState:UIControlStateNormal];

    _btnCounter.selected = YES;
    [self setButtonBorder];
    self.txtNotes.delegate = self;
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblHotelName.text = billBusiness.title;

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
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

#pragma mark - Textview Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:placeHolderForText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeHolderForText;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - User Functions
-(void)keyboardWillShow:(NSNotification *)notification {
    // Animate the current view out of the way
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

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
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
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
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
//    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        rect.origin.y -= keyboardSize.height;
//        rect.size.height += kOFFSET_FOR_KEYBOARD;
        rect.origin.y -= 200;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
//        rect.origin.y += keyboardSize.height;
//        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        rect.origin.y += 200;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;

    [UIView commitAnimations];
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

- (void)showAlertForNavigate:(NSString *)Title :(NSString *)Message{

    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];

    // Set a title and message
    alertViewController.title = NSLocalizedString(Title, nil);
    alertViewController.message = NSLocalizedString(Message, nil);

    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;

    alertViewController.titleColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
    alertViewController.buttonColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
    alertViewController.cancelButtonColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];

    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];

    alertViewController.swipeDismissalGestureEnabled = NO;
    alertViewController.backgroundTapDismissalGestureEnabled = NO;

    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              PaymentSummaryViewController *TotalCartItemVC = [[PaymentSummaryViewController alloc] initWithNibName:nil bundle:nil];
                                                              TotalCartItemVC.orderItems = self.orderItemsOD;
                                                              TotalCartItemVC.subTotal = [NSString stringWithFormat:@"%@",self.subTotalOD];
                                                              TotalCartItemVC.earnPts = self.earnPtsOD;
                                                              TotalCartItemVC.noteText = self.noteTextOD;
                                                              TotalCartItemVC.pd_noteText = self.pd_noteTextOD;
                                                              TotalCartItemVC.pickupTime = self.pickupTimeOD;
                                                              if([AppData sharedInstance].consumer_Delivery_Id != nil){
                                                                  TotalCartItemVC.deliveryamt = self.deliveryamtOD;
                                                                  TotalCartItemVC.delivery_startTime = self.delivery_startTimeOD;
                                                                  TotalCartItemVC.delivery_endTime = self.delivery_endTimeOD;
                                                              }
                                                              if([self.btnCounter isSelected]){
                                                                  TotalCartItemVC.selectedButtonNumber = 1;
                                                              }
                                                              else if ([self.btnTable isSelected]){
                                                                  TotalCartItemVC.selectedButtonNumber = 2;
                                                              }
                                                              else if ([self.btnDesignatedLocation isSelected]){
                                                                  TotalCartItemVC.selectedButtonNumber = 3;
                                                              }
                                                              else if ([self.btnParking isSelected]){
                                                                  TotalCartItemVC.selectedButtonNumber = 4;
                                                              }

                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                              [self.navigationController pushViewController:TotalCartItemVC animated:YES];
                                                          }]];

    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];

    // Present the alert view controller
    [self presentViewController:alertViewController animated:YES completion:nil];
}


-(void)setButtonBorder
{
    [[_btnParkingPickUp layer] setBorderWidth:1.0f];
    [[_btnParkingPickUp layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_btnCounterPickupTime layer] setBorderWidth:1.0f];
    [[_btnCounterPickupTime layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_btnDesignationLocationPickUp layer] setBorderWidth:1.0f];
    [[_btnDesignationLocationPickUp layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_btnLocation layer] setBorderWidth:1.0f];
    [[_btnLocation layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_tableDropDown layer] setBorderWidth:1.0f];
    [[_tableDropDown layer] setBorderColor:[UIColor blackColor].CGColor];
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{

//    NSDate *time = selectedTime;
//    NSDate *date1= [formatter dateFromString:deliveryStartTime];
//    NSDate *date2 = [formatter dateFromString:deliveryEndTime];
//    NSComparisonResult result = [time compare:date1];
//    NSLog(@"%ld",(long)result);
//    if ([setMinPickerTimeOD compare:time] == NSOrderedDescending ||
//            [date2 compare:time] == NSOrderedAscending)
//    {
//        if([setMinPickerTimeOD compare:time] == NSOrderedDescending)
//        {
//            if([element tag] == 1){
//                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//
//            }
//            else if([element tag] == 2){
//                [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//            }
//            else{
//                [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//            }
////            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//
//        }
//        else
//        {
//            if([element tag] == 1){
//                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//            }
//            else if([element tag] == 2){
//                [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//            }
//            else{
//                [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//            }
////            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
//
//        }
//    }
//    else
    {
        if([element tag] == 1){
            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }
        else if([element tag] == 2) {
            [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }
        else {
            [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }

//        [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];

    }
    NSLog(@"ActionSheetDatePicker selected time was: %@",selectedTime);
    [AppData sharedInstance].consumerPDTimeChosen = [formatter2 stringFromDate:selectedTime];

}


#pragma mark - Button Actions

- (IBAction) backBUttonClicked: (id) sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnCounterClicked:(id)sender {
    if ([sender isSelected]) {
//        [sender setSelected:NO];
//        _viewCounter.hidden = YES;
    } else
    {
        [sender setSelected:YES];
        [self.btnTable setSelected:NO];
        [self.btnDesignatedLocation setSelected:NO];
        [self.btnParking setSelected:NO];
        _viewCounter.hidden = NO;
        _viewTable.hidden = YES;
        _viewDesignationLocation.hidden = YES;
        _viewParking.hidden = YES;
    }
}

- (IBAction)btnTableClicked:(id)sender {
    if ([sender isSelected]) {
//        [sender setSelected:NO];
//        _viewTable.hidden = YES;
    } else
    {
        [sender setSelected:YES];
        [self.btnCounter setSelected:NO];
        [self.btnDesignatedLocation setSelected:NO];
        [self.btnParking setSelected:NO];
        _viewTable.hidden = NO;
        _viewCounter.hidden = YES;
        _viewDesignationLocation.hidden = YES;
        _viewParking.hidden = YES;

    }
}

- (IBAction)btnDesignatedLocationClicked:(id)sender {
    if ([sender isSelected]) {
//        [sender setSelected:NO];
//        _viewDesignationLocation.hidden = YES;
    } else {
        [sender setSelected:YES];
        [self.btnTable setSelected:NO];
        [self.btnCounter setSelected:NO];
        [self.btnParking setSelected:NO];
        _viewDesignationLocation.hidden = NO;
        _viewCounter.hidden = YES;
        _viewTable.hidden = YES;
        _viewParking.hidden = YES;
    }
}

- (IBAction)btnParkingClicked:(id)sender {
    if ([sender isSelected]) {
//        [sender setSelected:NO];
//        _viewParking.hidden = YES;
    } else {
        [sender setSelected:YES];
        [self.btnTable setSelected:NO];
        [self.btnDesignatedLocation setSelected:NO];
        [self.btnCounter setSelected:NO];
        _viewParking.hidden = NO;
        _viewCounter.hidden = YES;
        _viewTable.hidden = YES;
        _viewDesignationLocation.hidden = YES;
        
        NSDate *startTime = [self getPDStartTime:PickUpAtLocation];
        NSString *startTimeStr = [formatter2 stringFromDate:startTime];
        [self.btnParkingPickUp setTitle:startTimeStr forState:UIControlStateNormal];
    }
}

- (IBAction)btnPickupTimeDL:(id)sender {

}

- (IBAction)btnLocationClicked:(id)sender {

    [ActionSheetStringPicker showPickerWithTitle:@"Select a location"
                                            rows:self.locationNameArray
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                   picker, (long)selectedIndex, selectedValue);
                                           [AppData sharedInstance].consumer_Delivery_Location_Id = [self.locationArray[selectedIndex] objectForKey:@"delivery_locations_id"];
                                           [self.btnLocation setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];

}

- (NSDate *)getPDStartTime:(int)pd_type {
    BOOL businessOpen = false;
    if ([[APIUtility sharedInstance] isBusinessOpen:biz.opening_time CloseTime:biz.closing_time ]) {
        businessOpen = true;
    }
    NSDate *startTime;
    switch (pd_type) {
        case PickUpAtCounter:
            if (businessOpen) {
                startTime = [[NSDate date] dateByAddingTimeInterval:[biz.process_lead_time integerValue]*60];
            } else {
                startTime = [formatter dateFromString:biz.opening_time];
                startTime = [startTime dateByAddingTimeInterval:[biz.process_lead_time integerValue]*60];
            }
            break;
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            
            break;
        case DeliveryToLocation:
            if (businessOpen) {
                startTime = [[NSDate date] dateByAddingTimeInterval:[deliveryLeadTime integerValue]*60];
            }
            else {
                startTime = [formatter dateFromString:deliveryStartTime];
                startTime = [startTime dateByAddingTimeInterval:60*[deliveryLeadTime integerValue]];
            }
            
            break;
        default:
            
            break;
    }
    return startTime;
}



- (NSDate *)getPDEndTime:(int)pd_type {
    NSDate* endDate;
    switch (pd_type) {
        case PickUpAtCounter:
            
            break;
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            
            break;
        case DeliveryToLocation:
           endDate = [formatter dateFromString:deliveryEndTime];
            
            break;
        default:
            
            break;
    }
    
    return endDate;
}

- (int)getPDLeadTimeInMinute:(int)pd_type {
    int leadTime = 10;
    
    switch (pd_type) {
        case PickUpAtCounter:
            leadTime = [biz.process_lead_time intValue];
            break;
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            leadTime = 1;
            break;
        case DeliveryToLocation:
            leadTime = [deliveryLeadTime intValue];
            
            break;
        default:
            leadTime = 0;
            break;
    }
    
    
    return leadTime;
}

- (int)getPDIntervalInMinute:(int)pd_type {
    int intervalTime = 1;
    
    return intervalTime;
}

- (IBAction)btnCounterPickUpClicked:(id)sender {

    NSDate *date2= [self getPDStartTime:PickUpAtCounter];
    NSDate *date1 = [NSDate date]; //[formatter dateFromString:biz.opening_time];

    NSDate *date3= [formatter dateFromString:biz.closing_time];

    NSComparisonResult result = [date1 compare:date2];

    if(result == NSOrderedDescending)
    {
        NSLog(@"date1 is later than date2");
        setMinPickerTimeOD = date1;
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [self getPDIntervalInMinute:PickUpAtCounter];
        [datePicker showActionSheetPicker];

//        NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//        [UIAlertController showErrorAlert:message];
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"date2 is later than date1");

        NSComparisonResult result2 = [date2 compare:date3];
        if(result2 == NSOrderedAscending)
        {
            NSLog(@"date3 is later than date2, endTime is big than now time");
            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];

            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTimeOD];
            NSInteger minute = [components minute];
            NSLog(@"%ld",(long)minute);
            NSLog(@"%ld",(long)minute % [deliveryTimeInterval integerValue]);
            if(minute % [deliveryTimeInterval integerValue] == 0)
            {
                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];

                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                [datePicker showActionSheetPicker];
            }
            else
            {
                if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                {
                    setMinPickerTimeOD = date1;
                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
//                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//                    [UIAlertController showErrorAlert:message];

                }
                else
                {
                    NSNumber *delieverTime = deliveryTimeInterval;
                    delieverTime = @([delieverTime integerValue] * 2);
                    setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                    {
                        NSNumber *delieverTime = deliveryTimeInterval;
                        delieverTime = @([delieverTime integerValue]);
                        setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    }
//                    NSLog(@"%@",setMinPickerTimeOD);

                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
                }
            }
        }
        else if(result2 == NSOrderedDescending)
        {
            NSLog(@"date2 is later than date3, now time is big than end time");
            setMinPickerTimeOD = date1;
            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
            datePicker.minuteInterval = [deliveryTimeInterval integerValue];
            [datePicker showActionSheetPicker];
//            NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//            [UIAlertController showErrorAlert:message];
        }
    }
    else
    {
        NSLog(@"date1 is equal to date2");
        setMinPickerTimeOD = date1;

        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
        [datePicker showActionSheetPicker];
    }
}

- (IBAction)btnParkingPickUpClicked:(id)sender {
//    NSDate *now = [NSDate date];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm:ss";
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"select time" datePickerMode:UIDatePickerModeTime selectedDate:now target:self action:@selector(timeWasSelected:element:) origin:sender];
//    [datePicker showActionSheetPicker];
    NSString *time1 = deliveryStartTime;
    NSDate *now = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:TIME24HOURFORMAT];

    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    NSString *time2 = [formatter stringFromDate:now];

    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];

    NSString *time3 = deliveryEndTime;
    NSDate *date3= [formatter dateFromString:time3];

    NSComparisonResult result = [date1 compare:date2];

    if(result == NSOrderedDescending)
    {
        NSLog(@"date1 is later than date2");
        setMinPickerTimeOD = date1;
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
        [datePicker showActionSheetPicker];
//        NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//        [UIAlertController showErrorAlert:message];
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"date2 is later than date1");

        NSComparisonResult result2 = [date2 compare:date3];
        if(result2 == NSOrderedAscending)
        {
            NSLog(@"date3 is later than date2, endTime is big than now time");
            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];


            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTimeOD];
            NSInteger minute = [components minute];
            NSLog(@"%ld",(long)minute);
            NSLog(@"%ld",(long)minute % [deliveryTimeInterval integerValue]);
            if(minute % [deliveryTimeInterval integerValue] == 0)
            {
                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];

                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                [datePicker showActionSheetPicker];
            }
            else
            {
                if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                {
                    setMinPickerTimeOD = date1;
                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
//                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//                    [UIAlertController showErrorAlert:message];

                }
                else
                {
                    NSNumber *delieverTime = deliveryTimeInterval;
                    delieverTime = @([delieverTime integerValue] * 2);
                    setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                    {
                        NSNumber *delieverTime = deliveryTimeInterval;
                        delieverTime = @([delieverTime integerValue]);
                        setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    }
                    NSLog(@"%@",setMinPickerTimeOD);

                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
                }
            }
        }
        else if(result2 == NSOrderedDescending)
        {
            NSLog(@"date2 is later than date3, now time is big than end time");
            setMinPickerTimeOD = date1;
            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
            datePicker.minuteInterval = [deliveryTimeInterval integerValue];
            [datePicker showActionSheetPicker];
//            NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//            [UIAlertController showErrorAlert:message];
        }
    }
    else
    {
        NSLog(@"date1 is equal to date2");
        setMinPickerTimeOD = date1;

        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
        [datePicker showActionSheetPicker];
    }
}

- (IBAction)btnDesignationLocationPickupClicked:(id)sender {
//    NSDate *now = [NSDate date];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm:ss";
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"select time" datePickerMode:UIDatePickerModeTime selectedDate:now target:self action:@selector(timeWasSelected:element:) origin:sender];
//    [datePicker showActionSheetPicker];
//    NSString *time1 = [[NSDate date];
    NSDate *date2= [NSDate date];//[formatter dateFromString:time1];
    date2 = [date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];
    
    NSDate *date1 = [self getPDStartTime:DeliveryToLocation];
    
    NSString *time3 = deliveryEndTime;
    NSDate *date3= [formatter dateFromString:time3];
    date3 = [date3 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];

    NSLog(@"btnDesignationLocationPickupClicked Date1 (deliveryStartTime):%@, Date2 (now):%@, Date3 (deliveryEndTime):%@",
          [formatter stringFromDate:date1], [formatter stringFromDate:date2], [formatter stringFromDate:date3]);
    NSComparisonResult result = [date1 compare:date2];

    if(result == NSOrderedDescending)
    {
        NSLog(@"date1 is later than date2");
        setMinPickerTimeOD = date1;
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
        [datePicker showActionSheetPicker];
//        NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//        [UIAlertController showErrorAlert:message];
    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"date2 is later than date1");

        NSComparisonResult result2 = [date2 compare:date3];
        if(result2 == NSOrderedAscending)
        {
            NSLog(@"date3 is later than date2, endTime is big than now time");
//            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];
            setMinPickerTimeOD = date2;


            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTimeOD];
            NSInteger minute = [components minute];
            NSLog(@"%ld",(long)minute);
            NSLog(@"%ld",(long)minute % [deliveryTimeInterval integerValue]);
            if(minute % [deliveryTimeInterval integerValue] == 0)
            {
//                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];

                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                [datePicker showActionSheetPicker];
            }
            else
            {
                if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                {
                    setMinPickerTimeOD = date1;
                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
//                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//                    [UIAlertController showErrorAlert:message];

                }
                else
                {
                    NSNumber *delieverTime = deliveryTimeInterval;
                    delieverTime = @([delieverTime integerValue] * 2);
                    setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
                    {
                        NSNumber *delieverTime = deliveryTimeInterval;
                        delieverTime = @([delieverTime integerValue]);
                        setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                    }
//                    NSLog(@"%@",setMinPickerTimeOD);

                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
                    [datePicker showActionSheetPicker];
                }
            }
        }
        else if(result2 == NSOrderedDescending)
        {
            NSLog(@"date2 is later than date3, now time is big than end time");
            setMinPickerTimeOD = date1;
            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
            datePicker.minuteInterval = [deliveryTimeInterval integerValue];
            [datePicker showActionSheetPicker];
//            NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//            [UIAlertController showErrorAlert:message];
        }
    }
    else
    {
        NSLog(@"date1 is equal to date2");
        setMinPickerTimeOD = date1;

        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
        [datePicker showActionSheetPicker];
    }

}

- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnOkClicked:(id)sender {
    if(![self.txtNotes.text isEqualToString:@""] && ![self.txtNotes.text isEqualToString:placeHolderForText])
    {
        self.noteTextOD = self.txtNotes.text;
    }
    else
    {
        self.noteTextOD = @"";
    }
    
    if(self.btnDesignatedLocation.isSelected){
        if(self.btnLocation.titleLabel.text.length == 0){
            [self showAlert:@"Error" :@"Please select location."];
        }
        else if([self.btnDesignationLocationPickUp.titleLabel.text isEqualToString:@"-- Select Time --"]){
            [self showAlert:@"Error" :@"Please select the time."];
        }
        else {
            [HUD showAnimated:YES];
            
            NSDate* newDate =  [formatter2 dateFromString:self.btnDesignationLocationPickUp.titleLabel.text];
            uploadTime = [formatter stringFromDate:newDate];
            if(uploadTime == nil)
            {
               uploadTime = [formatter stringFromDate:[NSDate date]];
            }
            NSDictionary *inDataDict = @{@"delivery_address_name":self.btnLocation.titleLabel.text,
                           @"delivery_instruction":self.txtNotes.text,
                           @"delivery_time":uploadTime,
                           @"cmd":@"save_consumer_delivery",
                           @"consumer_id":stringUId
                           };
            [AppData sharedInstance].consumerPDTimeChosen = @"";
            [[APIUtility sharedInstance] ConsumerDelivaryInfoSaveAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                if([[response valueForKey:@"status"] integerValue] >= 0)
                {
                    if( ((NSArray *)response).count > 0 && [[response valueForKey:@"status"] integerValue] == 1) {

                        [AppData sharedInstance].consumer_Delivery_Id =[NSString stringWithFormat:@"%@", [response valueForKey:@"consumer_delivery_id"]];
                        [AppData sharedInstance].consumer_Delivery_Location = self.btnLocation.titleLabel.text;
                        [AppData sharedInstance].consumerPDTimeChosen = self.btnDesignationLocationPickUp.titleLabel.text;
                        [AppData sharedInstance].consumerPDMethodChosen = DELIVERY_LOCATION;

                        [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n Your delivery location is %@ \n The delivery time is %@ \n",[AppData sharedInstance].consumer_Delivery_Location,self.btnDesignationLocationPickUp.titleLabel.text]];
                    }
                    else
                    {
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                       message:@"Something went wrong."
                                                                                preferredStyle:UIAlertControllerStyleAlert];

                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];

                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    [HUD hideAnimated:YES];
                }
                else
                {
                    [HUD hideAnimated:YES];
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
        }
    }
    else if(self.btnCounter.isSelected){
        if([self.btnCounterPickupTime.titleLabel.text isEqualToString:@"-- Select Time --"]){
            [self showAlert:@"Error" :@"Please select pickup time."];
        }
        else{
            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";

            [AppData sharedInstance].consumerPDMethodChosen = PICKUP_COUNTER;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your carry-out time is %@ \n",self.btnCounterPickupTime.titleLabel.text]];
            
            [AppData sharedInstance].consumerPDTimeChosen = self.btnCounterPickupTime.titleLabel.text;
//            NSDate *tempDate = [formatter2 dateFromString:self.btnCounterPickupTime.titleLabel.text];
//            tempDate = [tempDate dateByAddingTimeInterval:60 * [biz.process_lead_time intValue]];
//            [AppData sharedInstance].consumerPDTimeChosen = [formatter2 stringFromDate:tempDate];
        }
    }
    else if(self.btnTable.isSelected){
        if([self.tableDropDown.titleLabel.text isEqualToString:@""]){
            [self showAlert:@"Error" :@"Please select Table Number."];
        }
        else{
            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = self.tableDropDown.titleLabel.text;

            NSDate* nextAvailableTime = [[NSDate date] dateByAddingTimeInterval:60 * [self getPDLeadTimeInMinute:DeliveryToTable]];
            [AppData sharedInstance].consumerPDTimeChosen = [formatter2 stringFromDate:nextAvailableTime];
            [AppData sharedInstance].consumerPDMethodChosen = DELIVERY_TABLE;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your table number is %@ \n",[AppData sharedInstance].consumer_Delivery_Location_Id]];
            
            
        }
    }
    else if(self.btnParking.isSelected){
        if([self.btnParkingPickUp.titleLabel.text isEqualToString:@"-- Select Time --"]){
            [self showAlert:@"Error" :@"Please select pickup time."];
        }
        else{
            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";

            [AppData sharedInstance].consumerPDMethodChosen = PICKUP_LOCATION;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your pick up time is %@ \n",self.btnParkingPickUp.titleLabel.text]];
        
            [AppData sharedInstance].consumerPDTimeChosen = self.btnParkingPickUp.titleLabel.text;
        }
    }
    else{

    }
}

- (IBAction)tableDropDownClicked:(id)sender {
    NSArray *table = [[NSArray alloc] initWithArray:tableNoArr];
    NSLog(@"%@",tableNoArr);
    NSLog(@"%@",table);
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Table Number"
                                            rows:table
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                   picker, (long)selectedIndex, selectedValue);
                                           [self.tableDropDown setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}
@end
