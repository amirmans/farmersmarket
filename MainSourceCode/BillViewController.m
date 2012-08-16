//
//  BillViewController.m
//  TapTalk
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyDoosts__. All rights reserved.
//

#import "BillViewController.h"
#import "TapTalkLooks.h"

@implementation BillViewController

@synthesize rateView = _rateView;
@synthesize ratingString;
@synthesize billImageView, billScrollView;
@synthesize cancelUIButton;
@synthesize payUIButton;
@synthesize questionsUIButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TapTalkLooks setToTapTalkLooks:payUIButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:cancelUIButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:questionsUIButton isActionButton:YES makeItRound:YES];
    
    _rateView.notSelectedImage = [UIImage imageNamed:@"kermit_empty.png"];
    _rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    _rateView.fullSelectedImage = [UIImage imageNamed:@"kermit_full.png"];
    _rateView.rating = 0;
    _rateView.editable = YES;
    _rateView.maxRating = 5;
    _rateView.delegate = self;
    
    
    [billScrollView setBackgroundColor:[UIColor blackColor]];
    [billScrollView setCanCancelContentTouches:NO];
    billScrollView.clipsToBounds = YES;
    
    billScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    CGSize billSize = CGSizeMake(billImageView.frame.size.width, billImageView.frame.size.height);
    [billScrollView setContentSize:billSize];
    [billScrollView addSubview:billImageView];
    
}

- (void)viewDidUnload
{
    billScrollView = nil;
    billImageView = nil;
    [self setPayUIButton:nil];
    [self setQuestionsUIButton:nil];
    [self setCancelUIButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES]; 
}



- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating 
{
    const int intRating = roundf(rating);
    NSString *strRating = @"No opinion";
    switch (intRating)
    {
        case 1:
            strRating = @"No opinion";
            break;
        case 2:
            strRating = @"No good";
            break;
        case 3:
            strRating = @"Average good";
            break;
        case 4:
            strRating = @"Good";
            break;
        case 5:
            strRating = @"Wow";
            break;
            default:
            strRating = @"No opinion";
    }
    
    ratingString.text = strRating;
}


@end
