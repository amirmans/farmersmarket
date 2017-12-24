//
//  CartViewTableViewCell.h
//  TapForAll
//
//  Created by Harry on 11/21/16.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIButton.h"

@interface CartViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Description;
@property (weak, nonatomic) IBOutlet UILabel *lbl_totalItems;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Price;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Notes;

@property (weak, nonatomic) IBOutlet CustomUIButton *btnAddItem;
@property (weak, nonatomic) IBOutlet CustomUIButton *btnRemoveItem;


@end
