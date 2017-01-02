//
//  CartViewTableViewCell.m
//  TapForAll
//
//  Created by Harry on 11/21/16.
//
//

#import "CartViewTableViewCell.h"

@implementation CartViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.lbl_Description sizeToFit];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
