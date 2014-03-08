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
    UIImage *image;

    GooglePlacesObject *googlePlacesObject;
    NSString *businessName;
    NSString *customerProfileName;
    NSString *chatSystemURL;
    int isCustomer;
    int businessID;
    
    NSString *rating;
    NSString *address;
    NSString *website;
    NSString *phone;
    NSString *sms_no;
    NSString *referenceData;
    NSMutableString * businessTypes;
    NSString *neighborhood;
    NSString *paymentProcessingEmail;
    NSString *paymentProcessingID;
    NSString *email;

    GooglePlacesConnection *googlePlacesConnection;

    NSDictionary *businessProducts;
    NSError *businessError;
}

@property(nonatomic, weak) id <TaptalkBusinessDelegate> businessDelegate;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;
@property(nonatomic, retain) UIImage *image;


@property(nonatomic, retain) NSDictionary *businessProducts;
@property(atomic, retain) GooglePlacesObject *googlePlacesObject;
//@property(nonatomic, readonly) BusinessCustomerProfileManager *customerProfile;
@property(nonatomic, retain) NSString *businessName;
@property(atomic, retain) NSString *chatSystemURL;
@property(atomic, retain) NSString *customerProfileName;
@property(atomic, assign) int businessID;
@property(nonatomic, assign) int isCustomer;
@property(nonatomic, assign) BOOL isProductListLoaded;

@property(nonatomic, retain) NSString *rating;
@property(nonatomic, retain) NSString *website;
@property(nonatomic, retain) NSString *address;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *sms_no;
@property(nonatomic, retain) NSString *paymentProcessingEmail;
@property(nonatomic, retain) NSString *paymentProcessingID;
@property(nonatomic, retain) NSString *email;
@property(atomic, retain) NSString *referenceData;
@property(atomic, retain) NSString *neighborhood;
@property(atomic, retain) NSMutableString * businessTypes;
@property(nonatomic, retain) NSError *businessError;


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)startLoadingBusinessProductCategoriesAndProducts;

- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject;
- (id)initWithDataFromDatabase:(NSDictionary *)data;

@end


@protocol TaptalkBusinessDelegate

- (void)Business:(Business *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)dictionaryServerResult;

- (void)Business:(Business *)conn didFailWithError:(NSError *)error;


@end