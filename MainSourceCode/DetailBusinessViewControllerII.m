//
//  DetailBusinessInformation.m
//  TapTalk
//
//  Created by Amir on 1/19/16.
//  Copyright (c) 2016 TapforIt.com . All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>
#import "VoteToAddBusinessConfirmation.h"
//#import "ServicesForBusinessViewController.h"
//#import "GooglePlacesObject.h"
#import "DetailBusinessViewControllerII.h"
#import "ServicesForBusinessTableViewController.h"
#import "ShakeHandWithBusinessViewController.h"
#import "DataModel.h"
#import "TapTalkLooks.h"
#import "CurrentBusiness.h"

#import "UIAlertView+TapTalkAlerts.h"
#import "LoginViewController.h"
#import "ChatMessagesViewController.h"
#import "UtilityConsumerProfile.h"

#import "KASlideShow.h"
#import "JBKenBurnsView.h"
#import "MBProgressHUD.h"
// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>




@interface DetailBusinessViewControllerII () {
    KASlideShow *picturesView;
    GMSMapView *mapView_;
}

@property (atomic, assign) BOOL viewIsDisplaying;
@end


@implementation DetailBusinessViewControllerII

@synthesize activityIndicator;
@synthesize rating;
@synthesize ratingLabel;
@synthesize contactInfo;
@synthesize businessNameData;
@synthesize customerProfileName;
@synthesize distanceInMileString;
@synthesize biz;
@synthesize isCustomer;
@synthesize showCodeButton;
@synthesize voteTobeCustomerButton;
@synthesize mapView;

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
        
        self.viewIsDisplaying = false;
    }

    return self;
}



- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    self.mapView.padding =
//    UIEdgeInsetsMake(self.topLayoutGuide.length + 5,
//                     0,
//                     self.bottomLayoutGuide.length + 5,
//                     0);
//    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewIsDisplaying = TRUE;
    [activityIndicator setHidesWhenStopped:TRUE];
    [activityIndicator startAnimating];
    
//    if (biz.picturesString != nil) {
//        //CGRect transformedBounds = CGRectApplyAffineTransform(picturesView_KSSlide.bounds, picturesView_KSSlide.transform);
//        //        CGRect picturesViewFrame = CGRectMake(9, 71, 302, 187);
//        CGRect picturesViewFrame = picturesView_KSSlide.frame;
//        picturesView = [[KASlideShow alloc] initWithFrame:picturesViewFrame];
//        [self.view addSubview:picturesView];
//        
//        [picturesView setDelay:3]; // Delay between transitions
//        [picturesView setTransitionDuration:2]; // Transition duration
//        [picturesView setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
//        [picturesView setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
//        
//        NSArray *bizpictureArray = [biz.picturesString componentsSeparatedByString:@","];
//        //        dispatch_async(dispatch_get_main_queue(), ^{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
//            NSString *imageRelativePathString;
//            UIImage  *image;
//            //[[self view] bringSubviewToFront:picturesView_KSSlide];
//            for (imageRelativePathString in bizpictureArray) {
//                // construct the absolute path for the image
//                imageRelativePathString = [imageRelativePathString stringByTrimmingCharactersInSet:
//                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *imageURLString = BusinessCustomerIndividualDirectory;
//                imageURLString = [imageURLString stringByAppendingFormat:@"//%i//%@",biz.businessID, imageRelativePathString];
//                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
//                if (image != nil) {
//                    [picturesView addImage:image];
//                }
//                else {
//                    NSLog(@"Image %@ didn't exist", imageURLString);
//                }
//            }
//            picturesView.delegate = self;
//            
//            // we stated to show it in the parent view
//            //        [MBProgressHUD hideHUDForView:self.view animated:YES];
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                if (self.viewIsDisplaying == TRUE) {
//                    [picturesView start];
//                }
//            });
//            
//        });
//    }
//    else {
//        typesOfBusiness.hidden = FALSE;
//    }
    
    [self doPopulateDisplayFields];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = businessNameData;

    // Do any additional setup after loading the view from its nib.
    // setup looks of the ui elements
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:rating isActionButton:NO makeItRound:NO];
    //[TapTalkLooks setBackgroundImage:self.view]; zzzzz
    [TapTalkLooks setToTapTalkLooks:enterAndGetService isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingLabel isActionButton:NO makeItRound:NO];

    if (self.isCustomer == 1) {
        [enterAndGetService setTitle:@"Enter" forState:UIControlStateNormal];
        showCodeButton.hidden = false;
        voteTobeCustomerButton.hidden = true;
        [TapTalkLooks setToTapTalkLooks:showCodeButton isActionButton:YES makeItRound:NO];
    }
    else {
        showCodeButton.hidden = TRUE;
        enterAndGetService.hidden = TRUE;
        voteTobeCustomerButton.hidden = false;

        [voteTobeCustomerButton setTitle:@"Add as a customer" forState:UIControlStateNormal];
        //voteTobeCustomerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [TapTalkLooks setToTapTalkLooks:voteTobeCustomerButton isActionButton:YES makeItRound:NO];
    }

//    [activityIndicator setHidesWhenStopped:TRUE];
//    [activityIndicator startAnimating];
//    self.title = businessNameData;
//    
//    if (biz.picturesString != nil) {
//        [picturesView_KSSlide setNeedsLayout];
//        [picturesView_KSSlide layoutIfNeeded ];
//        CGRect transformedBounds = CGRectApplyAffineTransform(picturesView_KSSlide.bounds, picturesView_KSSlide.transform);
////        CGRect picturesViewFrame = CGRectMake(9, 71, 302, 187);
//        CGRect picturesViewFrame = picturesView_KSSlide.frame;
//        picturesView = [[KASlideShow alloc] initWithFrame:transformedBounds];
//        [self.view addSubview:picturesView];
//        
//        [picturesView setDelay:3]; // Delay between transitions
//        [picturesView setTransitionDuration:2]; // Transition duration
//        [picturesView setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
//        [picturesView setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
//
//        NSArray *bizpictureArray = [biz.picturesString componentsSeparatedByString:@","];
////        dispatch_async(dispatch_get_main_queue(), ^{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
//            NSString *imageRelativePathString;
//            UIImage  *image;
//            //[[self view] bringSubviewToFront:picturesView_KSSlide];
//            for (imageRelativePathString in bizpictureArray) {
//                // construct the absolute path for the image
//                imageRelativePathString = [imageRelativePathString stringByTrimmingCharactersInSet:
//                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *imageURLString = BusinessCustomerIndividualDirectory;
//                imageURLString = [imageURLString stringByAppendingFormat:@"//%i//%@",biz.businessID, imageRelativePathString];
//                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
//                if (image != nil) {
//                    [picturesView addImage:image];
//                }
//                else {
//                    NSLog(@"Image %@ didn't exist", imageURLString);
//                }
//            }
//            picturesView.delegate = self;
//            
//            // we stated to show it in the parent view
//            //        [MBProgressHUD hideHUDForView:self.view animated:YES];
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                if (self.viewIsDisplaying == TRUE) {
//                    [picturesView start];
//                }
//            });
//            
//        });
//    }
//    else {
//        typesOfBusiness.hidden = FALSE;
//    }
//    
//    [self doPopulateDisplayFields];
//    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:45.536951
                                                            longitude:-122.649971
                                                                 zoom:10];
    mapView_ = [GMSMapView mapWithFrame:self.mapView.frame camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.mapType =  kGMSTypeNormal;
    self.mapView = mapView_;
    [self.view addSubview:self.mapView];
    
    
    // Creates a marker in the center of the map.
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = CLLocationCoordinate2DMake(45.5540999, -122.83644930000003);
    marker1.title = @"Koi Fusion";
    marker1.snippet = @"Bethany";
    marker1.map = self.mapView;
    marker1.map = nil;
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(45.3949638, -122.75168050000002);
    marker2.title = @"Koi Fusion";
    marker2.snippet = @"Bridgeport";
    marker2.map = self.mapView;

    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = CLLocationCoordinate2DMake(45.5047129, -122.6342027);
    marker3.title = @"Koi Fusion";
    marker3.snippet = @"Division";
    marker3.map = self.mapView;
    
    GMSMarker *marker4 = [[GMSMarker alloc] init];
    marker4.position = CLLocationCoordinate2DMake(45.5542509, -122.67553229999999);
    marker4.title = @"Koi Fusion";
    marker4.snippet = @"Mississippi";
    marker4.map = self.mapView;
    
    GMSMarker *marker5 = [[GMSMarker alloc] init];
    marker5.position = CLLocationCoordinate2DMake(45.403197, -122.76124290000001);
    marker5.title = @"Koi Fusion";
    marker5.snippet = @"Durham";
    marker5.map = self.mapView;

 
    

//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"bg_image.jpg"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIColor *bgColor = [UIColor colorWithPatternImage:image];
//    
//    [self.view setBackgroundColor:bgColor];
    
    
    [TapTalkLooks setBackgroundImage:self.view withBackgroundImage:biz.bg_image];
    [TapTalkLooks setFontColorForLabelsInView:self.view toColor:[UIColor whiteColor]];
}

- (void) viewWillDisappear:(BOOL)animated {

    self.viewIsDisplaying = FALSE;
    if (picturesView != nil) {
        [picturesView stop];
        picturesView = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    businessNameData = nil;
    [self setContactInfo:nil];
    [self setRating:nil];
    [self setActivityIndicator:nil];
    enterAndGetService = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)pushNextViewController {
    NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
    NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
    
    // needs to mainChoices and allChoices
    if ([BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts)
        [biz startLoadingBusinessProductCategoriesAndProducts];
    NSArray *tempNSArray = [allChoices objectForKey:@"Tap For All"];
    if (tempNSArray.count == 1 ) {
        
        if ([DataModel sharedDataModelManager].nickname.length < 1) {
            [UIAlertController showErrorAlert:@"You don't have a nick name yet.  Please go to the profile page and get one."];
        }
        else if (![UtilityConsumerProfile canUserChat]) {
            [UIAlertController showErrorAlert:@"You are NOT registered to particate in this chat.  Please ask the manager to add you."];
        }
        else {
            if (![[DataModel sharedDataModelManager] joinedChat]) {
                biz.needsBizChat = false;
                // show the user that are about to connect to a new business chatroom
                [DataModel sharedDataModelManager].shouldDownloadChatMessages = TRUE;
                LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
                loginController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
                
                [self presentViewController:loginController animated:YES completion:nil];
                loginController = nil;
            }
            
            ChatMessagesViewController *chatViewContoller = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:chatViewContoller animated:YES];
        }        
        
    }
    else {
        biz.needsBizChat = true;
        ServicesForBusinessTableViewController *services = [[ServicesForBusinessTableViewController alloc]
                                                        initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        
//        NSString *bgImageURL = @"";
//        if (biz.bg_image)
//            bgImageURL = [BusinessCustomerIconDirectory stringByAppendingString:biz.bg_image];
//        //    UIImage *cellBackgroundImage =[UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString:bgImageURL]]];
//        
////        UIImageView *temp = [[UIImageView alloc] init];
////        [temp Compatible_setImageWithURL:[NSURL URLWithString:bgImageURL] placeholderImage:nil options:SDWebImageProgressiveDownload];
// 
//        
//        
//        [services setCellBackGroundImageForCustomer:[UIImage imageNamed:@"koi_cell_bg.png"]];
        [self.navigationController pushViewController:services animated:YES];
//        temp = nil;
        services = nil;
    }
}

- (IBAction)enterAndGetServiceAction:(id)sender {
    if (self.isCustomer == 1) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:biz];
        [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:self.customerProfileName];

        [[DataModel sharedDataModelManager] setChatSystemURL:biz.chatSystemURL];
        [[DataModel sharedDataModelManager] setChat_masters:biz.chat_masters];
        [[DataModel sharedDataModelManager] setValidate_chat:biz.validate_chat];
        [[DataModel sharedDataModelManager] setBusinessName:biz.businessName];
        [[DataModel sharedDataModelManager] setShortBusinessName:biz.shortBusinessName];

        [self pushNextViewController];

    }
}


//- (void)addToCustomers {
//    VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:confirmation animated:YES];
//
//}

- (IBAction)showCode:(id)sender {
    ShakeHandWithBusinessViewController *shakeHandViewController = [[ShakeHandWithBusinessViewController alloc] initWithNibName:nil bundle:nil businessObject:biz];
    [self.navigationController pushViewController:shakeHandViewController animated:YES];
}

- (IBAction)voteTobeCustomerAction:(id)sender {
    VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:confirmation animated:YES];
}


#pragma mark -
- (void)doPopulateDisplayFields
{
    [activityIndicator stopAnimating];
    if (biz.businessError) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No additional information from google"
//                                                        message:@"Try another place or wait for a few minutes"
//                                                       delegate:nil cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
        
        [UIAlertController showOKAlertForViewController:self withText:@"No additional information from google.  Please try another place."];
    } else {
        if (biz.address == nil)
            contactInfo.text= @"Address not provided";
        else
            contactInfo.text = biz.address;
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n"];
        if (biz.website != Nil)
            contactInfo.text = [contactInfo.text stringByAppendingString:biz.website];
        else
            contactInfo.text = [contactInfo.text stringByAppendingString:@"website not provided."];
        contactInfo.text = [contactInfo.text stringByAppendingString:@"\n\n"];
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
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting more information from Google - Try again"
//                                                    message:[error localizedDescription]
//                                                   delegate:nil cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    [UIAlertController showOKAlertForViewController:self withText:@"Error getting more information from Google - Try again."];

    [activityIndicator stopAnimating];
}

@end
