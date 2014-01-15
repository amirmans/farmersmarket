#import "LoginViewController.h"

#import "DataModel.h"
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

    [businessforThisChatRoom setNumberOfLines:0];
    businessforThisChatRoom.text = [[DataModel sharedDataModelManager] businessName];
    businessforThisChatRoom.text = [businessforThisChatRoom.text stringByAppendingString:@"\'s chatroom"];
    [businessforThisChatRoom sizeToFit];

    [actionNameButton setTitle:@"TapTalk!" forState:UIControlStateNormal];
    self.nicknameTextField.text = [[DataModel sharedDataModelManager] nickname];
    nicknameInfoLabel.text = @"You can always change your nickname in the account page";
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
    hud.labelText = NSLocalizedString(@"Connecting to join the chatroom", @"");

    // Create the HTTP request object for our URL
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];

    NSString *userIDString = [NSString stringWithFormat:@"%d", [DataModel sharedDataModelManager].userID];
    NSDictionary *params = @{@"cmd":@"join",  @"userID":userIDString, @"code":[[DataModel sharedDataModelManager] businessName]};
    [manager GET:ChatSystemServer parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Response from chat server for joining:%@", responseObject);
              if ([self isViewLoaded]) {
                  [MBProgressHUD hideHUDForView:self.view animated:YES];

                  // If the HTTP response code is not "200 OK", then our server API
                  // complained about a problem. This shouldn't happen, but you never
                  // know. We must be prepared to handle such unexpected situations.
                  NSRange tempRange = [operation.responseString rangeOfString:@"OK"];
                  if (tempRange.location == NSNotFound) {
                      [UIAlertView showErrorAlert:NSLocalizedString(@"Warning in joining the chatsystem", nil)];
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
                  [UIAlertView showErrorAlert:operation.description];
              }
          }
    ];

}

- (IBAction)OKAction:(id)sender {
//    self.cancelWasPushed = FALSE;
    [self postJoinRequest];
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