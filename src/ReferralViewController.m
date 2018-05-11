//
//  ReferralViewController.m
//  TapForAll
//
//  Created by Amir on 4/24/18.
//

#import "ReferralViewController.h"
#import "APIUtility.h"
#import "DataModel.h"
#import "AppData.h"

@interface ReferralViewController ()

@end

@implementation ReferralViewController

@synthesize referralSendButton, referralMessageLabel, referredEmailLabel, errorMessageLabel
    ,referredNicknameLabel, referredEmailTextField, referralMessageTextView, referredNicknameTextField
    ,referralInstructionTextView;

- (BOOL)validateAllUserInput
{
    BOOL badInformation = FALSE;
    short nVerificationSteps = 2;
    short loopIndex = 0;
    
    while ((loopIndex < nVerificationSteps) && (badInformation == FALSE)) {
        switch (loopIndex) {
            case 0:
                if (referredNicknameTextField.text.length < 2) {
                    badInformation = TRUE;
                    errorMessageLabel.hidden = FALSE;
                    errorMessageLabel.text = @"Nickname must be more the 2 chars long.";
                    errorMessageLabel.textColor = [UIColor blueColor];
                }
            
                break;
        
            case 1:
                if (referredEmailTextField.text.length > 0)
                {
                    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                    
                    if ([emailTest evaluateWithObject:referredEmailTextField.text] == NO) {
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
                
            default:
                break;
        }
        loopIndex++;
    } // while
    
    return !badInformation;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Refer Tap in here";
    
    errorMessageLabel.hidden = TRUE;
    // Do any additional setup after loading the view from its nib.
    referralInstructionTextView.text = @"We will send an email to your friend.  Once your friend registers, you'll be awarded 100 points (value of $5).\nThank you for being a loyal customer.";
    
    referralMessageTextView.text =@"Hi,\nI am enjoying Tap In Here; Variatey of food, with quality and reliability you need.  On top of that you accumulate reward points.  Download it and use it.  Enjoy!";
    
    self.referralMessageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.referralMessageTextView.layer.borderWidth = 1.0;
    self.referralMessageTextView.layer.cornerRadius = 8;
    
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

- (IBAction)referralSendAction:(id)sender {
    if ([self validateAllUserInput] ) {
        if ([DataModel sharedDataModelManager].userID <= 0) {
            [AppData showAlert:@"Error" message:@"No profile information!" buttonTitle:@"ok" viewClass:self];
            return;
        }
        
        NSString *referrer_id = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
        NSString *referrer_email= [DataModel sharedDataModelManager].emailAddress;
        
        NSDictionary *paramsDict = @{@"cmd":@"save_referral_info"
                                         ,@"referrer_id":referrer_id
                                         ,@"referrer_email":referrer_email
                                         ,@"referred_email": referredEmailTextField.text
                                         ,@"msg_to_referred": referralMessageTextView.text
                                    };
        [[APIUtility sharedInstance] callServer:paramsDict server:ReferralServer method:@"POST" completiedBlock:^(NSDictionary *response) {

            if([[response valueForKey:@"status"] integerValue] >= 0)
            {

                [AppData showAlert:@"Thank you!" message:@"Hopefully, you'll get your rewards soon!" buttonTitle:@"ok" viewClass:self];
            }
            else
            {
                [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
            }
        }];
    }
}
@end
