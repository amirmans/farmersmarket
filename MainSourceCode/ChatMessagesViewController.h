//
//  MessagesFromOpenConnections.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 8/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapTalkChatMessage.h"


//@class DataModel;
@class ChatTableView;


@interface ChatMessagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TapTalkChatMessageDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITextField *composeMessageTextField;

@property (weak, nonatomic) IBOutlet ChatTableView *chatTableView;

//@property (atomic, strong) DataModel *dataModel; 
- (IBAction)sendMessage:(id)sender;

@end
