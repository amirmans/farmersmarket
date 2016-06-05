//
//  CateringViewController.m
//  TapForAll
//
//  Created by Sanjay on 3/31/16.
//
//

#import "CateringViewController.h"
#import "ActionSheetPicker.h"
@interface CateringViewController ()

@end

@implementation CateringViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.txtLocation.delegate = self;
    self.txtAdditionalNotes.delegate=self;
    self.txtFirstName.delegate = self;
    self.txtLastName.delegate = self;
    self.txtPhoneNumber.delegate = self;
    self.txtEmail.delegate = self;
    self.txtBudget.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    barBtnItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = barBtnItem;

    self.ratingView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    self.ratingView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    self.ratingView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    self.ratingView.rating = 0;
    self.ratingView.editable = NO;
    self.ratingView.maxRating = 5;

    
    self.Attendeesarray = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i <= 100; i++)
    {
        [self.Attendeesarray addObject:@(i)];
    }
    self.businessBackgroundImage.image = self.business.bg_image;
    
    [self setBusinessBackground];
    [self setProfileInformation];
    [self setBusinessCustomerInformation];
    
//    self.businessBackgroundImage.image =
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Methods

- (void) setBusinessBackground {
    [AppData setBusinessBackgroundColor:self.firstNameView];
    [AppData setBusinessBackgroundColor:self.lastNameView];
    [AppData setBusinessBackgroundColor:self.phoneNumberView];
    [AppData setBusinessBackgroundColor:self.emailView];
    [AppData setBusinessBackgroundColor:self.budgetView];
    [AppData setBusinessBackgroundColor:self.dateView];
    [AppData setBusinessBackgroundColor:self.timeView];
    [AppData setBusinessBackgroundColor:self.attendeesView];
    [AppData setBusinessBackgroundColor:self.locationView];
    [AppData setBusinessBackgroundColor:self.notesView];
    [AppData setBusinessBackgroundColor:self.btnSendRequest];
}

- (void) setProfileInformation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:NicknameKey] != nil) {
        self.txtFirstName.text = [defaults valueForKey:NicknameKey];
    }
    
    if ([defaults valueForKey:EmailAddressKey] != nil) {
        self.txtEmail.text = [defaults valueForKey:EmailAddressKey];
    }
}

- (void) backButtonPressed {
    
    NSLog(@"backButtonPressed");
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) setupEmail {
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"First name: %@ Last name: %@ \nPhone number: %@ \n Email: %@ \n Budget: %@\n Date:%@   Time:%@    Attendies: %@ \n Location: %@ \n Additional Notes:%@", self.txtFirstName.text,self.txtLastName.text ,self.txtPhoneNumber.text,self.txtEmail.text,self.txtBudget.text,self.txtDate.text,self.txtTime.text,self.txtAttendess.text,self.txtLocation.text,self.txtAdditionalNotes.text];
//    NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    if ([MFMailComposeViewController canSendMail]){
        // Create and show composer
        MFMailComposeViewController *mc = [MFMailComposeViewController new];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        //    [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please check your Email account in Mail" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
}

- (void) clearTextFields {
    self.txtFirstName.text = @"";
    self.txtLastName.text = @"";
    self.txtPhoneNumber.text = @"";
    self.txtEmail.text = @"";
    self.txtDate.text = @"";
    self.txtTime.text = @"";
    self.txtAttendess.text = @"";
    self.txtLocation.text = @"";
    self.txtAdditionalNotes.text = @"";
    self.txtBudget.text = @"";
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL) isValidPhone:(NSString *)phoneNumber
{
//    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
//    
//    return [phoneTest evaluateWithObject:phoneNumber];
//    
    
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    if ([numberTest evaluateWithObject:phoneNumber] == YES)
        return TRUE;
    else
        return FALSE;
}

- (void) setBusinessCustomerInformation{
    
    self.ratingView.rating = [self.business.rating floatValue];
    
    [self.btn_Address setTitle:self.business.address forState:UIControlStateNormal];
    
    if([self.business.website  isEqual: @""]) {
        [self.btn_Website setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [self.btn_Website setTitle:self.business.website forState:UIControlStateNormal];
    }
    
    self.lbl_SubTitle.text = self.business.customerProfileName;
    [self.lbl_SubTitle sizeToFit];
    NSLog(@"%@",self.business.customerProfileName);
    NSLog(@"%@ %.1f m",self.business.state,[[AppData sharedInstance]getDistance:self.business.lat longitude:self.business.lng]);
    //    self.lbl_StateAndDist.text = [NSString stringWithFormat:@"%@ %.1f m",biz.state,[[AppData sharedInstance]getDistance:biz.lat longitude:biz.lng]];
    
    self.lbl_StateAndDist.text = self.business.neighborhood;
    
    
    if([[APIUtility sharedInstance]isOpenBussiness:self.business.opening_time CloseTime:self.business.closing_time]){
        self.lbl_OpenNow.text = @"OPEN NOW";
        self.lbl_OpenNow.textColor = [UIColor greenColor];
    }else{
        self.lbl_OpenNow.text = @"CLOSED";
        self.lbl_OpenNow.textColor = [UIColor redColor];
    }
    self.lbl_Time.text = [[APIUtility sharedInstance]getOpenCloseTime:self.business.opening_time CloseTime:self.business.closing_time];
}

#pragma mark - Button Actions

- (IBAction)btnSendRequestClicked:(id)sender {
    if ([self.txtFirstName.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter First Name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtLastName.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter Last Name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtPhoneNumber.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter your Phone Number" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if (![self isValidPhone:self.txtPhoneNumber.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter valid Phone Number" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtEmail.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter Email id" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if (![self isValidEmail:self.txtEmail.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter valid Email id" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtDate.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter event date" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtTime.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter event time" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtAttendess.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter event attendees" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else if ([self.txtLocation.text  isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop" message:@"Please enter event location" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
    else {
        [self setupEmail];
    }
}

- (IBAction)btnDateClicked:(id)sender {
    [self.view endEditing:true];
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate new] target:self action:@selector(dateWasSelected:element:) origin:sender];
    NSDate *date =[NSDate new];
    datePicker.minimumDate =date;
    [datePicker showActionSheetPicker];
}

- (IBAction)btnTimeClicked:(id)sender {
    [self.view endEditing:true];
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate new] target:self action:@selector(timeWasSelected:element:) origin:sender];
    [datePicker showActionSheetPicker];

}

- (IBAction)btnAttendeesClicked:(id)sender {
    [self.view endEditing:true];
     [ActionSheetStringPicker showPickerWithTitle:@"Select Attendees" rows:self.Attendeesarray initialSelection:0 target:self successAction:@selector(prticipantWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

#pragma mark- Picker Methods

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    self.txtDate.text =[dateFormatter stringFromDate:selectedDate];
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.txtTime.text =[dateFormatter stringFromDate:selectedTime];
}

- (void)prticipantWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    self.txtAttendess.text = [NSString stringWithFormat:@"%@",[self.Attendeesarray objectAtIndex:[selectedIndex intValue]]];
}

- (void)actionPickerCancelled:(id)sender
{
    
}

CGFloat animatedDistance;  // .h

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.6;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


#pragma mark TextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
	textField.returnKeyType = UIReturnKeyDone;
	CGRect textFieldRect =
	[self.view.window convertRect:textField.bounds fromView:textField];
	CGRect viewRect = CGRectMake(0, 45, 320, 600);
	[self.view.window convertRect:self.view.bounds fromView:self.view];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
	CGFloat numerator =
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
	CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
	CGFloat heightFraction = numerator / denominator;
	
	
	if (heightFraction < 0.0)
    {
		heightFraction = 0.0;
    }
	else if (heightFraction > 1.0)
    {
		heightFraction = 1.0;
    }
	
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait ||
		orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
		animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
	else
    {
		animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.view setFrame:viewFrame];
	
    //	[self.view bringSubviewToFront:scroll];
	
	[UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance;
    //	viewFrame.origin.y = 0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
	[self.view setFrame:viewFrame];
	
    //[self.view bringSubviewToFront:scroll];	
	
	[UIView commitAnimations];
}

#pragma mark - MFMailDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [self clearTextFields];
            break;
        case MFMailComposeResultSent:
            [self clearTextFields];
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btn_AddressClicked:(id)sender {
    NSString *baseUrl = @"http://maps.apple.com/?q=";
    
    NSString *addressString = self.btn_Address.titleLabel.text;
    
    NSString *encodedUrl = [addressString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *finalurl = [NSString stringWithFormat:@"%@%@",baseUrl,encodedUrl];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalurl]];
}

- (IBAction)btn_WebsiteClicked:(id)sender {
    NSString *websiteUrl = self.btn_Website.titleLabel.text;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:websiteUrl]];
}

@end
