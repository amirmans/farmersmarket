//
//  BillViewController.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RateView.h"

@interface BillViewController : UIViewController <RateViewDelegate>
{
    RateView *rateView;
    UILabel *ratingString;
    
    __weak IBOutlet UIImageView *billImageView;
    __weak IBOutlet UIScrollView *billScrollView;
}

- (IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *payUIButton;
@property (weak, nonatomic) IBOutlet UIButton *questionsUIButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelUIButton;

@property (retain) IBOutlet RateView *rateView;
@property (atomic, retain) IBOutlet UILabel *ratingString;

@property (weak, atomic) IBOutlet UIScrollView *billScrollView;
@property (weak, atomic) IBOutlet UIImageView *billImageView;


@end
