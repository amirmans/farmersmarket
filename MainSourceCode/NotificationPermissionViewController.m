//
//  NotificationPermissionViewController.m
//  TapTalk
//
//  Created by Amir on 9/17/12.
//
//

#import "NotificationPermissionViewController.h"
#import "TapTalkLooks.h"

@interface NotificationPermissionViewController ()

@end

@implementation NotificationPermissionViewController

@synthesize numberOfAllowedNotificationsTextField;
@synthesize OKButton, cancelButton;
@synthesize firstExplanationTextField, secondExplanationTextField;
@synthesize notificationInitiatorTextField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        numberOfAllowedNotificationsTextField.text = @"1";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:self.cancelButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:self.OKButton isActionButton:YES makeItRound:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OKAction:(id)sender {
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stepperAction:(id)sender {
    double newValue = [(UIStepper *)sender value];
    [numberOfAllowedNotificationsTextField setText:[NSString stringWithFormat:@"%d", (int)newValue]];
}

- (void)viewDidUnload {
    [self setBusinessNameTextField:nil];
    [self setNumberOfAllowedNotificationsTextField:nil];
    [super viewDidUnload];
}
@end
