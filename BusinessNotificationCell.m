//
//  BusinessNotificationCell.m
//  TapForAll
//
//  Created by Harry on 4/14/16.
//
//

#import "BusinessNotificationCell.h"

@implementation BusinessNotificationCell

- (void)awakeFromNib {
    // Initialization code
    self.notificationBadgeView.layer.cornerRadius = self.notificationBadgeView.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
