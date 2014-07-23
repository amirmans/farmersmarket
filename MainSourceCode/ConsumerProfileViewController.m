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
#import "ConsumerProfileDataModel.h"

#import "AFNetworking.h"

@interface ConsumerProfileViewController () {
    NSMutableDictionary *consumerProfileDataDic;
}

@property (nonatomic, strong) NSDictionary *consumerProfileDataDic;

- (BOOL)validatePassword:(NSString *)pass;
- (BOOL)validateAllUserInput;
- (void)populateFieldsWithInitialValues;
- (void)postSaveRequest;

@end

static NSArray *consumerProfileDataArray = nil;

@implementation ConsumerProfileViewController

@synthesize nicknameTextField;
@synthesize passwordTextField;
@synthesize passwordAgainTextField;
@synthesize topContainerButton;
@synthesize lowerContainerButton;
@synthesize errorMessageLabel;
@synthesize ageGroupSegmentedControl;
@synthesize ageGroupTextField;
@synthesize resetButton;
@synthesize zipcodeLabel;
@synthesize emailLabel;
@synthesize zipcodeTextField;
@synthesize emailTextField;

@synthesize consumerProfileDataDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        consumerProfileDataDic = [[NSMutableDictionary alloc] init];
        ConsumerProfileDataModel *consumerProfileDataModel = [[ConsumerProfileDataModel alloc] init];
        consumerProfileDataArray = consumerProfileDataModel.consumerProfileDataArray;
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
    [TapTalkLooks setToTapTalkLooks:self.ageGroupSegmentedControl isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:self.nicknameTextField isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:self.ageGroupTextField isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:self.resetButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:self.saveButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:emailLabel isActionButton:NO makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:zipcodeLabel isActionButton:NO makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:zipcodeTextField isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:emailTextField isActionButton:NO makeItRound:YES];
    
    ageGroupSegmentedControl.tintColor = [UIColor colorWithRed: 0/255.0 green:0/255.0 blue:255.0f/255.0 alpha:1.0];
    
    errorMessageLabel.hidden = TRUE;

    nicknameTextField.delegate = self;
    [nicknameTextField setReturnKeyType:UIReturnKeyDone];
    
    zipcodeTextField.delegate = self;
    [zipcodeTextField setReturnKeyType:UIReturnKeyDone];

    emailTextField.delegate = self;
    [emailTextField setReturnKeyType:UIReturnKeyDone];

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
    zipcodeTextField.text = [[DataModel sharedDataModelManager] zipcode];
    emailTextField.text = [[DataModel sharedDataModelManager] emailAddress];
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
    short nVerificationSteps = 4;
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
//            case 1:
//                if (![self validatePassword:passwordTextField.text]) {
//                    badInformation = TRUE;
//                    errorMessageLabel.hidden = FALSE;
//                    errorMessageLabel.text = @"Password is invalid. Is it more than 5 chars?";
//                    errorMessageLabel.textColor = [UIColor redColor];
//                }
//                break;
//            case 2:
//                if (![passwordTextField.text isEqualToString:passwordAgainTextField.text])
//                    badInformation = TRUE;
//                break;
            case 2:
                if (emailTextField.text.length > 0)
                {
                    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                    
                    if ([emailTest evaluateWithObject:emailTextField.text] == NO) {
                        badInformation = TRUE;
                        errorMessageLabel.hidden = FALSE;
                        errorMessageLabel.text = @"Please enter valid email address";
                        errorMessageLabel.textColor = [UIColor redColor];
                    }
                    else {
                        
                    }
                }
                break;

            case 3:
                if (zipcodeTextField.text.length > 0)
                {
                    NSString *zipcodeRegEx = @"^[1..9][0-9,-]{4,}?";
                    NSPredicate *zipcodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipcodeRegEx];
                    
                    if ([zipcodeTest evaluateWithObject:zipcodeTextField.text] == NO) {
                        badInformation = TRUE;
                        errorMessageLabel.hidden = FALSE;
                        errorMessageLabel.text = @"Please enter valid zipcode";
                        errorMessageLabel.textColor = [UIColor redColor];
                    }
                    else {
                        // it checks to add to the params
                    }
                }
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
    
    [consumerProfileDataDic setObject:emailTextField.text forKey:@"email"];
    [consumerProfileDataDic setObject:zipcodeTextField.text forKey:@"zipcode"];
    [consumerProfileDataDic setObject:nicknameTextField.text forKey:@"nickname"];
    [consumerProfileDataDic setObject:[NSNumber numberWithInteger:ageGroup] forKey:@"age_group"];
    
    if ([DataModel sharedDataModelManager].userID > 0)
    {
        // notice update method in our server, takes care of both situations with or without device_token
        if (deviceToken != nil)
            params = @{@"cmd": @"update", @"uid": uid, @"device_token":deviceToken};
        else
            params = @{@"cmd": @"update", @"uid": uid};
    }
    else
    {
        if (deviceToken != nil)
            params = @{@"cmd": @"join_with_devicetoken", @"device_token":deviceToken};
        else
            params = @{@"cmd": @"join"};
    }
    [consumerProfileDataDic addEntriesFromDictionary:params];
    
    return consumerProfileDataDic;
    
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
//                [[DataModel sharedDataModelManager] setPassword:passwordAgainTextField.text];
                // we set two fields in the database after registering the user - now we are getting those fields
                //uid is determine by the database. so we set DataModel after we talk to the server
                //
                NSDictionary *jsonDictResponse = (NSDictionary *) responseObject;
                int userID = [[jsonDictResponse objectForKey:@"userID"] intValue];
                // userID of 0 means, we updated a record with an existing user ID, so we sould not change the exiting userID
                if (userID != 0)
                    [DataModel sharedDataModelManager].userID = userID;
                [DataModel sharedDataModelManager].ageGroup = ageGroupSegmentedControl.selectedSegmentIndex;
                NSString *qrImageFileName = [jsonDictResponse objectForKey:@"qrcode_file"];
                if ((qrImageFileName != nil) && (qrImageFileName != (id)[NSNull null])) {
                    [DataModel sharedDataModelManager].qrImageFileName = qrImageFileName;
                }
                [DataModel sharedDataModelManager].zipcode = zipcodeTextField.text;
                [DataModel sharedDataModelManager].emailAddress = emailTextField.text;
                
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
