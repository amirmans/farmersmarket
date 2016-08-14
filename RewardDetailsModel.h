//
//  RewardDetailsModel.h
//  TapForAll
//
//  Created by Harry on 4/8/16.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DataModel.h"
#import "Business.h"

@interface RewardDetailsModel : NSObject

+(RewardDetailsModel *) sharedInstance;

@property (nonatomic, strong) NSDictionary *rewardDict;

//
//- (void) getRewardData : (Business *) biz completiedBlock:(void (^)(NSDictionary *response, bool success))finished;
- (void)getRewardData:(Business *)biz completiedBlock:(void (^)(NSDictionary *response))finished;
@end
