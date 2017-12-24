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


@interface ChatMessagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TapTalkChatMessageDelegate> {

}

@property(strong, nonatomic) IBOutlet UIButton *sendButton;
@property(strong, nonatomic) IBOutlet UITextField *composeMessageTextField;
@property(strong, nonatomic) IBOutlet ChatTableView *chatTableView;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *toggleUpdatingChatMessages;


- (IBAction)sendMessage:(id)sender;

@end
