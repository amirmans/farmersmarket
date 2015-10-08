//
//  MeowToOrderController.m
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AskForSeviceViewController.h"
#import "MeowConfirmationViewController.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "TapTalkLooks.h"
#import "Business.h"

#define MAX_LENGTH 70


@implementation AskForSeviceViewController

static NSUInteger firstTime = TRUE;

@synthesize errorMessageView;
@synthesize orderView;
@synthesize cancelUIButton;
@synthesize askUIButton;
@synthesize myBusiness;
@synthesize initialMessage;
@synthesize scrollView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        myBusiness = biz;
        initialMessage = nil;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz intialMessage:(NSString *)message {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil forBusiness:biz];
    initialMessage = message;
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - methods added by Amir

- (IBAction)meow {
    [orderView resignFirstResponder];
    
    NSString *my_sms_no = myBusiness.sms_no;
    NSString *businessName = myBusiness.businessName;
    if ((my_sms_no == nil) || (my_sms_no = (id)[NSNull null]))
    {
        NSString *message = [NSString stringWithFormat:@"%@ has not given us their service number yet!", businessName];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        
        
//        [UIAlertView showErrorAlert:message];
        return;
    }

    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = orderView.text;
        
        controller.recipients = [NSArray arrayWithObjects:my_sms_no, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }

}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (([textView.text length] > MAX_LENGTH) && [text length] > 0)  // text length of zero indicates back space or delete keys
    {
        [self.errorMessageView setHidden:FALSE];
        return FALSE;
    }
    else if([text isEqualToString:@"\n"]) {
        [errorMessageView setHidden:TRUE];
        [textView resignFirstResponder];
        return YES;
    } else {
        [errorMessageView setHidden:TRUE];
        return TRUE;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (firstTime) {
        firstTime = FALSE;
        // if the initial message is set then don't clear the text, otherwise do (the default text is the instruction)
        if (initialMessage.length < 1) {
            textView.text = @"";
            [textView setNeedsDisplay];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    firstTime = TRUE;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Ask %@", myBusiness.businessName];
    // Do any additional setup after loading the view from its nib.
    [errorMessageView setHidden:TRUE];
    errorMessageView.text = @"Remember house Woody Cat can't read more than 250 characters";
    [TapTalkLooks setToTapTalkLooks:cancelUIButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:askUIButton isActionButton:YES makeItRound:NO];
    if ((initialMessage.length > 1) && (initialMessage !=nil) )
        self.orderView.text = initialMessage;
    
    orderView.delegate = self;
    [orderView setReturnKeyType:UIReturnKeyDone];
    orderView.keyboardAppearance = UIKeyboardAppearanceDark;
    [self registerForKeyboardNotifications];

}

- (void)viewDidUnload {
    [self setOrderView:nil];
    [self setAskUIButton:nil];
    [self setCancelUIButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    UIAlertView *alert;
    MeowConfirmationViewController *orderconfirmation;
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Ordering" message:@"Unknown Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
        case MessageComposeResultSent:
            orderconfirmation = [[MeowConfirmationViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:orderconfirmation animated:YES];
            break;
        default:
            break;
    }
    alert = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)Cancel:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear your text?" message:@"Sure?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alert show];
}


#pragma UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        orderView.text = @"";
        [orderView resignFirstResponder];
//        [self.view setNeedsDisplay];
    }
    else {
        // do nothing
    }
}



- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, askUIButton.frame.origin) ) {
        [self.scrollView scrollRectToVisible:askUIButton.frame animated:YES];
    }
    if (!CGRectContainsPoint(aRect, cancelUIButton.frame.origin) ) {
        [self.scrollView scrollRectToVisible:cancelUIButton.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


@end
