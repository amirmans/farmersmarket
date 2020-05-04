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
@property (strong, nonatomic) IBOutlet UILabel *lblOpenCloseDate;
@property (weak, nonatomic) IBOutlet UILabel *lblOpenClose;
@property (strong, nonatomic) IBOutlet UITextView *businessAddress;

@end
