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
@property (strong, nonatomic) IBOutlet UILabel *lblCVC;
@property (strong, nonatomic) IBOutlet UILabel *lblCardType;

@end
