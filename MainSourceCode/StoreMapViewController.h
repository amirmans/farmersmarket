//
//  StoreMapViewController.h
//  TapTalk
//
//  Created by Amir on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreMapViewController : UIViewController <UIScrollViewDelegate> {
    __weak IBOutlet UIScrollView *mapScrollView;
    __weak IBOutlet UIImageView *storeMapImageView;
}

@property(weak, nonatomic) IBOutlet UIImageView *storeMapImageView;
@property(weak, nonatomic) IBOutlet UIScrollView *mapScrollView;

@end
