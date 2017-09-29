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

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize btnNewOrder, btnPickupOrder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    btnPickupOrder.enabled = FALSE;
    btnPickupOrder.alpha = 0.7;
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
    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
    [businessArrays startGettingListofAllBusinesses];
    BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
    [self.navigationController pushViewController:businessListContorller animated:YES];

}

- (IBAction)btnPickOrderClicked:(id)sender {
}
@end
