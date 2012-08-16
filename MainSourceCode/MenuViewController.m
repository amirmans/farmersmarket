//
//  MenuViewController.m
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//   

#import "MenuViewController.h"

@implementation MenuViewController


@synthesize webView;
@synthesize activityIndicator;


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


-(void)goHome
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)checkLoad
{
    if (webView.loading)
        [activityIndicator startAnimating];
}

-(void)checkNotLoad
{
    if (!(webView.loading))
        [activityIndicator stopAnimating];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //TODO
    NSURL *url = [NSURL URLWithString:@"http://www.opentable.com/sazerac"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkLoad) userInfo:nil repeats:YES];
    [activityIndicator startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkNotLoad) userInfo:nil repeats:YES];
 
    //UIBarButtonItem *homeButton = 
    //[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(goHome)];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStyleBordered target:self action:@selector(goHome)];
    
    self.navigationItem.rightBarButtonItem = homeButton;

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
