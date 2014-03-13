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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        myBusiness = biz;
    }
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
        [UIAlertView showErrorAlert:message];
        return;
    }

    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = orderView.text;
        
        controller.recipients = [NSArray arrayWithObjects:my_sms_no, nil];
        controller.messageComposeDelegate = self;
//       [self presentModalViewController:controller animated:NO];  //compatibility
        [self presentViewController:controller animated:YES completion:nil];
    }

}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (([textView.text length] > MAX_LENGTH) && [text length] > 0)  // text length of zero indicates back space or delete keys
    {
        [self.errorMessageView setHidden:FALSE];
        return FALSE;
    }
    else {
        [errorMessageView setHidden:TRUE];
        return TRUE;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (firstTime) {
        firstTime = FALSE;
        textView.text = @"";
        [textView setNeedsDisplay];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    firstTime = TRUE;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Get service from %@", myBusiness.businessName];
    // Do any additional setup after loading the view from its nib.
    [errorMessageView setHidden:TRUE];
    errorMessageView.text = @"Remember house Woody Cat can't read more than 250 characters";
    [TapTalkLooks setToTapTalkLooks:cancelUIButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:askUIButton isActionButton:YES makeItRound:NO];

//    [errorMessageView setNeedsDisplay];
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
//    [self dismissModalViewControllerAnimated:YES]; Compatibility
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

/*
- (void)postJoinRequest
{
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Connecting", nil);
    
	NSURL* url = [NSURL URLWithString:ServerApiURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    
	[request setPostValue:@"join" forKey:@"cmd"];
	[request setPostValue:[dataModel userID] forKey:@"userID"];
	[request setPostValue:[dataModel deviceToken] forKey:@"token"];
	[request setPostValue:[dataModel nickname] forKey:@"name"];
	[request setPostValue:[dataModel secretCode] forKey:@"code"];
    
	[request setCompletionBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             if ([request responseStatusCode] != 200)
             {
                 ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
             }
             else
             {
                 [self userDidJoin];
             }
         }
     }];
    
	[request setFailedBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             ShowErrorAlert([[request error] localizedDescription]);
         }
     }];
    
	[request startAsynchronous];
}
*/

@end
