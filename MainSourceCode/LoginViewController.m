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
//    [TapTalkLooks setToTapTalkLooks:self.businessforThisChatRoom];
    [TapTalkLooks setToTapTalkLooks:self.nicknameTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.actionInfoLabel];

    [businessforThisChatRoom setNumberOfLines:0];
//    businessforThisChatRoom.lineBreakMode = UILineBreakModeWordWrap;
    businessforThisChatRoom.text = [[DataModel sharedDataModelManager] businessName];
    businessforThisChatRoom.text = [businessforThisChatRoom.text stringByAppendingString:@"\'s chatroom"];
//    businessforThisChatRoom.textAlignment = UITextAlignmentCenter;
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
    
//    NSURL *url = [NSURL URLWithString:ChatSystemServer];
//    NSMutableURLRequest *request = [NSMutableURLRequest
//            requestWithURL:url
//               cachePolicy: NSURLRequestUseProtocolCachePolicy
//           timeoutInterval: 10.0];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setValue:text forKey:@"message"];
//    NSString *userName = [DataModel sharedDataModelManager].nickname;
//    [request setValue:userName forKey:@"user"];
//    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setDelegate:self];
//
//    // Add the POST fields
//    [request setPostValue:@"join" forKey:@"cmd"];
//    NSString *userIDString = [NSString stringWithFormat:@"%d", [DataModel sharedDataModelManager].userID];
//    [request setPostValue:userIDString forKey:@"userID"];
//    [request setPostValue:[[DataModel sharedDataModelManager] businessName] forKey:@"code"];
//
//    NSLog(@"Called chat system with this: %@?cmd=%@&userID=%@&code=%@", url, @"join", userIDString, [[DataModel sharedDataModelManager] businessName]);
//
//    // This code will be executed when the HTTP request is successful
//    [request setCompletionBlock:^{
//        if ([self isViewLoaded]) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//
//            // If the HTTP response code is not "200 OK", then our server API
//            // complained about a problem. This shouldn't happen, but you never
//            // know. We must be prepared to handle such unexpected situations.
//            int requestErrorCode = [request responseStatusCode];
//            if (requestErrorCode != 200) {
//                [UIAlertView showErrorAlert:NSLocalizedString(@"Error in communicating with the chat system server to join", nil)];
//            }
//            else {
//                [self userDidJoin];
//            }
//        }
//    }];
//
//    // This code is executed when the HTTP request fails
//    [request setFailedBlock:^{
//        if ([self isViewLoaded]) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [UIAlertView showErrorAlert:[[request error] localizedDescription]];
//        }
//    }];
//
//    [request startAsynchronous];
}

- (IBAction)OKAction:(id)sender {
//    self.cancelWasPushed = FALSE;
    [self postJoinRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)cancelAction:(id)sender {
////    self.cancelWasPushed = TRUE;
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

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
