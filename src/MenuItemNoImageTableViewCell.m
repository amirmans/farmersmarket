//
//  MenuItemNoImageTableViewCell.m
//  TapForAll
//
//  Created by Harry on 6/3/16.
//
//

#import "MenuItemNoImageTableViewCell.h"

@implementation MenuItemNoImageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

    self.cellOuterView.layer.borderWidth = 1.0;
    self.cellOuterView.layer.borderColor = [UIColor colorWithDisplayP3Red:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0].CGColor;
    self.cellOuterView.layer.shadowColor = [UIColor colorWithDisplayP3Red:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0].CGColor;    self.cellOuterView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.cellOuterView.layer.shadowOpacity = 1.0;
    self.cellOuterView.layer.shadowRadius = 1.0;

    [self.imgProductIcon layoutIfNeeded];
    self.imgProductIcon.layer.cornerRadius = self.imgProductIcon.frame.size.width / 2;
    self.imgProductIcon.clipsToBounds = YES;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
