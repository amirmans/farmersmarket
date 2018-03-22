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

@interface HomeViewController ()
@property (strong, nonatomic) ActionSheetStringPicker *corpPicker;
@end

@implementation HomeViewController

@synthesize btnNewOrder, btnPickupOrder, textViewMessageToConsumers, corpButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    btnPickupOrder.enabled = FALSE;
    btnPickupOrder.alpha = 0.0;
    textViewMessageToConsumers.textColor = [UIColor whiteColor];
//    textViewMessageToConsumers.text = @"Carry-Out: ASAP (varies by merchant)\nDelivery: 45-60 min.";
    textViewMessageToConsumers.hidden = true;
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
            UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:@"We are taking you to the profile page.  Please update your profile info \n then come back to this page." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.tabBarController.selectedIndex = 1;
            }];
            [alert1 addAction:okAction];
            [self presentViewController:alert1 animated:true completion:^{
            }];
        
        return;
    }
    NSArray* corpList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corps;
    if ((!corpList) || ([corpList count] < 1)) {
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:@"Your company is not signed up to use our services!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert1 addAction:okAction];
        [self presentViewController:alert1 animated:true completion:^{
        }];
        
        return;
    }
    NSArray* deliveryLocations = [corpList valueForKey:@"delivery_location"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Table Number"
                                            rows:deliveryLocations
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                 picker, (long)selectedIndex, selectedValue);
                                           [self.corpButton setTitle:selectedValue forState:UIControlStateNormal];
                                           ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode = true;
                                           
                                           ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
                                           ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpIndex = selectedIndex;
                                           NSString *businessesForCorp = [[corpList objectAtIndex:selectedIndex] objectForKey:@"merchant_ids"];
                                           [businessArrays startGettingListofAllBusinessesForCorp:businessesForCorp];
                                           BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
                                           [self.navigationController pushViewController:businessListContorller animated:YES];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}
@end
