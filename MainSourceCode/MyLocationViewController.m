//
//  ViewController.m
//  MyLocationViewController
//
//  Created by Amir on 10/4/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

#import "MyLocationViewController.h"

#import "Business.h"
#import "DetailBusinessInformation.h"

@interface MyLocationViewController () {

@private

}
- (void)calulateAndDisplayLocationFor:(CLLocation *)argLocation;

- (void)addAnnotationsForBusinesses;

@end


@implementation MyLocationViewController


@synthesize mapView;
@synthesize region;
@synthesize currentLocation;
@synthesize mapActivityIndicator;
@synthesize information;
@synthesize locationManager;

@synthesize resultsLoaded;
//@synthesize urlConnection;
//@synthesize responseData;
@synthesize businessesAroundMe;
//@synthesize locations;
//@synthesize locationsFilterResults;


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        googlePlacesConnection = [[GooglePlacesConnection alloc] initWithDelegate:self];
        [self setResultsLoaded:NO];
        
        locationManager.delegate = self;
        mapView.delegate = self;

        locationManager.desiredAccuracy = 10.0f;
        locationManager.distanceFilter = 200.0f;
        
        [locationManager startUpdatingLocation];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Where?";
    [mapActivityIndicator hidesWhenStopped];
    [mapActivityIndicator startAnimating];
    self.mapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    [information setTextColor:[UIColor redColor]];
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setInformation:nil];
    [self setMapActivityIndicator:nil];
    self.locationManager = nil;
    mapView.delegate = nil;
    googlePlacesConnection = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark CLLocationManagerDelegate

- (void)startMonitoringForRegion:(CLRegion *)region {
    
}
//
//- (void)startSignificantChangeUpdates {
//    // Create the location manager if this object does not
//    // already have one.
//    if (nil == locationManager) {
//        locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        [locationManager startMonitoringSignificantLocationChanges];
//    }
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // If it's a relatively recent event, turn off updates to save power
    // However - it seems this method could be called multiple time to achieve the desired accuracy
    
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSLog(@"in didUpdateLocation: howRecent is: %f", howRecent);
//    if (abs(howRecent) > 15.0) {
//        NSLog(@"in didUpdateLocation: latitude %+.6f, longitude %+.6f about to calculateAndDisplayLocation",
//                newLocation.coordinate.latitude,
//                newLocation.coordinate.longitude);
        [self calulateAndDisplayLocationFor:newLocation];
//    }
    // else skip the event and process the next one.
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"locationManager failed with error: %@", [error description]);
}



#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    NSLog(@"About to display the icons");
}

- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated {

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    DetailBusinessInformation *detailBizInfo = [[DetailBusinessInformation alloc] initWithBusinessObject:((Business *) view.annotation)];
    [self.navigationController pushViewController:detailBizInfo animated:YES];
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    // NSLog(@"We are in the delegate method of mapViewWillStartLocationUser");
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // NSLog(@"We are in the delegate method of regionWillChangeAnimated");
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pingImagePath = [bundle pathForResource:@"flag" ofType:@"png"];
    UIImage *customerPinImage = [UIImage imageWithContentsOfFile:pingImagePath];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // We can return nil to let the MapView handle the default annotation view (blue dot):
        return nil;
    }

    // try to dequeue an existing pinView first
    static NSString *myLocationIdentifiers = @"businessesIdentifiers";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:myLocationIdentifiers];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myLocationIdentifiers];
        pinView.animatesDrop = YES;
        [pinView setCanShowCallout:YES];
        if (((Business *) annotation).image != nil) {
            UIImageView *iconView = [[UIImageView alloc] initWithImage:((Business *) annotation).image];
            pinView.leftCalloutAccessoryView = iconView;
//            iconView = nil;
        }
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else {
        NSLog(@"pinView wasn't nill");
        pinView.annotation = annotation;
    }
    // set the color of the pin
    if (((Business *) annotation).isCustomer == 1) {
        pinView.pinColor = MKPinAnnotationColorRed;
        //            [pinView setImage:customerPinImage];
        //            UIImageView *pinImageView = [[UIImageView alloc]initWithImage:customerPinImage];
        //            [pinView addSubview:pinImageView];
//        NSLog(@"In MyLocationViewController:viewForAnnotaion deciding on the pin color %@ is a customer", ((Business *) annotation).businessName);
    }
    else if (((Business *) annotation).isCustomer == 0) {
        pinView.pinColor = MKPinAnnotationColorPurple;
//        NSLog(@"In MyLocationViewController:viewForAnnotaion %@ is NOT a customer", ((Business *) annotation).businessName);
    }
    else {
        pinView.pinColor = MKPinAnnotationColorGreen;
//        NSLog(@"In MyLocationViewController:viewForAnnotaion %@ is unknown", ((Business *) annotation).businessName);
    }

    customerPinImage = nil;
//    NSLog(@"at the end pinView businessName is: %@ and its color is: %i", ((Business *) annotation).businessName, pinView.pinColor);

    return pinView;
}


- (IBAction)refresh:(id)sender {
    
    [mapActivityIndicator startAnimating];
    [self setResultsLoaded: NO];
    [locationManager startUpdatingLocation];
    [mapActivityIndicator stopAnimating];
    
}


#pragma mark -
#pragma mark GooglePlaces Delegation methods

//UPDATE - to handle filtering
/*
 Gets info from google - Populates into Business and adds to businessesAroundMe which is an array of businesses
 */
- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)objects {

    if ([objects count] == 0) {
        [mapActivityIndicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location frm google"
                                                        message:@"Try another place name or address"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        businessesAroundMe = [[NSMutableArray alloc] initWithCapacity:[objects count]];
        NSEnumerator *e = [objects objectEnumerator];
        GooglePlacesObject *googleObject;
        while (googleObject = [e nextObject]) {
            // do something with object
            Business *tapTalkBusiness = [[Business alloc] initWithGooglePlacesObject:googleObject];
            [businessesAroundMe addObject:tapTalkBusiness];
        }

        [self addAnnotationsForBusinesses];
        [mapActivityIndicator stopAnimating];
    }
}


- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error {
    [mapActivityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error receiving your place info from google - Try again"
                                                    message:[error localizedDescription]
                                                   delegate:nil cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark -
#pragma class methods

- (void)calulateAndDisplayLocationFor:(CLLocation *)argLocation {
    if (currentLocation == argLocation) {
        return;
    }
    if ([self isResultsLoaded]) {
        return;
    }
    [self setResultsLoaded:YES];

    MKCoordinateSpan span;
    span.longitudeDelta = 0.002;
    span.latitudeDelta = 0.002;

    region.span = span;
    region.center = argLocation.coordinate;
    [mapView setRegion:region animated:YES];

    currentLocation = argLocation;

    //What places to search for
    NSString *searchLocations;
    searchLocations = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",
                                                 kBar, kRestaurant, kCafe, kGrocerySupermarket, kDepartmentStore, kFood];

    [googlePlacesConnection getGoogleObjects:CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude) andTypes:searchLocations];
}


- (void)addAnnotationsForBusinesses {
    //    if (locationManager.location)
    {
        [self.mapView addAnnotations:businessesAroundMe];
        self.mapView.showsUserLocation = YES;
        [self setResultsLoaded:NO];
    }

}


@end
