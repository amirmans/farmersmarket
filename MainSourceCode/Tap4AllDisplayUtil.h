//
//  Tap4AllDisplayUtil.h
//  TapForAll
//
//  Created by Amir on 8/7/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface Tap4AllDisplayUtil : NSObject

+ (void)displayPicturesInJBKenBurnsViewFromArrayOfURLs:(NSArray *)picturesArray forPictureview:(JBKenBurnsView *)picturesView inParentView:(UIView *)parentView;

+ (void)displayPicturesInJBKenBurnsViewFromArrayOfImages:(NSArray *)images forPictureview:(JBKenBurnsView *)picturesView inParentView:(UIView *)parentView;

@end