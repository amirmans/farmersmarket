//
//  ProductItemViewCell.m
//  TapTalk
//
//  Created by Amir on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductItemViewCell.h"

@interface ProductItemViewCell () {

    UIImageView *__backgroundImageView;

@private

}
@end


@implementation ProductItemViewCell

@synthesize productImageView;
@synthesize title;
@synthesize descriptionTextView;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.productImageView.layer.cornerRadius = 10.0;
//        self.layer.borderWidth = 2;
        
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
