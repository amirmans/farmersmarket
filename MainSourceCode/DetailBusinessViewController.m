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
#import "BusinessDetailsContoller.h"
//#import "ServicesForBusinessTableViewController.h"
//#import "ShakeHandWithBusinessViewController.h"
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


@interface DetailBusinessViewController () {
    KASlideShow *picturesView;
}

@property (atomic, assign) BOOL viewIsDisplaying;
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
@synthesize voteTobeCustomerButton;
@synthesize picturesView_KSSlide;

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
        picturesView = nil;
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (picturesView !=nil) {
        [picturesView start];
    }
}



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewIsDisplaying = TRUE;
    [activityIndicator setHidesWhenStopped:TRUE];
    [activityIndicator startAnimating];
    
    if (biz.picturesString != nil) {
        //CGRect transformedBounds = CGRectApplyAffineTransform(picturesView_KSSlide.bounds, picturesView_KSSlide.transform);
        //        CGRect picturesViewFrame = CGRectMake(9, 71, 302, 187);
        CGRect picturesViewFrame = picturesView_KSSlide.frame;
        picturesView = [[KASlideShow alloc] initWithFrame:picturesViewFrame];
        [self.view addSubview:picturesView];
        
        [picturesView setDelay:3]; // Delay between transitions
        [picturesView setTransitionDuration:2]; // Transition duration
        [picturesView setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
        [picturesView setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
        
        NSArray *bizpictureArray = [biz.picturesString componentsSeparatedByString:@","];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
            NSString *imageRelativePathString;
            UIImage  *image;
            //[[self view] bringSubviewToFront:picturesView_KSSlide];
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
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (self.viewIsDisplaying == TRUE) {
                    [picturesView start];
                }
            });
            
        });
    }
    else {
        typesOfBusiness.hidden = FALSE;
    }
    
    [self doPopulateDisplayFields];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = businessNameData;
    //self.viewIsDisplaying = TRUE;
    //[[self view] bringSubviewToFront:typesOfBusiness];
    picturesView_KSSlide.hidden = true;
    // Do any additional setup after loading the view from its nib.
    // setup looks of the ui elements
    [TapTalkLooks setToTapTalkLooks:typesOfBusiness isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:rating isActionButton:NO makeItRound:NO];
    //[TapTalkLooks setBackgroundImage:self.view]; zzzzz
    [TapTalkLooks setToTapTalkLooks:enterAndGetService isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingLabel isActionButton:NO makeItRound:NO];
    
//    picturesView = nil;

//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = NSLocalizedString(@"Loading detaili business information...", @"");

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

//        CGRect buttonFrame = enterAndGetService.frame;
//        UIButton *voteToAddAsACustomer = [UIButton buttonWithType:UIButtonTypeCustom];
//        [voteToAddAsACustomer addTarget:self action:@selector(addToCustomers) forControlEvents:UIControlEventTouchUpInside];
        //buttonFrame.origin.x = 45;  zzzz
        //buttonFrame.size.width = 235; zzzz
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


- (void)pushNextViewController {
    
    NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
    NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
    
    // needs to mainChoices and allChoices
    
    NSLog(@"====8=8=8=8=8=8=8==88=8=%d",[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts);
   
    
    if ([BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts)
        [biz startLoadingBusinessProductCategoriesAndProducts];
    
    NSArray *tempNSArray = [allChoices objectForKey:@"Tap For All"];
    
    NSLog(@"%@",tempNSArray.debugDescription);
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
        BusinessDetailsContoller *services = [[BusinessDetailsContoller alloc]
                                                        initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        [self.navigationController pushViewController:services animated:YES];
        services = nil;
    }
}

- (IBAction)enterAndGetServiceAction:(id)sender {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = NSLocalizedString(@"Preparing to deliver TapForAll services", @"");
   // NSLog(@"Enter a business is pressed");
    if (self.isCustomer == 1) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:biz];
        [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:self.customerProfileName];
//        NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
//        NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
//        ServicesForBusinessTableViewController *services = [[ServicesForBusinessTableViewController alloc]
//                initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
        [[DataModel sharedDataModelManager] setChatSystemURL:biz.chatSystemURL];
        [[DataModel sharedDataModelManager] setChat_masters:biz.chat_masters];
        [[DataModel sharedDataModelManager] setValidate_chat:biz.validate_chat];
        [[DataModel sharedDataModelManager] setBusinessName:biz.businessName];
        [[DataModel sharedDataModelManager] setShortBusinessName:biz.shortBusinessName];
//        if ([BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts)
//            [biz startLoadingBusinessProductCategoriesAndProducts];
        [self pushNextViewController];
//        ServicesForBusinessTableViewController *services = [[ServicesForBusinessTableViewController alloc]
//                                                            initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:biz];
//        [self.navigationController pushViewController:services animated:YES];
//        services = nil;
    }
 //   [MBProgressHUD hideHUDForView:self.view animated:YES];
}


//- (void)addToCustomers {
//    VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:confirmation animated:YES];
//
//}

- (IBAction)showCode:(id)sender {
//    ShakeHandWithBusinessViewController *shakeHandViewController = [[ShakeHandWithBusinessViewController alloc] initWithNibName:nil bundle:nil businessObject:biz];
//    [self.navigationController pushViewController:shakeHandViewController animated:YES];
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
        if (! typesOfBusiness.isHidden) {
            NSString *tempText = biz.businessTypes;
            if (tempText == nil)
            {
                tempText =@"Business Types: Not Known";
            }
            if (distanceInMileString !=nil)
                tempText = [NSString stringWithFormat:@"\n%@\n%@%@", tempText, distanceInMileString, @" mi. from you"];
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
