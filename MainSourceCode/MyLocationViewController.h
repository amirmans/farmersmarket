//
//  ViewController.h
//  TestLocation
//
//  Created by Amir on 10/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GooglePlacesConnection.h"

@class GooglePlacesObject;

@interface MyLocationViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, GooglePlacesConnectionDelegate>
{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    MKCoordinateRegion region;
    NSMutableArray *businessesAroundMe;
    
//    NSMutableData           *responseData;
//    NSMutableArray          *locations;
//    NSMutableArray          *locationsFilterResults;
//    NSString                *searchString;
    
    GooglePlacesConnection  *googlePlacesConnection;
}

//+ (CGFloat)annotationPadding;
//+ (CGFloat)calloutHeight;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mapActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *information;
@property (atomic, retain) CLLocationManager *locationManager;
@property (atomic, retain) IBOutlet MKMapView *mapView;
@property (atomic, assign) MKCoordinateRegion region;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) NSMutableArray    *businessesAroundMe;
@property (nonatomic, getter = isResultsLoaded) BOOL resultsLoaded;

- (IBAction)refresh:(id)sender;

//@property (nonatomic, retain) NSURLConnection   *urlConnection;
//@property (nonatomic, retain) NSMutableData     *responseData;
//@property (nonatomic, retain) NSMutableArray    *locations;
//@property (nonatomic, retain) NSMutableArray    *locationsFilterResults;


@end
