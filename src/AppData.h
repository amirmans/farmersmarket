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
#import "AFNetworking.h"
#import "Business.h"
#import "CurrentBusiness.h"

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
@property (assign, nonatomic) BOOL isFromTotalCart; // we are coming to points page from the cart view
@property (retain, nonatomic) NSString *consumer_Delivery_Id;
@property (retain, nonatomic) NSString *consumer_Delivery_Location;
@property (retain, nonatomic) NSString *consumer_Delivery_Location_Id;
@property (retain, nonatomic) NSString *consumerPDTimeChosen;
@property (retain, nonatomic) NSString *consumerPDMethodChosen;
@property (retain, nonatomic) NSString *Current_Selected_Tab;
@property (assign, atomic) BOOL is_Profile_Changed;
@property (assign, atomic) BOOL market_mode;
- (NSDateFormatter *) setDateFormatter : (NSString *) dateFormat;
- (void) locationManager ;

+ (AppData *) sharedInstance;

+(CLLocationCoordinate2D) getLocationFromAddressString:(NSString*) addressStr;
+ (CLLocationDistance) getDistanceFromLocation : (CLLocation*) currentLocation Destination : (CLLocation*) destinationLocation;
-(NSString *)checkNetworkConnectivity;
- (void) getCurruntLocation;
- (float)getDistance:(double)lat longitude:(double)lng;
+ (void) setBusinessBackgroundColor : (UIView *) view;
+ (UIColor *) businessBackgroundColor;
- (UIColor *) setUIColorFromString : (NSString *) colorString;
+ (int) calculateRoundPoints : (CGFloat) value;
+ (CGFloat) calculateRoundPrice : (CGFloat) value;
+ (NSString *)getTimeDifferentStringFromDataTime:(NSDate *) dateTime;
+ (NSString *)getUTCFormateDate:(NSDate *)localDate;
@end
