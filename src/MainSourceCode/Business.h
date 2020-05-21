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
    NSString *Note;
    
    GooglePlacesObject *googlePlacesObject;
    NSString *businessName;
    NSString *customerProfileName;
    NSString *chatSystemURL;
    int isCustomer;
    int businessID;
    int branch;
    int time_interval;
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
    NSString *bg_image_name;
    NSString *text_color;
    NSString *bg_color;
    NSString *sub_businesses;
    
    UIColor *business_bg_color;
    UIColor *business_text_color;
    
    GooglePlacesConnection *googlePlacesConnection;
    
    NSDictionary *businessProducts;
    NSError *businessError;
    NSString *process_time;

    NSNumber *cycle_time;
//    NSNumber *lead_time;

    // these are strings because they can also be percentages
    NSString *delivery_location_charge;
    NSString *delivery_table_charge;
    NSString *pickup_counter_charge;
    NSString *pickup_location_charge;
    NSString *tax_rate;
    
    NSString *business_delivery_id;
    NSString *business_promotion_id;
    NSString *display_icon_product_categories;
    NSString *display_icon_products;
    NSString *promotion_code;
    NSString *promotion_discount_amount;
    NSString *promotion_message;
    NSInteger pickup_counter_later;
    BOOL accept_orders_when_closed;
    BOOL offers_points;
    NSString *curr_code;
    NSString *curr_symbol;
    NSString *section_in_map;
    NSString *biz_description;
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
@property(atomic, assign) int time_interval;

@property(atomic, assign) double lat;
@property(atomic, assign) double lng;

@property(nonatomic, assign) int isCustomer;
@property(nonatomic, assign) BOOL isProductListLoaded;
//@property(nonatomic, retain) NSString *Note;
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
@property(atomic, assign) NSInteger pickup_counter_later;
@property(atomic, assign) BOOL inquiryForProduct;
@property(atomic, assign) BOOL needsBizChat;
@property(nonatomic, retain) NSString *marketing_statement;
@property(nonatomic, retain) NSString *opening_time;
@property(nonatomic, retain) NSString *closing_time;
@property(nonatomic, retain) NSString *bg_image_name;
@property(nonatomic, strong) NSString *text_color;
@property(nonatomic, strong) NSString *bg_color;
@property(nonatomic, strong) UIImage *businessBackgroundImage;

@property(nonatomic, strong) UIColor *business_bg_color;
@property(nonatomic, strong) UIColor *business_text_color;
@property(nonatomic, strong) NSString *process_time;
@property(nonatomic, strong) NSString *keywords;

@property(nonatomic, strong) NSString *delivery_location_charge;
@property(nonatomic, strong) NSString *delivery_table_charge;
@property(nonatomic, strong) NSString *pickup_counter_charge;
@property(nonatomic, strong) NSString *pickup_location_charge;
@property(nonatomic, strong) NSString *tax_rate;


@property(nonatomic, strong) NSString *sub_businesses;
@property(nonatomic, strong) NSString *business_delivery_id;
@property(nonatomic, strong) NSString *business_promotion_id;
@property(nonatomic, strong) NSString *display_icon_product_categories;
@property(nonatomic, strong) NSString *display_icon_products;
@property(nonatomic, strong) NSString *promotion_code;
@property(nonatomic, strong) NSString *promotion_discount_amount;
@property(nonatomic, strong) NSString *promotion_message;
@property(nonatomic, strong) NSString *biz_description;


@property(atomic, assign) BOOL accept_orders_when_closed;
@property(atomic, assign) BOOL offers_points;
@property(nonatomic, strong) NSString *curr_code;
@property(nonatomic, strong) NSString *curr_symbol;

@property(nonatomic, strong) NSNumber *cycle_time;
@property(nonatomic, strong) NSNumber *lead_time;

@property(nonatomic, strong) NSString *section_in_map;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)startLoadingBusinessProductCategoriesAndProducts;
//- (void) startLoadingBusinessProductCategoriesAndProductsWithBusincessID : (NSString *) busiID;

- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject;
- (id)initWithDataFromDatabase:(NSDictionary *)data;

@end


@protocol TaptalkBusinessDelegate

- (void)Business:(Business *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)dictionaryServerResult;

- (void)Business:(Business *)conn didFailWithError:(NSError *)error;


@end
