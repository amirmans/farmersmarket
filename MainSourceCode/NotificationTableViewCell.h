//
//  NotificationTableViewCell.h
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *sender;
@property (weak, nonatomic) IBOutlet UITextField *dateAdded;
@property (weak, nonatomic) IBOutlet UIButton *readStatus;
@property (weak, nonatomic) IBOutlet UITextView *alertMessage;
@property (weak, nonatomic) IBOutlet UIImageView *businessNotificationIcon;

@end
