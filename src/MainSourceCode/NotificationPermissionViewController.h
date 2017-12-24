//
//  NotificationPermissionViewController.h
//  TapTalk
//
//  Created by Amir on 9/17/12.
//
//

#import <UIKit/UIKit.h>

@interface NotificationPermissionViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIButton *OKButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *notificationInitiatorTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstExplanationTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondExplanationTextField;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfAllowedNotificationsTextField;

- (IBAction)OKAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)stepperAction:(id)sender;

@end
