//
//  ChatConfirmation.h
//  TapTalk
//
//  Created by Amir on 6/30/12.
//
//

#import <UIKit/UIKit.h>

@interface ChatConfirmation : UIViewController
@property(weak, nonatomic) IBOutlet UILabel *chatRoomLabel;

- (IBAction)doSomething:(id)sender;

@property(weak, nonatomic) IBOutlet UILabel *textFieldInfo;
@property(weak, nonatomic) IBOutlet UILabel *actionInfo;

@end
