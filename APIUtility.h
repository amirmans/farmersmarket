//
//  LoadingView.h
//  woodwright
//
//  Created by Harry on 12/18/14.
//  Copyright (c) 2014 woodwright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


@interface APIUtility : NSObject

+ (APIUtility *) sharedInstance;

@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property(nonatomic) AFHTTPSessionManager *operationManager;
@property(nonatomic, strong) NSMutableURLRequest *requestOperation;
@property(nonatomic, strong) NSString *appendUrl;

- (NSString *) GMTToLocalTime: (NSString *)GMTTime;
- (NSString *) getCurrentTime;
- (BOOL) isOpenBussiness: (NSString *)openTime CloseTime:(NSString *)closeTime;
- (NSString *) getOpenCloseTime: (NSString *)openTime CloseTime:(NSString *)closeTime;
- (NSString *)getCivilianTime: (NSString *)militaryTime;

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr;

- (void)orderToServer:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;

//-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)setFavoriteAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)getRevardpointsForBusiness:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished ;

- (void)getAverageWaitTimeForBusiness:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getPreviousOrderListWithConsumerID  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getNotificationForConsumer  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_notifications_for_consumer_in_business :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) remove_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getAllCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getDefaultCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (BOOL)isZipCodeValid:(NSString *)zipCode;

-(void)BusinessDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)ConsumerDelivaryInfoSaveAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)ConsumerDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)CheckConsumerPromoCodeAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

- (void)getFromServer:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;
- (void)postFromServer:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;


@end
