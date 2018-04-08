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
    
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    btnPickupOrder.enabled = FALSE;
    btnPickupOrder.alpha = 0.0;
    textViewMessageToConsumers.textColor = [UIColor whiteColor];
//    textViewMessageToConsumers.text = @"Carry-Out: ASAP (varies by merchant)\nDelivery: 45-60 min.";
    textViewMessageToConsumers.hidden = true;
    
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
    
    // masure sure we have not passed the cutooff time and user can still order for lunch
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *nowString = [formatter stringFromDate:[NSDate date]];
    NSDate* dayInhms = [formatter dateFromString:nowString];
    
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    long weekday = [comps weekday];
    NSString *weekDayStr = [NSString stringWithFormat: @"%ld", weekday];
    NSString *businessWeekDaysStr = [corpDictionary objectForKey:@"delivery_week_days"];
    if ([businessWeekDaysStr rangeOfString:weekDayStr].location == NSNotFound) {
       returnMessage = @"There is no delivery today!";
    } else {
        NSString *cutoffStr = [corpDictionary objectForKey:@"cutoff_time"];
        NSDate *cutoff  = [formatter dateFromString:cutoffStr];
        if ([cutoff compare:dayInhms] == NSOrderedAscending) {
            returnMessage = @"It is past the cutoff time for today's delivery!";
        }
    }
    return returnMessage;
}


- (void)handleCorp {
    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
    if ([corpList count] < 1) {
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:@"Your company is not signed up to use our services!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert1 addAction:okAction];
        [self presentViewController:alert1 animated:true completion:^{
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
                                    NSString *errorMessage = [self isDayandTimeValidForCorp:corpDict];
                                    if ([errorMessage length] > 0)
                                    {
                                        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        }];
                                        [alert1 addAction:okAction];
                                        [self presentViewController:alert1 animated:true completion:^{
                                        }];
                                    } else {
                                           ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode = true;
                                           
                                           ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
                                           ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex = selectedIndex;
                                           NSString *businessesForCorp = [[corpList objectAtIndex:selectedIndex] objectForKey:@"merchant_ids"];
                                           [businessArrays startGettingListofAllBusinessesForCorp:businessesForCorp];
                                           BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
                                           [self.navigationController pushViewController:businessListContorller animated:YES];
                                        }
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
