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
#import "ASIFormDataRequest.h"
#import "TapTalkLooks.h"

@interface ConsumerProfileViewController ()

- (BOOL)validatePassword:(NSString *)pass;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

    [super viewDidUnload];
}
   

- (void)populateFieldsWithInitialValues {
    nicknameTextField.text = [DataModel sharedDataModelManager].nickname;
    passwordTextField.text = [DataModel sharedDataModelManager].password;
    passwordAgainTextField.text = [DataModel sharedDataModelManager].password;
    errorMessageLabel.text = @"";
}

- (BOOL)validatePassword:(NSString *)pass {
    if (pass.length < 6)
        return FALSE;
    else
        return TRUE;
}

- (IBAction)saveButtonAction:(id)sender {
    BOOL badInformation = FALSE;
    short nVerificationSteps = 3;
    short loopIndex = 0;
    //Validating input by the user - These rules should match the ones in the server
    while ((loopIndex < nVerificationSteps) && (badInformation == FALSE))
    {
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
    
    if (badInformation)
    {
        [UIAlertView showErrorAlert:@"There are errors in your input. Please fix them first"];
    }
    else
    {
        [self postSaveRequest];
        if (self.navigationController.parentViewController != nil)
            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)resetButtonAction:(id)sender {
    [self populateFieldsWithInitialValues];
//    TODO
//    ChatConfirmation *loginController = [[ChatConfirmation alloc] initWithNibName:nil bundle:nil];
//    loginController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    loginController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:loginController animated:YES completion:nil];
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
    if (![textToCompare isEqualToString:textField.text])
    {
        errorMessageLabel.text = @"Passwords Don't match.";
        errorMessageLabel.textColor = [UIColor redColor];
    }
    else
    {
        errorMessageLabel.text = @"Passwords matched.";
        errorMessageLabel.textColor = [UIColor greenColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)postSaveRequest
{
	// Show an activity spinner that blocks the whole screen
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Updating account information", @"");
        
	// Create the HTTP request object for our URL

    NSURL* url = [NSURL URLWithString:ConsumerProfileServer];
	__block ASIFormDataRequest* __weak request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    
	// Add the POST fields
    //	[request setPostValue:@"message" forKey:@"cmd"];
    //	[request setPostValue:[[DataModel sharedDataModelManager] userID] forKey:@"userID"];
    //	[request setPostValue:text forKey:@"text"];
    [request setPostValue:@"join" forKey:@"cmd"];
    [request setPostValue:nicknameTextField.text forKey:@"nickname"];
    [request setPostValue:passwordTextField.text forKey:@"password"];
    
    NSLog(@"saving profile information was called with this url: %@?cmd=%@&nickname=%@&password=%@", url, @"join",nicknameTextField.text, passwordTextField.text );
    
	// This code will be executed when the HTTP request is successful
	[request setCompletionBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             // If the HTTP response code is not "200 OK", then our server API
             // complained about a problem. This shouldn't happen, but you never
             // know. We must be prepared to handle such unexpected situations.
             int retcode = [request responseStatusCode];
             if ( retcode == 0)
             {
                 [UIAlertView showErrorAlert:NSLocalizedString(@"No connection to profile system ", nil)];
             }
             else
             {
                 //Success set everything now
                 [[NSUserDefaults standardUserDefaults] setObject:nicknameTextField.text forKey:NicknameKey];
                 [[DataModel sharedDataModelManager] setNickname:nicknameTextField.text];
                 [[DataModel sharedDataModelManager] setPassword:passwordAgainTextField.text];
                 [UIAlertView showErrorAlert:@"Profile information saved successfully"];
                 // uid is determine by the database. so we set DataModel fter we talk to the server
                 [DataModel sharedDataModelManager].userID = retcode;
             }
         }
     }];
    
	// This code is executed when the HTTP request fails
	[request setFailedBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [UIAlertView showErrorAlert:@"Error in accessing profile system.  Please try in a few min"];
         }
     }];
    
	[request startAsynchronous];
}


@end
