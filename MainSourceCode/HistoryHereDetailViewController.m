//
//  HIstoryHereDetailViewController.m
//  TapTalk
//
//  Created by Amir on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryHereDetailViewController.h"

@implementation HistoryHereDetailViewController


@synthesize notes, picturesFromHere, bill, billScroller, picturesScroller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    notes.text = @"Nice atmosphere good coffee but very slow Internet";

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"PianoBarNYNYCrowd" ofType:@"jpg"];

    UIImage *image1 = [UIImage imageWithContentsOfFile:path];

    path = [bundle pathForResource:@"NYC_01.07_MomofukuSsamBar_Oysters" ofType:@"jpg"];
    UIImage *image2 = [UIImage imageWithContentsOfFile:path];

    path = [bundle pathForResource:@"having-fun-playing-pool-at-bar-50" ofType:@"jpg"];
    UIImage *image3 = [UIImage imageWithContentsOfFile:path];

    picturesFromHere.animationImages = [NSArray arrayWithObjects:image1, image2, image3, nil];
    picturesFromHere.animationDuration = 4;
    [picturesFromHere startAnimating];

    [picturesScroller setBackgroundColor:[UIColor blackColor]];
    [picturesScroller setCanCancelContentTouches:NO];
    picturesScroller.clipsToBounds = YES;    // default is NO, we want to restrict drawing within our scrollview
    picturesScroller.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    CGFloat picturesWidth = picturesFromHere.frame.size.width;
    CGFloat picturesHeight = picturesFromHere.frame.size.height;

    [picturesScroller setContentSize:CGSizeMake(picturesWidth, picturesHeight)];


    //Bill stuff
    path = [bundle pathForResource:@"ImageOfABill" ofType:@"jpg"];
    UIImage *billImage = [[UIImage alloc] initWithContentsOfFile:path];
    bill = [[UIImageView alloc] initWithImage:billImage];
    //   CGRect billFrame = bill.frame;
    //   billFrame.origin.x = billImage.size.width/2;

    [billScroller setBackgroundColor:[UIColor blackColor]];
    [billScroller setCanCancelContentTouches:NO];
    billScroller.clipsToBounds = YES;

    billScroller.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    CGSize billSize = CGSizeMake(bill.frame.size.width, bill.frame.size.height);
    [billScroller setContentSize:billSize];
    [billScroller addSubview:bill];

    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.billScroller.bounds.size;
    CGRect frameToCenter = bill.frame;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;

    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    bill.frame = frameToCenter;



    // Configure zooming.
    CGSize imageSize = [billImage size];
    CGSize screenSize = [bill bounds].size;
    CGFloat widthRatio = screenSize.width / imageSize.width;
    CGFloat heightRatio = screenSize.height / imageSize.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    billScroller.maximumZoomScale = 4.0;
    billScroller.minimumZoomScale = initialZoom;
    billScroller.zoomScale = initialZoom;
    billScroller.bounces = YES;
    billScroller.bouncesZoom = YES;
    [billScroller setContentSize:CGSizeMake(imageSize.width * initialZoom,
            imageSize.height * initialZoom)];
}


- (void)viewDidUnload {
    [self setNotes:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return bill;
}

@end
