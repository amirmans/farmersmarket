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
#import "SavedCardTableCell.h"
#import "AFNetworking.h"
#import "APIUtility.h"

@interface ConsumerProfileViewController () {
    NSMutableDictionary *consumerProfileDataDic;
}

@property (nonatomic, strong) NSDictionary *consumerProfileDataDic;
@property (nonatomic, strong) MBProgressHUD *hud;


- (BOOL)validatePassword:(NSString *)pass;
- (BOOL)validateAllUserInput;
- (void)populateFieldsWithInitialValues;
- (void)postSaveRequest;

@end

NSMutableArray *savedCardDataArray;

static NSArray *consumerProfileDataArray = nil;

@implementation ConsumerProfileViewController

@synthesize nicknameTextField;
@synthesize passwordTextField;
@synthesize passwordAgainTextField;
@synthesize errorMessageLabel;
@synthesize ageGroupSegmentedControl;
@synthesize ageGroupTextField;
@synthesize resetButton;
@synthesize zipcodeLabel;
@synthesize emailLabel;
@synthesize zipcodeTextField;
@synthesize emailTextField, hud;

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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [TapTalkLooks setBackgroundImage:self.view];
//    [TapTalkLooks setToTapTalkLooks:self.topContainerButton isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.lowerContainerButton isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.ageGroupSegmentedControl isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.nicknameTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.ageGroupTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.resetButton isActionButton:YES makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:self.saveButton isActionButton:YES makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:emailLabel isActionButton:NO makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:zipcodeLabel isActionButton:NO makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:zipcodeTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:emailTextField isActionButton:NO makeItRound:YES];
//
//    ageGroupSegmentedControl.tintColor = [UIColor colorWithRed: 0/255.0 green:0/255.0 blue:255.0f/255.0 alpha:1.0];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // all these steps needs to be done to load the background image
//    [TapTalkLooks setBackgroundImage:self.view];
//    [TapTalkLooks setToTapTalkLooks:self.topContainerButton isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.lowerContainerButton isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.ageGroupSegmentedControl isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.nicknameTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:self.ageGroupTextField isActionButton:NO makeItRound:YES];
////    [TapTalkLooks setToTapTalkLooks:self.resetButton isActionButton:YES makeItRound:NO];
////    [TapTalkLooks setToTapTalkLooks:self.saveButton isActionButton:YES makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:emailLabel isActionButton:NO makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:zipcodeLabel isActionButton:NO makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:zipcodeTextField isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:emailTextField isActionButton:NO makeItRound:YES];
//    
//    ageGroupSegmentedControl.tintColor = [UIColor colorWithRed: 0/255.0 green:0/255.0 blue:255.0f/255.0 alpha:1.0];
    
    savedCardDataArray = [[NSMutableArray alloc] init];
    
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
    nicknameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    zipcodeTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    emailTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    
    self.topView.layer.borderWidth = 2.0;
    self.topView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.topView.layer.cornerRadius = 10.0;
    
    self.bottomView.layer.borderWidth = 2.0;
    self.bottomView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bottomView.layer.cornerRadius = 10.0;
    
    self.title = @"Profile";
    
    self.savedCardTable.delegate = self;
    self.savedCardTable.dataSource = self;
    
    self.savedCardTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    [self getStripeDataArray];

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
    [self setErrorMessageLabel:nil];
    [self setPasswordAgainTextField:nil];
    [self setAgeGroupSegmentedControl:nil];

    [super viewDidUnload];
}

- (void) getStripeDataArray {
    [savedCardDataArray removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:stripeArrayKey] != nil) {
        [savedCardDataArray addObjectsFromArray:[defaults objectForKey:stripeArrayKey]];
        [self.savedCardTable reloadData];
    }
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
                    errorMessageLabel.textColor = [UIColor blueColor];
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
                        errorMessageLabel.textColor = [UIColor blueColor];
                    }
                    else {
                        
                    }
                } else {
                    badInformation = TRUE;
                    errorMessageLabel.hidden = FALSE;
                    errorMessageLabel.text = @"Please enter valid email address";
                    errorMessageLabel.textColor = [UIColor blueColor];
                }
                break;

            case 3:
                if (zipcodeTextField.text.length > 0)
                {
//                    NSString *zipcodeRegEx = @"^[1..9][0-9,-]{4,}?";
//                    NSPredicate *zipcodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipcodeRegEx];
                    if (![[APIUtility sharedInstance] isZipCodeValid:zipcodeTextField.text]) {
//                    if ([zipcodeTest evaluateWithObject:zipcodeTextField.text] == NO) {
                        badInformation = TRUE;
                        errorMessageLabel.hidden = FALSE;
                        errorMessageLabel.text = @"Please enter valid zip code";
                        errorMessageLabel.textColor = [UIColor blueColor];
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
        [UIAlertController showErrorAlert:@"There are errors in your input. Please fix them first"];
    }
    else {
        errorMessageLabel.hidden = TRUE;
        errorMessageLabel.text = @"";
        
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

#pragma mark - TableView DataSource / Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [savedCardDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SavedCardTableCell";
    
    SavedCardTableCell *cell = (SavedCardTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SavedCardTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *cardDict = [savedCardDataArray objectAtIndex:indexPath.row];
    
    NSString *cardNo = [cardDict valueForKey:@"number"];
    
    NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
    
    NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];
    
    cell.lblCardNo.text = cardDisplayNumber;
    cell.lblMonthYear.text = [NSString stringWithFormat:@"%@/%@",[cardDict valueForKey:@"expMonth"],[cardDict valueForKey:@"expYear"]];
    cell.lblCVC.text = @"XXX";
    
    return cell;
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
        errorMessageLabel.textColor = [UIColor blueColor];
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
    NSString *uuid = [DataModel sharedDataModelManager].uuid;
    
    [consumerProfileDataDic setObject:emailTextField.text forKey:@"email"];
    [consumerProfileDataDic setObject:zipcodeTextField.text forKey:@"zipcode"];
    [consumerProfileDataDic setObject:nicknameTextField.text forKey:@"nickname"];
    [consumerProfileDataDic setObject:[NSNumber numberWithInteger:ageGroup] forKey:@"age_group"];
    

    // notice update method in our server, takes care of both situations with or without device_token
    if (deviceToken != nil)
        params = @{@"cmd": @"update", @"uuid": uuid, @"device_token":deviceToken};
    else
        params = @{@"cmd": @"update", @"uuid": uuid};
   
    [consumerProfileDataDic addEntriesFromDictionary:params];
    
    return consumerProfileDataDic;
    
}

- (void)postSaveRequest {
    // Show an activity spinner that blocks the whole screen
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"Updating you info...";
    hud.detailsLabel.text = @"Your info is being saved securly in a secure place.";
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // it seems this should be after setting the mode
    [hud.bezelView setBackgroundColor:[UIColor orangeColor]];
    hud.bezelView.color = [UIColor orangeColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:hud];
    [hud showAnimated:YES];
    
    NSString *urlString = ConsumerProfileServer;
    AFHTTPSessionManager *manager;
    manager = [AFHTTPSessionManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    NSDictionary *params = [self getCorrespondingParameters];
    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject)
    {
        if ([self isViewLoaded]) {
            [hud hideAnimated:YES];
            hud = nil;
            
//            NSLog(@"operation (saving profile information) response status code: %ld", (long)operation.response.statusCode);
//            //status code = 200 is html code for OK - so anything else means not OK
//            if (operation.response.statusCode != 200) {
//                [UIAlertController showErrorAlert:NSLocalizedString(@"Error in generating user ID.  Please try agin a few minutes!", nil)];
//            }
//            else {
                [[DataModel sharedDataModelManager] setNickname:nicknameTextField.text];
//                [[DataModel sharedDataModelManager] setPassword:passwordAgainTextField.text];
                // we set two fields in the database after registering the user - now we are getting those fields
                //uid is determine by the database. so we set DataModel after we talk to the server
                //
                NSDictionary *jsonDictResponse = (NSDictionary *) responseObject;
        
                [DataModel sharedDataModelManager].ageGroup = ageGroupSegmentedControl.selectedSegmentIndex;
                NSString *qrImageFileName = [jsonDictResponse objectForKey:@"qrcode_file"];
                if ((qrImageFileName != nil) && (qrImageFileName != (id)[NSNull null])) {
                    [DataModel sharedDataModelManager].qrImageFileName = qrImageFileName;
                }
                [DataModel sharedDataModelManager].zipcode = zipcodeTextField.text;
                [DataModel sharedDataModelManager].emailAddress = emailTextField.text;
            
                [[DataModel sharedDataModelManager] setUserIDWithString:jsonDictResponse[@"uid"]];
            
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:@"Profile information saved successfully."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
//            }
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error) {
          NSLog(@"Error: %@", error);
          if ([self isViewLoaded]) {
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              [UIAlertController showErrorAlert:@"Error in accessing profile system.  Please try again in a few min"];
          }
          
    }];
}


@end
