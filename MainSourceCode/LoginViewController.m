#import "LoginViewController.h"

#import "Consts.h"
#import "DataModel.h"
#import "CurrentBusiness.h"
#import "MBProgressHUD.h"
#import "TapTalkLooks.h"
#import "UIAlertView+TapTalkAlerts.h"

#import "AFNetworking.h"


@implementation LoginViewController

@synthesize businessforThisChatRoom;
@synthesize nicknameTextField;
@synthesize nicknameInfoLabel;
@synthesize actionInfoLabel;
@synthesize actionNameButton;
//@synthesize cancelWasPushed;

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.cancelWasPushed = FALSE;

    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:self.nicknameTextField isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:self.actionNameButton isActionButton:YES makeItRound:NO];

    [businessforThisChatRoom setNumberOfLines:0];
    businessforThisChatRoom.text = [[DataModel sharedDataModelManager] businessName];
    businessforThisChatRoom.text = [businessforThisChatRoom.text stringByAppendingString:@"\'s chatroom"];
    [businessforThisChatRoom sizeToFit];

    [actionNameButton setTitle:@"Tap to Chat!" forState:UIControlStateNormal];
    self.nicknameTextField.text = [[DataModel sharedDataModelManager] nickname];
    nicknameInfoLabel.text = @"You can always change your nickname in the profile tab";
    actionInfoLabel.text = [actionInfoLabel.text stringByAppendingString:[[DataModel sharedDataModelManager] businessName]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Server Communication

- (void)userDidJoin {
    // Close the Login screen
    [[DataModel sharedDataModelManager] setJoinedChat:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postJoinRequest {
    // Show an activity spinner that blocks the whole screen
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Joining the chatroom", @"");

    // Create the HTTP request object for our URL
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

//    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];

    NSString *userIDString = [NSString stringWithFormat:@"%li", [DataModel sharedDataModelManager].userID];
    NSString *businessIDString = [NSString stringWithFormat:@"%i",[CurrentBusiness sharedCurrentBusinessManager].business.businessID];
    NSDictionary *params = @{@"cmd":@"join",  @"userID":userIDString, @"business_id":businessIDString};
    [manager GET:ChatSystemServer parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              if ([self isViewLoaded]) {
                  [MBProgressHUD hideHUDForView:self.view animated:YES];

                  // If the HTTP response code is not "200 OK", then our server API
                  // complained about a problem. This shouldn't happen, but you never
                  // know. We must be prepared to handle such unexpected situations.
                  NSLog(@"Registered in the chat system with response of %@",operation.responseString);
                  NSRange tempRange = [operation.responseString rangeOfString:@"OK"];
                  if (tempRange.location == NSNotFound) {
                      [UIAlertController showErrorAlert:NSLocalizedString(@"Warning in joining the chat system", nil)];
                  }
                  else {
                      [self userDidJoin];
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error in login to the ChatSystem with error of %@ The response from the server was: %@", error, operation.responseString);
              if ([self isViewLoaded]) {
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  [UIAlertController showErrorAlert:operation.description];
              }
          }
    ];

}

- (IBAction)OKAction:(id)sender {
//    self.cancelWasPushed = FALSE;
    [self postJoinRequest];
    if ([DataModel sharedDataModelManager].businessMessages != nil)
            [[DataModel sharedDataModelManager].businessMessages removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setActionInfoLabel:nil];
    [self setNicknameInfoLabel:nil];
    [self setNicknameTextField:nil];
    [self setActionNameButton:nil];
    [self setActionNameButton:nil];
    [self setBusinessforThisChatRoom:nil];
    [super viewDidUnload];
}
@end
