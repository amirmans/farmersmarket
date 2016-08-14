//
//  DetailBusinessInformation.m
//  TapTalk
//  Created by Amir on 1/19/16.
//  Copyright (c) 2016 TapforIt.com . All rights reserved.

#import <GoogleMaps/GoogleMaps.h>
#import "VoteToAddBusinessConfirmation.h"
//#import "ServicesForBusinessViewController.h"
//#import "GooglePlacesObject.h"
#import "DetailBusinessViewControllerII.h"
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
#import "APIUtility.h"
#import "AppData.h"
#import "DetailBusinessVCTableViewCell.h"
#import "BusinessDetailsContoller.h"
// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>
#import "RewardDetailsModel.h"

static NSString * const TitleKey = @"title";
static NSString * const SubTitleKey = @"Subtitle";
static NSString * const InfoKey = @"info";
static NSString * const LatitudeKey = @"latitude";
static NSString * const LongitudeKey = @"longitude";
static NSString * const pinImage = @"pinIma";

static const CGFloat CalloutYOffset = 50.0f;
static const CGFloat DefaultZoom = 12.0f;

@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end


@interface DetailBusinessViewControllerII () {
    KASlideShow *picturesView;
//    GMSMapView *mapView_;

    GMSMapView *mapViews;
    UIView *emptyCalloutView;

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
@synthesize locationManager;

// we don't have access to biz.isCustomer in all the methods of the class
- (void)setIsCustomer:(int)isCust {
    NSAssert ((isCust == 0 || isCust ==1),@"the only valid values are 0 or 1");
    isCustomer = (BOOL)isCust;
}

#pragma mark - Life Cycle

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
     //    mapViews = [[GMSMapView alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width ,self.viewMap.bounds.size.height)];
    
//    mapViews.delegate = self;
//    mapViews.mapType =  kGMSTypeNormal;

    
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

- (void) viewDidAppear:(BOOL)animated {
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
    self.navigationItem.hidesBackButton =  true;
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    // setup looks of the ui elements
    [TapTalkLooks setToTapTalkLooks:contactInfo isActionButton:NO makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:rating isActionButton:NO makeItRound:NO];
    //[TapTalkLooks setBackgroundImage:self.view]; zzzzz
    [TapTalkLooks setToTapTalkLooks:enterAndGetService isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingLabel isActionButton:NO makeItRound:NO];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.detailTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

    if (self.isCustomer == 1) {
        [enterAndGetService setTitle:@"Enter" forState:UIControlStateNormal];
        showCodeButton.hidden = false;
        voteTobeCustomerButton.hidden = true;
        [TapTalkLooks setToTapTalkLooks:showCodeButton isActionButton:YES makeItRound:NO];
    } else {
        showCodeButton.hidden = TRUE;
        enterAndGetService.hidden = TRUE;
        voteTobeCustomerButton.hidden = false;

        [voteTobeCustomerButton setTitle:@"Add as a customer" forState:UIControlStateNormal];
        //voteTobeCustomerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [TapTalkLooks setToTapTalkLooks:voteTobeCustomerButton isActionButton:YES makeItRound:NO];
    }
    
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
 
    self.calloutView = [[SMCalloutView alloc] init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    button.tintColor = [UIColor whiteColor];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(calloutAccessoryButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    self.mapView.delegate = self;
    
    locationManager.desiredAccuracy = 10.0f;
    locationManager.distanceFilter = 200.0f;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
//    self.mapView.mapType = MKMapTypeStandard;
    
    //Get Current Location
    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    NSLog(@"current location lat = %@ long = %@", latitudeString, longitudeString);
//    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[latitudeString doubleValue]
//                                                                    longitude:[longitudeString doubleValue]
//                                                                         zoom:DefaultZoom];

//    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:45.55409990
//                                                                    longitude:-122.83644930
//                                                                         zoom:DefaultZoom];
//
//    mapViews = [GMSMapView mapWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width ,self.viewMap.bounds.size.height) camera:cameraPosition];
//    
//    mapViews = [[GMSMapView alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width ,self.viewMap.bounds.size.height)];
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:45.55409990
                                                                    longitude:-122.83644930
                                                                         zoom:DefaultZoom];
    
    mapViews = [GMSMapView mapWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width ,self.viewMap.bounds.size.height) camera:cameraPosition];

    mapViews.delegate = self;
    mapViews.mapType =  kGMSTypeNormal;
    [self.viewMap addSubview:mapViews];
    emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addMarkersToMap];
    
    NSMutableArray *SortByLocationArray = [self getSortByLocationTapForApp];
    [self.bussinessListByBranch removeAllObjects];
    self.bussinessListByBranch = SortByLocationArray;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CLLocationCoordinate2D center;
    center= [[APIUtility sharedInstance]getLocationFromAddressString:biz.address];
    NSLog(@"%@",biz.address);
    
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:center.latitude
    //                                                            longitude:center.longitude
    //                                                                 zoom:0];
    //    mapView = [GMSMapView mapWithFrame:self.mapView.frame camera:camera];
    //    mapView.myLocationEnabled = YES;
    //    mapView.mapType =  kGMSTypeNormal;
    //    self.mapView = mapView;
    //    [self.view addSubview:self.mapView];
    
    
    // Creates a marker in the center of the map.
    //    GMSMarker *marker1 = [[GMSMarker alloc] init];
    //    marker1.position = CLLocationCoordinate2DMake(center.latitude, center.longitude);
    //    marker1.title = @"Koi Fusion";
    //    marker1.snippet = @"Bethany";
    //    marker1.map = self.mapView;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    businessNameData = nil;
    [self setContactInfo:nil];
    [self setRating:nil];
    [self setActivityIndicator:nil];
    enterAndGetService = nil;
    [super viewDidUnload];
    
    mapViews.delegate = nil;
    locationManager = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Custom Methods

- (void)deleteOrderData {

}

- (void)setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) favRating {
    
//    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":@"1",@"rating":favRating,@"id":businessId,@"type":@"1"};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        
    }];
}

-(NSMutableArray *)getSortByLocationTapForApp
{
    NSArray *testLocations = [NSArray arrayWithArray:self.bussinessListByBranch];

    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];
    
    NSArray *orderedUsers = [testLocations sortedArrayUsingComparator:^(id a,id b) {
        Business *userA = [[Business alloc] initWithDataFromDatabase:a];
        Business *userB = [[Business alloc] initWithDataFromDatabase:b];
//        BCSBlip userA = (BCSBlip )a;
//        BCSBlip userB = (BCSBlip )b;
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:userA.lat  longitude:userA.lng];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:userB.lat longitude:userB.lng];
        
        CLLocationDistance distanceA = [location1 distanceFromLocation:myLocation];
        CLLocationDistance distanceB = [location2 distanceFromLocation:myLocation];
        
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return [orderedUsers mutableCopy];
}

- (void)calloutAccessoryButtonTapped:(id)sender {
    if (mapViews.selectedMarker) {
        
        GMSMarker *marker = mapViews.selectedMarker;
        NSDictionary *userData = marker.userData;
        
        //        BusinessDetailsContoller *BusinessDetailsVC = [[BusinessDetailsContoller alloc] initWithNibName:@"BusinessDetailsContoller" bundle:nil];
        //
        //        [self.navigationController pushViewController: BusinessDetailsVC animated:YES];
        
        [self enterAndGetServiceAction:self];
        
        NSLog(@"Title: %@",userData[TitleKey]);
        NSLog(@"Info: %@",userData[InfoKey]);
    }
}

- (void)addMarkersToMap {

    self.markerArray = [[NSMutableArray alloc]init];
    for (NSDictionary *markerInfo in self.bussinessListByBranch) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        UIImage *pinImages = [UIImage imageNamed:@"pin3"];
        
        CLLocationCoordinate2D center;
        center= [[APIUtility sharedInstance]getLocationFromAddressString:[markerInfo valueForKeyPath:@"address"]];
        
        Business *biz1 = [[Business alloc] initWithDataFromDatabase:markerInfo];
        marker.position = CLLocationCoordinate2DMake(biz1.lat, biz1.lng);
        marker.title = biz1.businessName;
        marker.icon = pinImages;
        marker.userData = markerInfo;
        marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
        marker.groundAnchor = CGPointMake(0.5, 1.0);
        marker.map = mapViews;
        [self.markerArray addObject:marker];
    }
    [self focusMapToShowAllMarkers];
}

- (void)focusMapToShowAllMarkers
{
    //    CLLocationCoordinate2D myLocation = ((GMSMarker *)self.markerArray.firstObject).position;
    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    CLLocation *myLocation1 = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];
    CLLocationCoordinate2D myLocation = myLocation1.coordinate;
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];
    
    for (GMSMarker *marker in self.markerArray)
        bounds = [bounds includingCoordinate:marker.position];
    
    [mapViews animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

- (void)doPopulateDisplayFields {
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

#pragma mark - Button Actions

- (IBAction) backBUttonClicked: (id) sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)enterAndGetServiceAction:(id)sender {
    
    if (self.isCustomer == 1) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:selectedBiz];
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
//    ShakeHandWithBusinessViewController *shakeHandViewController = [[ShakeHandWithBusinessViewController alloc] initWithNibName:nil bundle:nil businessObject:biz];
//    [self.navigationController pushViewController:shakeHandViewController animated:YES];
}

- (IBAction)voteTobeCustomerAction:(id)sender {
    VoteToAddBusinessConfirmation *confirmation = [[VoteToAddBusinessConfirmation alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:confirmation animated:YES];
}

#pragma mark - GMSMapViewDelegate
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
   
    CLLocationCoordinate2D anchor = marker.position;
    
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
    
    if(marker.userData != nil){
        self.calloutView.title = marker.title;
        self.calloutView.subtitle = [marker.userData valueForKeyPath:@"customerProfileName"];
        self.calloutView.calloutOffset = CGPointMake(0, -CalloutYOffset);
        self.calloutView.hidden = NO;
        
        
        NSString *bg_color = [marker.userData valueForKeyPath:@"bg_color"];
        
        UIColor *businessColor = [[AppData sharedInstance] setUIColorFromString:bg_color];
        self.calloutView.backgroundView.containerView.backgroundColor = businessColor;
        
        //        self.whiteArrowImage = [self image:self.blackArrowImage withColor:[AppData businessBackgroundColor]];
        
        self.calloutView.backgroundView.whiteArrowImage = [self.calloutView.backgroundView image:self.calloutView.backgroundView.blackArrowImage withColor:businessColor];
        
        self.calloutView.backgroundView.arrowImageView = [[UIImageView alloc] initWithImage:self.calloutView.backgroundView.whiteArrowImage];
        [self.calloutView.backgroundView.arrowView addSubview:self.calloutView.backgroundView.arrowImageView];

        UIImageView *thumbView = [[UIImageView alloc] init];
        NSString *tmpIconName = [marker.userData valueForKeyPath:@"icon"];
        
        //    NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        //    NSURL *imageURL = [NSURL URLWithString:imageURLString];
        //    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
        {
            NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            [thumbView Compatible_setImageWithURL:imageURL placeholderImage:nil];
        }
        
        thumbView.layer.cornerRadius = 2.0;
        thumbView.layer.masksToBounds = YES;
        
        // wrap it in a blue background on iOS 7+
        UIButton *blueView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        blueView.backgroundColor = [UIColor clearColor];
        
        //[blueView addTarget:self action:@selector(carClicked) forControlEvents:UIControlEventTouchUpInside];
        thumbView.frame = CGRectMake(0, 0, 44, 44);
        [blueView addSubview:thumbView];
        
        self.calloutView.leftAccessoryView = blueView;
        self.calloutView.leftAccessoryView = thumbView;
        
    }else{
        self.calloutView.title = @"My Location";
    }
    
    [self.calloutView presentCalloutFromRect:calloutRect
                                      inView:mapView
                           constrainedToView:mapView
                                    animated:YES];
    
    return emptyCalloutView;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
   
    self.calloutView.hidden = YES;
}

- (void)mapView:(GMSMapView *)mapView
didChangeCameraPosition:(GMSCameraPosition *)position {
    self.calloutView.hidden = YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    /* don't move map camera to center marker on tap */
    NSDictionary *dataDict = marker.userData;
    NSString *lat = [dataDict valueForKey:@"lat"];
    NSString *lng = [dataDict valueForKey:@"lng"];
    
//    [self setMapCameraTo:[lat doubleValue] lng:[lng doubleValue] mile:40];
    
    [self centerTapedMarker:[lat doubleValue] lng:[lng doubleValue]];
    mapViews.selectedMarker = marker;
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self calulateAndDisplayLocationFor:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"OldLocation");
}

- (void)calulateAndDisplayLocationFor:(CLLocation *)argLocation {
    if (currentLocation == argLocation) {
        return;
    }
    MKCoordinateSpan span;
    span.longitudeDelta = 0.002;
    span.latitudeDelta = 0.002;
    
    region.span = span;
    region.center = argLocation.coordinate;

    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = CLLocationCoordinate2DMake(region.center.latitude, region.center.longitude);
    marker1.title = @"Koi Fusion";
    marker1.snippet = @"Bethany";
    marker1.map = mapViews;

    currentLocation = argLocation;
}

- (void)pushNextViewController {
      biz = selectedBiz;
    NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
    NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
    
    
    NSLog(@"=8=8=8=8=8=8=8=8==88=8= %d",[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts);
    // needs to mainChoices and allChoices
    if ([BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].loadProducts)
    {
        [biz startLoadingBusinessProductCategoriesAndProducts];
//        [[RewardDetailsModel sharedInstance] getRewardData:biz];
        [[RewardDetailsModel sharedInstance] getRewardData:biz completiedBlock:^(NSDictionary *response) {
            if (1) {
                NSDictionary *reward = response;
                NSLog(@"%@",reward);
                NSString *total_available_points = [[[reward valueForKey:@"data"] valueForKey:@"total_available_points"] stringValue];
                
                [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:total_available_points];
                
            }

        }];
    }
    
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
        BusinessDetailsContoller *services = [[BusinessDetailsContoller alloc]
                                              initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:selectedBiz];
        //        NSString *bgImageURL = @"";
        //        if (biz.bg_image)
        //            bgImageURL = [BusinessCustomerIconDirectory stringByAppendingString:biz.bg_image];
        //        //    UIImage *cellBackgroundImage =[UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString:bgImageURL]]];
        //
        //        UIImageView *temp = [[UIImageView alloc] init];
        //        [temp Compatible_setImageWithURL:[NSURL URLWithString:bgImageURL] placeholderImage:nil options:SDWebImageProgressiveDownload];

        //        [services setCellBackGroundImageForCustomer:[UIImage imageNamed:@"koi_cell_bg.png"]];
        
        [self.navigationController pushViewController:services animated:YES];
        //        temp = nil;
        services = nil;
    }
}

- (void)setMapCameraTo :(double)lat lng:(double)lng mile:(float)mile{
    
    mile = mile + 1.0;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
        double radius = mile * 621.371;
    
    region = MKCoordinateRegionMakeWithDistance(center,radius,radius);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/1.00, region.center.longitude - region.span.longitudeDelta/1.15);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/1.00, region.center.longitude + region.span.longitudeDelta/1.15);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:southWest coordinate:northEast];
    
    mapViews.camera = [mapViews cameraForBounds:bounds insets:UIEdgeInsetsMake(10, 0, 0, 0)];
}

- (void) centerTapedMarker :(double)lat lng:(double)lng {
    CGFloat currentZoom = self.mapView.camera.zoom;
    GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:currentZoom];
    [self.mapView setCamera:sydney];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bussinessListByBranch.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"DetailBusinessVCTableViewCell";
    
    DetailBusinessVCTableViewCell *cell = (DetailBusinessVCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailBusinessVCTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *cellDict;
    cellDict = [self.bussinessListByBranch objectAtIndex:indexPath.row];
    Business *biz1 = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:indexPath.row]];
//    cell.biz = biz1;
    
    cell.lblOpenCloseDate.text =[[APIUtility sharedInstance]getOpenCloseTime:biz1.opening_time CloseTime:biz1.closing_time];
    
    NSString *tmpIconName = biz1.iconRelativeURL;
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell imgBusinessIcon] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
    
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    cell.rateView.rating = 0;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
    
    cell.titleLabel.text = biz1.title;
    cell.subtitleLabel.text = biz1.address;
    cell.bussinessType.text = biz1.businessTypes;
    cell.bussinessAddress.text = biz1.neighborhood;

    cell.distance.text = [NSString stringWithFormat:@"%.1f m",[[AppData sharedInstance]getDistance:biz1.lat longitude:biz1.lng]];
    cell.rateView.rating = [biz1.rating floatValue];

    if([[APIUtility sharedInstance]isOpenBussiness:biz1.opening_time CloseTime:biz1.closing_time]){
        cell.lblOpenClose.text = @"OPEN NOW";
        cell.lblOpenClose.textColor = [UIColor grayColor];
    }else{
        cell.lblOpenClose.text = @"CLOSED";
        cell.lblOpenClose.textColor = [UIColor orangeColor];
    }
    
    cell.btnFevorite.tag = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (IBAction)FevoriteButtonClicked:(UIButton *) sender
{
    NSInteger index = sender.tag;
    Business *business = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:index]];
    
    if(sender.selected) {
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"0"];
        sender.selected = false;
    }
    else {
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"5"];
        sender.selected = true;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld",(long)indexPath.row);
    
    
//        BusinessDetailsContoller *BusinessDetailsVC = [[BusinessDetailsContoller alloc] initWithNibName:@"BusinessDetailsContoller" bundle:nil];
    selectedBiz = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:indexPath.row]];
    [self enterAndGetServiceAction:self];
}

@end
