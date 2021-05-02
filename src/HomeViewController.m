//
//  HomeViewController.m
//  TapForAll
//
//  Created by Trushal on 4/9/17.
//
//

#import "HomeViewController.h"
#import "BusinessListViewController.h"
#import "ListofBusinesses.h"
#import "AppData.h"
#import "ActionSheetPicker.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

static NSDateFormatter *formatter= nil;
static NSDateFormatter *displayFormatter= nil;
NSString *companyNotSignedUpMessage =@"Based on your work email, your company has not joined our dedicated lunch services.\nRequest service at info@Tap-In.co. For now, You are welcome to browse the menus.";

@interface HomeViewController () {
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) ActionSheetStringPicker *corpPicker;
@property (atomic, strong) NSTimer *corpListTimer;
@end

@implementation HomeViewController

@synthesize btnNewOrder, btnPickupOrder, textViewMessageToConsumers, corpButton, corpListTimer;


- (NSInteger)indexOfDayOfWeek {
//    NSDate *now = [NSDate date];
    NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
//    NSArray *daysOfWeek = @[@"",@"Su",@"M",@"T",@"W",@"Th",@"F",@"S"];
//    [nowDateFormatter setDateFormat:@"e"];
    NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:[NSDate date]] integerValue];
    return weekdayNumber;
}

- (NSInteger)findTheNextDayIndex:(NSString *)weekDaysStr inCompareto:(long)todaysIndex {
    NSInteger nextBusinessDayIndex = 0;
    NSArray *arr = [weekDaysStr componentsSeparatedByString:@","];
    if (arr.count < 2) {
        nextBusinessDayIndex = [arr[0] integerValue];

        return nextBusinessDayIndex;
    }

    [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        if ([obj1 intValue] == [obj2 intValue])
            return NSOrderedSame;

        else if ([obj1 intValue] < [obj2 intValue])
            return NSOrderedAscending;

        else
            return NSOrderedDescending;

    }];

    NSLog(@"The sorted weekday str is %@", arr);

    if (todaysIndex >= [arr[(arr.count -1)] integerValue]) {
        nextBusinessDayIndex = [arr[0] integerValue];

        return nextBusinessDayIndex;
    }

    for (int i = 0; i < arr.count; i++) {
        if (todaysIndex < [arr[i] integerValue]) {
            nextBusinessDayIndex = [arr[i] integerValue];
            break;
        }
    }

    return(nextBusinessDayIndex);
}

- (NSString *)stringFromWeekday:(NSInteger)weekday {
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return dateFormatter.shortWeekdaySymbols[weekday];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [[NSNotificationCenter defaultCenter]   addObserver:self
//                                                selector:@selector(displayInitialCorpMessage)
//                                                name:@"GotCorps"
//                                                object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];

    }
    if (displayFormatter == nil) {
        displayFormatter = [[NSDateFormatter alloc]init];
        [displayFormatter setDateFormat:@"hh:mm a"];
        [displayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }


    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    btnPickupOrder.enabled = FALSE;
    btnPickupOrder.alpha = 0.0;

//    [self displayInitialCorpMessage];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.label.text = @"Finding your company...";

    HUD.mode = MBProgressHUDModeIndeterminate;
    // it seems this should be after setting the mode
    [HUD.bezelView setBackgroundColor:[UIColor orangeColor]];
    HUD.bezelView.color = [UIColor orangeColor];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:HUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    textViewMessageToConsumers.text = @"";

    [self.tabBarController setSelectedIndex:0];

    [AppData sharedInstance].Current_Selected_Tab = @"0";
    self.navigationController.navigationBar.hidden = YES;

    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(displayInitialCorpMessage)
                                                   name:@"GotCorps"
                                                 object:nil];
    // We need this to stick the meesage, i.e when we come back from other tabs
    [self displayInitialCorpMessage];
}

-(void) viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (NSString *)isDayandTimeValidForCorp:(NSDictionary *)corpDictionary {
    NSString *returnMessage = @"";

    // make sure we have not passed the cutoff time and user can still order for lunch
    NSString *nowString = [formatter stringFromDate:[NSDate date]];
    NSDate* dayInhms = [formatter dateFromString:nowString];


    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    long weekday = [comps weekday];
    NSString *weekDayStr = [NSString stringWithFormat: @"%ld", weekday];
    NSString *businessWeekDaysStr = [corpDictionary objectForKey:@"delivery_week_days"];
    if ([businessWeekDaysStr rangeOfString:weekDayStr].location == NSNotFound) {
        NSInteger nextDeliveryDayIndex = [self findTheNextDayIndex:businessWeekDaysStr inCompareto:weekday];
        NSString *nextDeliveryDayStr =  [self stringFromWeekday:nextDeliveryDayIndex];
        returnMessage = [NSString stringWithFormat:@"There is no delivery today!\nThe next delivery day is: %@.\nYou may view the menus without ordering.", nextDeliveryDayStr];
    } else {
        NSString *cutoffStr = [corpDictionary objectForKey:@"cutoff_time"];
        NSDate *cutoff  = [formatter dateFromString:cutoffStr];

        // get the cutoffString in user friendly format

        NSDateFormatter *displayDateFormatter = [APIUtility sharedInstance].utilityDisplayDateFormatter;
        [displayDateFormatter setDateFormat:@"H:mm"];
        [displayDateFormatter setTimeZone:[NSTimeZone localTimeZone]];


        //            NSDateFormatter *displayDateFormatter = [APIUtility sharedInstance].utilityDisplayDateFormatter;
        NSDate *cuttoffDisplayDate = [formatter dateFromString:cutoffStr];
        NSString *cutoffDisplayDateStr = [displayDateFormatter stringFromDate:cuttoffDisplayDate];



        if ([cutoff compare:dayInhms] == NSOrderedAscending) {
            returnMessage = [NSString stringWithFormat:@"For today's delivery cut-off time (%@) is past!\nHowever, you may view the menus without ordering.",cutoffDisplayDateStr ];
        } else
        {
            returnMessage = [NSString stringWithFormat:@"Based on your work email, corp delivery service is open until %@.", cutoffDisplayDateStr];
        }
    }
    return returnMessage;
}

- (NSString *)determineInitialCorpMessage {
    NSString *returnVal;

    NSString* workEmail= [DataModel sharedDataModelManager].emailWorkAddress;
    if(workEmail == nil || [workEmail isKindOfClass:[NSNull class]] || workEmail.length==0) {
        return @"There is no work email in your pofile so we cannot determine your corporation.";
    }

    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
    if (corpList == nil) {
        returnVal = @"";
    } else {
        if ([self isThereRealCorp:corpList]) {
            NSDictionary *corpDict = [corpList objectAtIndex:0];
            returnVal = [self isDayandTimeValidForCorp:corpDict];
        } else {
            returnVal = companyNotSignedUpMessage;
            returnVal = @"Based on your work email, your company has not joined our lunch services.\nRequest service at info@Tap-In.co.";
        }
    }

    return returnVal;
}

-(void)displayInitialCorpMessage {
//    textViewMessageToConsumers.hidden = false;
    // user has changed the profile, we wait until we need more infor from the server to display it here
    if ([AppData sharedInstance].is_Profile_Changed) {
        return;
    }
    textViewMessageToConsumers.textColor = [UIColor whiteColor];
    textViewMessageToConsumers.text = [self determineInitialCorpMessage];

}

- (BOOL)messageSaysGoodToOrder:(NSString *)alertMessage {

    if ([alertMessage rangeOfString:@"open"].location == NSNotFound) {
        return false;
    } else {
        return true;
    }
}

- (void)loadBusinessesForCorp:(NSString *)businessesForCorp {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode = true;

    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
    [businessArrays startGettingListofAllBusinessesForCorp:businessesForCorp];
    BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
    [self.navigationController pushViewController:businessListContorller animated:YES];
}


- (void)handleNoCorpFound:(NSArray *)corpList {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode = true;
    NSString *businessesForCorp = [[corpList objectAtIndex:0] objectForKey:@"merchant_ids"];
    [self loadBusinessesForCorp:businessesForCorp];
}


- (BOOL)isThereRealCorp:(NSArray *)corpList {
    BOOL returnVal = true;
    if (corpList.count < 1) {
        returnVal = FALSE;
    } else if (corpList.count == 1) {
      if ([[[corpList objectAtIndex:0] objectForKey:@"domain"] isEqual:@"Default"] || [[[corpList objectAtIndex:0] objectForKey:@"domain"] isEqual:@"default"]) {
        returnVal = FALSE;
      }

    }
    return returnVal;
}


- (void)handleCorp {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode = false;
    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;

    if (![self isThereRealCorp:corpList]) {

        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@""
                                    message:companyNotSignedUpMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (corpList.count > 0) {
                [self handleNoCorpFound:corpList];
            }
        }];
        [alert1 addAction:okAction];
        [self presentViewController:alert1 animated:true completion:^{
//            if (corpList.count > 0) {
//                [self handleNoCorpFound:corpList];
//            }
        }];

        return;
    }
    NSArray* deliveryLocations = [corpList valueForKey:@"delivery_location"];

    [ActionSheetStringPicker showPickerWithTitle:@"Delivery location?"
                                rows:deliveryLocations
                                initialSelection:0
                                doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                    NSLog(@"Picker: %@, Index: %ld, value: %@",
                                            picker, (long)selectedIndex, selectedValue);
                                    [self.corpButton setTitle:selectedValue forState:UIControlStateNormal];

                                    NSDictionary *corpDict = [corpList objectAtIndex:selectedIndex];
                                    NSString *alertMessage = [self isDayandTimeValidForCorp:corpDict];
                                    if (![self messageSaysGoodToOrder:alertMessage])
                                    {
                                        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode = true;
                                    }
                                    else {
                                        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode = false;

                                        NSString *deliveryTimeStr =[corpDict objectForKey:@"delivery_time"];
                                        NSString *cuttoffTimeStr =[corpDict objectForKey:@"cutoff_time"];

                                        NSDate *cutoffTime  = [formatter dateFromString:cuttoffTimeStr];
                                        cuttoffTimeStr = [displayFormatter stringFromDate:cutoffTime];
                                        NSDate *deliveryTime  = [formatter dateFromString:deliveryTimeStr];
                                        deliveryTimeStr = [displayFormatter stringFromDate:deliveryTime];

                                        alertMessage = [NSString stringWithFormat:@"It's a good time to order!\nCut-off time: %@\nfor delivery at: %@", cuttoffTimeStr, deliveryTimeStr];
                                    }

                                    UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex = selectedIndex;
                                        NSString *businessesForCorp = [[corpList objectAtIndex:selectedIndex] objectForKey:@"merchant_ids"];
                                        [self loadBusinessesForCorp:businessesForCorp];
                                    }];

                                    [alert1 addAction:okAction];

                                    [self presentViewController:alert1 animated:true completion:^{

                                    }];
                                }
                                cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                    }
                                origin:self.view];
}


- (void)timerCallBack {
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    NSArray* corpList = delegate.corps;
    //    NSLog(@"%@",_ResponseDataArray);
    if (corpList) {
        [corpListTimer invalidate];
        corpListTimer = nil;
        [HUD hideAnimated:YES];
        [self handleCorp];
    } else {
//         NSString* workEmail= [DataModel sharedDataModelManager].emailWorkAddress;
//        [delegate getCorps:workEmail];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnNewOrderClicked:(id)sender {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode = false;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode = false;
    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
    [businessArrays startGettingListofAllBusinesses];
    BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
    [self.navigationController pushViewController:businessListContorller animated:YES];

}

- (IBAction)btnPickOrderClicked:(id)sender {
}
- (IBAction)ShowCorpsAction:(id)sender {
    NSString* workEmail= [DataModel sharedDataModelManager].emailWorkAddress;
    if(workEmail == nil || [workEmail isKindOfClass:[NSNull class]] || workEmail.length==0) {
            UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:@"We are taking you to the profile page.  Please update your profile info and work email.\nThen come back to this page." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.tabBarController.selectedIndex = 1;
            }];
            [alert1 addAction:okAction];
            [self presentViewController:alert1 animated:true completion:^{
            }];

        return;
    }
    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;

    if (!corpList) {
         [HUD showAnimated:YES];
        corpListTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    } else {
        [self handleCorp];
    }

}
@end
