//
//  TapTalkLooks.m
//  TapTalk
//
//  Created by Amir on 8/8/12.
//
//

#import "TapTalkLooks.h"

@implementation TapTalkLooks


+ (void)setToTapTalkLooks:(UIView *)tempView isActionButton:(BOOL)action makeItRound:(BOOL)roundIt {
    if (action) {
        if ([tempView isKindOfClass:[UIButton class]]) {
            tempView.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
            [((UIButton *) tempView) setTitleColor:[UIColor colorWithRed:255.0f / 255.0f green:175.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];

            return;
        }
    }

    if (roundIt) {
        [[tempView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[tempView layer] setBorderWidth:2.3];
        [[tempView layer] setCornerRadius:15];
        [tempView setClipsToBounds:YES];
    }

    tempView.backgroundColor = [UIColor colorWithRed:255.0f / 255.0f green:204.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
    if ([tempView isKindOfClass:[UITextField class]])
        ((UITextField *) tempView).textColor = [UIColor blackColor];
}


+ (void)setBackgroundImage:(UIView *)tempView {
    // all these steps needs to be done to load the background image
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *imagePath = [bundle pathForResource:@"bg_image" ofType:@"jpg"];
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imagePath];

    UIGraphicsBeginImageContext(tempView.frame.size);
    [backgroundImage drawInRect:tempView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    tempView.backgroundColor = [UIColor colorWithPatternImage:image];
    backgroundImage = nil;
}

@end
