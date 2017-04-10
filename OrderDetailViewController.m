//
//  OrderDetailViewController.m
//  TapForAll
//
//  Created by Trushal on 4/7/17.
//
//

#import "OrderDetailViewController.h"
#import "AppData.h"
#import "ActionSheetPicker.h"

@interface OrderDetailViewController ()<UITextViewDelegate>{
    NSArray *deliveryLocation;
    ActionSheetDatePicker *datePicker;
}
@property (strong, nonatomic) NSString *notesTextOrderDetail;
@property (assign) BOOL flagRedeemPointOD;
@property (assign) double originalPointsValueOD;
@property (assign) NSInteger originalNoPointsOD;
@property (assign) double dollarValueForEachPointsOD;  //detemined by the points level's ceiling
@property (assign) NSInteger currenPointsLevelOD;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (assign) NSInteger redeemNoPointsOD;  // number of points being redeemed
@property (assign) double  redeemPointsValueOD;// value for the points that we are redeeming


@end

@implementation OrderDetailViewController
@synthesize orderItemsOD;
@synthesize flagRedeemPointOD, originalPointsValueOD, originalNoPointsOD,dollarValueForEachPointsOD,currenPointsLevelOD, redeemNoPointsOD, redeemPointsValueOD, hud,pickupTimeOD;

NSNumber *delivery_time_intervalOD;
NSDate *setMinPickerTimeOD;

//NSString *Note_defaultText = @"Note for order(Optional)";
#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pickup Order";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    deliveryLocation = [NSArray arrayWithObjects:@"New york", @"sydney", @"california", @"canada", nil];
    [_btnLocation setTitle:deliveryLocation[0] forState:UIControlStateNormal];
    
    _btnCounter.selected = YES;
    [self setButtonBorder];
    self.txtNotes.delegate = self;
    billBusiness = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.lblHotelName.text = billBusiness.title;
//    if(billBusiness.Note != nil){
//        self.lblBusinessNote.text = billBusiness.Note;
//    }
//    else{
        self.lblBusinessNote.text = @"";
//    }
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [self.btnParkingPickUp setTitle:[dateFormatter stringFromDate:now] forState:UIControlStateNormal];
    [self.btnCounterPickupTime setTitle:[dateFormatter stringFromDate:now] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
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

#pragma mark - User Functions
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
    NSLog(@"%@",selectedTime);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    if([element tag] == 1){
        [self.btnCounterPickupTime setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
    else if([element tag] == 2){
        [self.btnDesignationLocationPickUp setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
    else{
        [self.btnParkingPickUp setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
    }
//
//    NSDate *now = [NSDate date];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"HH:mm:ss"];
//    [df setTimeZone:[NSTimeZone systemTimeZone]];
//    NSLog(@"The Current Time is %@",[df stringFromDate:now]);
//    
//    NSString *selectTime = [df stringFromDate:selectedTime];
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm:ss"];
//    
//    NSDate *time = [formatter dateFromString:selectTime];
//    NSDate *date1= [formatter dateFromString:_delivery_startTimeOD];
//    NSDate *date2 = [formatter dateFromString:_delivery_endTimeOD];
//    NSComparisonResult result = [time compare:date1];
//    NSLog(@"%ld",(long)result);
//    if ([setMinPickerTime compare:time] == NSOrderedDescending ||
//        [date2 compare:time] == NSOrderedAscending)
//    {
//        if([setMinPickerTime compare:time] == NSOrderedDescending)
//        {
//            //            NSDate *time1 = [formatter2 dateFromString:[formatter2 stringFromDate:setMinPickerTime]];
//            self.lblDeliveryTIme.text = [formatter2 stringFromDate:setMinPickerTime];
//            uploadTime = [formatter stringFromDate:setMinPickerTime];
//        }
//        else
//        {
//            //            NSDate *withOutSelectTime = [setMinPickerTime dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
//            //            NSDate *time1 = [formatter2 dateFromString:[formatter2 stringFromDate:withOutSelectTime]];
//            self.lblDeliveryTIme.text = [formatter2 stringFromDate:setMinPickerTime];
//            
//            uploadTime = [formatter stringFromDate:setMinPickerTime];
//        }
//    }
//    else
//    {
//        self.lblDeliveryTIme.text = [formatter2 stringFromDate:selectedTime];
//        
//        uploadTime = [formatter stringFromDate:selectedTime];
//    }
//    NSLog(@"%@",selectedTime);
//    NSLog(@"%@",self.lblDeliveryTIme.text);
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
                                           [self.btnLocation setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];

}

- (IBAction)btnCounterPickUpClicked:(id)sender {
        
    [self.view endEditing:true];
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"select time" datePickerMode:UIDatePickerModeTime selectedDate:now target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];

    
//        NSString *time1 = _delivery_startTimeOD;
//        
//        NSDate *now = [NSDate date];
//    
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"HH:mm:ss"];
//        NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
//        NSString *time2 = [formatter stringFromDate:now];
//        
//        NSDate *date1= [formatter dateFromString:time1];
//        NSDate *date2 = [formatter dateFromString:time2];
//        
//        NSString *time3 = _delivery_endTimeOD;
//        NSDate *date3= [formatter dateFromString:time3];
//        
//        NSComparisonResult result = [date1 compare:date2];
//        
//        if(result == NSOrderedDescending)
//        {
//            NSLog(@"date1 is later than date2");
//            setMinPickerTimeOD = date1;
//            
//        }
//        else if(result == NSOrderedAscending)
//        {
//            NSLog(@"date2 is later than date1");
//            setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
//            
//            
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTime];
//            NSInteger minute = [components minute];
//            NSLog(@"%ld",(long)minute);
//            NSLog(@"%ld",(long)minute % [delivery_time_interval integerValue]);
//            if(minute % [delivery_time_interval integerValue] == 0)
//            {
//                setMinPickerTimeOD =[date2 dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
//                
//                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTimeOD maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                datePicker.minuteInterval = [delivery_time_interval integerValue];
//                [datePicker showActionSheetPicker];
//            }
//            else
//            {
//                if([setMinPickerTime compare:date3] == NSOrderedDescending)
//                {
//                    
//                    NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
//                    [UIAlertController showErrorAlert:message];
//                    
//                }
//                else
//                {
//                    NSNumber *delieverTime = delivery_time_interval;
//                    delieverTime = @([delieverTime integerValue] * 2);
//                    setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
//                    if([setMinPickerTime compare:date3] == NSOrderedDescending)
//                    {
//                        NSNumber *delieverTime = delivery_time_interval;
//                        delieverTime = @([delieverTime integerValue]);
//                        setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
//                    }
//                    NSLog(@"%@",setMinPickerTime);
//                    
//                    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//                    datePicker.minuteInterval = [delivery_time_interval integerValue];
//                    [datePicker showActionSheetPicker];
//                }
//            }
//        }
//        else
//        {
//            NSLog(@"date1 is equal to date2");
//            setMinPickerTime = date1;
//            
//            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
//            datePicker.minuteInterval = [delivery_time_interval integerValue];
//            [datePicker showActionSheetPicker];
//        }
}

- (IBAction)btnParkingPickUpClicked:(id)sender {
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"select time" datePickerMode:UIDatePickerModeTime selectedDate:now target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];

}

- (IBAction)btnDesignationLocationPickupClicked:(id)sender {
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"select time" datePickerMode:UIDatePickerModeTime selectedDate:now target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];

}

- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnOkClicked:(id)sender {
    if(![self.txtNotes.text isEqualToString:@""] && ![self.txtNotes.text isEqualToString:@"notes ..."])
    {
        self.noteTextOD = self.txtNotes.text;
    }
    else
    {
        self.noteTextOD = @"";
    }
    CartViewSecondScreenViewController *TotalCartItemVC = [[CartViewSecondScreenViewController alloc] initWithNibName:@"CartViewSecondScreenViewController" bundle:nil];
    TotalCartItemVC.orderItems = self.orderItemsOD;
    TotalCartItemVC.subTotal = [NSString stringWithFormat:@"%@",self.subTotalOD];
    TotalCartItemVC.earnPts = self.earnPtsOD;
    TotalCartItemVC.noteText = self.noteTextOD;
    TotalCartItemVC.pickupTime = self.pickupTimeOD;
    if([AppData sharedInstance].consumer_Delivery_Id != nil){
        TotalCartItemVC.deliveryamt = self.deliveryamtOD;
        TotalCartItemVC.delivery_startTime = self.delivery_startTimeOD;
        TotalCartItemVC.delivery_endTime = self.delivery_endTimeOD;
    }
    [self.navigationController pushViewController:TotalCartItemVC animated:YES];
}

- (IBAction)tableDropDownClicked:(id)sender {
    NSArray *colors = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];

    [ActionSheetStringPicker showPickerWithTitle:@"Select a Table Number"
                                            rows:colors
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
