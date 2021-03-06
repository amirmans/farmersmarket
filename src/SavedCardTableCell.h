//
//  SavedCardTableCell.h
//  TapForAll
//
//  Created by Harry on 2/25/16.
//
//

#import <UIKit/UIKit.h>

@interface SavedCardTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblCardNo;
@property (strong, nonatomic) IBOutlet UILabel *lblMonthYear;

@property (strong, nonatomic) IBOutlet UILabel *lblCardType;
@property (strong, nonatomic) IBOutlet UILabel *defaultLabl;
@property (strong, nonatomic) IBOutlet UISwitch *defaultSwitch;
- (IBAction)defaultSwitchAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *expDateLbl;

@end
