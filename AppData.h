//
//  AppData.h
//  Emotake
//
//  Created by Harry on 7/21/14.
//  Copyright (c) 2014 Emotake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppData : NSObject<UIAlertViewDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) CLLocation *currentLocation;


- (void) locationManager ;

+ (AppData *) sharedInstance;

+(CLLocationCoordinate2D) getLocationFromAddressString:(NSString*) addressStr;
+ (CLLocationDistance) getDistanceFromLocation : (CLLocation*) currentLocation Destination : (CLLocation*) destinationLocation;
+ (void) showAlert:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle;
-(NSString *)checkNetworkConnectivity;
- (void) getCurruntLocation;
- (float)getDistance:(double)lat longitude:(double)lng;
@end
