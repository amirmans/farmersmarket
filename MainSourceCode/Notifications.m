//
//  Notifications.m
//  meowcialize
//
//  Created by Amir Amirmansoury on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Notifications.h"
#import "DataModel.h"
#import "NotificationPermissionViewController.h"


@implementation Notifications

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
- (void) viewWillAppear:(BOOL)animated {    
    NSString *business = [DataModel sharedDataModelManager].businessName;
    if ([[DataModel sharedDataModelManager] businessAllowedToSendNotification:business])
    {
        
    }
    else
    {
        NotificationPermissionViewController *checkPermission =[[NotificationPermissionViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:checkPermission animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
