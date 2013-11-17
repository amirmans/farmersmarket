//
//  ChatConfirmation.m
//  TapTalk
//
//  Created by Amir on 6/30/12.
//
//

@implementation ChatConfirmation
@synthesize textFieldInfo;
@synthesize actionInfo;
@synthesize chatRoomLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [chatRoomLabel setNumberOfLines:0];
    chatRoomLabel.lineBreakMode = UILineBreakModeWordWrap;
//    [chatRoomLabel sizeToFit];
//    chatRoomLabel.text = [[DataModel sharedDataModelManager] businessName];
    NSString *tempText = @"this is the business ABC";
    tempText = [tempText stringByAppendingString:@"\'s chatroom"];
    chatRoomLabel.text = tempText;
//    chatRoomLabel.text = [chatRoomLabel.text stringByAppendingString:@"\'s chatroom"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setChatRoomLabel:nil];
    [self setTextFieldInfo:nil];
    [self setActionInfo:nil];
    [super viewDidUnload];
}

- (IBAction)doSomething:(id)sender {
}
@end
