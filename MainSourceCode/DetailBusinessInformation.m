//
//  DetailBusinessInformation.m
//  TapTalk
//
//  Created by Amir on 3/19/12.
//  Copyright (c) 2012 MyDoosts.com . All rights reserved.
//

#import "VoteToAddBusinessConfirmation.h"
//#import "ServicesForBusinessViewController.h"
#import "GooglePlacesObject.h"
#import "DetailBusinessInformation.h"
#import "ServicesForBusinessTableViewController.h"
#import <QuartzCore/CALayer.h>
#import "DataModel.h"
#import "TapTalkLooks.h"


@interface DetailBusinessInformation ()

@end

@implementation DetailBusinessInformation

@synthesize activityIndicator;
@synthesize typesOfBusiness;
@synthesize rating;
@synthesize contactInfo;

@synthesize typesData;
@synthesize businessNameData;
@synthesize customerProfileName;
@synthesize distanceInMileString;
@synthesize referenceData;
@synthesize biz;
@synthesize isCustomer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil businessObject:(Business *)bizArg
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        googlePlacesConnection = [[GooglePlacesConnection alloc]initWithDelegate:self];
        biz = bizArg;
    }
    return self;
}

- (id)initWithBusinessObject:(Business *)bizArg
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        biz = bizArg;
        googlePlacesConnection = [[GooglePlacesConnection alloc]initWithDelegate:self];
        referenceData = biz.googlePlacesObject.reference;
        businessNameData = biz.googlePlacesObject.name;
        typesData = biz.googlePlacesObject.type;
        //distanceInMileString is valid in the google object but not in detailGoogleObject - weird
        distanceInMileString = biz.googlePlacesObject.distanceInMilesString;
        isCustomer = biz.isCustomer;
        if (self.isCustomer)
        {
            self.customerProfileName = biz.customerProfileName;
            assert(self.customerProfileName);
            [biz startLoadingBusinessProductCategoriesAndProducts]; //TODO
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // all these steps needs to be done to load the background image
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *imagePath = [bundle pathForResource: @"bg_image" ofType: @"jpg"];
//    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
//    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [backgroundImage drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
//    backgroundImage = nil;

    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:addToCustomersOrService isActionButton:YES makeItRound:NO];
    // Do any additional setup after loading the view from its nib.
    if (self.isCustomer) { 
        if (biz.isProductListLoaded)
            [addToCustomersOrService setTitle:@"Enter and get TapTalk service" forState:UIControlStateNormal];
        else {
            [addToCustomersOrService setTitle:@"Loading services" forState:UIControlStateNormal];
        }
    }
    else {
        [addToCustomersOrService setTitle:@"Vote to add as a customer" forState:UIControlStateNormal];
    }

    [googlePlacesConnection getGoogleObjectDetails:self.referenceData];
    [activityIndicator setHidesWhenStopped:TRUE];
    [activityIndicator startAnimating];
    self.title = businessNameData;

    NSString *typeText;
    NSString *tempText = [[NSString alloc] init];
    int index =0;
    for (typeText in typesData)
    {
        if( index == 0)
        {
            tempText = [NSString stringWithFormat:@"%@",typeText];
        }
        else {
            tempText = [NSString stringWithFormat:@"%@, %@",tempText, typeText];
        }
        index++;
    }

    tempText = [tempText capitalizedString];
    tempText = [NSString stringWithFormat:@"%@\n\n%@%@", tempText,distanceInMileString,@" miles from you"];
    typesOfBusiness.text = tempText;

    // setup looks of the ui elements
    [[typesOfBusiness layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[typesOfBusiness layer] setBorderWidth:2.3];
    [[typesOfBusiness layer] setCornerRadius:15];
    [typesOfBusiness setClipsToBounds: YES];
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
//    [TapTalkLooks setToTapTalkLooks:rating];

    tempText = nil;
}

- (void)viewDidUnload
{
    googlePlacesConnection = nil;
    referenceData = nil;
    businessNameData = nil;
    typesData = nil;
    
    [self setContactInfo:nil];
    [self setRating:nil];
    [self setTypesOfBusiness:nil];
    [self setActivityIndicator:nil];
//    [self setNext:nil];
    addToCustomersOrService = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addToCustomersOrGotoServicePage:(id)sender {
    
    if (self.isCustomer) {
        [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setBusinessName:self.customerProfileName];
        NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices; 
        NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
        ServicesForBusinessTableViewController *detailInfo =[[ServicesForBusinessTableViewController alloc] initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        [[DataModel sharedDataModelManager] setChatSystemURL:biz.chatSystemURL];
        [[DataModel sharedDataModelManager] setBusinessName:biz.businessName];
//        ServicesForBusinessViewController *detailInfo =[[ServicesForBusinessViewController alloc] initWithData:biz];
        [self.navigationController pushViewController:detailInfo animated:YES];
    }
    else {
        
        VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:confirmation animated:YES];
    }
}


#pragma mark -
#pragma mark GooglePlaces Delegation methods

//UPDATE - to handle filtering
- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)objects 
{
    
    if ([objects count] == 0) {
        [activityIndicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No additional information was for this location from google"
                                                        message:@"Try another place name or wait for a few minutes"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        //        locations = objects;
        //UPDATED locationFilterResults for filtering later on
        GooglePlacesObject *googleDetailObject = [objects objectAtIndex:0];

        rating.text =  [NSString stringWithFormat:@"%@", googleDetailObject.rating];
        contactInfo.text = googleDetailObject.formattedAddress;
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n"];
        contactInfo.text = [contactInfo.text stringByAppendingString:googleDetailObject.website];
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n"];
        contactInfo.text = [contactInfo.text stringByAppendingString:googleDetailObject.formattedPhoneNumber];

        contactInfo.dataDetectorTypes = UIDataDetectorTypeAll;
     }
    [activityIndicator stopAnimating];
//    [self.view setNeedsDisplay];
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting more information from Google - Try again"
                                                    message:[error localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];

    [activityIndicator stopAnimating];
//    [self.view setNeedsDisplay];
}

@end
