//
//  PickupDeliveryOptionsViewController.m
//  TapForAll
//
//  Created on 4/7/17.
//
//

#import "PickupDeliveryOptionsViewController.h"
#import "APIUtility.h"
//#import "AppData.h"
#import "ActionSheetPicker.h"
#import "NYAlertViewController.h"
#import "IQKeyboardManager.h"
#define kOFFSET_FOR_KEYBOARD 80.0

NSString  * const ClosedTimeInstructionMessage = @"Closed for the rest of day. No orders!";
NSString  * const TimePlaceHolder = @"Tap to select time";


@interface PickupDeliveryOptionsViewController ()<UITextViewDelegate>{
    NSArray *deliveryLocation;
    ActionSheetDatePicker *datePicker;
    
    // operation related dates
    NSString *deliveryStartTime;
    NSString *deliveryEndTime;
    NSNumber *deliveryTimeInterval;
    NSNumber *deliveryLeadTime;
    NSDate *businessOpeningDate;
    NSDate *businessClosingDate;
    NSDate *deliveryOpeningDate;
    NSDate *deliveryClosingDate;
    // int calculatedLeadTime;
    
    int pickupAvailabilityStatus;
    int deliveryAvailabilityStatus;
    //Please note that time picker displays the times that you will have your order,
    //if you place an order now.
    int timePickerTimeInterval;
    NSDate *timePickerStartTime;
    NSDate *timePickerEndTime;
    NSDate *timePickerSelectedTime;
    NSTimeZone *tz;
    NSString *uploadTime; //?
    
    NSNumber *tableMinNo;
    NSNumber *tableMaxNo;
    NSMutableArray *tableNoArr;
    NSDateFormatter *formatter2;
    NSDateFormatter *serverDateFormatter;
    
    NSString *stringUId;
    CGSize keyboardSize;
    Business *biz;
}
@property (strong, nonatomic) NSString *notesTextOrderDetail;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSDateFormatter *serverDateFormatter;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimeZone *tz;

@property(nonatomic, strong) NSString *placeHolderForText;


@end

@implementation PickupDeliveryOptionsViewController
@synthesize orderItemsOD;
@synthesize hud,pickupTimeOD, formatter, tz, placeHolderForText;
@synthesize serverDateFormatter, btnParkingPickUp, btnDesignatedLocationDeliveryTime, btnCounterPickupTime;
// lables
@synthesize lblTable, lblCarryout, lblDeliveryTo, lblParkingSpace, lblPickupTimeInstruction, lblDeliveryLocationTimeInstruction;

NSNumber *delivery_time_intervalOD;
NSDate *setMinPickerTimeOD;

//- (float)calcDeliveryServiceCharges:(float)subTotal using:(NSString *)chargeFormula {
//    float returnVal = 0.0;
//    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
//    NSRange range = [chargeFormula rangeOfCharacterFromSet:cset];
//    if (range.location == NSNotFound) {
//        return ([chargeFormula floatValue]);
//    } else {
//        NSString* floatString =
//        [chargeFormula stringByReplacingOccurrencesOfString:@" %" withString:@""];
//        return ([floatString floatValue]);
//        // ( or ) are present
//    }
//
//    return returnVal;
//}

- (void) triggerAction:(NSNotification *)notification {
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
            
            //Adjust with business hours and get the intersecions.  Delivery cannot happen with the business itself is closed
            deliveryStartTime = [[APIUtility sharedInstance] laterTimeInString:deliveryStartTime and:billBusiness.opening_time];
            deliveryEndTime = [[APIUtility sharedInstance] earlierTimeInString:deliveryEndTime and:billBusiness.closing_time];
            
            
            deliveryTimeInterval = [locationDict valueForKey:@"delivery_time_interval_in_minutes"];
            deliveryLeadTime = [locationDict valueForKey:@"delivery_lead_time_in_minutes"];
            
            self.locationArray = [[locationDict valueForKey:@"locations"] mutableCopy];
            
            for (int i = 0 ; i < self.locationArray.count ; i++) {
                [self.locationNameArray addObject:[self.locationArray[i] objectForKey:@"location_name"]];
            }
            
            if ([self calcTimesForTimePicker:DeliveryToLocation]) {
                lblDeliveryLocationTimeInstruction.text = [NSString stringWithFormat:@"%@-%@, Every %i min"
                                                           ,[formatter2 stringFromDate:timePickerStartTime]
                                                           ,[formatter2 stringFromDate:timePickerEndTime]
                                                           ,timePickerTimeInterval];
                [self.btnDesignatedLocationDeliveryTime setTitle:TimePlaceHolder forState:UIControlStateNormal];
            } else {
                
                //                lblDeliveryLocationTimeInstruction.text = ClosedTimeInstructionMessage;
                if (deliveryAvailabilityStatus == Pickup_closed_all_day) {
                    lblDeliveryLocationTimeInstruction.text = @"";
                    [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed all day" forState:UIControlStateNormal];
                } else {
                    lblDeliveryLocationTimeInstruction.text = [NSString stringWithFormat:@"%@-%@"
                                                               ,[formatter2 stringFromDate:timePickerStartTime]
                                                               ,[formatter2 stringFromDate:timePickerEndTime]
                                                               ];
                    [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
                }
                self.btnDesignatedLocationDeliveryTime.enabled = false;
                // we have all the info to determine if we have service available
                if (![self calcTimesForTimePicker:PickUpAtCounter]) {
                    [UIAlertController showErrorAlert:@"All services are closed.\nYour order is saved for the next time around."];
                }
            }
        } else {
            NSLog(@"we don't have anything in location both for table and designated arrays");
            lblDeliveryLocationTimeInstruction.text = ClosedTimeInstructionMessage;
            [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed all day" forState:UIControlStateNormal];
            // we have all the info to determine if we have service available
            if (![self calcTimesForTimePicker:PickUpAtCounter]) {
                [UIAlertController showErrorAlert:@"All services are closed.\nYour order is saved for the next time around."];
                //                lblDeliveryLocationTimeInstruction.text = @"";
                [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed!" forState:UIControlStateNormal];
                self.btnDesignatedLocationDeliveryTime.enabled = false;
            }
        }
    }
    else{
        [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
    }
    
    [HUD hideAnimated:YES];
    
}




- (void) initOperationDates:(Business *)billBusiness {
    tz= [NSTimeZone localTimeZone];
    serverDateFormatter = [[AppData sharedInstance] setDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
    formatter = [[AppData sharedInstance] setDateFormatter:TIME24HOURFORMAT];
    [formatter setTimeZone:tz];
    [serverDateFormatter setTimeZone:tz];
    
    formatter2 = [[AppData sharedInstance] setDateFormatter:TIME12HOURFORMAT];
    [formatter2 setTimeZone:tz];
    businessOpeningDate = [formatter dateFromString:billBusiness.opening_time];
    businessClosingDate = [formatter dateFromString:billBusiness.closing_time];
    deliveryOpeningDate = [formatter dateFromString:deliveryStartTime];
    deliveryClosingDate = [formatter dateFromString:deliveryStartTime];
    
    // calculatedLeadTime = 0;
    
    timePickerTimeInterval = 0;
    timePickerStartTime = nil;
    timePickerEndTime = nil;
    timePickerSelectedTime = nil;
}

- (BOOL)calcTimesForTimePicker:(int)pd_type {
    BOOL returnVal = true;
    pickupAvailabilityStatus = 0;
    deliveryAvailabilityStatus = 0;
    
    // opening and closing hours only have hour and minute of the date component
    // for compersion to now we need to construct dates with all the compoenents
    // so let's get the year, month and day components from the date that the businesses
    // were retrieved
    //    AppDelegate * myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    myAppDelegate.informationDate = [serverDateFormatter dateFromString:[serverDateFormatter stringFromDate:[NSDate date]]]; //zzz TODO
    //
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:myAppDelegate.informationDate];
    //    NSInteger year = [components year];
    //    NSInteger month = [components month];
    //    NSInteger day = [components day];
    
    
    
    //    NSDate *tempTimePickerStartDate = timePickerStartTime;
    //    NSDate *tempTimePickerEndDate = timePickerEndTime;
    
    //    NSDateComponents *dc = [[NSDateComponents alloc] init];
    //    [dc setYear:year];
    //    [dc setMonth:month];
    //    [dc setDay:day];
    
    switch (pd_type) {
        case PickUpAtCounter:
            
            //            tempTimePickerStartDate = [self dateFromGivenDate:timePickerStartTime WithYear:year month:month andDay:day];
            //            [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:timePickerStartTime options:0];
            //            tempTimePickerEndDate = [self dateFromGivenDate:timePickerEndTime WithYear:year month:month andDay:day];
            //            [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:timePickerEndTime options:0];
            
            //            tempTimePickerStartDate =  timePickerStartTime;
            //            tempTimePickerEndDate =  timePickerEndTime;
            timePickerTimeInterval = biz.time_interval;
            // now, the current time, in our time zone.  In the future, we will use what the user has selected before?
            timePickerSelectedTime = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
            timePickerSelectedTime = [timePickerSelectedTime dateByAddingTimeInterval:[biz.cycle_time integerValue]*60];
            timePickerStartTime = [[formatter dateFromString:biz.opening_time]
                                   dateByAddingTimeInterval:[biz.cycle_time integerValue]*60];
            timePickerEndTime =  [formatter dateFromString:biz.closing_time];
            
            if ([timePickerEndTime timeIntervalSinceReferenceDate] <= [timePickerStartTime timeIntervalSinceReferenceDate]) {
                returnVal = false;
                pickupAvailabilityStatus = Pickup_closed_all_day;
                
                break;
            }
            
            if ([timePickerSelectedTime timeIntervalSinceReferenceDate] > [timePickerEndTime timeIntervalSinceReferenceDate]) {
                returnVal = false;
                pickupAvailabilityStatus = Pickup_closed_rest_of_day;
            } else {
                
                if ([timePickerStartTime timeIntervalSinceReferenceDate] > [timePickerSelectedTime timeIntervalSinceReferenceDate] )
                {
                    if (billBusiness.pickup_counter_later <= 0) {
                        returnVal = false;
                        pickupAvailabilityStatus = Pickup_open_later_today;
                    } else {
                        timePickerSelectedTime = timePickerStartTime;
                    }
                } else {
                    timePickerStartTime = timePickerSelectedTime;
                }
            }
            
            
            break;
            
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            
            break;
        case DeliveryToLocation:
            if (deliveryStartTime == nil ||  deliveryEndTime == nil) {
                deliveryAvailabilityStatus=Pickup_closed_all_day;
                returnVal = false;
                break;
            }
            
            timePickerTimeInterval = [deliveryTimeInterval intValue];
            // now, the current time, in our time zone.  In the future, we will use what the user has selected before?
            timePickerSelectedTime = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
            timePickerSelectedTime = [timePickerSelectedTime dateByAddingTimeInterval:[deliveryLeadTime integerValue]*60];
            
            timePickerStartTime = [[formatter dateFromString:deliveryStartTime]
                                   dateByAddingTimeInterval:[deliveryLeadTime integerValue]*60];
            timePickerEndTime =  [[formatter dateFromString:deliveryEndTime]
                                  dateByAddingTimeInterval:[deliveryLeadTime integerValue]*60];
            
            if ([timePickerSelectedTime timeIntervalSinceReferenceDate] > [timePickerEndTime timeIntervalSinceReferenceDate]) {
                deliveryAvailabilityStatus=Pickup_closed_rest_of_day;
                returnVal = false;
            } else {
                
                if ([timePickerStartTime timeIntervalSinceReferenceDate] > [timePickerSelectedTime timeIntervalSinceReferenceDate] )
                {
                    timePickerSelectedTime = timePickerStartTime;
                } else {
                    timePickerStartTime = timePickerSelectedTime;
                }
            }
            
            break;
        default:
            
            break;
    }
    
    return returnVal;
}

#pragma mark - Life Cycles
- (void)viewDidLoad {
    // the program is coded to show "pickup at counter" by default and as the first choide
    [super viewDidLoad];
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblTitle.text = billBusiness.title;
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
    
    [self initOperationDates:biz];
    
    self.locationArray = [[NSMutableArray alloc]init];
    self.locationNameArray = [[NSMutableArray alloc]init];
    
    long uid = [[DataModel sharedDataModelManager] userID];
    if (uid <= 0) {
        [UIAlertController showErrorAlert:@"Please register on profile page to place your order. \nYour cart items are saved.\nYou can order them the next time around."];
        return;
    }
    
    stringUId = [NSString stringWithFormat:@"%ld", uid];
    
    self.btnOk.enabled = false;
    lblPickupTimeInstruction.textColor = [UIColor grayColor];
    lblDeliveryLocationTimeInstruction.textColor = [UIColor grayColor];
    //---------- Buisness delivery info ---------//
    
    
    //    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    //    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    //    NSDictionary *inDataDict = @{@"business_id":business_id};
    //    NSLog(@"%@",inDataDict);
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(triggerAction:) name:@"GotDeliveryInfo" object:nil];
    
    [HUD showAnimated:YES];
    
    //---------- Set Button enable/disable ------//
    //    NSInteger  tableVal = [biz.delivery_table_charge intValue];
    //    NSInteger  locationVal = [biz.delivery_location_charge intValue];
    //    NSString *openingTime = bis.opening_time;
    //    NSString *closingTime = bis.closing_time;
    //    self.btnCounter.enabled = NO;
    //    self.btnCounterPickupTime.enabled = NO;
    //    [self.btnCounterPickupTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
    //    lblPickupTimeInstruction.text = ClosedTimeInstructionMessage;
    self.viewCounter.hidden = YES;
    self.viewTable.hidden = YES;
    self.viewDesignatedLocation.hidden = YES;
    self.viewParking.hidden = YES;
    
    //labels
    lblParkingSpace.textColor = [UIColor grayColor];
    lblTable.textColor = [UIColor grayColor];
    lblCarryout.textColor = [UIColor grayColor];
    lblDeliveryTo.textColor = [UIColor grayColor];
    
    if (![biz.pickup_counter_charge isEqualToString:@"-1"]) {
        lblCarryout.enabled = YES;
        lblCarryout.textColor = [UIColor blackColor];
        self.btnCounter.enabled = YES;
        self.viewCounter.hidden = NO;
        self.txtNotes.hidden = YES;
        BOOL serviceAvailable = [self calcTimesForTimePicker:PickUpAtCounter];
        if (serviceAvailable) {
            self.btnOk.enabled = true;
            
            if (billBusiness.pickup_counter_later > 0) {
                lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@, Every %i min"
                                                 ,[formatter2 stringFromDate:timePickerStartTime]
                                                 ,[formatter2 stringFromDate:timePickerEndTime]
                                                 ,billBusiness.time_interval];
                self.btnCounterPickupTime.enabled = YES;
                [self.btnCounterPickupTime setTitle:TimePlaceHolder forState:UIControlStateNormal];
            } else {
                lblPickupTimeInstruction.text = @"";
                self.btnCounterPickupTime.enabled = NO;
                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:timePickerStartTime] forState:UIControlStateNormal];
            }
        } else {
            //            lblPickupTimeInstruction.text = ClosedTimeInstructionMessage;
            self.btnCounterPickupTime.enabled = NO;
            if (pickupAvailabilityStatus == Pickup_closed_all_day) {
                lblPickupTimeInstruction.text = @"";
                [self.btnCounterPickupTime setTitle:@"Closed all day" forState:UIControlStateNormal];
            } else if (pickupAvailabilityStatus == Pickup_open_later_today) {
                lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@"
                                                 ,[formatter2 stringFromDate:timePickerStartTime]
                                                 ,[formatter2 stringFromDate:timePickerEndTime]
                                                 ];
                [self.btnCounterPickupTime setTitle:@"Closed - Will be open later today" forState:UIControlStateNormal];
            } else {
                lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@"
                                                 ,[formatter2 stringFromDate:timePickerStartTime]
                                                 ,[formatter2 stringFromDate:timePickerEndTime]
                                                 ];
                [self.btnCounterPickupTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
            }
        }
        
        //
        //        if (billBusiness.pickup_counter_later <= 0) {
        //            if (serviceAvailable) {
        //                self.btnOk.enabled = true;
        //            }
        //            self.btnCounterPickupTime.enabled = NO;
        //            lblPickupTimeInstruction.text = @"";
        //            [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:timePickerStartTime] forState:UIControlStateNormal];
        //        } else {
        //            self.btnCounterPickupTime.enabled = YES;
        //            if (serviceAvailable) {
        //                lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@, Every %i min"
        //                                                 ,[formatter2 stringFromDate:timePickerStartTime]
        //                                                 ,[formatter2 stringFromDate:timePickerEndTime]
        //                                                 ,billBusiness.time_interval];
        //                self.btnOk.enabled = true;
        ////                [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:timePickerStartTime] forState:UIControlStateNormal];
        //                [self.btnCounterPickupTime setTitle:TimePlaceHolder forState:UIControlStateNormal];
        //            } else {
        //                lblPickupTimeInstruction.text = ClosedTimeInstructionMessage;
        //                [self.btnCounterPickupTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
        //            }
        //        }
        
        float serviceCharge = [APIUtility calcCharge:[self.subTotalOD doubleValue] using:billBusiness.pickup_counter_charge];
        if (serviceCharge > 0) {
            NSString *chargeText = [NSString stringWithFormat:@"\nCharge:%@", biz.curr_symbol];
            NSString* lableText = [lblCarryout.text stringByAppendingString:chargeText];
            NSString *stringServiceChargeAmount = [NSString stringWithFormat:@"%.2f", serviceCharge];
            lableText = [lableText stringByAppendingString:stringServiceChargeAmount];
            lblCarryout.text = lableText;
        }
        
        //        NSDate *startTime = [self getPDStartTime:PickUpAtCounter];
        //        NSString *startTimeStr = [formatter2 stringFromDate:startTime];
        //        [self.btnDesignationLocationPickUp setTitle:startTimeStr forState:UIControlStateNormal];
        //        [self.btnCounterPickupTime setTitle:startTimeStr forState:UIControlStateNormal];
        //        self.btnOk.enabled = true;
    }
    if (![biz.pickup_location_charge isEqualToString:@"-1"]) {
        self.btnParking.enabled = YES;
        lblParkingSpace.enabled = YES;
        lblParkingSpace.textColor = [UIColor blackColor];
        //        self.txtNotes.hidden = NO;
    }
    
    if (![biz.delivery_table_charge isEqualToString:@"-1"]) {
        self.btnTable.enabled = YES;
        lblTable.enabled = YES;
        lblTable.textColor = [UIColor blackColor];
        //        self.txtNotes.hidden = NO;
    }
    
    if ( ![biz.delivery_location_charge isEqualToString:@"-1"] ) {
        self.btnDesignatedLocation.enabled = YES;
        lblDeliveryTo.enabled = YES;
        lblDeliveryTo.textColor = [UIColor blackColor];
        
        float serviceCharge = [APIUtility calcCharge:[self.subTotalOD doubleValue] using:billBusiness.delivery_location_charge];
        if (serviceCharge > 0) {
            NSString *chargeText = [NSString stringWithFormat:@"\nCharge:%@", biz.curr_symbol];
            lblDeliveryTo.text = [lblDeliveryTo.text stringByAppendingString:chargeText];
            NSString *stringDeliveryChargeAmount = [NSString stringWithFormat:@"%.2f", serviceCharge];
            lblDeliveryTo.text = [lblDeliveryTo.text stringByAppendingString:stringDeliveryChargeAmount];
        }
        //        self.txtNotes.hidden = NO;
        
        NSDate *startTime = [self getPDStartTime:DeliveryToLocation];
        NSString *startTimeStr = [formatter2 stringFromDate:startTime];
        [self.btnDesignatedLocationDeliveryTime setTitle:startTimeStr forState:UIControlStateNormal];
    }
    
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setTimeZone:tz];
    [displayFormatter setDateFormat:@"h:mm a"];
    
    _btnCounter.selected = YES;
    [self setButtonBorder];
    self.txtNotes.delegate = self;
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
                                                              //                                                              if([AppData sharedInstance].consumer_Delivery_Id != nil){
                                                              ////                                                                  TotalCartItemVC.deliveryamt = self.deliveryamtOD;
                                                              //                                                                  TotalCartItemVC.delivery_startTime = self.delivery_startTimeOD;
                                                              //                                                                  TotalCartItemVC.delivery_endTime = self.delivery_endTimeOD;
                                                              //                                                              }
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
    [[btnParkingPickUp layer] setBorderWidth:1.0f];
    [[btnParkingPickUp layer] setBorderColor:[UIColor blackColor].CGColor];
    [[btnCounterPickupTime layer] setBorderWidth:1.0f];
    [[btnCounterPickupTime layer] setBorderColor:[UIColor blackColor].CGColor];
    [[btnDesignatedLocationDeliveryTime layer] setBorderWidth:1.0f];
    [[btnDesignatedLocationDeliveryTime layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_btnLocation layer] setBorderWidth:1.0f];
    [[_btnLocation layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_tableDropDown layer] setBorderWidth:1.0f];
    [[_tableDropDown layer] setBorderColor:[UIColor blackColor].CGColor];
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{
    if([element tag] == 1) {
        [self.btnCounterPickupTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
    else if([element tag] == 2) {
        [self.btnDesignatedLocationDeliveryTime setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
    else {
        [self.btnParkingPickUp setTitle:[formatter2 stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
    
    NSLog(@"ActionSheetDatePicker selected time was: %@",selectedTime);
    [AppData sharedInstance].consumerPDTimeChosen = [formatter2 stringFromDate:selectedTime];
}


#pragma mark - Button Actions

- (IBAction)backBUttonClicked:(id)sender {
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
        _viewDesignatedLocation.hidden = YES;
        _viewParking.hidden = YES;
        self.txtNotes.hidden = YES;
        
        lblDeliveryLocationTimeInstruction.hidden = YES;
        lblPickupTimeInstruction.hidden = NO;
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
        _viewDesignatedLocation.hidden = YES;
        _viewParking.hidden = YES;
        self.txtNotes.hidden = NO;
        
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
        _viewDesignatedLocation.hidden = NO;
        _viewCounter.hidden = YES;
        _viewTable.hidden = YES;
        _viewParking.hidden = YES;
        self.txtNotes.hidden = NO;
        lblDeliveryLocationTimeInstruction.hidden = NO;
        lblPickupTimeInstruction.hidden = YES;
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
        _viewDesignatedLocation.hidden = YES;
        self.txtNotes.hidden = NO;
        
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
    //    BOOL businessOpen = false;
    //    if ([[APIUtility sharedInstance] isBusinessOpen:biz.opening_time CloseTime:biz.closing_time ]) {
    //        businessOpen = true;
    //    }
    NSDate *startTime;
    switch (pd_type) {
        case PickUpAtCounter:
            //            if (businessOpen) {
            //                startTime = [[NSDate date] dateByAddingTimeInterval:[biz.lead_time integerValue]*60];
            //            } else
        {
            startTime = [formatter dateFromString:biz.opening_time];
            startTime = [startTime dateByAddingTimeInterval:[biz.cycle_time integerValue]*60];
        }
            break;
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            
            break;
        case DeliveryToLocation:
            //            if (businessOpen) {
            //                startTime = [[NSDate date] dateByAddingTimeInterval:[deliveryLeadTime integerValue]*60];
            //            }
            //            else
        {
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
    NSDate* endTime;
    switch (pd_type) {
        case PickUpAtCounter:
            endTime = [formatter dateFromString:biz.closing_time];
            endTime = [endTime dateByAddingTimeInterval:[biz.cycle_time integerValue]*60];
            
            break;
        case PickUpAtLocation:
            
            break;
        case DeliveryToTable:
            
            break;
        case DeliveryToLocation:
            endTime = [formatter dateFromString:deliveryEndTime];
            endTime = [endTime dateByAddingTimeInterval:60*[deliveryLeadTime integerValue]];
            
            break;
        default:
            
            break;
    }
    
    return endTime;
}

- (int)getPDLeadTime:(int)pd_type {
    int leadTime = 10;
    
    switch (pd_type) {
        case PickUpAtCounter:
            leadTime = [biz.cycle_time intValue];
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

- (int)getPDTimeInterval:(int)pd_type {
    int interval = 1;
    
    switch (pd_type) {
        case PickUpAtCounter:
            interval = biz.time_interval;
            break;
        case PickUpAtLocation:
            interval = biz.time_interval;
            break;
        case DeliveryToTable:
            interval = biz.time_interval;
            break;
        case DeliveryToLocation:
            interval = [deliveryTimeInterval intValue];
            
            break;
        default:
            
            break;
    }
    
    return interval;
}

- (IBAction)btnCounterPickUpClicked:(id)sender {
    lblPickupTimeInstruction.hidden = NO;
    if ([self calcTimesForTimePicker:PickUpAtCounter]) {
        lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@, every %i min"
                                         ,[formatter2 stringFromDate:timePickerStartTime]
                                         ,[formatter2 stringFromDate:timePickerEndTime]
                                         ,billBusiness.time_interval];
        
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:timePickerSelectedTime minimumDate:timePickerStartTime maximumDate:timePickerEndTime target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = timePickerTimeInterval;
        [datePicker showActionSheetPicker];
        
        self.btnOk.enabled = true;
    } else {
        self.btnOk.enabled = false;
        self.btnCounterPickupTime.enabled = NO;
        if (pickupAvailabilityStatus == Pickup_closed_all_day) {
            lblPickupTimeInstruction.text = @"";
            [self.btnCounterPickupTime setTitle:@"Closed all day" forState:UIControlStateNormal];
        } else {;
            lblPickupTimeInstruction.text = [NSString stringWithFormat:@"%@-%@"
                                             ,[formatter2 stringFromDate:timePickerStartTime]
                                             ,[formatter2 stringFromDate:timePickerEndTime]];
            [self.btnCounterPickupTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
        }
        
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
    //    NSString *time1 = deliveryStartTime;
    //    NSDate *now = [NSDate date];
    ////    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:TIME24HOURFORMAT];
    //
    //    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    //    NSString *time2 = [formatter stringFromDate:now];
    //
    //    NSDate *date1= [formatter dateFromString:time1];
    //    NSDate *date2 = [formatter dateFromString:time2];
    //
    //    NSString *time3 = deliveryEndTime;
    //    NSDate *date3= [formatter dateFromString:time3];
    //
    //    NSComparisonResult result = [date1 compare:date2];
    //
    //    if(result == NSOrderedDescending)
    //    {
    //        NSLog(@"date1 is later than date2");
    //        setMinPickerTimeOD = date1;
    //        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //        datePicker.minuteInterval = [getPDTimeInterval:DeliveryToLocation integerValue];
    //        [datePicker showActionSheetPicker];
    ////        NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
    ////        [UIAlertController showErrorAlert:message];
    //    }
    //    else if(result == NSOrderedAscending)
    //    {
    //        NSLog(@"date2 is later than date1");
    //
    //        NSComparisonResult result2 = [date2 compare:date3];
    //        if(result2 == NSOrderedAscending)
    //        {
    //            NSLog(@"date3 is later than date2, endTime is big than now time");
    //            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[getPD  : integerValue]];
    //
    //
    //            NSCalendar *calendar = [NSCalendar currentCalendar];
    //            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTimeOD];
    //            NSInteger minute = [components minute];
    //            NSLog(@"%ld",(long)minute);
    //            NSLog(@"%ld",(long)minute % [getPDTimeInterval: integerValue]);
    //            if(minute % [getPDTimeInterval: integerValue] == 0)
    //            {
    //                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[getPDTimeInterval: integerValue]];
    //
    //                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //                datePicker.minuteInterval = [getPDTimeInterval: integerValue];
    //                [datePicker showActionSheetPicker];
    //            }
    //            else
    //            {
    //                if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
    //                {
    //                    setMinPickerTimeOD = date1;
    //                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //                    datePicker.minuteInterval = [getPDTimeInterval: integerValue];
    //                    [datePicker showActionSheetPicker];
    ////                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
    ////                    [UIAlertController showErrorAlert:message];
    //
    //                }
    //                else
    //                {
    //                    NSNumber *delieverTime = getPDTimeInterval:;
    //                    delieverTime = @([delieverTime integerValue] * 2);
    //                    setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
    //                    if([setMinPickerTimeOD compare:date3] == NSOrderedDescending)
    //                    {
    //                        NSNumber *delieverTime = getPDTimeInterval:;
    //                        delieverTime = @([delieverTime integerValue]);
    //                        setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
    //                    }
    //                    NSLog(@"%@",setMinPickerTimeOD);
    //
    //                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //                    datePicker.minuteInterval = [getPDTimeInterval: integerValue];
    //                    [datePicker showActionSheetPicker];
    //                }
    //            }
    //        }
    //        else if(result2 == NSOrderedDescending)
    //        {
    //            NSLog(@"date2 is later than date3, now time is big than end time");
    //            setMinPickerTimeOD = date1;
    //            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date1 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //            datePicker.minuteInterval = [getPDTimeInterval: integerValue];
    //            [datePicker showActionSheetPicker];
    ////            NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
    ////            [UIAlertController showErrorAlert:message];
    //        }
    //    }
    //    else
    //    {
    //        NSLog(@"date1 is equal to date2");
    //        setMinPickerTimeOD = date1;
    //
    //        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    //        datePicker.minuteInterval = [getPDTimeInterval: integerValue];
    //        [datePicker showActionSheetPicker];
    //    }
}

- (IBAction)btnDesignatedLocationDeliveryClicked:(id)sender {
    lblDeliveryLocationTimeInstruction.hidden = NO;
    if ([self calcTimesForTimePicker:DeliveryToLocation]) {
        lblDeliveryLocationTimeInstruction.text = [NSString stringWithFormat:@"%@-%@, every %@ min"
                                                   ,[formatter2 stringFromDate:timePickerStartTime]
                                                   ,[formatter2 stringFromDate:timePickerEndTime]
                                                   ,deliveryTimeInterval];
        
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:timePickerSelectedTime minimumDate:timePickerStartTime maximumDate:timePickerEndTime target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = timePickerTimeInterval;
        [datePicker showActionSheetPicker];
        
        self.btnOk.enabled = true;
    } else {
        self.btnOk.enabled = false;
        if (deliveryAvailabilityStatus == Pickup_closed_all_day) {
            lblDeliveryLocationTimeInstruction.text = @"";
            [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed all day" forState:UIControlStateNormal];
        } else {
            [self.btnDesignatedLocationDeliveryTime setTitle:@"Closed for the rest of the day" forState:UIControlStateNormal];
            lblDeliveryLocationTimeInstruction.text = [NSString stringWithFormat:@"%@-%@"
                                                       ,[formatter2 stringFromDate:timePickerStartTime]
                                                       ,[formatter2 stringFromDate:timePickerEndTime]];
        }
        
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
        else if([self.btnDesignatedLocationDeliveryTime.titleLabel.text isEqualToString:TimePlaceHolder]){
            [self showAlert:@"Error" :@"Please select the time."];
        }
        else {
            [HUD showAnimated:YES];
            
            NSDate* newDate =  [formatter2 dateFromString:self.btnDesignatedLocationDeliveryTime.titleLabel.text];
            uploadTime = [formatter stringFromDate:newDate];
            if(uploadTime == nil)
            {
                uploadTime = [formatter stringFromDate:[NSDate date]];
            }
            NSString *instruction = self.txtNotes.text;
            if ([self.txtNotes.text isEqualToString:placeHolderForText]) {
                instruction = @"";
            }
            NSDictionary *inDataDict = @{@"delivery_address_name":self.btnLocation.titleLabel.text,
                                         @"delivery_instruction":instruction,
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
                        [AppData sharedInstance].consumerPDTimeChosen = self.btnDesignatedLocationDeliveryTime.titleLabel.text;
                        [AppData sharedInstance].consumerPDMethodChosen = DELIVERY_LOCATION;
                        float deliveryCharge = [APIUtility calcCharge:[self.subTotalOD doubleValue] using:self->billBusiness.delivery_location_charge];
                        if ( deliveryCharge > 0 ) {
                            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\nYour delivery location is %@ \n\n delivery time: %@\ndelivery charge: %@%.2f", [AppData sharedInstance].consumer_Delivery_Location,self.btnDesignatedLocationDeliveryTime.titleLabel.text
                                                                   ,self->biz.curr_symbol ,deliveryCharge]];
                        } else {
                            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\nYour delivery location is %@ \n The delivery time is %@", [AppData sharedInstance].consumer_Delivery_Location,self.btnDesignatedLocationDeliveryTime.titleLabel.text]];
                        }
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
                    [self->HUD hideAnimated:YES];
                }
                else
                {
                    [self->HUD hideAnimated:YES];
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
        }
    }
    else if(self.btnCounter.isSelected){
        if([self.btnCounterPickupTime.titleLabel.text isEqualToString:TimePlaceHolder]){
            [self showAlert:@"Error" :@"Please select pickup time."];
        }
        else{
            [AppData sharedInstance].consumer_Delivery_Id =@"";
            [AppData sharedInstance].consumer_Delivery_Location_Id = @"";
            [AppData sharedInstance].consumer_Delivery_Location = @"";
            
            [AppData sharedInstance].consumerPDMethodChosen = PICKUP_COUNTER;
            
            float serviceCharge = [APIUtility calcCharge:[self.subTotalOD doubleValue] using:billBusiness.pickup_counter_charge];
            if (serviceCharge <= 0) {
                [self showAlertForNavigate:@"Detail":[NSString stringWithFormat:@"\n  Your carry-out time is %@ \n",self.btnCounterPickupTime.titleLabel.text]];
            } else {
                [self showAlertForNavigate:@"Detail":[NSString stringWithFormat:@"\n  Carry-out time is %@ Service charge: %@%.2f\n",self.btnCounterPickupTime.titleLabel.text, biz.curr_symbol ,serviceCharge]];
            }
            
            [AppData sharedInstance].consumerPDTimeChosen = self.btnCounterPickupTime.titleLabel.text;
            //            NSDate *tempDate = [formatter2 dateFromString:self.btnCounterPickupTime.titleLabel.text];
            //            tempDate = [tempDate dateByAddingTimeInterval:60 * [biz.lead_time intValue]];
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
            
            NSDate* nextAvailableTime = [[NSDate date] dateByAddingTimeInterval:60 * [self getPDLeadTime:DeliveryToTable]];
            [AppData sharedInstance].consumerPDTimeChosen = [formatter2 stringFromDate:nextAvailableTime];
            [AppData sharedInstance].consumerPDMethodChosen = DELIVERY_TABLE;
            [self showAlertForNavigate:@"Detail" :[NSString stringWithFormat:@"\n  Your table number is %@ \n",[AppData sharedInstance].consumer_Delivery_Location_Id]];
            
            
        }
    }
    else if(self.btnParking.isSelected){
        if([self.btnParkingPickUp.titleLabel.text isEqualToString:TimePlaceHolder]){
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
