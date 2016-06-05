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
@property(nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property(nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property(nonatomic, strong) NSString *appendUrl;

- (NSString *) GMTToLocalTime: (NSString *)GMTTime;
- (NSString *) getCurrentTime;
- (BOOL) isOpenBussiness: (NSString *)openTime CloseTime:(NSString *)closeTime;
- (NSString *) getOpenCloseTime: (NSString *)openTime CloseTime:(NSString *)closeTime;

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr;

- (void)orderToServer:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)setFavoriteAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)getRevardpointsForBusiness:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished ;

- (void) getPreviousOrderListWithConsumerID  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) getNotificationForConsumer  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished;

- (void) save_notifications_for_consumer_in_business :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished;
@end
