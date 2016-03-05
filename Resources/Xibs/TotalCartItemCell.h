//
//  TotalCartItemCell.h
//  TapForAll
//
//  Created by Harry on 2/15/16.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIButton.h"

@interface TotalCartItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_menuImage;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Description;

@property (weak, nonatomic) IBOutlet UILabel *lbl_totalItems;


- (IBAction)btn_plus_Clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Price;
- (IBAction)btn_minus_clicked:(id)sender;

@property (weak, nonatomic) IBOutlet CustomUIButton *btn_minus;

@property (weak, nonatomic) IBOutlet CustomUIButton *btn_plus;

@end
