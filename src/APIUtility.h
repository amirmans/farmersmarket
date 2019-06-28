//
//  LoadingView.h
//  woodwright
//
//  Created by Harry on 12/18/14.
//  Copyright (c) 2014 woodwright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Business.h"


@interface APIUtility : NSObject {
    NSDateFormatter* utilityDisplayDateFormatter;
}

+ (APIUtility *) sharedInstance;

@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property(nonatomic) AFHTTPSessionManager *operationManager;
@property(nonatomic, strong) NSMutableURLRequest *requestOperation;
@property(nonatomic, strong) NSString *appendUrl;
@property(nonatomic, strong) NSDateFormatter *utilityDisplayDateFormatter;

- (NSString *) GMTToLocalTime: (NSString *)GMTTime;
- (BOOL)isBusinessOpenAt:(NSString *)givenDate OpenTime:(NSString *)openTime CloseTime:(NSString *)closeTime;
- (BOOL) isBusinessOpen: (NSString *)openTime CloseTime:(NSString *)closeTime;
- (BOOL)isServiceAvailable: (int)service during:(NSString *)openTime and:(NSString *)closeTime withType:(int)serivceBeforeOpen;
- (int)serviceAvailableStatus: (int)service during:(NSString *)openTime and:(NSString *)closeTime withType:(int)serivceBeforeOpen;
- (NSString *) getOpenCloseTime: (NSString *)openTime CloseTime:(NSString *)closeTime;
- (NSString *)getCivilianTime: (NSString *)militaryTime;

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr;

- (void)callServer:(NSDictionary *)data server:(NSString *)url method:(NSString *)method completiedBlock:(void (^)(NSDictionary *response))finished;

//-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)setFavoriteAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)getRewardpointsForBusiness:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished ;

- (void)getAverageWaitTimeForBusiness:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getPreviousOrderListWithConsumerID  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getNotificationForConsumer  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_notifications_for_consumer_in_business :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) remove_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getAllCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getDefaultCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (BOOL)isZipCodeValid:(NSString *)zipCode;

+ (float)calcCharge:(float)subTotal using:(NSString *)chargeFormula;

- (NSString *)laterTimeInString:(NSString *)time1 and:(NSString *)time2;
- (NSString *)earlierTimeInString:(NSString *)time1 and:(NSString *)time2;

- (NSString *)transformValidSMSNo:(NSString *)phone;
- (NSString*)usPhoneNumber:(NSString *)E_164FormatNo;


-(void)BusinessDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)ConsumerDelivaryInfoSaveAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)ConsumerDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)CheckConsumerPromoCodeAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;


@end
