//
//  OrderDetailViewController.m
//  TapForAll
//
//  Created by Trushal on 4/7/17.
//
//

#import "OrderDetailViewController.h"
//#import "AppData.h"
#import "ActionSheetPicker.h"
#import "NYAlertViewController.h"
#import "IQKeyboardManager.h"
#define kOFFSET_FOR_KEYBOARD 80.0

@interface OrderDetailViewController ()<UITextViewDelegate>{
    NSArray *deliveryLocation;
    ActionSheetDatePicker *datePicker;
    NSString *deliveryStartTime;
    NSString *deliveryEndTime;
    NSNumber *deliveryTimeInterval;
    NSNumber *tableMinNo;
    NSNumber *tableMaxNo;
    NSMutableArray *tableNoArr;
    NSDateFormatter *formatter2;
    NSString *uploadTime;
    NSString *stringUId;
    CGSize keyboardSize;
}
@property (strong, nonatomic) NSString *notesTextOrderDetail;
@property (strong, nonatomic) NSDateFormatter *formatter;
//@property (assign) BOOL flagRedeemPointOD;
//@property (assign) double originalPointsValueOD;
//@property (assign) NSInteger originalNoPointsOD;
//@property (assign) double dollarValueForEachPointsOD;  //detemined by the points level's ceiling
//@property (assign) NSInteger currenPointsLevelOD;
@property (nonatomic, strong) MBProgressHUD *hud;
//@property (assign) NSInteger redeemNoPointsOD;  // number of points being redeemed
//@property (assign) double  redeemPointsValueOD;// value for the points that we are redeeming


@end

@implementation OrderDetailViewController
@synthesize orderItemsOD;
@synthesize /*flagRedeemPointOD, originalPointsValueOD, originalNoPointsOD, dollarValueForEachPointsOD,currenPointsLevelOD,redeemNoPointsOD, redeemPointsValueOD,*/ hud,pickupTimeOD, formatter;

NSNumber *delivery_time_intervalOD;
NSDate *setMinPickerTimeOD;

//NSString *Note_defaultText = @"Note for order(Optional)";

//- (NSDictionary *)serviceOperationHours:(NSdictionary*) times{
//    {
//
//        NSDate *PDStartTime = [times valueForKey:@"PDStartTime"];
//        NSDate *PDEndTime = [times valueForKey:@"PDEndTime"];
//        NSDate *BusinessEndTime = [times valueForKey:@"BusinessEndTime"];
//        NSDate *BusinessStartTime = [times valueForKey:@"BusinessStartTime"];
//        NSDate *now = [NSDate date];
////        [formatter setDateFormat:@"HH:mm:ss"];
//
//        NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
//
//        NSString *time2 = [formatter stringFromDate:now];
//
//        NSDate *date1 = PDStartTime;  //delivery start time
//        NSDate *date2 = [formatter dateFromString:time2]; //date2 is now
//
//        NSString *time3 = deliveryEndTime; // date3 is delivery end time
//        NSDate *date3= [formatter dateFromString:time3];
//
//        NSComparisonResult result = [date1 compare:date2];
//
//        if(result == NSOrderedDescending)
//        {
//            NSLog(@"date1 is later than date2");
//            setMinPickerTimeOD = date1;
//            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//            datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//            [datePicker showActionSheetPicker];
//
////        NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
////        [UIAlertController showErrorAlert:message];
//        }
//        else if(result == NSOrderedAscending)
//        {
//            NSLog(@"date2 is later than date1");
//
//            NSComparisonResult result2 = [date2 compare:date3];
//            if(result2 == NSOrderedAscending)
//            {
//                NSLog(@"date3 is later than date2, endTime is later than now time");
//                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];
//
//                NSCalendar *calendar = [NSCalendar currentCalendar];
//                NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTimeOD];
//                NSInteger minute = [components minute];
//                NSLog(@"%ld",(long)minute);
//                NSLog(@"%ld",(long)minute % [deliveryTimeInterval integerValue]);
//                if(minute % [deliveryTimeInterval integerValue] == 0)
//                {
//                    setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[deliveryTimeInterval integerValue]];
//
//                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                    datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//                    [datePicker showActionSheetPicker];
//                }
//                else
//                {
//                    if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
//                    {
//                        setMinPickerTimeOD = date1;
//                        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//                        [datePicker showActionSheetPicker];
////                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
////                    [UIAlertController showErrorAlert:message];
//
//                    }
//                    else
//                    {
//                        NSNumber *delieverTime = deliveryTimeInterval;
//                        delieverTime = @([delieverTime integerValue] * 2);
//                        setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
//                        if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
//                        {
//                            NSNumber *delieverTime = deliveryTimeInterval;
//                            delieverTime = @([delieverTime integerValue]);
//                            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
//                        }
//                        NSLog(@"%@",setMinPickerTimeOD);
//
//                        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                        datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//                        [datePicker showActionSheetPicker];
//                    }
//                }
//            }
//            else if(result2 == NSOrderedDescending)
//            {
//                NSLog(@"date2 is later than date3, now time is big than end time");
//                setMinPickerTimeOD = date1;
//                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//                [datePicker showActionSheetPicker];
////            NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
////            [UIAlertController showErrorAlert:message];
//            }
//        }
//        else
//        {
//            NSLog(@"date1 is equal to date2");
//            setMinPickerTimeOD = date1;
//
//            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//            datePicker.minuteInterval = [deliveryTimeInterval integerValue];
//            [datePicker showActionSheetPicker];
//        }
//    }


- (void)triggerAction:(NSNotification *)notification {
    NSDictionary *response = notification.userInfo;
    if([[response valueForKey:@"status"] integerValue] >= 0)
    {
        if(((NSArray *)[response valueForKey:@"table"]).count > 0) {

            NSArray *tableDict = [response valueForKey:@"table"];
            NSArray *locationDict = [response valueForKey:@"location_info"];
            NSLog(@"%@",tableDict);
            deliveryStartTime = [locationDict valueForKey:@"delivery_start_time"];
            deliveryEndTime = [locationDict valueForKey:@"delivery_end_time"];
            deliveryTimeInterval = [locationDict valueForKey:@"delivery_time_interval_in_minutes"];
            self.lblBusinessNote.text = [tableDict valueForKey:@"message_to_consumers"];
            tableMinNo = [tableDict valueForKey:@"table_no_min"];
            tableMaxNo = [tableDict valueForKey:@"table_no_max"];
            self.locationArray = [[locationDict valueForKey:@"locations"] mutableCopy];

            for (int i = 0 ; i < self.locationArray.count ; i++) {
                [self.locationNameArray addObject:[self.locationArray[i] objectForKey:@"location_name"]];
            }
            NSLog(@"%@",tableMinNo);
            NSLog(@"%@",tableMaxNo);
            for (int i = [tableMinNo intValue] ; i <= [tableMaxNo intValue] ; i++) {
                [tableNoArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            self.btnCounterPickupTime.enabled = YES;
            
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
    self.title = @"Pickup/Delivery Options";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tableNoArr = [[NSMutableArray alloc] init];

    formatter = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//    formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm:ss"];

    formatter2 = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
//    formatter2 = [[NSDateFormatter alloc] init];
//    [formatter2 setDateFormat:@"hh:mm a"];
    self.locationArray = [[NSMutableArray alloc]init];
    self.locationNameArray = [[NSMutableArray alloc]init];

    long uid = [[DataModel sharedDataModelManager] userID];
    if (uid <= 0) {
        [UIAlertController showErrorAlert:@"Please register on profile page to set your favorites. \nYou can order them next time around."];
        return;
    }

    stringUId = [NSString stringWithFormat:@"%ld", uid];


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
    Business *bis = [CurrentBusiness sharedCurrentBusinessManager].business;
    NSInteger  counterVal = [bis.pickup_counter_charge intValue];
    NSInteger  tableVal = [bis.delivery_table_charge intValue];
    NSInteger  locationVal = [bis.delivery_location_charge intValue];
    NSInteger  parkingVal = [bis.pickup_location_charge intValue];
    NSString *openingTime = bis.opening_time;
    NSString *closingTime = bis.closing_time;

    if(counterVal != -1){
        self.btnCounter.enabled = YES;
        self.viewCounter.hidden = NO;
        self.viewTable.hidden = YES;
        self.viewDesignationLocation.hidden = YES;
        self.viewParking.hidden = YES;
    }
    if(parkingVal != -1){
        self.btnParking.enabled = YES;
    }


    if(tableVal != -1){
        self.btnTable.enabled = YES;

    }
    if(locationVal != -1){
        self.btnDesignatedLocation.enabled = YES;

    }

    self.btnOk.enabled = false;

    NSDate *now = [NSDate date];
    [formatter setDateFormat:TIME12HOURFORMAT];

    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    NSString *stringNow = [formatter stringFromDate:now];

    NSDate *dateOpeningTime= [formatter dateFromString:openingTime];
    NSDate *dateNow = [formatter dateFromString:stringNow];

    NSDate *dateClosingTime= [formatter dateFromString:closingTime];

    NSComparisonResult result = [dateOpeningTime compare:dateNow];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:TIME24HOURFORMAT];
    NSDate *dateFromString = [dateFormatter dateFromString:openingTime];
    [dateFormatter setDateFormat:TIME12HOURFORMAT];
    openingTime = [dateFormatter stringFromDate:dateFromString];
    
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    if(result == NSOrderedDescending) // opening time is in future.  Display opening time
    {
        [self.btnParkingPickUp setTitle:openingTime forState:UIControlStateNormal];
        [self.btnDesignationLocationPickUp setTitle:openingTime forState:UIControlStateNormal];
        [self.btnCounterPickupTime setTitle:openingTime forState:UIControlStateNormal];
        self.btnOk.enabled = true;
    }
    else if(result == NSOrderedAscending) // "now" is in future of opening time  - display now
    {
        NSComparisonResult result2 = [dateNow compare:dateClosingTime];
        if(result2 == NSOrderedAscending)
        {
            if([dateNow compare:dateClosingTime] == NSOrderedDescending) // Closing time in is in future of
            {
                NSString *currentTime = openingTime;
                [self.btnParkingPickUp setTitle:currentTime forState:UIControlStateNormal];
                [self.btnDesignationLocationPickUp setTitle:currentTime forState:UIControlStateNormal];
                [self.btnCounterPickupTime setTitle:currentTime forState:UIControlStateNormal];
                self.btnOk.enabled = true;
            }
            else
            {
                NSDate *newDate = [now dateByAddingTimeInterval:60*[deliveryTimeInterval intValue]]; // Add XXX seconds to *now
                NSString *currentTime = [formatter stringFromDate:newDate];
                [self.btnParkingPickUp setTitle:currentTime forState:UIControlStateNormal];
                [self.btnDesignationLocationPickUp setTitle:currentTime forState:UIControlStateNormal];
                [self.btnCounterPickupTime setTitle:currentTime forState:UIControlStateNormal];
                self.btnOk.enabled = true;
            }
        }
        else if(result2 == NSOrderedDescending)
        {

//            NSString *currentTime = [formatter stringFromDate:openingTime];
            [self.btnParkingPickUp setTitle:openingTime forState:UIControlStateNormal];
            [self.btnDesignationLocationPickUp setTitle:openingTime forState:UIControlStateNormal];
            [self.btnCounterPickupTime setTitle:openingTime forState:UIControlStateNormal];
            self.btnOk.enabled = true;
        }
    }
    else
    {
        NSLog(@"date1 is equal to date2");
        NSString *currentTime = openingTime;
        [self.btnParkingPickUp setTitle:currentTime forState:UIControlStateNormal];
        [self.btnDesignationLocationPickUp setTitle:currentTime forState:UIControlStateNormal];
        [self.btnCounterPickupTime setTitle:currentTime forState:UIControlStateNormal];
        self.btnOk.enabled = true;
    }

    deliveryLocation = self.locationNameArray;
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
    if ([textView.text isEqualToString:@"notes..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"notes...";
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

#pragma mark - User Functions
-(void)keyboardWillShow:(NSNotification *)notification {
    // Animate the current view out of the way
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
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
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
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
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= height;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += height;
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
                                                              CartViewSecondScreenViewController *TotalCartItemVC = [[CartViewSecondScreenViewController alloc] initWithNibName:@"CartViewSecondScreenViewController" bundle:nil];
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
//    UIAlertController * alert = [UIAlertController
//                                 alertControllerWithTitle:Title
//                                 message:Message
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* OKButton = [UIAlertAction
//                               actionWithTitle:@"Confirm"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   CartViewSecondScreenViewController *TotalCartItemVC = [[CartViewSecondScreenViewController alloc] initWithNibName:@"CartViewSecondScreenViewController" bundle:nil];
//                                   TotalCartItemVC.orderItems = self.orderItemsOD;
//                                   TotalCartItemVC.subTotal = [NSString stringWithFormat:@"%@",self.subTotalOD];
//                                   TotalCartItemVC.earnPts = self.earnPtsOD;
//                                   TotalCartItemVC.noteText = self.noteTextOD;
//                                   TotalCartItemVC.pickupTime = self.pickupTimeOD;
//                                   if([AppData sharedInstance].consumer_Delivery_Id != nil){
//                                       TotalCartItemVC.deliveryamt = self.deliveryamtOD;
//                                       TotalCartItemVC.delivery_startTime = self.delivery_startTimeOD;
//                                       TotalCartItemVC.delivery_endTime = self.delivery_endTimeOD;
//                                   }
//                                   [self.navigationController pushViewController:TotalCartItemVC animated:YES];
//                               }];
//    UIAlertAction* CancelButton = [UIAlertAction
//                               actionWithTitle:@"Cancel"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   [self dismissViewControllerAnimated:true completion:nil];
//                               }];
//
//    
//    [alert addAction:OKButton];
//    [alert addAction:CancelButton];
//    
//    [self presentViewController:alert animated:YES completion:nil];
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
//    NSLog(@"%@",selectedTime);
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm a";
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    if([element tag] == 1){
//        [self.btnCounterPickupTime setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
//    }
//    else if([element tag] == 2){
//        [self.btnDesignationLocationPickUp setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
//    }
//    else{
//        [self.btnParkingPickUp setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
//    }
//

    NSLog(@"%@",selectedTime);

    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"HH:mm:ss"];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is %@",[df stringFromDate:now]);
    NSString *selectTime = [df stringFromDate:selectedTime];

//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:TIME24HOURFORMAT];

    NSDate *time = [formatter dateFromString:selectTime];
    NSDate *date1= [formatter dateFromString:deliveryStartTime];
    NSDate *date2 = [formatter dateFromString:deliveryEndTime];
    NSComparisonResult result = [time compare:date1];
    NSLog(@"%ld",(long)result);
    if ([setMinPickerTimeOD compare:time] == NSOrderedDescending ||
            [date2 compare:time] == NSOrderedAscending)
    {
        if([setMinPickerTimeOD compare:time] == NSOrderedDescending)
        {
            if([element tag] == 1){
                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];

            }
            else if([element tag] == 2){
                [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
            }
            else{
                [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
            }
//            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];

        }
        else
        {
            if([element tag] == 1){
                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
            }
            else if([element tag] == 2){
                [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
            }
            else{
                [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];
            }
//            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:setMinPickerTimeOD] forState:UIControlStateNormal];

        }
    }
    else
    {
        if([element tag] == 1){
            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }
        else if([element tag] == 2){
            [self.btnDesignationLocationPickUp setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }
        else{
            [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
        }

//        [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];

    }
    NSLog(@"%@",selectedTime);

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
    }
}

- (IBAction)btnPickupTimeDL:(id)sender {

}

- (IBAction)btnLocationClicked:(id)sender {

    [ActionSheetStringPicker showPickerWithTitle:@"Select a delivery location"
                                            rows:deliveryLocation
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

- (IBAction)btnCounterPickUpClicked:(id)sender {

//    [self.view endEditing:true];
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

- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnOkClicked:(id)sender {
    if(![self.txtNotes.text isEqualToString:@""] && ![self.txtNotes.text isEqualToString:@"notes..."])
    {
        self.noteTextOD = self.txtNotes.text;
    }
    else
    {
        self.noteTextOD = @"";
    }
    NSDateFormatter* df = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setTimeZone:[NSTimeZone systemTimeZone]];

    if(self.btnDesignatedLocation.isSelected){
        if(self.btnLocation.titleLabel.text.length == 0){
            [self showAlert:@"Error" :@"Please select location."];
        }
        else if([self.btnDesignationLocationPickUp.titleLabel.text isEqualToString:@"-- Select Time --"]){
            [self showAlert:@"Error" :@"Please select pickup time."];
        }
        else {

            [HUD showAnimated:YES];
            NSDate* newDate = [df dateFromString:self.btnDesignationLocationPickUp.titleLabel.text];
            [df setDateFormat:TIME24HOURFORMAT];
//            newDate = [df stringFromDate:newDate];
            uploadTime = (NSString *)[df stringFromDate:newDate];
            NSLog(@"%@",uploadTime);
            NSDictionary *inDataDict;

            if(uploadTime != nil)
            {

                inDataDict = @{              @"delivery_address_name":self.btnLocation.titleLabel.text,
                        @"delivery_instruction":self.txtNotes.text,
                        @"delivery_time":uploadTime,
                        @"cmd":@"save_consumer_delivery",
                        @"consumer_id":stringUId
                };
            }else
            {
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                dateFormatter.dateFormat = @"hh:mm a";
                NSDateFormatter *dateFormatter = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
                NSDate *now = [NSDate date];

                dateFormatter.dateFormat = TIME24HOURFORMAT;
                uploadTime = [dateFormatter stringFromDate:now];

                inDataDict = @{              @"delivery_address_name":self.btnLocation.titleLabel.text,
                        @"delivery_instruction":self.txtNotes.text,
                        @"delivery_time":uploadTime,
                        @"cmd":@"save_consumer_delivery",
                        @"consumer_id":stringUId
                };
            }
            NSLog(@"%@",inDataDict);
            [[APIUtility sharedInstance] ConsumerDelivaryInfoSaveAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                if([[response valueForKey:@"status"] integerValue] >= 0)
                {
                    if( ((NSArray *)response).count > 0 && [[response valueForKey:@"status"] integerValue] == 1) {

                        [AppData sharedInstance].consumer_Delivery_Id =[NSString stringWithFormat:@"%@", [response valueForKey:@"consumer_delivery_id"]];
                        [AppData sharedInstance].consumer_Delivery_Location = self.btnLocation.titleLabel.text;
                        [AppData sharedInstance].Pick_Time = uploadTime;
                        [AppData sharedInstance].Pd_Mode = DELIVERY_LOCATION;

                        [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n Your Delivery Location is %@ \n Your Pick up time is %@ \n",[AppData sharedInstance].consumer_Delivery_Location,self.btnDesignationLocationPickUp.titleLabel.text]];
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
            [df setDateFormat:TIME12HOURFORMAT];
            NSDate* newDate = [df dateFromString:self.btnCounterPickupTime.titleLabel.text];
            [df setDateFormat:TIME24HOURFORMAT];
//            newDate = [df stringFromDate:newDate];
            uploadTime = (NSString *)[df stringFromDate:newDate];
            NSLog(@"%@",uploadTime);

            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";
            [AppData sharedInstance].Pick_Time = uploadTime;
            [AppData sharedInstance].Pd_Mode = PICKUP_COUNTER;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your Pick up time is %@ \n",self.btnCounterPickupTime.titleLabel.text]];
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
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"hh:mm a";
            NSDateFormatter *dateFormatter = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
            NSDate *now = [NSDate date];
            dateFormatter.dateFormat = TIME24HOURFORMAT;
            uploadTime = [dateFormatter stringFromDate:now];
            [AppData sharedInstance].Pick_Time = uploadTime;
            [AppData sharedInstance].Pd_Mode = DELIVERY_TABLE;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your Table Number is %@ \n",[AppData sharedInstance].consumer_Delivery_Location_Id]];
        }
    }
    else if(self.btnParking.isSelected){
        if([self.btnParkingPickUp.titleLabel.text isEqualToString:@"-- Select Time --"]){
            [self showAlert:@"Error" :@"Please select pickup time."];
        }
        else{
            [df setDateFormat:TIME12HOURFORMAT];
            NSDate* newDate = [df dateFromString:self.btnParkingPickUp.titleLabel.text];
            [df setDateFormat:TIME24HOURFORMAT];
//            newDate = [df stringFromDate:newDate];
            uploadTime = (NSString *)[df stringFromDate:newDate];
            NSLog(@"%@",uploadTime);

            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";
            [AppData sharedInstance].Pick_Time = uploadTime;
            [AppData sharedInstance].Pd_Mode = PICKUP_LOCATION;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your Pick up time is %@ \n",self.btnParkingPickUp.titleLabel.text]];
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
