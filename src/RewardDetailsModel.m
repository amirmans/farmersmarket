//
//  RewardDetailsModel.m
//  TapForAll
//
//  Created by Harry on 4/8/16.
//
//

#import "RewardDetailsModel.h"
#import "Corp.h"

RewardDetailsModel *sharedObject;

@implementation RewardDetailsModel

+(RewardDetailsModel *) sharedInstance {
    if (sharedObject == nil) {
        sharedObject = [[RewardDetailsModel alloc] init];
    }
    return sharedObject;
}

//- (void) getRewardData : (Business *) biz completiedBlock:(void (^)(NSDictionary *response, bool success))finished {
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
////    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
////    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    NSInteger userID = [DataModel sharedDataModelManager].userID;
//    
//    NSString *businessIDString = [NSString stringWithFormat:@"%i", biz.businessID];
//
//    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=get_all_points&consumerID=%ld&businessID=%@",GetRewardPoints,(long)userID,businessIDString];
//
//    [manager GET:urlString parameters:@{} progress:nil success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseObject) {
//        NSDictionary *dict = responseObject;
//        self.rewardDict = dict;
//        NSLog(@"%@",responseObject);
//        finished(responseObject,true);
//    } failure:^(NSURLSessionTask * _Nullable operation, NSError * _Nonnull error) {
//        NSLog(@"%@",error.userInfo);
//        finished(@{@"error":error.userInfo},false);
//    }];
//}



-(void)getRewardData:(Business *)biz completiedBlock:(void (^)(NSDictionary *response))finished {
    
    NSInteger userID = [DataModel sharedDataModelManager].userID;
  
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *corp_id=@"";
    if (([Corp sharedCorp].chosenCorp) && [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"]> 0 ) {
        corp_id = [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"];
    }
    NSDictionary *data= @{@"cmd":@"get_all_points",@"consumerID": [NSString stringWithFormat:@"%ld",(long)userID],
                          @"businessID":[NSString stringWithFormat:@"%ld",(long)biz.businessID],
                          @"corp_id":corp_id};
    
    NSDictionary *headers = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",@""]};
    [manager GET:[NSString stringWithFormat:@"%@",GetRewardPoints] parameters:data headers:headers progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        self.rewardDict = responseObject;;
        if (finished) {
            finished(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



@end
