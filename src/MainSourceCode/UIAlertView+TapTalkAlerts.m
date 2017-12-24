//
//  Category UIAlertView+TapTalkAlerts.m
//  TapTalk
//
//  Created by Amir on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+TapTalkAlerts.h"

@implementation UIAlertController (TapTalkAlerts)

+ (void)showErrorAlert:(NSString *)text {
//    UIAlertView *alertView = [[UIAlertView alloc]
//            initWithTitle:text
//                  message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//
//    [alertView show];
//    alertView = nil;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:text
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleCancel
                               handler:nil];
    [alert addAction:OKButton];
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    UIViewController *mainController = [keyWindow rootViewController];
    [mainController presentViewController:alert animated:YES completion:nil];
}

+ (void)showInformationAlert:(NSString *)text withTitle:(NSString *)title {
//    UIAlertView *alertView = [[UIAlertView alloc]
//                              initWithTitle:title
//                              message:text delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//    
//    [alertView show];
//    alertView = nil;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:text
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleCancel
                               handler:nil];
    [alert addAction:OKButton];
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    UIViewController *mainController = [keyWindow rootViewController];
    [mainController presentViewController:alert animated:YES completion:nil];
}


+ (void)showOKAlertForViewController:(UIViewController *)vc withText:(NSString *)text {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:text
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:nil];
}


@end
