//
//  BusinessTableViewCell.m
//  TapForAll
//
//  Created by Amir on 2/17/14.
//
//

#import "MarketTableViewCell.h"
#import "AppDelegate.h"

@implementation MarketTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode) {
//        _lbl_market_open_hours.hidden = true;
//        [_lbl_mkt_pickup_location setHidden:true];
    }
    // Configure the view for the selected state
}

@end
