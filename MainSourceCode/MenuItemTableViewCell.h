//
//  MenuItemTableViewCell.h
//  TapForAll
//
//  Created by Harry on 2/9/16.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIButton.h"

@interface MenuItemTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *Content_back_view;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_description;
@property (strong, nonatomic) IBOutlet UIView *line_view;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Pts;
@property (strong, nonatomic) IBOutlet UILabel *lbl_money;
@property (strong, nonatomic) IBOutlet UILabel *lbl_dollar;
- (IBAction)btn_minus:(id)sender;

- (IBAction)btn_plus:(id)sender;
//@property (weak, nonatomic) IBOutlet UIButton *btnFevorite;
@property (strong, nonatomic) IBOutlet CustomUIButton *btnFevorite;


- (IBAction)btnFevoriteClicked:(id)sender;
@property (weak, nonatomic) IBOutlet CustomUIButton *btn_plus;
@property (weak, nonatomic) IBOutlet CustomUIButton *btn_minus;

@end
