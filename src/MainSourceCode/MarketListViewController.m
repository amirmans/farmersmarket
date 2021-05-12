 //
//  MarketListTableViewController.m
//  TapForAll
//
//  Created by Amir on 4/28/20.
//
//

#import "AppDelegate.h"
#import "MarketListViewController.h"
//#import "MarketTableViewCell.h"
#import "Consts.h"
#import "TapTalkLooks.h"
#import "DetailBusinessViewControllerII.h"
//#import "ServicesForBusinessTableViewController.h"
#import "Business.h"
#import "AppData.h"
//#import "MyLocationViewController.h"
#import "APIUtility.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataModel.h"
#import "BusinessServicesViewController.h"
#import "CurrentBusiness.h"
#import "MBProgressHUD.h"

#import "BusinessListViewController.h"
#import "ListofBusinesses.h"
#import "Corp.h"
#import "ActionSheetPicker.h"

@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end

@interface MarketListViewController () {

    NSTimer *marketListTimer;
    UISearchController *searchController;
    UIView *emptyCalloutView;

    CLLocation *currentLocation;
}

@property (atomic, strong) NSTimer *marketListTimer;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results

@property (nonatomic, strong) CLLocation *currentLocation;

- (void)corpChangeLocationAction:(UIButton *)sender;
@end

@implementation MarketListViewController


@synthesize marketListArray;
@synthesize filteredMarketListArray;
@synthesize marketListTimer;
@synthesize corpTableView;
@synthesize searchController;
@synthesize currentLocation;
//@synthesize externalLocation;

static const CGFloat CalloutYOffset = 50.0f;
//static const CGFloat DefaultZoom = 12.0f;
// CLLocationManager *locationManager;

MKCoordinateRegion marketRegion;
//Business *biz;

- (void)setMarketList {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.pd_locations_id = 0;
//    marketListArray = [businesses marketListArray];
    self.ResponseDataArray = [appDelegate.allCorps mutableCopy];
//    NSLog(@"%@",_ResponseDataArray);
    if (self.ResponseDataArray.count > 0 ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (!marketListArray) {
            marketListArray= [[NSMutableArray alloc]init];
        }// m
        [marketListArray removeAllObjects];
        for (int i = 0; i < self.ResponseDataArray.count ; i++) {
            [marketListArray addObject:[[self.ResponseDataArray objectAtIndex:i] mutableCopy]];
        }
        if (marketListArray.count > 0 ) {
            [marketListTimer invalidate];
            marketListTimer = nil;

            [HUD hideAnimated:YES];
            self.marketListArray = [self getSortByLocationTapForApp];
            self.searchResults = [NSMutableArray arrayWithCapacity:marketListArray.count];
            [corpTableView reloadData];
//            TODO [self addMarkersToMap];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(becomeActive:)
                                              name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
     }

    return self;
}


- (void)becomeActive:(NSNotification *)notification {
    NSLog(@"MarketList is becoming active");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppDelegate sharedInstance].pd_locations_id = 0;
    if ([DataModel sharedDataModelManager].userID != 0) {
        NSDictionary *param = @{@"cmd":@"get_all_points",@"consumerID":[NSNumber numberWithInteger:[DataModel sharedDataModelManager].userID],@"businessID":@"", @"corp_id":@""};
        [[APIUtility sharedInstance]getRewardpointsForBusiness:param completiedBlock:^(NSDictionary *points_data) {
            int status = [[points_data objectForKey:@"status"] intValue];
            if (status == 1) {
                NSString *total_earned_points = [points_data valueForKey:@"total_point"];
                [[self.tabBarController.tabBar.items objectAtIndex:Points_Tabbar_Position] setBadgeValue:total_earned_points];
            }
        }];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [CurrentBusiness sharedCurrentBusinessManager].business = nil;
    [Corp sharedCorp].chosenCorp = [NSMutableDictionary dictionary];
//    externalLocation = [[NSMutableDictionary alloc] init];

    if (!marketListArray) {
        marketListArray= [[NSMutableArray alloc]init];
    }// m
//    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
//    self.navigationItem.leftBarButtonItem = BackButton;
//    BackButton.tintColor = [UIColor whiteColor];

//  ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
//  if (!marketListArray) {
//      marketListArray= [[NSMutableArray alloc]init];
//  }// must be there
//    self.ResponseDataArray = marketListArray;
//  if (self.ResponseDataArray.count > 0 ) {
//      for (int i = 0; i < self.ResponseDataArray.count ; i++) {
//          if([[[self.ResponseDataArray objectAtIndex:i]valueForKey:@"branch"] isEqualToString:@"0"])
//              [marketListArray addObject:[self.ResponseDataArray objectAtIndex:i]];
//      }
//      NSMutableArray *SortByLocationArray = [self getSortByLocationTapForApp];
//      [self.marketListArray removeAllObjects];
//      self.marketListArray = SortByLocationArray;
//  }

//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.searchController.definesPresentationContext = NO;

    //ToDO for a later release
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    self.searchController.searchResultsUpdater = self;
//    self.searchController.dimsBackgroundDuringPresentation = NO;
////    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
////                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
//    self.searchController.searchBar.delegate = self;
//    [self.searchController.searchBar setPlaceholder:@"What Are You Looking For"];
////    self.searchController.searchBar.barTintColor = [UIColor blackColor];
//
////    self.bizTableView.tableHeaderView = self.searchController.searchBar;
//
//    self.navigationItem.titleView = searchController.searchBar;
//
//    self.searchController.hidesNavigationBarDuringPresentation = false;
//    self.searchController.searchBar.frame = CGRectMake(40,
//                                                       self.searchController.searchBar.frame.origin.y,
//                                                       (self.view.frame.size.width - 40), 44.0);
    self.extendedLayoutIncludesOpaqueBars = YES;



    // The table view controller is in a nav controller, and so the containing nav controller is the 'search results controller'
    //UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//  searchController.searchResultsUpdater = self;
//  searchController.dimsBackgroundDuringPresentation = NO;
//  searchController.hidesNavigationBarDuringPresentation = NO;
//  searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);

    self.corpTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

//  self.corpTableView.tableHeaderView = self.searchController.searchBar;

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.label.text = @"Updating Farmers Markets...";
//    HUD.detailsLabel.text = @"It is worth the wait!";

    HUD.mode = MBProgressHUDModeIndeterminate;

    // it seems this should be after setting the mode
    [HUD.bezelView setBackgroundColor:[UIColor orangeColor]];
    HUD.bezelView.color = [UIColor orangeColor];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;

    [self.view addSubview:HUD];
    [HUD showAnimated:YES];

//  if (marketListArray.count <= 0 ) {
//      marketListTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
//  }
////    else {
//     [HUD hideAnimated:YES];
////    }
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    filteredMarketListArray = [[NSMutableArray alloc] initWithCapacity:marketListArray.count];
    // TODO for a later release
//    UIBarButtonItem *displayMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map view" style:UIBarButtonItemStyleDone target:self action:@selector(displayMapView:)];
//    displayMapButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = displayMapButton;
//    displayMapButton = nil;
//    self.title = @"Biz Partners";

//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-in-logo-navigation-bar"]];
    self.title = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"]; //@"Tap-In Here";

    self.calloutView = [[SMCalloutView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    button.tintColor = [UIColor whiteColor];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(calloutAccessoryButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;

    //    self.mapView.mapType = MKMapTypeStandard;

    //Get Current Location
    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
//    NSLog(@"current location lat = %@ long = %@", latitudeString, longitudeString);
//  GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[latitudeString doubleValue]
//                                                                        longitude:[longitudeString doubleValue]
//                                                                             zoom:DefaultZoom];

//  latitudeString = @"47.6210177";
//  longitudeString = @"-122.3268878";

    [self setMapCameraTo:[latitudeString doubleValue] lng:[longitudeString doubleValue] mile:40];
    self.mapView.delegate = self;
    self.mapView.mapType =  kGMSTypeNormal;
    emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self addMarkersToMap];

}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [AppData sharedInstance].Current_Selected_Tab = @"0";
//    [TapTalkLooks setBackgroundImage:bizTableView];
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                                  selector:@selector(setMarketList)
                                                      name:@"GotAllCorps"
                                                    object:nil];
}

- (void) backButtonPressed {
//    NSLog(@"backButtonPressed");
    [self.searchController setActive:NO];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (NSMutableArray *)getSortByLocationTapForApp
{
    NSArray *testLocations = [NSArray arrayWithArray:self.marketListArray];

    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];

    NSArray *orderedUsers = [testLocations sortedArrayUsingComparator:^(NSDictionary *a,NSDictionary *b) {
        Business *userA = [[Business alloc] initWithDataFromDatabase:a];
        Business *userB = [[Business alloc] initWithDataFromDatabase:b];
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


- (void)displayMapView:(UIBarButtonItem *)button{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    BusinessListTableViewController *listTableView = [[BusinessListTableViewController alloc] initWithNibName:nil bundle:nil];
//    MyLocationViewController *myLocation = [[MyLocationViewController alloc] initWithNibName:nil bundle:nil];
//
//    [self.navigationController pushViewController:myLocation animated:YES];
//    myLocation = nil;
}

// - (void)addMarkersToMap {
//  self.markerArray = [[NSMutableArray alloc]init];
//  for (NSDictionary *markerInfo in self.marketListArray) {
//      GMSMarker *marker = [[GMSMarker alloc] init];

//      UIImage *pinImages = [UIImage imageNamed:@"pin3"];

//      CLLocationCoordinate2D center;
//      center= [[APIUtility sharedInstance]getLocationFromAddressString:[markerInfo valueForKeyPath:@"address"]];

//      Business *biz1 = [[Business alloc] initWithDataFromDatabase:markerInfo];
//      marker.position = CLLocationCoordinate2DMake(biz1.lat, biz1.lng);
//      marker.title = biz1.businessName;
//      marker.icon = pinImages;
//      marker.userData = markerInfo;
//      marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
//      marker.groundAnchor = CGPointMake(0.5, 1.0);
//      marker.map = self.mapView;
//      [self.markerArray addObject:marker];
//  }
// //    [self focusMapToShowAllMarkers];
// }

- (void)setMapCameraTo :(double)lat lng:(double)lng mile:(float)mile{
    mile = mile + 1.0;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
    double radius = mile * 621.371;

    marketRegion = MKCoordinateRegionMakeWithDistance(center,radius,radius);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(marketRegion.center.latitude - marketRegion.span.latitudeDelta/1.00, marketRegion.center.longitude - marketRegion.span.longitudeDelta/1.15);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(marketRegion.center.latitude + marketRegion.span.latitudeDelta/1.00, marketRegion.center.longitude + marketRegion.span.longitudeDelta/1.15);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:southWest coordinate:northEast];
    self.mapView.camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(10, 0, 0, 0)];

}

- (void) centerTapedMarker :(double)lat lng:(double)lng {
    CGFloat currentZoom = self.mapView.camera.zoom;
    GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:currentZoom];
    [self.mapView setCamera:sydney];
}

// - (void)focusMapToShowAllMarkers
// {
//  //    CLLocationCoordinate2D myLocation = ((GMSMarker *)self.markerArray.firstObject).position;
//  NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
//  NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
//  CLLocation *myLocation1 = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];
//  CLLocationCoordinate2D myLocation = myLocation1.coordinate;

//  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];

//  for (GMSMarker *marker in self.markerArray)
//      bounds = [bounds includingCoordinate:marker.position];

//  [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
// }
- (IBAction) backBUttonClicked: (id) sender;
{
    [self.searchController setActive:NO];
    [self.navigationController popViewControllerAnimated:true];
    //    [self.navigationController popToRootViewControllerAnimated:true];

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
        UIImageView *thumbView = [[UIImageView alloc] init];
        NSString *tmpIconName = [marker.userData valueForKeyPath:@"icon"];

        NSString *bg_color = [marker.userData valueForKeyPath:@"bg_color"];

        UIColor *businessColor = [[AppData sharedInstance] setUIColorFromString:bg_color];
        self.calloutView.backgroundView.backgroundColor = businessColor;

//        self.whiteArrowImage = [self image:self.blackArrowImage withColor:[AppData businessBackgroundColor]];

//        self.calloutView.backgroundView.whiteArrowImage = [self.calloutView.backgroundView image:self.calloutView.backgroundView.blackArrowImage withColor:businessColor];

//        self.calloutView.backgroundView.arrowImageView = [[UIImageView alloc] initWithImage:self.calloutView.backgroundView.whiteArrowImage];
//        [self.calloutView.backgroundView.arrowView addSubview:self.calloutView.backgroundView.arrowImageView];

//        self.calloutView.backgroundView.arrowView.backgroundColor = businessColor;
//        self.calloutView.backgroundView.containerView
//        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
//        NSURL *imageURL = [NSURL URLWithString:imageURLString];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];

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
    }
    else {
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

- (BOOL)mapView:(GMSMapView *)mapView didTahoursarker:(GMSMarker *)marker {
    /* don't move map camera to center marker on tap */

    NSDictionary *dataDict = marker.userData;
    NSString *lat = [dataDict valueForKey:@"lat"];
    NSString *lng = [dataDict valueForKey:@"lng"];

//    [self setMapCameraTo:[lat doubleValue] lng:[lng doubleValue] mile:40];
    [self centerTapedMarker:[lat doubleValue] lng:[lng doubleValue]];
    self.mapView.selectedMarker = marker;
    return YES;
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//
//    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
//    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
//    //    NSLog(@"current location lat = %@ long = %@", latitudeString, longitudeString);
//    //  GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[latitudeString doubleValue]
//    //                                                                        longitude:[longitudeString doubleValue]
//    //                                                                             zoom:DefaultZoom];
//
//    //  latitudeString = @"47.6210177";
//    //  longitudeString = @"-122.3268878";
//
//    [self setMapCameraTo:[latitudeString doubleValue] lng:[longitudeString doubleValue] mile:40];
//
//    [self calulateAndDisplayLocationFor:newLocation];
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
//    NSLog(@"OldLocation");
}

- (void)calulateAndDisplayLocationFor:(CLLocation *)argLocation {
    if (currentLocation == argLocation) {
        return;
    }
    MKCoordinateSpan span;
    span.longitudeDelta = 0.002;
    span.latitudeDelta = 0.002;

    marketRegion.span = span;
    marketRegion.center = argLocation.coordinate;

    currentLocation = argLocation;

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return filteredMarketListArray.count;
    }

    return marketListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // for some odd reasons when the table is reload after a search row height doesn't get its value from the nib
    // file - so I had to do this - the value should correspond to the value in the cell xib file
    return 330;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MarketTableViewCell";
    static NSString *searchCellIdentifier = @"SearchBusinessListCell";
    MarketTableViewCell *cell = nil;

    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }

    if (cell == nil) {

        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MarketTableViewCell" owner:nil options:nil];

        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (MarketTableViewCell *) currentObject;
                break;
            }
        }
//        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
    }

    NSDictionary *cellDict;
    if (self.searchController.active)
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        cellDict = [filteredMarketListArray objectAtIndex:indexPath.row];
    }
    else
    {
        cellDict = [marketListArray objectAtIndex:indexPath.row];
    }

//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    Business * biz =[[Business alloc] initWithDataFromDatabase: cellDict];

//    NSLog(@"%@",cellDict);

    // Configure the cell...
//    cell.businessNameTextField.text = [cellDict objectForKey:@"name"];
    cell.titleLabel.text = [cellDict objectForKey:@"corp_name"];

    NSString *businessTypes = [cellDict objectForKey:@"delivery_location"];
    if (businessTypes != (id)[NSNull null] && businessTypes != nil )
    {
//        cell.businessTypesTextField.text = businessTypes;
        cell.businessType.text = businessTypes;
    } else {
        cell.businessType.text = @"";
    }
//
//    [cell.tf_corp_website setText:[cellDict objectForKey:@"website"]];
    [cell.tf_mkt_pickup_location setText:[cellDict objectForKey:@"location_abbr"]];
    [cell.tf_cutoff_datetime setText:[cellDict objectForKey:@"cutoff_date"]];
    [cell.tf_pickup_date setText:[cellDict objectForKey:@"pickup_date"]];

//    NSString *neighborhood = [cellDict objectForKey:@"neighborhood"];
//    if (neighborhood != (id)[NSNull null] && neighborhood != nil )
//    {
//        cell.neighborhoodTextField.text = neighborhood;
//    }
//
    NSString *marketing_statement = [cellDict objectForKey:@"marketing_statement"];
    if (marketing_statement != (id)[NSNull null] && marketing_statement != nil )
    {
//        cell.neighborhoodTextField.text = neighborhood;
        cell.subtitleLabel.text = marketing_statement;
    } else {
        cell.subtitleLabel.text = @"";
    }
    NSString *open_hours = [cellDict objectForKey:@"market_open_hours"];
     if (open_hours != (id)[NSNull null] && open_hours.length != 0 ) {
         cell.lbl_market_open_hours.text = open_hours;
     }
    NSString *tmpIconName = [cellDict objectForKey:@"pictures"];
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [CorpsIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell businessIconImageView] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
    cell.businessIconImageView.clipsToBounds  = true;

    tmpIconName = [cellDict objectForKey:@"logo"];
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [CorpsIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell iv_market_logo] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
//    cell.iv_market_logo.clipsToBounds  = true;

    cell.rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    cell.rateView.rating = 0;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;

    if ([cellDict valueForKey:@"rating"] != [NSNull null]) {
        cell.rateView.rating =  [[cellDict valueForKey:@"rating"] floatValue];
    }
    else {
        cell.rateView.rating =  0;
    }

//    NSLog(@"%@",biz.opening_time);
// zzz For farmers market
//    if([cellDict objectForKey:@"driver_pickup_time"] == [NSNull null] || [cellDict objectForKey:@"cutoff_time"] == [NSNull null]) {
//        cell.lbl_mkt_pickup_location.hidden = true;
//        cell.lblOpenCloseDate.hidden = true;
//    }
//    else {
//        cell.lbl_mkt_pickup_location.hidden = false;
//        cell.lblOpenCloseDate.hidden = false;
//        int pickupLater = (int)[[cellDict objectForKey:@"pickup_counter_later"] integerValue];
////        if([[APIUtility sharedInstance]isBusinessOpen: [cellDict objectForKey:@"opening_time"] CloseTime:[cellDict objectForKey:@"closing_time"], objectForKey:@"pickup_counter_later]){
//        if([[APIUtility sharedInstance] isServiceAvailable:PickUpAtCounter during:[cellDict objectForKey:@"opening_time"] and:[cellDict objectForKey:@"closing_time"] withType:pickupLater]) {
//            cell.lbl_mkt_pickup_location.text = @"OPEN For SERVICES";
//            cell.lbl_mkt_pickup_location.textColor = [UIColor orangeColor];
//            cell.lblOpenCloseDate.text = [[APIUtility sharedInstance]getOpenCloseTime:[cellDict objectForKey:@"opening_time"] CloseTime:[cellDict objectForKey:@"closing_time"]];
//
//        }else{
//            cell.lbl_mkt_pickup_location.text = @"CLOSED for SERVICES";
//            cell.lbl_mkt_pickup_location.textColor = [UIColor grayColor];
////            cell.lblOpenCloseDate.text = @"";
//            cell.lblOpenCloseDate.textColor = [UIColor grayColor];
//            cell.lblOpenCloseDate.text = [[APIUtility sharedInstance]getOpenCloseTime:[cellDict objectForKey:@"opening_time"] CloseTime:[cellDict objectForKey:@"closing_time"]];
//        }
//
//    }

//    if([[APIUtility sharedInstance]isOpenBussiness: [cellDict objectForKey:@"opening_time"] CloseTime:[cellDict objectForKey:@"closing_time"]]){
//        cell.lblOpenClose.text = @"OPEN NOW";
//        cell.lblOpenClose.textColor = [UIColor greenColor];
//    }else{
//        cell.lblOpenClose.text = @"NOW CLOSED";
//        cell.lblOpenClose.textColor = [UIColor redColor];
//    }
//
//    cell.lblOpenCloseDate.text = [[APIUtility sharedInstance]getOpenCloseTime:[cellDict objectForKey:@"opening_time"] CloseTime:[cellDict objectForKey:@"closing_time"]];
//
//
//        if([[APIUtility sharedInstance]isOpenBussiness:biz.opening_time CloseTime:biz.closing_time]){
//            self.lbl_OpenNow.text = @"OPEN NOW";
//            self.lbl_OpenNow.textColor = [UIColor greenColor];
//        }else{
//            self.lbl_OpenNow.text = @"CLOSED";
//            self.lbl_OpenNow.textColor = [UIColor redColor];
//        }
//        self.lbl_time.text = [[APIUtility sharedInstance]getOpenCloseTime:biz.opening_time CloseTime:biz.closing_time];


    double lat = [[cellDict valueForKey:@"lat"] doubleValue];
    double lng = [[cellDict valueForKey:@"lng"] doubleValue];

    NSString *distanceText = [NSString stringWithFormat:@"%.1f mi",[[AppData sharedInstance]getDistance:lat longitude:lng]];
//    cell.distance.text = [NSString stringWithFormat:@"%.1f mi",[[AppData sharedInstance]getDistance:lat longitude:lng]];
    cell.distance.text= distanceText;

//    NSString *neighborhood = [cellDict objectForKey:@"neighborhood"];
    NSString *businessAddress = [cellDict objectForKey:@"address"];
    if (businessAddress != (id)[NSNull null] && businessAddress != nil )
    {
        //        cell.neighborhoodTextField.text = neighborhood;
//        cell.businessAddress.text = neighborhood;
//        NSString *businessAddressTest = [NSString stringWithFormat:@"%@     %@",businessAddress,distanceText];
//        cell.businessAddress.text = businessAddress;
         cell.businessAddress.text = [NSString stringWithFormat:@"%@\n%@", businessAddress, [cellDict objectForKey:@"website"]];

    }

//    cell.btnFevorite.tag = indexPath.row;
    if (((NSString *)[cellDict valueForKey:@"has_external_pickup_location"]).intValue < 1) {
        cell.lbChangeLocation.hidden = TRUE;
    } else {
        cell.lbChangeLocation.hidden = FALSE;
    }

    cell.lbChangeLocation.tag = indexPath.row;

    [cell.lbChangeLocation addTarget:self action:@selector(corpChangeLocationAction:) forControlEvents:UIControlEventTouchUpInside];


    return cell;
}

- (IBAction)FevoriteButtonClicked:(UIButton *)sender
{
    if(sender.selected)
        sender.selected = false;
    else
        sender.selected = true;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)calloutAccessoryButtonTapped:(id)sender {
    if (self.mapView.selectedMarker) {
        GMSMarker *marker = self.mapView.selectedMarker;
        NSDictionary *userData = marker.userData;

        //        BusinessServicesViewController *BusinessDetailsVC = [[BusinessServicesViewController alloc] initWithNibName:@"BusinessServicesViewController" bundle:nil];
        //
        //        [self.navigationController pushViewController: BusinessDetailsVC animated:YES];

        Business * biz =[[Business alloc] initWithDataFromDatabase: userData];

        NSMutableArray *branchArray = [[NSMutableArray alloc]initWithObjects:userData, nil];

        if (self.ResponseDataArray.count > 0 ) {
            for (int i = 0; i < self.ResponseDataArray.count ; i++) {
                if([[[self.ResponseDataArray objectAtIndex:i]valueForKey:@"branch"] isEqualToString:[NSString stringWithFormat:@"%d",biz.businessID]])
                    [branchArray addObject:[self.ResponseDataArray objectAtIndex:i]];
            }
        }

        if (branchArray.count > 1) {
            DetailBusinessViewControllerII *detailBizInfo = [[DetailBusinessViewControllerII alloc] initWithBusinessObject:biz];
            detailBizInfo.bussinessListByBranch = branchArray;
            [self.navigationController pushViewController:detailBizInfo animated:YES];
        }else{
            Business *selectedBiz = [[Business alloc] initWithDataFromDatabase:[branchArray objectAtIndex:0]];
            [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
            [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:selectedBiz];
            [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:selectedBiz.customerProfileName];
            [[DataModel sharedDataModelManager] setChatSystemURL:selectedBiz.chatSystemURL];
            [[DataModel sharedDataModelManager] setChat_masters:selectedBiz.chat_masters];
            [[DataModel sharedDataModelManager] setValidate_chat:selectedBiz.validate_chat];
            [[DataModel sharedDataModelManager] setBusinessName:selectedBiz.businessName];
            [[DataModel sharedDataModelManager] setShortBusinessName:selectedBiz.shortBusinessName];

            NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
            NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;

            BusinessServicesViewController *services = [[BusinessServicesViewController alloc]
                                                  initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:selectedBiz];

            [self.navigationController pushViewController:services animated:YES];
        }


//        NSLog(@"Title: %@",userData[TitleKey]);
//        NSLog(@"Info: %@",userData[InfoKey]);4
    }
}

- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (IBAction)enterAndGetServiceAction:(id)sender {

}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    self.searchController.active = false;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).corpMode = true;


    NSDictionary *cellDict;
    if (self.searchController.active)
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        cellDict = [filteredMarketListArray objectAtIndex:indexPath.row];
    }
    else
    {
        cellDict = [marketListArray objectAtIndex:indexPath.row];
    }
    NSString* businessesForCorp  = [cellDict objectForKey:@"merchant_ids"];

    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
    [businessArrays startGettingListofAllBusinessesForCorp:businessesForCorp];
    BusinessListViewController *businessListContorller = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
    businessListContorller.title = [cellDict objectForKey:@"domain"];
    [Corp sharedCorp].chosenCorp = [((Corp *)cellDict) mutableCopy];//[marketListArray objectAtIndex:indexPath.row];
    [AppData sharedInstance].market_mode = true;
    [AppData sharedInstance].consumerPDTimeChosen = [cellDict objectForKey:@"pickup_date"];
    [self.navigationController pushViewController:businessListContorller animated:YES];

}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    [self.filteredMarketListArray removeAllObjects]; // First clear the filtered array.
    for (NSDictionary *bizDict in marketListArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(SELF contains[cd] %@)", searchText];
        if ([predicate evaluateWithObject:[bizDict objectForKey:@"keywords"]])
        {
            [filteredMarketListArray addObject:bizDict];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
//
//    return YES;
//}


#pragma mark - UISearchResultsUpdating

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.corpTableView reloadData];
}

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark -
#pragma mark === UISearchResultsUpdating ===
#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)arg_searchController
{

    NSString *searchString = arg_searchController.searchBar.text;
//    [[self filterContentForSearchText:[arg_searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];

    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];


    [self.corpTableView reloadData];
}




#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
//    [self updateSearchResultsForSearchController:self.searchController];
//}
//

//#pragma mark - Content Filtering
//
//- (void)updateFilteredContentForProductName:(NSString *)productName type:(NSString *)typeName {
//
//    // Update the filtered array based on the search text and scope.
//    if ((productName == nil) || [productName length] == 0) {
//        // If there is no search string and the scope is "All".
//        if (typeName == nil) {
//            self.searchResults = [self.products mutableCopy];
//        } else {
//            // If there is no search string and the scope is chosen.
//            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
//            for (Product *product in self.products) {
//                if ([product.type isEqualToString:typeName]) {
//                    [searchResults addObject:product];
//                }
//            }
//            self.searchResults = searchResults;
//        }
//        return;
//    }
//
//
//    [self.searchResults removeAllObjects]; // First clear the filtered array.
//
//    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
//     */
//    for (Product *product in self.products) {
//        if ((typeName == nil) || [product.type isEqualToString:typeName]) {
//            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
//            NSRange productNameRange = NSMakeRange(0, product.name.length);
//            NSRange foundRange = [product.name rangeOfString:productName options:searchOptions range:productNameRange];
//            if (foundRange.length > 0) {
//                [self.searchResults addObject:product];
//            }
//        }
//    }
//}



- (void)corpChangeLocationAction:(UIButton *)sender {
    NSMutableDictionary *cellDict;
    if (self.searchController.active)
    {
        cellDict = [filteredMarketListArray objectAtIndex:sender.tag];
    }
    else
    {
        cellDict = [marketListArray objectAtIndex:sender.tag];
    }
    NSArray *_deliveryLocations = [cellDict valueForKey:@"external_locations"];
    if (_deliveryLocations == nil || [_deliveryLocations count] == 0) {
        return;
    }

    NSArray *deliveryLocations = [_deliveryLocations valueForKeyPath:@"Location address"];
    __block long tag = sender.tag;
    [ActionSheetStringPicker showPickerWithTitle:@"Delivery location?"
                                rows:deliveryLocations
                                initialSelection:0
                                doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSLog(@"Picker: %@, Index: %ld, value: %@",
              picker, (long)selectedIndex, selectedValue);
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).pd_locations_id = selectedIndex;

        NSArray *externalLocations =  [[self.marketListArray objectAtIndex:tag] objectForKey:@"external_locations"];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *locationArrayIndex = [[externalLocations objectAtIndex:selectedIndex] objectForKey:@"external_pickup_location_id"];
        appDelegate.pd_locations_id = [locationArrayIndex intValue];
        NSString* locationAddress = [[externalLocations objectAtIndex:selectedIndex] objectForKey:@"Location address"];
        [[self.marketListArray objectAtIndex:tag] setObject:selectedValue forKey:@"delivery_location"];
        [[self.marketListArray objectAtIndex:tag] setObject:locationAddress forKey:@"location_abbr"];


        [[self.marketListArray objectAtIndex:tag] setObject:selectedValue forKey:@"location_abbr"];
//        [self.externalLocation setObject:[NSNumber numberWithLong:tag] forKey:@"index"];
//        [self.externalLocation setObject:selectedValue forKey:@"address"];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:tag inSection:0];
        [self.corpTableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
    }
    cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    }
    origin:self.view
    ];
}

@end
