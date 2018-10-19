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

@interface HomeViewController () {
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) ActionSheetStringPicker *corpPicker;
@property (atomic, strong) NSTimer *corpListTimer;
@end

@implementation HomeViewController

@synthesize btnNewOrder, btnPickupOrder, textViewMessageToConsumers, corpButton, corpListTimer;


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
    
    [self displayInitialCorpMessage];
    
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
    [self.tabBarController setSelectedIndex:0];
    [AppData sharedInstance].Current_Selected_Tab = @"0";
    self.navigationController.navigationBar.hidden = YES;
}

-(void) viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
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
       returnMessage = @"There is no delivery today!\nHowever, you may enjoy viewing the menus without ordering.";
    } else {
        NSString *cutoffStr = [corpDictionary objectForKey:@"cutoff_time"];
        NSDate *cutoff  = [formatter dateFromString:cutoffStr];
        if ([cutoff compare:dayInhms] == NSOrderedAscending) {
            returnMessage = @"It is past the cut-off time for today's delivery!\nHowever, you may enjoy viewing the menus without ordering.";
        }
    }
    return returnMessage;
}

- (NSString *)determineInitialCorpMessage {
    NSString *returnVal;
    
    NSString* workEmail= [DataModel sharedDataModelManager].emailWorkAddress;
    if(workEmail == nil || [workEmail isKindOfClass:[NSNull class]] || workEmail.length==0) {
        return @"Please update your profile info and work email.\nThen come back to this page.";
    }
    
    
    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
    NSDictionary *corpDict = [corpList objectAtIndex:0];
    returnVal = [self isDayandTimeValidForCorp:corpDict];
    
    return returnVal;
}

-(void)displayInitialCorpMessage {
    textViewMessageToConsumers.textColor = [UIColor whiteColor];
    textViewMessageToConsumers.text = [self determineInitialCorpMessage];
    
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
                                    message:@"Your company is not signed up to use our services!\nWe need 10 registrations to start the process. For now, you may view the menus." preferredStyle:UIAlertControllerStyleAlert];
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
                                    if ([alertMessage length] > 0)
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
