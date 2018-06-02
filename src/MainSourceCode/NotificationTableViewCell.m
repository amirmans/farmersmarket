//
//  NotificationTableViewCell.m
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//
#import "AppDelegate.h"
#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
            
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
