//
//  MenuItemTableViewCell.m
//  TapForAll
//
//  Created by Harry on 2/9/16.
//
//

#import "MenuItemTableViewCell.h"

@implementation MenuItemTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btn_minus:(id)sender {
    
//    int value = [_lbl_money.text intValue];
//    
//      if (value) {
//          value -= 1;
//          int ptsValue = value * 10;
//    
//          _lbl_Pts.text =  [NSString stringWithFormat:@"%d%@", ptsValue,@" pts"];
//
//          _lbl_money.text = [NSString stringWithFormat:@"%d",value];
//      }
}
- (IBAction)btn_plus:(id)sender {
    
//    int value = [_lbl_money.text intValue];
//    
//    value += 1;
//    
//    int ptsValue = value * 10;
//    _lbl_Pts.text =  [NSString stringWithFormat:@"%d%@", ptsValue,@" pts"];
//    
//    _lbl_money.text = [NSString stringWithFormat:@"%d",value];
    
}
- (IBAction)btnFevoriteClicked:(id)sender {
}
@end
