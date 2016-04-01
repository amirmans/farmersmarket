//
//  AppData.m
//  Emotake
//
//  Created by Harry on 7/21/14.
//  Copyright (c) 2014 Emotake. All rights reserved.
//

#import "AppData.h"
#import <CoreLocation/CoreLocation.h>

static AppData *sharedObj;



@implementation AppData

+ (AppData *) sharedInstance
{
    if(sharedObj == nil)
    {
        sharedObj = [[AppData alloc] init];
    }
    return sharedObj;
}

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        [self locationManager];
    }
    return self;
}


- (void) locationManager
{
    if ([CLLocationManager locationServicesEnabled])
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    else{
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be showing past informations. To enable, Settings->Location->location services->on" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Continue",nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert setDelegate:self];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *location = newLocation;
    
    if (location != nil) {
        ;
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", location.coordinate.longitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", location.coordinate.latitude]);
        
        self.currentLocation = location;
        
        [self stopLocationService];
    }
}

- (void) getCurruntLocation {
    [self startLocationService];
}

- (void) startLocationService {
    [locationManager startUpdatingLocation];
}

- (void) stopLocationService {
    [locationManager stopUpdatingLocation];
}


+(CLLocationCoordinate2D) getLocationFromAddressString:(NSString*) addressStr {
    
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
    
}

+ (CLLocationDistance) getDistanceFromLocation : (CLLocation*) currentLocation Destination : (CLLocation*) destinationLocation {
    CLLocationDistance distance = [currentLocation distanceFromLocation:destinationLocation];
    return distance;
}

+ (void) showAlert:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle {
}

- (float) getDistance:(double)lat longitude:(double)lng {
    
    NSString *latitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *longitudeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:[latitudeString doubleValue] longitude:[longitudeString doubleValue]];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocationDistance distance = [AppData getDistanceFromLocation:currentLocation Destination:destinationLocation];
//    NSLog(@"%f KM",distance/1000);
    return distance/1609.344;
}

-(NSString *)checkNetworkConnectivity
{
    static NSString *networkStatus = @"";

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
//            self.network = 0;
            networkStatus = @"NoAccess";
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
//            self.network = 1;
            networkStatus = @"e";
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
//            self.network = 2;
            networkStatus = @"WiFi";
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return networkStatus;
}
@end
