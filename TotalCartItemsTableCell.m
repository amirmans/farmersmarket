//
//  TotalCartItemsTableCell.m
//  TapForAll
//
//  Created by Harry on 4/12/16.
//
//

#import "TotalCartItemsTableCell.h"

@implementation TotalCartItemsTableCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.lbl_Description sizeToFit];
    [self.lbl_OrderOption sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
