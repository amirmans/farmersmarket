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

-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

-(void)setFavoriteAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished;

@end
