//
//  TapTalkLooks.h
//  TapTalk
//
//  Created by Amir on 8/8/12.
//
//

#import <Foundation/Foundation.h>

@interface TapTalkLooks : NSObject

+ (void)setToTapTalkLooks:(UIView *)tempView isActionButton:(BOOL)action makeItRound:(BOOL)roundIt;

+ (void)setBackgroundImage:(UIView *)tempView;
+ (void)setBackgroundImage:(UIView *)tempView withBackgroundImage:(UIImage *)bgImage;
+ (void)setFontColorForView:(UIView *)tempView toColor:(UIColor *)color;
+ (void)setFontColorForLabelsInView:(UIView *)tempView toColor:(UIColor *)color;
+ (void)setFontColorForTextsInView:(UIView *)tempView toColor:(UIColor *)color;

@end
