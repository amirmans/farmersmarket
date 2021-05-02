//
//  BusinessTableViewCell.h
//  TapForAll
//
//  Created by Amir on 2/17/14.
//
//

#import <UIKit/UIKit.h>
#import "RateView.h"
@interface MarketTableViewCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *businessIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet RateView *rateView;
@property (strong, nonatomic) IBOutlet UILabel *businessType;
//@property (strong, nonatomic) IBOutlet UILabel *businessAddress;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *lbl_market_open_hours;
@property (strong, nonatomic) IBOutlet UILabel *lbl_mkt_pickup_location;
@property (strong, nonatomic) IBOutlet UITextField *tf_mkt_pickup_location;
@property (strong, nonatomic) IBOutlet UITextView *businessAddress;
@property (strong, nonatomic) IBOutlet UITextField *tf_cutoff_datetime;
@property (strong, nonatomic) IBOutlet UITextField *tf_corp_website;
@property (strong, nonatomic) IBOutlet UITextField *tf_pickup_date;
@property (strong, nonatomic) IBOutlet UIImageView *iv_market_logo;
@property (strong, nonatomic) IBOutlet UIImageView *tempAccessoryImageView;
@property (strong, nonatomic) IBOutlet UIButton *lbChangeLocation;


@end
