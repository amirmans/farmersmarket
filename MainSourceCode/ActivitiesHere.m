//
//  Home_Business
//  TapTalk
//
//  Created by Amir Amirmansoury on 8/25/11.
//  Copyright (c) 2011 __MyDoosts__. All rights reserved.
//

#import "ActivitiesHere.h"
#import "HistoryHereViewController.h"

@implementation ActivitiesHere


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
    }

    return self;
}


- (IBAction)performActivitiesHere:(id)sender {
//    NSBundle *bundle = [NSBundle mainBundle];

    NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
    NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
    EnterBusinessViewController *inPlaceViewController = [[EnterBusinessViewController alloc] initWithData:allChoices :mainChoices];
    [self.navigationController pushViewController:inPlaceViewController animated:YES];


    NSLog(@"in performActivitiesHere self.tabBarController.navigationController is: %@ and self.navigationController is: %@", self.tabBarController.navigationController, self.navigationController);
}


- (IBAction)history:(id)sender {
    HistoryHereViewController *historyViewController = [[HistoryHereViewController alloc] initWithNibName:nil bundle:nil];
//    historyViewController.hidesBottomBarWhenPushed = NO;
//    UINavigationController *historyNav = [[UINavigationController alloc] init];

//    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController pushViewController:historyViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Decisions,Decisions,...";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
