//
//  ReferralViewController.h
//  TapForAll
//
//  Created by Amir on 4/24/18.
//

#import <UIKit/UIKit.h>

@interface ReferralViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *referredEmailLabel;
@property (strong, nonatomic) IBOutlet UITextField *referredEmailTextField;
@property (strong, nonatomic) IBOutlet UITextView *referralMessageTextView;
@property (strong, nonatomic) IBOutlet UITextField *referredNicknameTextField;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *referredNicknameLabel;
@property (strong, nonatomic) IBOutlet UIButton *referralSendButton;
@property (strong, nonatomic) IBOutlet UILabel *referralMessageLabel;
@property (strong, nonatomic) IBOutlet UITextView *referralInstructionTextView;


- (IBAction)referralSendAction:(id)sender;

@end
