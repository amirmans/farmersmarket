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
#import "DataModel.h"
#import "TapTalkLooks.h"


@interface DetailBusinessViewController ()

@end

@implementation DetailBusinessViewController

@synthesize activityIndicator;
@synthesize typesOfBusiness;
@synthesize rating;
@synthesize contactInfo;
@synthesize businessNameData;
@synthesize customerProfileName;
@synthesize distanceInMileString;
@synthesize biz;
@synthesize isCustomer;


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
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:addToCustomersOrService isActionButton:YES makeItRound:NO];

    if (self.isCustomer == 1) {
        [addToCustomersOrService setTitle:@"Enter and use TapForAll services" forState:UIControlStateNormal];
    }
    else {
        [addToCustomersOrService setTitle:@"Vote to add as a customer" forState:UIControlStateNormal];
    }

    [activityIndicator setHidesWhenStopped:TRUE];
    [activityIndicator startAnimating];
    self.title = businessNameData;
    
    // setup looks of the ui elements
    [TapTalkLooks setToTapTalkLooks:typesOfBusiness isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
    [self doPopulateDisplayFields];
}

- (void)viewDidUnload {
    businessNameData = nil;
    [self setContactInfo:nil];
    [self setRating:nil];
    [self setTypesOfBusiness:nil];
    [self setActivityIndicator:nil];
    addToCustomersOrService = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addToCustomersOrShowServicePage:(id)sender {

    if (self.isCustomer == 1) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:self.customerProfileName];
        NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
        NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
        ServicesForBusinessTableViewController *detailInfo = [[ServicesForBusinessTableViewController alloc]
                initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        [[DataModel sharedDataModelManager] setChatSystemURL:biz.chatSystemURL];
        [[DataModel sharedDataModelManager] setBusinessName:biz.businessName];
        [biz startLoadingBusinessProductCategoriesAndProducts];
        [self.navigationController pushViewController:detailInfo animated:YES];
    }
    else {
        VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:confirmation animated:YES];
    }
}


#pragma mark -
- (void)doPopulateDisplayFields
{
    [activityIndicator stopAnimating];
    if (biz.businessError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No additional information was for this location from google"
                                                        message:@"Try another place name or wait for a few minutes"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {        
        NSString *tempText = biz.businessTypes;
        if (tempText == nil)
        {
            tempText =@"Business Types: Not Known";
        }
        if (distanceInMileString !=nil)
            tempText = [NSString stringWithFormat:@"%@\n%@%@", tempText, distanceInMileString, @" miles from you"];
        else if (biz.neighborhood)
            tempText = [NSString stringWithFormat:@"%@\nNeighborhood: %@", tempText, biz.neighborhood];
        else
            tempText = [NSString stringWithFormat:@"%@\n%@", tempText, @"N/A"];
        tempText = [tempText capitalizedString];
        
        typesOfBusiness.textAlignment =  NSTextAlignmentCenter;
        typesOfBusiness.text = tempText;
        
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
