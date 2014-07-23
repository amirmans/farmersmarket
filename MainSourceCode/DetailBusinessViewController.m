//
//  DetailBusinessInformation.m
//  TapTalk
//
//  Created by Amir on 3/19/12.
//  Copyright (c) 2012 MyDoosts.com . All rights reserved.
//

#import "VoteToAddBusinessConfirmation.h"
//#import "ServicesForBusinessViewController.h"
//#import "GooglePlacesObject.h"
#import "DetailBusinessViewController.h"
#import "ServicesForBusinessTableViewController.h"
#import "ShakeHandWithBusinessViewController.h"
#import "DataModel.h"
#import "TapTalkLooks.h"
#import "CurrentBusiness.h"

#import "KASlideShow.h"
#import "JBKenBurnsView.h"
#import "MBProgressHUD.h"


@interface DetailBusinessViewController () {
    KASlideShow *picturesView;
}


@end


@implementation DetailBusinessViewController

@synthesize activityIndicator;
@synthesize typesOfBusiness;
@synthesize rating;
@synthesize ratingLabel;
@synthesize contactInfo;
@synthesize businessNameData;
@synthesize customerProfileName;
@synthesize distanceInMileString;
@synthesize biz;
@synthesize isCustomer;
@synthesize showCodeButton;

// we don't have access to biz.isCustomer in all the methods of the class
- (void)setIsCustomer:(int)isCust {
    NSAssert ((isCust == 0 || isCust ==1),@"the only valid values are 0 or 1");
    isCustomer = (BOOL)isCust;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil businessObject:(Business *)bizArg {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        biz = bizArg;
        distanceInMileString = nil;
    }
    return self;
}

- (id)initWithBusinessObject:(Business *)bizArg {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        biz = bizArg;

        businessNameData = biz.businessName;
        //distanceInMileString is correct in the google object but not in detailGoogleObject - weird
        distanceInMileString = biz.googlePlacesObject.distanceInMilesString;
        isCustomer = biz.isCustomer;
        if (self.isCustomer == 1) {
            self.customerProfileName = biz.customerProfileName;
            assert(self.customerProfileName);
        }
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // setup looks of the ui elements
    [TapTalkLooks setToTapTalkLooks:typesOfBusiness isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:rating isActionButton:NO makeItRound:NO];
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:enterAndGetService isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingLabel isActionButton:NO makeItRound:NO];
    
    picturesView = nil;
    
    if (self.isCustomer == 1) {
        [enterAndGetService setTitle:@"Enter" forState:UIControlStateNormal];
        showCodeButton.hidden = false;
        [TapTalkLooks setToTapTalkLooks:showCodeButton isActionButton:YES makeItRound:NO];
    }
    else {
        showCodeButton.hidden = TRUE;
        enterAndGetService.hidden = TRUE;

        CGRect buttonFrame = enterAndGetService.frame;
        UIButton *voteToAddAsACustomer = [UIButton buttonWithType:UIButtonTypeCustom];
        [voteToAddAsACustomer addTarget:self action:@selector(addToCustomers) forControlEvents:UIControlEventTouchUpInside];
        buttonFrame.origin.x = 45;
        buttonFrame.size.width = 235;
        voteToAddAsACustomer.frame = buttonFrame;
        [voteToAddAsACustomer setTitle:@"Add as a customer" forState:UIControlStateNormal];
        voteToAddAsACustomer.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [TapTalkLooks setToTapTalkLooks:voteToAddAsACustomer isActionButton:YES makeItRound:NO];
        [self.view addSubview:voteToAddAsACustomer];
    }

    [activityIndicator setHidesWhenStopped:TRUE];
    [activityIndicator startAnimating];
    self.title = businessNameData;
    
    if (biz.picturesString != nil) {
        CGRect picturesViewFrame = CGRectMake(9, 71, 302, 177);
        picturesView = [[KASlideShow alloc] initWithFrame:picturesViewFrame];
        [self.view addSubview:picturesView];
        
        [picturesView setDelay:3]; // Delay between transitions
        [picturesView setTransitionDuration:2]; // Transition duration
        [picturesView setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
        [picturesView setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display

        NSArray *bizpictureArray = [biz.picturesString componentsSeparatedByString:@","];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *imageRelativePathString;
            UIImage  *image;
            for (imageRelativePathString in bizpictureArray) {
                // construct the absolute path for the image
                imageRelativePathString = [imageRelativePathString stringByTrimmingCharactersInSet:
                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *imageURLString = BusinessCustomerIndividualDirectory;
                imageURLString = [imageURLString stringByAppendingFormat:@"//%i//%@",biz.businessID, imageRelativePathString];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                if (image != nil) {
                    [picturesView addImage:image];
                }
                else {
                    NSLog(@"Image %@ didn't exist", imageURLString);
                }
            }
            picturesView.delegate = self;
            
            // we stated to show it in the parent view
            //        [MBProgressHUD hideHUDForView:self.view animated:YES];
            [picturesView start];
        });
    }
    else {
        typesOfBusiness.hidden = FALSE;
    }
    
    [self doPopulateDisplayFields];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    if (picturesView != nil)
        [picturesView stop];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    businessNameData = nil;
    [self setContactInfo:nil];
    [self setRating:nil];
    [self setTypesOfBusiness:nil];
    [self setActivityIndicator:nil];
    enterAndGetService = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)enterAndGetServiceAction:(id)sender {

    if (self.isCustomer == 1) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:biz];
        [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:self.customerProfileName];
        NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
        NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
        ServicesForBusinessTableViewController *detailInfo = [[ServicesForBusinessTableViewController alloc]
                initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        [[DataModel sharedDataModelManager] setChatSystemURL:biz.chatSystemURL];
        [[DataModel sharedDataModelManager] setChat_master_uid:biz.chat_master_uid];
        [[DataModel sharedDataModelManager] setBusinessName:biz.businessName];
        [biz startLoadingBusinessProductCategoriesAndProducts];
        [self.navigationController pushViewController:detailInfo animated:YES];
    }
}


- (void)addToCustomers {
    VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:confirmation animated:YES];

}

- (IBAction)showCode:(id)sender {
    ShakeHandWithBusinessViewController *shakeHandViewController = [[ShakeHandWithBusinessViewController alloc] initWithNibName:nil bundle:nil businessObject:biz];
    [self.navigationController pushViewController:shakeHandViewController animated:YES];
}


#pragma mark -
- (void)doPopulateDisplayFields
{
    [activityIndicator stopAnimating];
    if (biz.businessError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No additional information from google"
                                                        message:@"Try another place name or wait for a few minutes"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        if (! typesOfBusiness.isHidden) {
            NSString *tempText = biz.businessTypes;
            if (tempText == nil)
            {
                tempText =@"Business Types: Not Known";
            }
            if (distanceInMileString !=nil)
                tempText = [NSString stringWithFormat:@"\n%@\n%@%@", tempText, distanceInMileString, @" miles from you"];
            else if (biz.neighborhood)
                tempText = [NSString stringWithFormat:@"%@\n\nNeighborhood: %@", tempText, biz.neighborhood];
            else
                tempText = [NSString stringWithFormat:@"%@\n%@", tempText, @"N/A"];
            tempText = [tempText capitalizedString];
            
            typesOfBusiness.textAlignment =  NSTextAlignmentCenter;
            typesOfBusiness.text = tempText;
        }
        
        if (biz.address == nil)
            contactInfo.text= @"Address not provided";
        else
            contactInfo.text = biz.address;
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n"];
        if (biz.website != Nil)
            contactInfo.text = [contactInfo.text stringByAppendingString:biz.website];
        else
            contactInfo.text = [contactInfo.text stringByAppendingString:@"website not provided."];
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n\n"];
        if (biz.phone != nil)
            contactInfo.text = [contactInfo.text stringByAppendingString:biz.phone];
        else
            contactInfo.text = [contactInfo.text stringByAppendingString:@"Phone number not provided."];
        
        contactInfo.dataDetectorTypes = UIDataDetectorTypeAll;
        
        if (biz.rating)
        {
            rating.text = [[NSString stringWithFormat:@"%@", biz.rating] stringByAppendingString:@" out of 5"];
        }
        else
            rating.text = @"N/A";

    }

}

- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting more information from Google - Try again"
                                                    message:[error localizedDescription]
                                                   delegate:nil cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    [activityIndicator stopAnimating];
}

@end
