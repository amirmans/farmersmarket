//
//  BusinessDetailsTableCell.h
//  TapForAll
//
//  Created by Sanjay on 2/8/16.
//
//

#import <UIKit/UIKit.h>

@interface BusinessDetailsTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_Profile;

@property (strong, nonatomic) IBOutlet UILabel *lbl_profileName;

@property (weak, nonatomic) IBOutlet UIView *FoodView;

@end
