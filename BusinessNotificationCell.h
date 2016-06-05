//
//  BusinessNotificationCell.h
//  TapForAll
//
//  Created by Harry on 4/14/16.
//
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface BusinessNotificationCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgBusinessIcon;
@property (weak, nonatomic) IBOutlet UILabel *bussinessType;
@property (weak, nonatomic) IBOutlet UILabel *bussinessAddress;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *btnFevorite;
@property (strong, nonatomic) IBOutlet UILabel *lblOpenCloseDate;
@property (weak, nonatomic) IBOutlet UILabel *lblOpenClose;
@property (strong, nonatomic) IBOutlet UIView *notificationBadgeView;

@property (strong, nonatomic) IBOutlet UIImageView *img_LatestNotification;
@property (weak, nonatomic) IBOutlet UILabel *lblSentTime;


@end
