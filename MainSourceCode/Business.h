//
//  MyLocationAnnotation.h
//  TapTalk
//
//  Created by Amir on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessCustomerProfileManager.h"
#import "GooglePlacesObject.h"
#import "GooglePlacesConnection.h"
#import "ServerInteractionManager.h"

@class GooglePlacesObject;
@protocol TaptalkBusinessDelegate;

@interface Business : NSObject <MKAnnotation, NSURLConnectionDelegate, GooglePlacesConnectionDelegate,  PostProcesses> {
    
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSString *iconRelativeURL;
    UIImage *iconImage;
    UIImage *bg_image;
    
    GooglePlacesObject *googlePlacesObject;
    NSString *businessName;
    NSString *customerProfileName;
    NSString *chatSystemURL;
    int isCustomer;
    int businessID;
    int branch;
    double lat;
    double lng;
    
    NSString *rating;
    NSString *address;
    NSString *city;
    NSString *state;
    NSString *website;
    NSString *phone;
    NSString *sms_no;
    NSString *referenceData;
    NSMutableString * businessTypes;
    NSString *neighborhood;
    NSString *paymentProcessingEmail;
    NSString *paymentProcessingID;
    NSString *email;
    NSString *map_image_url;
    NSString *imageFileName;
    NSString *imageFileExt;
    NSString *picturesString;
    NSArray *chat_masters;
    NSInteger validate_chat;
    NSInteger is_collection;
    BOOL needsBizChat;
    BOOL inquiryForProduct;
    
    NSString *opening_time;
    NSString *closing_time;
    
    GooglePlacesConnection *googlePlacesConnection;
    
    NSDictionary *businessProducts;
    NSError *businessError;
}

@property(nonatomic, weak) id <TaptalkBusinessDelegate> businessDelegate;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;
@property(nonatomic, retain) NSString *iconRelativeURL;
@property(nonatomic, retain) UIImage *bg_image;
@property(nonatomic, strong) UIImage *iconImage;


@property(nonatomic, retain) NSDictionary *businessProducts;
@property(nonatomic, retain) NSDictionary *businessEvents;

@property(atomic, retain) GooglePlacesObject *googlePlacesObject;
//@property(nonatomic, readonly) BusinessCustomerProfileManager *customerProfile;
@property(nonatomic, retain) NSString *businessName;
@property(nonatomic, retain) NSString *shortBusinessName;
@property(atomic, retain) NSString *chatSystemURL;
@property(atomic, retain) NSString *customerProfileName;
@property(atomic, assign) int businessID;
@property(atomic, assign) int branch;

@property(atomic, assign) double lat;
@property(atomic, assign) double lng;

@property(nonatomic, assign) int isCustomer;
@property(nonatomic, assign) BOOL isProductListLoaded;

@property(nonatomic, retain) NSString *rating;
@property(nonatomic, retain) NSString *website;
@property(nonatomic, retain) NSString *address;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *state;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *sms_no;
@property(nonatomic, retain) NSString *paymentProcessingEmail;
@property(nonatomic, retain) NSString *paymentProcessingID;
@property(nonatomic, retain) NSString *email;
@property(atomic, retain) NSString *referenceData;
@property(atomic, retain) NSString *neighborhood;
@property(atomic, retain) NSMutableString * businessTypes;
@property(nonatomic, retain) NSError *businessError;
@property(atomic, strong) NSArray *chat_masters;
@property(nonatomic, strong) NSString *map_image_url;
@property(nonatomic, strong) NSString *imageFileName;
@property(nonatomic, retain) NSString *imageFileExt;
@property(nonatomic, strong) NSString *picturesString;
@property(atomic, assign) NSInteger validate_chat;
@property(atomic, assign) NSInteger is_collection;
@property(atomic, assign) BOOL inquiryForProduct;
@property(atomic, assign) BOOL needsBizChat;
@property(nonatomic, retain) NSString *marketing_statement;
@property(nonatomic, retain) NSString *opening_time;
@property(nonatomic, retain) NSString *closing_time;


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)startLoadingBusinessProductCategoriesAndProducts;

- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject;
- (id)initWithDataFromDatabase:(NSDictionary *)data;

@end


@protocol TaptalkBusinessDelegate

- (void)Business:(Business *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)dictionaryServerResult;

- (void)Business:(Business *)conn didFailWithError:(NSError *)error;


@end