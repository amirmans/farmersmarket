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
//#import "ConsumerProfileDataModel.h"
#import "SavedCardTableCell.h"
#import "AFNetworking.h"
#import "APIUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "AppData.h"
#import "AppDelegate.h"

#import "BillPayViewController.h"

@interface ConsumerProfileViewController () {
    NSMutableDictionary *consumerProfileDataDic;
}

@property (nonatomic, strong) NSDictionary *consumerProfileDataDic;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *E_164FormatPhoneNumber;

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
@synthesize emailWorkTextField, emailWorkLabel;
@synthesize smsNoLabel, smsNoTextField, E_164FormatPhoneNumber;
@synthesize consumerProfileDataDic;

-(void)SetTextFieldBorder :(UITextField *)textField{
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = [UIColor grayColor].CGColor;
    border.frame = CGRectMake(0.0, textField.frame.size.height -borderWidth , textField.frame.size.width, 1.0);
    //    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    //    border.borderWidth = borderWidth;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        consumerProfileDataDic = [[NSMutableDictionary alloc] init];
//        ConsumerProfileDataModel *consumerProfileDataModel = [[ConsumerProfileDataModel alloc] init];
//        consumerProfileDataArray = consumerProfileDataModel.consumerProfileDataArray;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //    [self SetTextFieldBorder:emailTextField];
    //    [self SetTextFieldBorder:zipcodeTextField];
    //    [self SetTextFieldBorder:nicknameTextField];
    //    [self SetTextFieldBorder:smsNoTextField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tabBarController setSelectedIndex:1];
      [AppData sharedInstance].Current_Selected_Tab = @"1";
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

    [self SetTextFieldBorder:emailTextField];
    [self SetTextFieldBorder:zipcodeTextField];
    [self SetTextFieldBorder:nicknameTextField];
    [self SetTextFieldBorder:smsNoTextField];

    savedCardDataArray = [[NSMutableArray alloc] init];
    
    errorMessageLabel.hidden = TRUE;

    nicknameTextField.delegate = self;
    nicknameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [nicknameTextField setReturnKeyType:UIReturnKeyDone];
    nicknameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    zipcodeTextField.delegate = self;
    zipcodeTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [zipcodeTextField setReturnKeyType:UIReturnKeyDone];
    zipcodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    emailTextField.delegate = self;
    emailTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [emailTextField setReturnKeyType:UIReturnKeyDone];
    emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    smsNoTextField.delegate = self;
    smsNoTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [smsNoTextField setReturnKeyType:UIReturnKeyDone];
    smsNoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
//    passwordTextField.secureTextEntry = YES;
//    [passwordTextField setReturnKeyType:UIReturnKeyDone];
//    passwordTextField.delegate = self;
//
//    passwordAgainTextField.secureTextEntry = YES;
//    [passwordAgainTextField setReturnKeyType:UIReturnKeyDone];
//    passwordAgainTextField.delegate = self;

    [self populateFieldsWithInitialValues];
    
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


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

//#pragma mark - keyboard movements
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    keyboardSize.height = 10; //zzz
//
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = -keyboardSize.height;
//        self.view.frame = f;
//    }];
//}
//
//-(void)keyboardWillHide:(NSNotification *)notification
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = 0.0f;
//        self.view.frame = f;
//    }];
//}


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
    E_164FormatPhoneNumber = @"";
    
    int ageGroupfromDefault = [[DataModel sharedDataModelManager] ageGroup];
    ageGroupSegmentedControl.selectedSegmentIndex = ageGroupfromDefault;
    ageGroupTextField.text = [ageGroupSegmentedControl titleForSegmentAtIndex:ageGroupfromDefault];
    zipcodeTextField.text = [[DataModel sharedDataModelManager] zipcode];
//    smsNoTextField.text = [[APIUtility sharedInstance] usPhoneNumber:[[DataModel sharedDataModelManager] sms_no]];
    smsNoTextField.text = [[DataModel sharedDataModelManager] sms_no];

    
    emailTextField.text = [[DataModel sharedDataModelManager] emailAddress];
    emailWorkTextField.text = [[DataModel sharedDataModelManager] emailWorkAddress];
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
    short nVerificationSteps = 6;
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
                if (emailWorkTextField.text.length > 0)
                {
                    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                    NSPredicate *emailWorkTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                    
                    if ([emailWorkTest evaluateWithObject:emailWorkTextField.text] == NO) {
                        badInformation = TRUE;
                        errorMessageLabel.hidden = FALSE;
                        errorMessageLabel.text = @"Work email address is not valid";
                        errorMessageLabel.textColor = [UIColor blueColor];
                    }
                }
                break;

            case 4:
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
            case 5:
                if (smsNoTextField.text.length > 0)
                {
                    
                    if ([[APIUtility sharedInstance] transformValidSMSNo:smsNoTextField.text].length != 12) {
                        //                    if ([zipcodeTest evaluateWithObject:zipcodeTextField.text] == NO) {
                        badInformation = TRUE;
                        errorMessageLabel.hidden = FALSE;
                        errorMessageLabel.text = @"Please enter valid SMS number";
                        errorMessageLabel.textColor = [UIColor blueColor];
                        E_164FormatPhoneNumber = @"";
                    }
                    else {
                        // it checks to add to the params
                        E_164FormatPhoneNumber = [[APIUtility sharedInstance] transformValidSMSNo:smsNoTextField.text];
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


- (BOOL)saveProfile {
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

    return !badInformation;
}

//- (IBAction)saveButtonAction:(id)sender {
//    [self saveProfile];
//}

- (IBAction)ageGroupSegmentedControlAction:(id)sender {
    ageGroupTextField.text = [ageGroupSegmentedControl titleForSegmentAtIndex:ageGroupSegmentedControl.selectedSegmentIndex];
}


//- (IBAction)resetButtonAction:(id)sender {
- (IBAction)saveButtonAction:(id)sender {

    [super viewDidLoad];
    BOOL successfulSave = [self saveProfile];
    if (successfulSave) {
        [self.tabBarController setSelectedIndex:0];
    }

//    [self populateFieldsWithInitialValues];
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
    
    [AppData sharedInstance].is_Profile_Changed = @"YES";
    if (textField == nicknameTextField) {
        if ([smsNoTextField.text length] <= 0)
            [smsNoTextField becomeFirstResponder];
        return;
    }
//    if (passwordAgainTextField.text.length < 1)
//        return;
//
//    NSString *textToCompare;
//    if (textField == passwordAgainTextField)
//        textToCompare = passwordTextField.text;
//    else
//        textToCompare = passwordAgainTextField.text;
//
//    errorMessageLabel.hidden = FALSE;
//    if (![textToCompare isEqualToString:textField.text]) {
//        errorMessageLabel.text = @"Passwords Don't match.";
//        errorMessageLabel.textColor = [UIColor blueColor];
//    }
//    else {
//        errorMessageLabel.text = @"Passwords matched.";
//        errorMessageLabel.textColor = [UIColor greenColor];
//    }
    
    if (textField == smsNoTextField) {
        if ([zipcodeTextField.text length] <= 0)
            [zipcodeTextField becomeFirstResponder];
    } else if (textField == emailTextField) {
        if ([nicknameTextField.text length] <= 0)
            [nicknameTextField becomeFirstResponder];
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
    [consumerProfileDataDic setObject:emailWorkTextField.text forKey:@"email_work"];
    [consumerProfileDataDic setObject:zipcodeTextField.text forKey:@"zipcode"];
    [consumerProfileDataDic setObject:nicknameTextField.text forKey:@"nickname"];
    [consumerProfileDataDic setObject:[NSNumber numberWithInteger:ageGroup] forKey:@"age_group"];
    [consumerProfileDataDic setObject:E_164FormatPhoneNumber forKey:@"sms_no"];

//    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    [consumerProfileDataDic setObject:[NSString stringWithFormat:@"V%@",appVersionString] forKey:@"app_ver"];

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
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json format of data send to save_order: %@", jsonString);
    }
    
    NSLog(@"In ConsumerProfileViewController::postSaveRequest urlString is:%@, and params are:%@", urlString, params);
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
                [[DataModel sharedDataModelManager] setNickname:self.nicknameTextField.text];
//                [[DataModel sharedDataModelManager] setPassword:passwordAgainTextField.text];
                // we set two fields in the database after registering the user - now we are getting those fields
                //uid is determine by the database. so we set DataModel after we talk to the server
                //
                // saving information in our system
                NSDictionary *jsonDictResponse = (NSDictionary *) responseObject;
            
    
                [DataModel sharedDataModelManager].ageGroup = self.ageGroupSegmentedControl.selectedSegmentIndex;
                NSString *qrImageFileName = [jsonDictResponse objectForKey:@"qrcode_file"];
                if ((qrImageFileName != nil) && (qrImageFileName != (id)[NSNull null])) {
                    [DataModel sharedDataModelManager].qrImageFileName = qrImageFileName;
                }
            
                [[DataModel sharedDataModelManager] setZipcode:self.zipcodeTextField.text];
                [[DataModel sharedDataModelManager] setEmailAddress:self.emailTextField.text];
                [[DataModel sharedDataModelManager] setSms_no:self.smsNoTextField.text];
                [DataModel sharedDataModelManager].emailWorkAddress = self.emailWorkTextField.text;
            
                [[DataModel sharedDataModelManager] setUserIDWithString:jsonDictResponse[@"uid"]];
            
                AppDelegate *delegate =((AppDelegate *)[[UIApplication sharedApplication] delegate]);
                [delegate getCorps:self.emailWorkTextField.text];
            
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:@"Profile information saved successfully."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                      
                                                                      [AppData sharedInstance].is_Profile_Changed = @"NO";}];
                
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



- (IBAction)orderHistoryAction:(id)sender {
}

- (IBAction)manageCardsAction:(id)sender {
    BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:0 forBusiness:[CurrentBusiness sharedCurrentBusinessManager].business];
    payBillViewController.parentViewControllerName = @"ConsumerProfileViewController";
    //                [AppData sharedInstance].consumer_Delivery_Id = nil;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    NSUInteger nCount = [allViewControllers count];
    
    payBillViewController.business = [CurrentBusiness sharedCurrentBusinessManager].business;
    [self.navigationController pushViewController:payBillViewController animated:YES];
    
    allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    NSUInteger nCount2 = [allViewControllers count];
}
@end
