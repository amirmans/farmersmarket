//
//  ConsumerProfile.m
//  TapTalk
//
//  Created by Amir on 6/25/12.
//
//

#import "ConsumerProfileViewController.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "DataModel.h"
#import "MBProgressHUD.h"
#import "TapTalkLooks.h"

#import "AFNetworking.h"

@interface ConsumerProfileViewController ()

- (BOOL)validatePassword:(NSString *)pass;
- (BOOL)validateAllUserInput;
- (void)populateFieldsWithInitialValues;
- (void)postSaveRequest;

@end

@implementation ConsumerProfileViewController

@synthesize nicknameTextField;
@synthesize passwordTextField;
@synthesize passwordAgainTextField;
@synthesize topContainerButton;
@synthesize lowerContainerButton;
@synthesize errorMessageLabel;
@synthesize ageGroupSegmentedControl;
@synthesize ageGroupTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // all these steps needs to be done to load the background image
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:self.topContainerButton isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:self.lowerContainerButton isActionButton:NO makeItRound:YES];

    errorMessageLabel.hidden = TRUE;

    nicknameTextField.delegate = self;
    [nicknameTextField setReturnKeyType:UIReturnKeyDone];

    passwordTextField.secureTextEntry = YES;
    [passwordTextField setReturnKeyType:UIReturnKeyDone];
    passwordTextField.delegate = self;

    passwordAgainTextField.secureTextEntry = YES;
    [passwordAgainTextField setReturnKeyType:UIReturnKeyDone];
    passwordAgainTextField.delegate = self;

    [self populateFieldsWithInitialValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setNicknameTextField:nil];
    [self setPasswordTextField:nil];
    [self setPasswordAgainTextField:nil];
    [self setTopContainerButton:nil];
    [self setLowerContainerButton:nil];
    [self setErrorMessageLabel:nil];
    [self setPasswordAgainTextField:nil];
    [self setAgeGroupSegmentedControl:nil];

    [super viewDidUnload];
}


- (void)populateFieldsWithInitialValues {
    nicknameTextField.text = [DataModel sharedDataModelManager].nickname;
    passwordTextField.text = [DataModel sharedDataModelManager].password;
    passwordAgainTextField.text = [DataModel sharedDataModelManager].password;
    errorMessageLabel.text = @"";
    
    int ageGroupfromDefault = [[DataModel sharedDataModelManager] ageGroup];
    ageGroupSegmentedControl.selectedSegmentIndex = ageGroupfromDefault;
    ageGroupTextField.text = [ageGroupSegmentedControl titleForSegmentAtIndex:ageGroupfromDefault];
}

- (BOOL)validatePassword:(NSString *)pass {
    if (pass.length < 6)
        return FALSE;
    else
        return TRUE;
}

- (BOOL)validateAllUserInput
{
    BOOL badInformation = FALSE;
    short nVerificationSteps = 3;
    short loopIndex = 0;
    
    while ((loopIndex < nVerificationSteps) && (badInformation == FALSE)) {
        switch (loopIndex) {
            case 0:
                if (nicknameTextField.text.length < 2) {
                    badInformation = TRUE;
                    errorMessageLabel.hidden = FALSE;
                    errorMessageLabel.text = @"Nickname must be more the 2 chars long.";
                    errorMessageLabel.textColor = [UIColor redColor];
                }
                
                break;
            case 1:
                if (![self validatePassword:passwordTextField.text]) {
                    badInformation = TRUE;
                    errorMessageLabel.hidden = FALSE;
                    errorMessageLabel.text = @"Password is invalid. Is it more than 5 chars?";
                    errorMessageLabel.textColor = [UIColor redColor];
                }
                break;
            case 2:
                if (![passwordTextField.text isEqualToString:passwordAgainTextField.text])
                    badInformation = TRUE;
                break;
            default:
                break;
        }
        loopIndex++;
    } // while
    
    return badInformation;
}


- (IBAction)saveButtonAction:(id)sender {

    //Validating input by the user - These rules should match the ones in the server
    BOOL badInformation = [self validateAllUserInput];

    if (badInformation) {
        [UIAlertView showErrorAlert:@"There are errors in your input. Please fix them first"];
    }
    else {
        [self postSaveRequest];
        if (self.navigationController.parentViewController != nil)
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)ageGroupSegmentedControlAction:(id)sender {
    ageGroupTextField.text = [ageGroupSegmentedControl titleForSegmentAtIndex:ageGroupSegmentedControl.selectedSegmentIndex];
}

- (IBAction)resetButtonAction:(id)sender {
    [self populateFieldsWithInitialValues];
}

#pragma mark
#pragma UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == nicknameTextField)
        return;
    if (passwordAgainTextField.text.length < 1)
        return;

    NSString *textToCompare;
    if (textField == passwordAgainTextField)
        textToCompare = passwordTextField.text;
    else
        textToCompare = passwordAgainTextField.text;

    errorMessageLabel.hidden = FALSE;
    if (![textToCompare isEqualToString:textField.text]) {
        errorMessageLabel.text = @"Passwords Don't match.";
        errorMessageLabel.textColor = [UIColor redColor];
    }
    else {
        errorMessageLabel.text = @"Passwords matched.";
        errorMessageLabel.textColor = [UIColor greenColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSDictionary *)getCorrespondingParameters
{
    NSDictionary *params;
    NSInteger ageGroup = ageGroupSegmentedControl.selectedSegmentIndex;
    NSString *deviceToken = [[DataModel sharedDataModelManager] deviceToken];
    NSNumber *uid = [NSNumber numberWithLong:[DataModel sharedDataModelManager].userID];
    if ([DataModel sharedDataModelManager].userID > 0)
    {
        // notice update method in our server, takes care of both situations with or without device_token
        if (deviceToken != nil)
            params = @{@"cmd": @"update", @"uid": uid ,@"nickname": nicknameTextField.text,@"password": passwordTextField.text, @"age_group":[NSNumber numberWithInteger:ageGroup], @"device_token":deviceToken};
        else
            params = @{@"cmd": @"update", @"uid": uid ,@"nickname": nicknameTextField.text,
                       @"password": passwordTextField.text, @"age_group":[NSNumber numberWithInteger:ageGroup]};
    }
    else
    {
        if (deviceToken != nil)
            params = @{@"cmd": @"join_with_devicetoken", @"nickname": nicknameTextField.text,@"password": passwordTextField.text, @"age_group":[NSNumber numberWithInteger:ageGroup], @"device_token":deviceToken};
        else
            params = @{@"cmd": @"join", @"nickname": nicknameTextField.text,
                   @"password": passwordTextField.text, @"age_group":[NSNumber numberWithInteger:ageGroup]};
    }
    
    return params;
    
}

- (void)postSaveRequest {
    // Show an activity spinner that blocks the whole screen
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Updating account information", @"");
    
    NSString *urlString = ConsumerProfileServer;
    
    AFHTTPRequestOperationManager *manager;
    manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    NSDictionary *params = [self getCorrespondingParameters];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if ([self isViewLoaded]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"operation (saving profile information) response status code: %ld", (long)operation.response.statusCode);
            //status code = 200 is html code for OK - so anything else means not OK
            if (operation.response.statusCode != 200) {
                [UIAlertView showErrorAlert:NSLocalizedString(@"Error in generatin user ID.  Please try agin a few min later", nil)];
            }
            else {
                [[DataModel sharedDataModelManager] setNickname:nicknameTextField.text];
                [[DataModel sharedDataModelManager] setPassword:passwordAgainTextField.text];
                // uid is determine by the database. so we set DataModel after we talk to the server
                NSDictionary *jsonDictResponse = (NSDictionary *) responseObject;
                int userID = [[jsonDictResponse objectForKey:@"userID"] intValue];
                // userID of 0 means, we updated a record with an existing user ID, so we sould not change the exiting userID
                if (userID != 0)
                    [DataModel sharedDataModelManager].userID = userID;
                [DataModel sharedDataModelManager].ageGroup = ageGroupSegmentedControl.selectedSegmentIndex;
                
                [UIAlertView showErrorAlert:@"Profile information saved successfully"];
            }
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
          if ([self isViewLoaded]) {
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              [UIAlertView showErrorAlert:@"Error in accessing profile system.  Please try again in a few min"];
          }
          
    }];
}


@end
