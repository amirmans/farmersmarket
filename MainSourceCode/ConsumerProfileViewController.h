//
//  ConsumerProfile.h
//  TapTalk
//
//  Created by Amir on 6/25/12.
//
//

#import <UIKit/UIKit.h>

@interface ConsumerProfileViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *topContainerButton;
@property (weak, nonatomic) IBOutlet UIButton *lowerContainerButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;

- (IBAction)saveButtonAction:(id)sender;
- (IBAction)resetButtonAction:(id)sender;


@end
