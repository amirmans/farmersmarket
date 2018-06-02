//
//  BusinessNotificationCell.m
//  TapForAll
//
//  Created by Harry on 4/14/16.
//
//

#import "AppDelegate.h"
#import "BusinessNotificationCell.h"

@implementation BusinessNotificationCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.notificationBadgeView.layer.cornerRadius = self.notificationBadgeView.frame.size.height/2;
    
    _rateView.hidden = true;
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
        
//        _lblOpenCloseDate.hidden = true;
//        _lblOpenClose.hidden = true;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
