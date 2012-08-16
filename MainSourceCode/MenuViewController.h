//
//  MenuViewController.h
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuViewController : UIViewController
{
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
}

@property (atomic, retain) IBOutlet UIWebView *webView;
@property (atomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;


@end