//
//  TotalCartItemsTableCell.h
//  TapForAll
//
//  Created by Harry on 4/12/16.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIButton.h"

@interface TotalCartItemsTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Description;

@property (weak, nonatomic) IBOutlet UILabel *lbl_totalItems;

@property (strong, nonatomic) IBOutlet UILabel *lbl_OrderOption;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Price;

@property (strong, nonatomic) IBOutlet UILabel *lbl_Points;

@property (strong, nonatomic) IBOutlet CustomUIButton *btnChangeOrder;

@property (strong, nonatomic) IBOutlet CustomUIButton *btnAddItem;
@property (strong, nonatomic) IBOutlet CustomUIButton *btnRemoveItem;


@end
