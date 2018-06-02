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
        
//        UIAlertController * alert = [UIAlertController
//                                     alertControllerWithTitle:@"Location Services Disabled"
//                                     message:@"You currently have all location services for this device disabled. If you proceed, you will be showing past informations. To enable, Settings->Location->location services->on"
//                                     preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* okButton = [UIAlertAction
//                                    actionWithTitle:@"OK"
//                                    style:UIAlertActionStyleDefault
//                                    handler:^(UIAlertAction * action) {
//                                        //Handle your yes please button action here
//                                    }];
//
//        
//        [alert addAction:okButton];
//
//        
//        [presentViewController:alert animated:YES completion:nil];
//        
        [self showAlert:@"Location Services Disabled" :@"You currently have all location services for this device disabled. If you proceed, you will be showing past informations. To enable, Settings->Location->location services->on"];
//        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be showing past informations. To enable, Settings->Location->location services->on" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Continue",nil];
//        [servicesDisabledAlert show];
//        [servicesDisabledAlert setDelegate:self];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self showAlert:@"Error" :@"Failed to Get Your Location"];
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
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

//    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *esc_addr = [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
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

+ (void) setBusinessBackgroundColor : (UIView *) view {
    
    Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
    
    [view setBackgroundColor:biz.business_bg_color];
}

+ (UIColor *) businessBackgroundColor {
    Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
    return biz.business_bg_color;
}

- (UIColor *) setUIColorFromString : (NSString *) colorString {
    
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"rgb( )"];
    
    NSString *removeRGBCharacter = [[colorString componentsSeparatedByCharactersInSet:trim] componentsJoinedByString:@""];
    
//    NSLog(@"%@",removeRGBCharacter);
    
    NSArray *rgbArray = [removeRGBCharacter componentsSeparatedByString:@","];
    
    NSInteger rColor = [[rgbArray objectAtIndex:0] integerValue];
    NSInteger gColor = [[rgbArray objectAtIndex:1] integerValue];
    NSInteger bColor = [[rgbArray objectAtIndex:2] integerValue];
    
    return [UIColor colorWithRed:rColor/255.0 green:gColor/255.0 blue:bColor/255.0 alpha:1];
}

+ (int) calculateRoundPoints : (CGFloat) value {
    int rounded_down = floorf(value * 100) / 100;
    return rounded_down;
}

+ (CGFloat) calculateRoundPrice : (CGFloat) value {
    CGFloat rounded_down = floorf(value * 100 +0.5 ) / 100;
    return rounded_down;
}

+ (NSString *)getTimeDifferentStringFromDataTime:(NSDate *) dateTime
{
    NSDictionary *timeScale = @{@"s"  :@1,
                                @"minute"  :@60,
                                @"hour"  :@3600,
                                @"day"  :@86400,
                                @"week"  :@605800,
                                @"month"  :@2629743,
                                @"year"  :@31556926
                                };
    NSString *scale;
    int timeAgo = abs(0 - (int)[dateTime timeIntervalSinceNow]);
    if (timeAgo < 60) {
        scale = @"s";
    } else
        if (timeAgo < 3600) {
            scale = @"minute";
        } else if (timeAgo < 86400) {
            scale = @"hour";
        } else if (timeAgo < 605800) {
            scale = @"day";
        } else if (timeAgo < 2629743) {
            scale = @"week";
        }else if (timeAgo < 31556926) {
            scale = @"month";
        } else {
            scale = @"year";
        }
    
    if([scale isEqualToString:@"month" ] && timeAgo > 3600) {
        timeAgo = timeAgo/2629743;
    }
    else {
        timeAgo = timeAgo/[[timeScale objectForKey:scale] integerValue];
    }
    
    NSString *s = @"ago";
    if (timeAgo > 1) {
        scale = [scale stringByAppendingString:@"s"];
    }
    
    return [NSString stringWithFormat:@"%d %@ %@", timeAgo, scale,s];
}

+ (NSString *)getUTCFormateDate:(NSDate *)localDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:gregorianCalendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}
- (void)showAlert:(NSString *)Title :(NSString *)Message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:Title
                                 message:Message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleCancel
                               handler:nil];
    [alert addAction:OKButton];
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    UIViewController *mainController = [keyWindow rootViewController];
    [mainController presentViewController:alert animated:YES completion:nil];
}
- (NSDateFormatter *) setDateFormatter : (NSString *) dateFormat{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

@end
