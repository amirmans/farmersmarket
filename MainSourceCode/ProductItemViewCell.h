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
@property (weak, nonatomic) IBOutlet UITextView *packageInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;
@property(weak, nonatomic) IBOutlet UITextField *title;
@property(weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
