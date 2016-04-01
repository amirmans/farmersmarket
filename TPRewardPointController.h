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
@interface TPRewardPointController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblPoints;
@property (strong, nonatomic) IBOutlet UILabel *lblLevel;
@property (strong, atomic) NSMutableArray *pointsarray;
@property (strong, atomic) NSMutableDictionary *pointsdictionary;
@end
