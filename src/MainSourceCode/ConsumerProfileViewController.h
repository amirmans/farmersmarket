//
//  ConsumerProfile.h
//  TapTalk
//
//  Created by Amir on 6/25/12.
//
//

#import <UIKit/UIKit.h>

@interface ConsumerProfileViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property(weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageGroupTextField;
@property (strong, nonatomic) IBOutlet UITextField *smsNoTextField;

@property (strong, nonatomic) IBOutlet UILabel *zipcodeLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property(weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *smsNoLabel;

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UITableView *savedCardTable;

@property (weak, nonatomic) IBOutlet UISegmentedControl *ageGroupSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *emailWorkTextField;
@property (strong, nonatomic) IBOutlet UILabel *emailWorkLabel;

- (IBAction)saveButtonAction:(id)sender;
- (IBAction)ageGroupSegmentedControlAction:(id)sender;
//- (IBAction)resetButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *orderHistoryBtn;
- (IBAction)orderHistoryAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *manageCardsBtn;
- (IBAction)manageCardsAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *tv_tc_privacy;

@end
