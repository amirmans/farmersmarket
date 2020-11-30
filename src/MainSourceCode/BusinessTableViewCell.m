//
//  BusinessTableViewCell.m
//  TapForAll
//
//  Created by Amir on 2/17/14.
//
//

#import "BusinessTableViewCell.h"
#import "AppDelegate.h"

@implementation BusinessTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
        _lblOpenCloseDate.hidden = true;
        [_lblOpenClose setHidden:true];
    }
    [self.tv_business_desc setUserInteractionEnabled:TRUE];
    [self.tv_business_desc setScrollEnabled:TRUE];

}

@end
