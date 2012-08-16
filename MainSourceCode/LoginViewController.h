
//@class DataModel;

// The Login screen lets the user register a nickname and chat room
@interface LoginViewController : UIViewController
{
}

@property (assign) BOOL cancelWasPushed;
@property (weak, nonatomic) IBOutlet UILabel *businessforThisChatRoom;
@property (nonatomic, retain) IBOutlet UITextField* nicknameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nicknameInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionNameButton;

- (IBAction)OKAction:(id)sender;

@end
