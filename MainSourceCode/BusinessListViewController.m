//
//  BusinessListTableViewController.m
//  TapForAll
//
//  Created by Amir on 2/2/14.
//
//

#import "BusinessListViewController.h"
#import "BusinessTableViewCell.h"
#import "Consts.h"
#import "TapTalkLooks.h"
#import "DetailBusinessViewControllerII.h"
#import "ServicesForBusinessTableViewController.h"
#import "ListofBusinesses.h"
#import "Business.h"
#import "AppData.h"
#import "MyLocationViewController.h"
#import "APIUtility.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataModel.h"

@interface BusinessListViewController () {

    NSTimer *bizListTimer;
    UISearchController *searchController;
    UIView *emptyCalloutView;
}

@property (atomic, strong) NSTimer *bizListTimer;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results
@end

@implementation BusinessListViewController


@synthesize businessListArray;
@synthesize filteredBusinessListArray;
@synthesize listBusinessesActivityIndicator;
@synthesize bizListTimer;
@synthesize bizTableView;
@synthesize searchController;

static const CGFloat CalloutYOffset = 50.0f;
//static const CGFloat DefaultZoom = 12.0f;
CLLocationManager *locationManager;
CLLocation *currentLocation;
MKCoordinateRegion region;
Business *biz;

- (void)timerCallBack {
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
//    businessListArray = [businesses businessListArray];
    self.ResponseDataArray = [businesses businessListArray];
    if (self.ResponseDataArray.count > 0 ) {
        [businessListArray removeAllObjects];
        for (int i = 0; i < self.ResponseDataArray.count ; i++) {
            if([[[self.ResponseDataArray objectAtIndex:i]valueForKey:@"branch"] isEqualToString:@"0"])
                [businessListArray addObject:[self.ResponseDataArray objectAtIndex:i]];
        }
        if (businessListArray.count > 0 ) {
            [bizListTimer invalidate];
            bizListTimer = nil;
            [listBusinessesActivityIndicator stopAnimating];
            NSMutableArray *SortByLocationArray = [self getSortByLocationTapForApp];
            [self.businessListArray removeAllObjects];
            self.businessListArray = SortByLocationArray;
            [bizTableView reloadData];
            [self addMarkersToMap];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
     }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Create a mutable array to contain products for the search results table.
    ListofBusinesses* businesses = [ListofBusinesses sharedListofBusinesses];
    businessListArray= [[NSMutableArray alloc]init];
    self.ResponseDataArray = [businesses businessListArray];
    if (self.ResponseDataArray.count > 0 ) {
        for (int i = 0; i < self.ResponseDataArray.count ; i++) {
            if([[[self.ResponseDataArray objectAtIndex:i]valueForKey:@"branch"] isEqualToString:@"0"])
                [businessListArray addObject:[self.ResponseDataArray objectAtIndex:i]];
        }
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.bizTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
//                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setPlaceholder:@"What Are You Looking For"];
//    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    
//    self.bizTableView.tableHeaderView = self.searchController.searchBar;
    
    self.navigationItem.titleView = searchController.searchBar;
    
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.searchBar.frame = CGRectMake(40,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       (self.view.frame.size.width - 40), 44.0);
    
    self.definesPresentationContext = YES;
    
    self.searchResults = [NSMutableArray arrayWithCapacity:businessListArray.count];
    
    // The table view controller is in a nav controller, and so the containing nav controller is the 'search results controller'
    //UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.navigationController];
//    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    searchController.searchResultsUpdater = self;
//    searchController.dimsBackgroundDuringPresentation = NO;
//    searchController.hidesNavigationBarDuringPresentation = NO;
//    searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
//    self.bizTableView.tableHeaderView = self.searchController.searchBar;
    
    
    if (businessListArray.count <= 0 ) {
        bizListTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    } else {
        [listBusinessesActivityIndicator stopAnimating];
    }

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    filteredBusinessListArray = [[NSMutableArray alloc] initWithCapacity:businessListArray.count];
    UIBarButtonItem *displayMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map view" style:UIBarButtonItemStyleDone target:self action:@selector(displayMapView:)];
    displayMapButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = displayMapButton;
    displayMapButton = nil;
    self.title = @"Biz Partners";
    
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
//        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[latitudeString doubleValue]
//                                                                        longitude:[longitudeString doubleValue]
//                                                                             zoom:DefaultZoom];

//    latitudeString = @"47.6210177";
//    longitudeString = @"-122.3268878";

    [self setMapCameraTo:[latitudeString doubleValue] lng:[longitudeString doubleValue] mile:40];
    self.mapView.delegate = self;
    self.mapView.mapType =  kGMSTypeNormal;
    emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addMarkersToMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%ld",[DataModel sharedDataModelManager].userID);
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"ViewillAppear Method Call");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    [TapTalkLooks setBackgroundImage:bizTableView];
}

-(NSMutableArray *)getSortByLocationTapForApp
{
    NSArray *testLocations = [NSArray arrayWithArray:self.businessListArray];
    
    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];
    
    NSArray *orderedUsers = [testLocations sortedArrayUsingComparator:^(id a,id b) {
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
    MyLocationViewController *myLocation = [[MyLocationViewController alloc] initWithNibName:nil bundle:nil];

    [self.navigationController pushViewController:myLocation animated:YES];
    myLocation = nil;
}

- (void)addMarkersToMap {
    self.markerArray = [[NSMutableArray alloc]init];
    for (NSDictionary *markerInfo in self.businessListArray) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        UIImage *pinImages = [UIImage imageNamed:@"pin2"];
        
        CLLocationCoordinate2D center;
        center= [[APIUtility sharedInstance]getLocationFromAddressString:[markerInfo valueForKeyPath:@"address"]];
        
        Business *biz1 = [[Business alloc] initWithDataFromDatabase:markerInfo];
        marker.position = CLLocationCoordinate2DMake(biz1.lat, biz1.lng);
        marker.title = biz1.businessName;
        marker.icon = pinImages;
        marker.userData = markerInfo;
        marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
        marker.groundAnchor = CGPointMake(0.5, 1.0);
        marker.map = self.mapView;
        [self.markerArray addObject:marker];
    }
//    [self focusMapToShowAllMarkers];
}

- (void)setMapCameraTo :(double)lat lng:(double)lng mile:(float)mile{
    mile = mile + 1.0;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
    double radius = mile * 621.371;
    
    region = MKCoordinateRegionMakeWithDistance(center,radius,radius);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/1.00, region.center.longitude - region.span.longitudeDelta/1.15);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/1.00, region.center.longitude + region.span.longitudeDelta/1.15);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:southWest coordinate:northEast];
    self.mapView.camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(10, 0, 0, 0)];
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
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
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
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        thumbView.image = [UIImage imageWithData:imageData];
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
    
    [self setMapCameraTo:[lat doubleValue] lng:[lng doubleValue] mile:40];
    self.mapView.selectedMarker = marker;
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
    marker1.map = self.mapView;
    
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
        return filteredBusinessListArray.count;
    }
    
    return businessListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // for some odd reasons when the table is reload after a search row height doesn't get its value from the nib
    // file - so I had to do this - the value should correspond to the value in the cell xib file 
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"BusinessListCell";
    static NSString *searchCellIdentifier = @"SearchBusinessListCell";
    BusinessTableViewCell *cell = nil;
    
    if (self.searchController.active) {
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell == nil) {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (BusinessTableViewCell *) currentObject;
                break;
            }
        }
//        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
    }
    NSDictionary *cellDict;
    if (self.searchController.active)
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        cellDict = [filteredBusinessListArray objectAtIndex:indexPath.row];
    }
    else
    {
        cellDict = [businessListArray objectAtIndex:indexPath.row];
    }
    
    NSLog(@"%@",cellDict);
    
    // Configure the cell...
//    cell.businessNameTextField.text = [cellDict objectForKey:@"name"];
    cell.titleLabel.text = [cellDict objectForKey:@"name"];
    
    NSString *businessTypes = [cellDict objectForKey:@"businessTypes"];
    if (businessTypes != (id)[NSNull null] && businessTypes != nil )
    {
//        cell.businessTypesTextField.text = businessTypes;
        cell.businessType.text = businessTypes;
    }
//zzzz
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
    }
    
    NSString *tmpIconName = [cellDict objectForKey:@"icon"];
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell businessIconImageView] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
    
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
    
    double lat = [[cellDict valueForKey:@"lat"] doubleValue];
    double lng = [[cellDict valueForKey:@"lng"] doubleValue];
    
    cell.distance.text = [NSString stringWithFormat:@"%.1f m",[[AppData sharedInstance]getDistance:lat longitude:lng]];
    
    NSString *neighborhood = [cellDict objectForKey:@"neighborhood"];
    if (neighborhood != (id)[NSNull null] && neighborhood != nil )
    {
        //        cell.neighborhoodTextField.text = neighborhood;
        cell.businessAddress.text = neighborhood;
    }

//    cell.btnFevorite.tag = indexPath.row;
//    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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
        
        //        BusinessDetailsContoller *BusinessDetailsVC = [[BusinessDetailsContoller alloc] initWithNibName:@"BusinessDetailsContoller" bundle:nil];
        //
        //        [self.navigationController pushViewController: BusinessDetailsVC animated:YES];
        
        Business * biz =[[Business alloc] initWithDataFromDatabase: userData];
        
        DetailBusinessViewControllerII *detailBizInfo = [[DetailBusinessViewControllerII alloc] initWithBusinessObject:biz];
        NSMutableArray *branchArray = [[NSMutableArray alloc]initWithObjects:userData, nil];
        
        detailBizInfo.bussinessListByBranch = branchArray;
        [self.navigationController pushViewController:detailBizInfo animated:YES];

//        NSLog(@"Title: %@",userData[TitleKey]);
//        NSLog(@"Info: %@",userData[InfoKey]);
    }
}

- (IBAction)enterAndGetServiceAction:(id)sender {
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Business * biz = nil;
    if (self.searchController.active) {
        biz = [[Business alloc] initWithDataFromDatabase:[filteredBusinessListArray objectAtIndex:indexPath.row]];
    }
    else
    {
        biz = [[Business alloc] initWithDataFromDatabase:[businessListArray objectAtIndex:indexPath.row]];
    }
    
    NSMutableArray *branchArray = [[NSMutableArray alloc]init];
    if (self.searchController.active)
        [branchArray addObject:[filteredBusinessListArray objectAtIndex:indexPath.row]];
    else
        [branchArray addObject:[businessListArray objectAtIndex:indexPath.row]];

    if (self.ResponseDataArray.count > 0 ) {
        for (int i = 0; i < self.ResponseDataArray.count ; i++) {
            if([[[self.ResponseDataArray objectAtIndex:i]valueForKey:@"branch"] isEqualToString:[NSString stringWithFormat:@"%d",biz.businessID]])
                [branchArray addObject:[self.ResponseDataArray objectAtIndex:i]];
        }
    }
    DetailBusinessViewControllerII *detailBizInfo = [[DetailBusinessViewControllerII alloc] initWithBusinessObject:biz];
    detailBizInfo.bussinessListByBranch = branchArray;
    [self.navigationController pushViewController:detailBizInfo animated:YES];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    [self.filteredBusinessListArray removeAllObjects]; // First clear the filtered array.
    for (NSDictionary *bizDict in businessListArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(SELF contains[cd] %@)", searchText];
        if ([predicate evaluateWithObject:[bizDict objectForKey:@"name"]])
        {
            [filteredBusinessListArray addObject:bizDict];
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
    [self.bizTableView reloadData];
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
    
    
    [self.bizTableView reloadData];
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

@end
