//
//  HIstoryHereDetailViewController.h
//  TapTalk
//
//  Created by Amir on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryHereDetailViewController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UITextView *notes;
    IBOutlet UIScrollView *picturesScroller;
    IBOutlet UIImageView *picturesFromHere;
    IBOutlet UIScrollView *billScroller;
    IBOutlet UIImageView *bill;
}

@property (strong, nonatomic) UITextView *notes;
@property (atomic, retain) UIScrollView *picturesScroller;
@property (atomic, retain) UIImageView *picturesFromHere;
@property (atomic, retain) UIScrollView *billScroller;
@property (atomic, retain) UIImageView *bill;


@end
