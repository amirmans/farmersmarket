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
//            [((UIButton *) tempView) setTitleColor:[UIColor colorWithRed:255.0f / 255.0f green:175.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
            [((UIButton *) tempView) setTitleColor:[UIColor colorWithRed:153.0f / 255.0f green:255.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];

            return;
        }
    }

    if ([tempView isKindOfClass:[UILabel class]]) {
        [((UILabel *) tempView) setTextColor:[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]];
        return;
    }


    if (roundIt) {
        [[tempView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[tempView layer] setBorderWidth:2.3];
        [[tempView layer] setCornerRadius:15];
        [tempView setClipsToBounds:YES];
    }

//    tempView.backgroundColor = [UIColor colorWithRed:255.0f / 255.0f green:204.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
//    tempView.backgroundColor = [UIColor colorWithRed:235.0f / 255.0f green:204.0f / 255.0f blue:231.0f / 255.0f alpha:1.0f];
    tempView.backgroundColor = [UIColor colorWithRed:235.0f / 255.0f green:241.0f / 255.0f blue:231.0f / 255.0f alpha:1.0f];
    if ([tempView isKindOfClass:[UITextField class]])
        ((UITextField *) tempView).textColor = [UIColor blueColor];
}


+ (void)setBackgroundImage:(UIView *)tempView {
    // all these steps need to be done to load the background image
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *imagePath = [bundle pathForResource:@"bg_image" ofType:@"jpg"];
//    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
//
//    UIGraphicsBeginImageContext(tempView.frame.size);
//    [backgroundImage drawInRect:tempView.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    tempView.backgroundColor = [UIColor colorWithPatternImage:image];
//    backgroundImage = nil;
    
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_image.jpg"]];
    [backgroundView setContentMode: UIViewContentModeScaleAspectFit];
    [tempView addSubview:backgroundView];
    [tempView sendSubviewToBack: backgroundView];

    
//    UIGraphicsBeginImageContext(tempView.frame.size);
//    [[UIImage imageNamed:@"bg_image.jpg"] drawInRect:tempView.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    tempView.backgroundColor = [UIColor colorWithPatternImage:image];
//    
    
//    tempView.backgroundColor = [UIColor clearColor];
//    tempView.opaque = NO;
//    tempView.backgroundView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_image.jpg"]];
//
  
}


+ (void)setBackgroundImage:(UIView *)tempView withBackgroundImage:(UIImage *)bgImage {
    
    if (bgImage) {
        UIGraphicsBeginImageContext(tempView.frame.size);
        [bgImage drawInRect:tempView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIColor *bgColor = [UIColor colorWithPatternImage:image];
        
        [tempView setBackgroundColor:bgColor];
    }
    else {
        [tempView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_image.jpg"]]];
    }
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:bgImage];
//    [backgroundView setContentMode: UIViewContentModeScaleAspectFit];
//    [tempView addSubview:backgroundView];
//    [tempView sendSubviewToBack: backgroundView];
}

+ (void)setFontColorForView:(UIView *)tempView toColor:(UIColor *)color {

    //Get all UIViews in self.view.subViews
    for (UIView *view in [tempView subviews]) {
        //Check if the view is of UILabel class
        if ([view isKindOfClass:[UILabel class]]) {
            //Cast the view to a UILabel
            UILabel *label = (UILabel *)view;
            //Set the color to label
            label.textColor = color;
        }
        if ([view isKindOfClass:[UITextField class]]) {
            //Cast the view to a UILabel
            UITextField *textField = (UITextField *)view;
            //Set the color to label
            textField.textColor = color;
        }
        if ([view isKindOfClass:[UITextView class]]) {
            //Cast the view to a UILabel
            UITextView *textView = (UITextView *)view;
            //Set the color to label
            textView.textColor = color;
        }

    }
}

+ (void)setFontColorForLabelsInView:(UIView *)tempView toColor:(UIColor *)color {
    
    //Get all UIViews in self.view.subViews
    for (UIView *view in [tempView subviews]) {
        //Check if the view is of UILabel class
        if ([view isKindOfClass:[UILabel class]]) {
            //Cast the view to a UILabel
            UILabel *label = (UILabel *)view;
            //Set the color to label
            label.textColor = color;
        }
        
    }
}


+ (void)setFontColorForTextsInView:(UIView *)tempView toColor:(UIColor *)color {
    
    //Get all UIViews in self.view.subViews
    for (UIView *view in [tempView subviews]) {
        //Check if the view is of UILabel class
         if ([view isKindOfClass:[UITextField class]]) {
            //Cast the view to a UILabel
            UITextField *textField = (UITextField *)view;
            //Set the color to label
            textField.textColor = color;
        }
        if ([view isKindOfClass:[UITextView class]]) {
            //Cast the view to a UILabel
            UITextView *textView = (UITextView *)view;
            //Set the color to label
            textView.textColor = color;
        }
        
    }
}



@end
