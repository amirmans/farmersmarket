//
//  DetailBusinessVCTableViewCell.h
//  TapForAll
//
//  Created by Harry on 2/8/16.
//
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface DetailBusinessVCTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblOpenClose;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgBusinessIcon;
@property (weak, nonatomic) IBOutlet UILabel *bussinessType;
@property (weak, nonatomic) IBOutlet UILabel *bussinessAddress;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *btnFevorite;
@property (strong, nonatomic) IBOutlet UILabel *lblOpenCloseDate;
//@property (strong, nonatomic) Business *biz;

@end
