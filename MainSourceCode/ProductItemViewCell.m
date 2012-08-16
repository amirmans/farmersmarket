//
//  ProductItemViewCell.m
//  TapTalk
//
//  Created by Amir on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductItemViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductItemViewCell() {

    UIImageView *__backgroundImageView;
    
@private
    
}
@end


@implementation ProductItemViewCell

@synthesize productImageView;
@synthesize title;
@synthesize descriptionTextView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //– stretchableImageWithLeftCapWidth:topCapHeight:
        //__backgroundImageView = [[UIImageView alloc] initWithImage:...stretchableImage...];
        //self.contentView addSubview:__backgroundImageView];
        //[self.contentView sendSubviewToBack:__backgroundImageView];
        self.productImageView.layer.cornerRadius = 10.0;
        self.productImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 2;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
