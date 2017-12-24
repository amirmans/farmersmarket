//
//  Tap4AllDisplayUtil.m
//  TapForAll
//
//  Created by Amir on 8/7/14.
//
//

#import "Tap4AllDisplayUtil.h"
#import "Consts.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation Tap4AllDisplayUtil


+ (void)displayPicturesInJBKenBurnsViewFromArrayOfURLs:(NSArray *)pictureArray forPictureview:(JBKenBurnsView *)picturesView inParentView:(UIView *)parentView
{
    picturesView.layer.borderWidth = 1;
    picturesView.layer.borderColor = [UIColor blueColor].CGColor;

    if (pictureArray.count > 1) {
        dispatch_queue_t loadImageQueue = dispatch_queue_create("com_mydoosts_com_queue",NULL);
        dispatch_async(loadImageQueue, ^{
            picturesView.hidden = FALSE;
            NSString *imageURLString;
            UIImage *image;
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for (imageURLString in pictureArray) {
                imageURLString = [imageURLString stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                [images addObject:image];
            }
            
            [picturesView animateWithImages:images transitionDuration:3 initialDelay:0 loop:YES isLandscape:NO];
            images = nil;
        });
    } else {
        picturesView.hidden = TRUE;
        CGRect imageViewRect = [picturesView frame];
        UIImageView *onePictureImageView =[[UIImageView alloc] initWithFrame:imageViewRect];
        [parentView addSubview:onePictureImageView];
        NSURL *imageURL = [NSURL URLWithString:[pictureArray objectAtIndex:0]];
        [onePictureImageView Compatible_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];
    }
}



+ (void)displayPicturesInJBKenBurnsViewFromArrayOfImages:(NSArray *)images forPictureview:(JBKenBurnsView *)picturesView inParentView:(UIView *)parentView
{
    picturesView.layer.borderWidth = 1;
    picturesView.layer.borderColor = [UIColor blueColor].CGColor;

    if (images.count > 1) {
        dispatch_queue_t loadImageQueue = dispatch_queue_create("com_mydoosts_com_queue",NULL);
        dispatch_async(loadImageQueue, ^{
            picturesView.hidden = FALSE;
            [picturesView animateWithImages:images transitionDuration:3 initialDelay:0 loop:YES isLandscape:NO];
        });
    } else {
        picturesView.hidden = TRUE;
        CGRect imageViewRect = [picturesView frame];
        UIImageView *onePictureImageView =[[UIImageView alloc] initWithFrame:imageViewRect];
        onePictureImageView.image = [images objectAtIndex:0];
        [parentView addSubview:onePictureImageView];
    }
    
}



@end