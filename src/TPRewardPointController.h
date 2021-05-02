//
//  TPRewardPointController.h
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "CurrentBusiness.h"
#import "DataModel.h"
#import "AppData.h"
@interface TPRewardPointController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblPoints;
@property (strong, atomic) NSMutableArray *pointsarray;
@property (strong, atomic) NSMutableDictionary *pointsdictionary;
@property (strong, nonatomic) IBOutlet UIImageView *businessBackgrounImage;
@property (strong, nonatomic) IBOutlet UILabel *lblCongrats;

@property (strong, nonatomic) IBOutlet UILabel *lblRedeemPoints;
@property (weak, nonatomic) IBOutlet UIButton *btnWait;
@property (weak, nonatomic) IBOutlet UIButton *btnRedeem;

@property (assign, nonatomic) BOOL isFromTotalCart;
@property(strong,nonatomic) NSString *currency_code;
@property  (strong,nonatomic) NSString *currency_symbol;
@property (strong, nonatomic) IBOutlet UITextView *tv_points_msg3;
@property (strong, nonatomic) IBOutlet UILabel *lbl_businessName;

@property (strong, nonatomic) IBOutlet UILabel *lbl_point_value;
//- (IBAction)btnRedeemClicked:(id)sender;
//- (IBAction)btnWaitClicked:(id)sender;


@end
