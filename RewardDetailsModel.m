//
//  RewardDetailsModel.m
//  TapForAll
//
//  Created by Harry on 4/8/16.
//
//

#import "RewardDetailsModel.h"

RewardDetailsModel *sharedObject;

@implementation RewardDetailsModel

+(RewardDetailsModel *) sharedInstance {
    if (sharedObject == nil) {
        sharedObject = [[RewardDetailsModel alloc] init];
    }
    return sharedObject;
}

- (void) getRewardData : (Business *) biz completiedBlock:(void (^)(NSDictionary *response, bool success))finished {

    AFHTTPRequestOperationManager *manager;
    manager = [AFHTTPRequestOperationManager manager];
    NSInteger userID = [DataModel sharedDataModelManager].userID;
    NSString *businessIDString = [NSString stringWithFormat:@"%i", biz.businessID];

    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=get_all_points&consumerID=%ld&businessID=%@",GetRewardPoints,(long)userID,businessIDString];

    [manager GET:urlString parameters:@{} success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *dict = responseObject;
        self.rewardDict = dict;
        NSLog(@"%@",responseObject);
        finished(responseObject,true);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error.userInfo);
        finished(@{@"error":error.userInfo},false);
    }];
}

@end
