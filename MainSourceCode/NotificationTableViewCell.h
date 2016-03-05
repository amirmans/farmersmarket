//
//  NotificationTableViewCell.h
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblEventTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscription;
@property (strong, nonatomic) IBOutlet UIImageView *imgEventImage;
@property (strong, nonatomic) IBOutlet UIButton *btnLocation;
@property (strong, nonatomic) IBOutlet UIButton *btnAddToCalendar;


@end
