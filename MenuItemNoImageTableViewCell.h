//
//  MenuItemNoImageTableViewCell.h
//  TapForAll
//
//  Created by Harry on 6/3/16.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIButton.h"

@interface MenuItemNoImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *ImageView;

@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;


@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_description;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Pts;
@property (strong, nonatomic) IBOutlet UILabel *lbl_money;
@property (strong, nonatomic) IBOutlet CustomUIButton *btnFevorite;
@property (weak, nonatomic) IBOutlet CustomUIButton *btn_plus;

@property (strong, nonatomic) IBOutlet UIView *addedItemView;
@property (weak, nonatomic) IBOutlet UIView *tempItemOutView;

@property (weak, nonatomic) IBOutlet UIImageView *imgContentBackGround;


@end
