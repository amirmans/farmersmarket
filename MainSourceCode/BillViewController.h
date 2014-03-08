//
//  BillViewController.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
@class Business;

@interface BillViewController : UIViewController <RateViewDelegate> {
    RateView *rateView;
    UILabel *ratingString;

    __weak IBOutlet UIImageView *billImageView;
    __weak IBOutlet UIScrollView *billScrollView;
    NSDecimalNumber *billInDollar;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz;

- (IBAction)cancel:(id)sender;
- (IBAction)readyToPayAction:(id)sender;
- (IBAction)questionsAction:(id)sender;

@property(weak, nonatomic) IBOutlet UIButton *payUIButton;
@property(weak, nonatomic) IBOutlet UIButton *questionsUIButton;
@property(weak, nonatomic) IBOutlet UIButton *cancelUIButton;

@property(retain) IBOutlet RateView *rateView;
@property(atomic, retain) IBOutlet UILabel *ratingString;

@property(weak, atomic) IBOutlet UIScrollView *billScrollView;
@property(weak, atomic) IBOutlet UIImageView *billImageView;
@property(strong, atomic) IBOutlet Business *billBusiness;
@property(strong, atomic) NSDecimalNumber *billInDollar;


@end
