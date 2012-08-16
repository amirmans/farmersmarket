//
//  StoreMapViewController.m
//  TapTalk
//
//  Created by Amir on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreMapViewController.h"
#import "StoreMap.h"

@implementation StoreMapViewController
@synthesize storeMapImageView;
@synthesize mapScrollView;



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
    mapScrollView.delegate = self;
    self.title = @"Map of the store";
    
    // Configure zooming
    StoreMap *storeMap = [[StoreMap alloc] init];
    UIImage *mapImage = storeMap.map;
    
    CGSize mapImageSize = [mapImage size];
    CGSize scrollViewSize = mapScrollView.bounds.size;

    CGFloat widthRatio = mapImageSize.width / scrollViewSize.width;
    CGFloat heightRatio = mapImageSize.height / scrollViewSize.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
	mapScrollView.maximumZoomScale = 4.0;
    mapScrollView.minimumZoomScale = 1; /*initialZoom*/;
    mapScrollView.zoomScale  = 1; /*initialZoom;*/
    mapScrollView.bounces = YES;
    mapScrollView.bouncesZoom = YES;
    [mapScrollView setContentSize:CGSizeMake(mapImageSize.width * initialZoom,
                                          mapImageSize.height * initialZoom)];
    [mapScrollView setCenter:storeMapImageView.center];
    storeMapImageView.image = mapImage;
    
    
	[mapScrollView addSubview:storeMapImageView];
    [self.view addSubview:mapScrollView];
    
    
    
    
    [mapScrollView setBackgroundColor:[UIColor blackColor]];
    [mapScrollView setCanCancelContentTouches:NO];
    mapScrollView.clipsToBounds = YES;
    
    mapScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;     
}

- (void)viewDidUnload
{
    storeMapImageView = nil;
    [self setStoreMapImageView:nil];
    mapScrollView = nil;
    [self setMapScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.storeMapImageView;
}

@end
