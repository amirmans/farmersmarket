//
//  ProductItemViewCell.h
//  TapTalk
//
//  Created by Amir on 4/22/12.
//  Copyright (c) 2012 MyDoosts.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductItemViewCell : UITableViewCell {

}
@property(weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property(weak, nonatomic) IBOutlet UITextField *title;
@property(weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *specialLabel;
@property (strong, nonatomic) IBOutlet UILabel *field_2_label;
@property (strong, nonatomic) IBOutlet UILabel *field_1_label;
@property (strong, nonatomic) IBOutlet UITextView *field_1_textview;
@property (strong, nonatomic) IBOutlet UITextView *field_2_textview;

@end
