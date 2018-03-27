//
//  Category UIAlertView+TapTalkAlerts.h
//  TapTalk
//
//  This category created by Amir on 6/2/12.
//  Copyright (c) 2012 __TapForAll, Inc.__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (TapTalkAlerts)

+ (void)showErrorAlert:(NSString *)text;
+ (void)showOKAlertForViewController:(UIViewController *)vc withText:(NSString *)text;
+ (void)showInformationAlert:(NSString *)text withTitle:(NSString *)title;

@end
