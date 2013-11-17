//
//  Category UIAlertView+TapTalkAlerts.m
//  TapTalk
//
//  Created by Amir on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+TapTalkAlerts.h"

@implementation UIAlertView (TapTalkAlerts)

+ (void)showErrorAlert:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:text
                  message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];

    [alertView show];
    alertView = nil;
}

@end
