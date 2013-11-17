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

@protocol TaptalkBusinessDelegate;

@interface Business : NSObject <MKAnnotation, NSURLConnectionDelegate> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    UIImage *image;

    BusinessCustomerProfileManager *customerProfile;
    GooglePlacesObject *googlePlacesObject;
    NSString *businessName;
    NSString *customerProfileName;
    NSString *chatSystemURL;
    int isCustomer;
    int businessID;

//    NSMutableData *responseWithLargData;
    NSDictionary *businessProducts;
}

@property(nonatomic, weak) id <TaptalkBusinessDelegate> delegate;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;
@property(nonatomic, retain) UIImage *image;


@property(nonatomic, retain) NSDictionary *businessProducts;
@property(atomic, retain) GooglePlacesObject *googlePlacesObject;
@property(nonatomic, readonly) BusinessCustomerProfileManager *customerProfile;
@property(nonatomic, retain) NSString *businessName;
@property(atomic, retain) NSString *chatSystemURL;
@property(atomic, retain) NSString *customerProfileName;
@property(atomic, assign) int businessID;
@property(nonatomic, assign) int isCustomer;
//@property(nonatomic, assign) BOOL isPinIconLoaded;
@property(nonatomic, assign) BOOL isProductListLoaded;


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (void)startLoadingBusinessProductCategoriesAndProducts;

/*
- (id)initWithCoordinate:(CLLocationCoordinate2D)argCoordicate
             BusinessName:(NSString *)bName
                    Title:(NSString *)tName
                 SubTitle:(NSString *)stName 
            ImageFileName:(NSString *)imgFName
       ImageFileExtension:(NSString *)imgXName;
 */

- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject;

@end


@protocol TaptalkBusinessDelegate

- (void)Business:(Business *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)dictionaryServerResult;

- (void)Business:(Business *)conn didFailWithError:(NSError *)error;


@end