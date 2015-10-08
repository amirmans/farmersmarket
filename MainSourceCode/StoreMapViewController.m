//
//  StoreMapViewController.m
//  TapTalk
//
//  Created by Amir on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreMapViewController.h"
#import "TapTalkLooks.h"
#import "CurrentBusiness.h"
#import "UIAlertView+TapTalkAlerts.h"

@implementation StoreMapViewController
@synthesize storeMapImageView;
@synthesize mapScrollView;


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
    mapScrollView.delegate = self;
    NSString *mapSubDir = [CurrentBusiness sharedCurrentBusinessManager].business.map_image_url;
    if (mapSubDir == nil) {
//        [UIAlertView showErrorAlert:@"Map is not given to us."];
        [UIAlertController showOKAlertForViewController:self withText:@"Map is not given to us."];
        return;
    }
        
    NSString *imageURLString = [BusinessCustomersMapDirectory stringByAppendingString:mapSubDir];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:nil
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                       if (image && finished) {
                           storeMapImageView.image = image;
                           self.mapScrollView.contentSize = storeMapImageView.image.size;
                           mapScrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
                           mapScrollView.minimumZoomScale = 1;
                           mapScrollView.maximumZoomScale = 5;
                           [mapScrollView setScrollEnabled:YES];
                           mapScrollView.contentInset = UIEdgeInsetsZero;
                       }
                   }];
    
    [TapTalkLooks setBackgroundImage:mapScrollView];

}


- (void)viewDidUnload {
    storeMapImageView = nil;
    [self setStoreMapImageView:nil];
    mapScrollView = nil;
    [self setMapScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.storeMapImageView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [mapScrollView setZoomScale:1.0 animated:YES];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)inscrollView
{
    UIView *subView = [inscrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (inscrollView.bounds.size.width > inscrollView.contentSize.width)?
    (inscrollView.bounds.size.width - inscrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (inscrollView.bounds.size.height > inscrollView.contentSize.height)?
    (inscrollView.bounds.size.height - inscrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(inscrollView.contentSize.width * 0.5 + offsetX,
                                 inscrollView.contentSize.height * 0.5 + offsetY);
}


@end
