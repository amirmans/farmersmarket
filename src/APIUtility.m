//
//  LoadingView.h
//  woodwright
//
//  Created by Harry on 12/18/14.
//  Copyright (c) 2014 woodwright. All rights reserved.
//

#import "APIUtility.h"
#import "AppData.h"
#import "Reachability.h"
#import "AFNetworking.h"

static APIUtility *sharedObj;
static NSDateFormatter* utilyDateFormatter;

@implementation APIUtility

+ (APIUtility *) sharedInstance
{
    if(sharedObj == nil)
    {
        sharedObj = [[APIUtility alloc] init];
        sharedObj.sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        sharedObj.operationManager = [AFHTTPSessionManager manager];
        sharedObj.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        utilyDateFormatter = [[NSDateFormatter alloc]init];
        [utilyDateFormatter setDateFormat:@"HH:mm:ss"];
        [utilyDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//        [utilyDateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];

    }
    return sharedObj;
}

-(void)cancelRequest
{
    [sharedObj.operationManager.operationQueue cancelAllOperations];
    [sharedObj.sessionManager.operationQueue cancelAllOperations];
}

-(void)showDialogBox
{
//    [AppData showAlert:@"Message" message:@"No internet connection" buttonTitle:@"Ok"];
}


- (void)callServer:(NSDictionary *)data server:(NSString *)url method:(NSString *)method completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    if ([method isEqual:@"POST"]) {
    [manager POST:url
       parameters:data progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              finished(responseObject);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error in sending order to the server: %@", error.description);
              finished(@{@"server_error_message":error.description, @"server_error":@"-1"});
          }];
    } else {
        [manager GET:url
           parameters:data progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
                  finished(responseObject);
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  
                  NSLog(@"Error in sending order to the server: %@", error.description);
                  finished(@{@"server_error_message":error.description, @"server_error":@"-1"});
              }];
    }
}


//-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
//{
//    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
//    {
//        return;
//    }
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.requestSerializer setTimeoutInterval:timeInterval];
//    
//    [manager GET:[NSString stringWithFormat:@"%@",BusinessInformationServer] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
//        if (finished) {
//            finished((NSDictionary*)responseObject);
//        }
//        
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        
//        NSLog(@"Error: %@", error);
//        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
//        NSDictionary *temp = @{};
//        
//        if([error code] == -1004) {
//            
//            if (finished) {
//                finished(dic);
//            }
//        }
//        else
//        {
//            if (finished) {
//                finished(temp);
//            }
//        }
//    }];
//}

-(void)BusinessDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    NSLog(@"%@",data);
    [manager GET:[NSString stringWithFormat:@"%@",BusinessDelivaryInformationServer] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}

-(void)ConsumerDelivaryInfoAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:[NSString stringWithFormat:@"%@",OrderServerURL] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}
-(void)ConsumerDelivaryInfoSaveAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager POST:OrderServerURL
       parameters:data progress:nil
          success:^(NSURLSessionTask *task, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              finished(responseObject);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error saving delivary info in the server: %@", error.description);
              finished(@{@"error":error.description});
          }];
}

-(void)CheckConsumerPromoCodeAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:[NSString stringWithFormat:@"%@",OrderServerURL] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        if (finished) {
            finished(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}


-(void)setFavoriteAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished {
    
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:[NSString stringWithFormat:@"%@",SetFavoriteServer] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        if (finished) {
            finished(@{@"success":@"YES"});
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}

-(void)getRewardpointsForBusiness:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:[NSString stringWithFormat:@"%@",GetRewardPoints] parameters:data progress: nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error in getting rewards: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}

- (void) getPreviousOrderListWithConsumerID  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=previous_order&consumer_id=%@&business_id=%@",GetPrevious_order,consumer_id,business_id];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
//        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(dic);
            }
        }
    }];
}

- (void)save_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager POST:Save_cc_info
       parameters:param progress:nil
          success:^(NSURLSessionTask *task, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              finished(responseObject);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error saving credit card in the server: %@", error.description);
              finished(@{@"error":error.description});
          }];
}

- (void)remove_cc_info :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
//    NSError *error = [NSError alloc];
//    NSData *data1 = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager POST:remove_cc
       parameters:param progress:nil
          success:^(NSURLSessionTask *task, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              finished(responseObject);
          }
          failure:^(NSURLSessionTask *task, NSError *error) {
              
              NSLog(@"Error saving credit card in the server: %@", error.description);
              finished(@{@"error":error.description});
          }];
}

- (void) getAllCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=get_consumer_all_cc_info&consumer_id=%@",Get_consumer_all_cc_info,consumer_id];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSLog(@"get %@", responseObject);
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        //        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(dic);
            }
        }
    }];
}


- (void) getDefaultCCInfo : (NSString *) consumer_id completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=get_consumer_default_cc&consumer_id=%@",Get_consumer_all_cc_info,consumer_id];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSLog(@"get %@", responseObject);
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        //        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(dic);
            }
        }
    }];
}




- (void) getNotificationForConsumer  :(NSString *) consumer_id BusinessID : (NSString *) business_id completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?cmd=get_all_notifications_for_consumer&consumer_id=%@",Get_notifications,consumer_id];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSLog(@"get %@", responseObject);
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask  *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        //        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(dic);
            }
        }
    }];
}

- (void) save_notifications_for_consumer_in_business :(NSDictionary *) param completiedBlock:(void (^)(NSDictionary *response))finished {
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager POST:save_notifications
       parameters:param progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              finished(responseObject);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              
              NSLog(@"Error saving credit card in the server: %@", error.description);
              finished(@{@"error":error.description});
          }];
}


- (NSString *) GMTToLocalTime: (NSString *)GMTTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    return timeStamp;
}


/** Returns a new NSDate object with the time set to the indicated hour,
 * and minute.
 * @param hour The hour to use in the new date.
 * @param minute The number of minutes to use in the new date.
 */
- (NSDate *)dateFromGivenDate:(NSDate *)givenDate WithHour:(NSInteger)hour
                       minute:(NSInteger)minute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitDay
                                               fromDate:givenDate];
    [components setHour:hour];
    [components setMinute:minute];
    
    NSDate *newDate = [calendar dateFromComponents:components];
    
    return newDate;
}

- (NSDate *)dateFromGivenDate:(NSDate *)givenDate WithYear:(NSInteger)year
                        month:(NSInteger)month  andDay:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitHour|
                                    NSCalendarUnitMinute|
                                    NSCalendarUnitSecond
                                               fromDate:givenDate];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}


- (BOOL)isBusinessOpenAt:(NSString *)givenDate OpenTime:(NSString *)openTime CloseTime:(NSString *)closeTime {

    NSString *time1 = openTime;
    NSString *time2 = closeTime;
    NSString *time3 = givenDate;
    
    NSDate *date1 = [utilyDateFormatter dateFromString:time1];
    NSDate *date2 = [utilyDateFormatter dateFromString:time2];
    NSDate *date3 = [utilyDateFormatter dateFromString:time3];
    
    NSComparisonResult result = [date1 compare:date3];
    NSComparisonResult result1 = [date2 compare:date3];
    if(result == NSOrderedAscending && result1 == NSOrderedDescending)
    {
        return true;
    } else if(result == NSOrderedSame || result1 == NSOrderedSame){
        return true;
    } else {
        return false;
    }
    
    return  false;
}


- (BOOL)isBusinessOpen: (NSString *)openTime CloseTime:(NSString *)closeTime {
    NSString *currentTime = [utilyDateFormatter stringFromDate:[NSDate date]];
    
    NSString *time1 = openTime;
    NSString *time2 = closeTime;
    NSString *time3 = currentTime;
    
    NSDate *date1 = [utilyDateFormatter dateFromString:time1];
    NSDate *date2 = [utilyDateFormatter dateFromString:time2];
    NSDate *date3 = [utilyDateFormatter dateFromString:time3];
    
    NSComparisonResult result = [date1 compare:date3];
    NSComparisonResult result1 = [date2 compare:date3];
    if(result == NSOrderedAscending && result1 == NSOrderedDescending)
    {
        return true;
    } else if(result == NSOrderedSame || result1 == NSOrderedSame){
        return true;
    } else {
        return false;
    }
    return  false;
}

- (NSString *)earlierTimeInString:(NSString *)time1 and:(NSString *)time2 {

    NSArray *time1_Array = [time1 componentsSeparatedByString:@":"];
    NSArray *time2_Array = [time2 componentsSeparatedByString:@":"];
    
    long long time1InSeconds = [time1_Array[0] integerValue] * 3600 + [time1_Array[1] integerValue]* 60 + [time1_Array[2] integerValue];
    long long time2InSeconds = [time2_Array[0] integerValue] * 3600 + [time2_Array[1] integerValue]* 60 + [time2_Array[2] integerValue];
    
    if (time2InSeconds < time1InSeconds) {
        return time2;
    } else {
        return time1;
    }
}

- (NSString *)laterTimeInString:(NSString *)time1 and:(NSString *)time2 {
    
    NSArray *time1_Array = [time1 componentsSeparatedByString:@":"];
    NSArray *time2_Array = [time2 componentsSeparatedByString:@":"];
    
    long long time1InSeconds = [time1_Array[0] integerValue] * 3600 + [time1_Array[1] integerValue]* 60 + [time1_Array[2] integerValue];
    long long time2InSeconds = [time2_Array[0] integerValue] * 3600 + [time2_Array[1] integerValue]* 60 + [time2_Array[2] integerValue];
    
    if (time2InSeconds > time1InSeconds) {
        return time2;
    } else {
        return time1;
    }
}


- (int)serviceAvailableStatus: (int)service during:(NSString *)openTime and:(NSString *)closeTime withType:(int)serviceBeforeOpen {
    int returnVal = 0;
    
    
    
    //    static const int Pickup_closed_all_day = 1;
    //    static const int Pickup_closed_rest_of_day = 2;
    //    static const int Pickup_open_later_today = 4;
    //    static const int Pickup_open = 8;
    
//    NSString *time1 = biz.opening_time;
//    NSString *time2 = biz.closing_time;
    
    NSArray *openTimeArray = [openTime componentsSeparatedByString:@":"];
    NSArray *closeTimeArray = [closeTime componentsSeparatedByString:@":"];
    
    long long openTimeInSeconds = [openTimeArray[0] integerValue] * 3600 + [openTimeArray[1] integerValue]* 60 + [openTimeArray[2] integerValue];
    long long closeTimeInSeconds = [closeTimeArray[0] integerValue] * 3600 + [closeTimeArray[1] integerValue]* 60 + [closeTimeArray[2] integerValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitHour|
                                    NSCalendarUnitMinute|
                                    NSCalendarUnitSecond
                                    fromDate:[NSDate date]];
    long long currentTimeInSeconds = [components hour] * 3600 + [components minute] * 60 + [components second];
    
    
//    NSDate *date1 = [utilyDateFormatter dateFromString:openTime];
//    NSDate *date2 = [utilyDateFormatter dateFromString:closeTime];
//    NSDate *date3 = [utilyDateFormatter dateFromString:time3];
//    NSDate *date1 = [self dateFromGivenDate:[NSDate date] WithHour:[openTimeArray[0] integerValue]
//                                     minute:(NSInteger)[openTimeArray[1] integerValue]];
//    NSDate *date2 = [self dateFromGivenDate:[NSDate date] WithHour:[closeTimeArray[0] integerValue]
//                                     minute:(NSInteger)[closeTimeArray[1] integerValue]];
    
    if (openTimeInSeconds >= closeTimeInSeconds) {
        returnVal = Pickup_closed_all_day;
    } else if (currentTimeInSeconds > closeTimeInSeconds) {
        returnVal = Pickup_closed_rest_of_day;
    } else if (currentTimeInSeconds < openTimeInSeconds) {
        returnVal = Pickup_open_later_today;
    } else {
        returnVal = Pickup_open;
    }
    
    return returnVal;
    
//    NSString *currentTime = [utilyDateFormatter stringFromDate:[NSDate date]];
//    NSDate *date3 = [utilyDateFormatter dateFromString:currentTime];
//    NSDate *date3 = [NSDate date];
    
//    NSComparisonResult result2 = [date1 compare:date2];
//    NSComparisonResult result = [date1 compare:date3];
//    NSComparisonResult result1 = [date2 compare:date3];
//
//    if(result2 == NSOrderedSame || result2 == NSOrderedDescending)
//    {
//        returnVal = Pickup_closed_all_day;
//    } else if(result == NSOrderedAscending && result1 == NSOrderedDescending)
//    {
//        returnVal = Pickup_open;
//    } else if(result == NSOrderedSame || result1 == NSOrderedSame){
//        returnVal = Pickup_open;
//    } else if (result == NSOrderedDescending)
//    {
//        returnVal = Pickup_open_later_today;
//    }
//    else {
//        returnVal = Pickup_closed_rest_of_day;
//    }
    
//    return returnVal;
//    if (returnVal == Pickup_open)
//    {
//        return true;
//    } else if ( (returnVal == Pickup_open_later_today) &&  (serviceBeforeOpen > 0) ) {
//        return true;
//    } else {
//        return false;
//    }
}

- (BOOL)isServiceAvailable:(int)service during:(NSString *)openTime and:(NSString *)closeTime withType:(int) serviceBeforeOpen {
    int serviceStatus = [self serviceAvailableStatus:service during:openTime and:closeTime withType:serviceBeforeOpen];
    
    if (serviceStatus == Pickup_open)
    {
        return true;
    } else if ( (serviceStatus == Pickup_open_later_today) &&  (serviceBeforeOpen > 0) ) {
        return true;
    } else {
        return false;
    }
}



- (NSString *) getOpenCloseTime: (NSString *)openTime CloseTime:(NSString *)closeTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];
    
    NSString *time1 = openTime;
    NSString *time2 = closeTime;
    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    if (distanceBetweenDates <= 0) {
        return @"Closed all day";
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"h:mma";
    
//    NSLog(@"%@",[timeFormatter stringFromDate:date2]);
    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date1];
//    NSInteger hour= [components hour];
//    NSInteger minute = [components minute];
//    NSInteger second = [components second];

//    NSLog(@"%ld-%ld-%ld",(long)hour,(long)minute,(long)second);
    NSString *openCloseTime = [NSString stringWithFormat:@"%@-%@",[timeFormatter stringFromDate:date1],[timeFormatter stringFromDate:date2]];
    return openCloseTime;
}


- (NSString *)getCivilianTime: (NSString *)militaryTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];
    
    NSString *time1 = militaryTime;
   
    NSDate *date1= [formatter dateFromString:time1];

    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"h a";
    
    return [NSString stringWithFormat:@"%@",[timeFormatter stringFromDate:date1]];
}



-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
//    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *esc_addr = [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
//    NSLog(@"View Controller get Location Logitute : %f",center.latitude);
//    NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
}

//- (UIFont) setSystemBold16Font {
//    UIFont* boldFont = [UIFont boldSystemFontOfSize:16];
//    return boldFont;
//}



- (void)getAverageWaitTimeForBusiness:(NSDictionary *)data server:(NSString *)url completiedBlock:(void (^)(NSDictionary *response))finished {

    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];
    
    [manager GET:[NSString stringWithFormat:@"%@",GetRewardPoints] parameters:data progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        NSDictionary *dic= [[NSDictionary alloc] initWithObjects:@[@"NO"] forKeys:@[@"success"]];
        NSDictionary *temp = @{};
        
        if([error code] == -1004) {
            
            if (finished) {
                finished(dic);
            }
        }
        else
        {
            if (finished) {
                finished(temp);
            }
        }
    }];
}


- (BOOL)isZipCodeValid:(NSString *)zipCode {
    BOOL returnVal = FALSE;
    
//    NSString *zipcodeRegEx = @"^[1..9][0-9,-]{4,}?"; // for us
    NSString *zipcodeRegEx = @"^(\\d{5}(-\\d{4})?|[a-z]\\d[a-z][- ]*\\d[a-z]\\d)$"; // for us and canada
    NSPredicate *zipcodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipcodeRegEx];
    
    if ([zipcodeTest evaluateWithObject:zipCode] == NO) {
        returnVal = FALSE;
    }
    else {
        returnVal = TRUE;
    }

    
    return returnVal;
}

- (NSString *)transformValidSMSNo:(NSString *)phone {
    
    NSString *phoneNumber = [phone stringByReplacingOccurrencesOfString:@", ()-+"  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@","  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" "  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"("  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")"  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-"  withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+"  withString:@""];
    
    if (phoneNumber.length == 10)
    {
        phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
    } else if (phoneNumber.length == 11) {
        phoneNumber = [@"+" stringByAppendingString:phoneNumber];
    }
    
    
    NSString *phoneRegex = @"^[+][1][2-9][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    if ([phoneTest evaluateWithObject:phoneNumber])
    {
        return phoneNumber;
    }
    else {
        return @"";
    }
}



- (NSString*)usPhoneNumber:(NSString *)E_164FormatNo {
    
    if (E_164FormatNo.length < 10) {
        return @"";
    }
    NSString* stringts = [NSMutableString stringWithString:E_164FormatNo];
    stringts = [stringts stringByReplacingOccurrencesOfString:@"+"  withString:@""];
    
    NSRange range = [stringts rangeOfString:@"1"];
    if (range.length > 0)
        stringts= [stringts stringByReplacingCharactersInRange:range withString:@""];
    
    NSMutableString* usNumber = [NSMutableString stringWithString:stringts];
    [usNumber insertString: @"(" atIndex:0];
    [usNumber insertString: @")" atIndex:4];
    [usNumber insertString: @"-" atIndex:5];
    [usNumber insertString: @"-" atIndex:9];
    
    return usNumber;
}

+ (float)calcCharge:(float)subTotal using:(NSString *)chargeFormula {
    float returnVal = 0.0;
    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"%"];
    NSRange range = [chargeFormula rangeOfCharacterFromSet:cset];
    if (range.location == NSNotFound) {
        return ([chargeFormula floatValue]);
    } else {
        NSString* floatString =
        [chargeFormula stringByReplacingOccurrencesOfString:@" %" withString:@""];
        return ([floatString floatValue]);
    }
    
    return returnVal;
}

@end
