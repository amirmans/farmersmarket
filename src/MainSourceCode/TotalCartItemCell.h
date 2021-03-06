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



@property (weak, nonatomic) IBOutlet UILabel *lbl_totalItems;

@property (strong, nonatomic) IBOutlet UILabel *lbl_OrderOption;

- (IBAction)btn_plus_Clicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Price;

- (IBAction)btn_minus_clicked:(id)sender;

@property (weak, nonatomic) IBOutlet CustomUIButton *btn_minus;

@property (weak, nonatomic) IBOutlet CustomUIButton *btn_plus;

@property (strong, nonatomic) IBOutlet CustomUIButton *btnFavorite;

- (IBAction)minusButtonClicked:(id)sender;
- (IBAction)plusButtonClicked:(id)sender;


@end
