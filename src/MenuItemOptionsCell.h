//
//  MenuItemOptionsCell.h
//  TapForAll
//
//  Created by Harry on 4/21/16.
//
//

#import <UIKit/UIKit.h>

@interface MenuItemOptionsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_CheckMark;
@property (strong, nonatomic) IBOutlet UILabel *lblItemName;
@property (weak, nonatomic) IBOutlet UIView *availabilityStatusView;


@end
