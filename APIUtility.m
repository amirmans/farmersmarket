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

static APIUtility *sharedObj;

@implementation APIUtility

+ (APIUtility *) sharedInstance
{
    if(sharedObj == nil)
    {
        sharedObj = [[APIUtility alloc] init];
        sharedObj.sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        sharedObj.operationManager = [AFHTTPRequestOperationManager manager];
        sharedObj.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
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
    [AppData showAlert:@"Message" message:@"No internet connection" buttonTitle:@"Ok"];
}

-(void)BusinessListAPICall:(NSDictionary *)data completiedBlock:(void (^)(NSDictionary *response))finished
{
    if ([[[AppData sharedInstance]checkNetworkConnectivity] isEqualToString:@"NoAccess"])
    {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@",BusinessInformationServer] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"get %@", responseObject);
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@",SetFavoriteServer] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"get %@", responseObject);
        if (finished) {
            finished((NSDictionary*)responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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


- (NSString *) GMTToLocalTime: (NSString *)GMTTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    return timeStamp;
}

- (NSString *) getCurrentTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];
    NSString *theTime = [dateFormatter stringFromDate:[NSDate date]];
    return theTime;
}

- (BOOL) isOpenBussiness: (NSString *)openTime CloseTime:(NSString *)closeTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];

   [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *time1 = openTime;
    NSString *time2 = closeTime;
    NSString *time3 = currentTime;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    NSDate *date3 = [formatter dateFromString:time3];
    
    NSComparisonResult result = [date1 compare:date3];
    NSComparisonResult result1 = [date2 compare:date3];
    if(result == NSOrderedAscending && result1 == NSOrderedDescending)
    {
        NSLog(@"date1 is later than date2");
        return true;
    } else if(result == NSOrderedSame || result1 == NSOrderedSame){
        NSLog(@"date2 is later than date1");
        return true;
    } else {
        NSLog(@"date1 is equal to date2");
        return false;
    }
    return  false;
}

- (NSString *) getOpenCloseTime: (NSString *)openTime CloseTime:(NSString *)closeTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss" options:0 locale:[NSLocale currentLocale]]];
    
    NSString *time1 = openTime;
    NSString *time2 = closeTime;
    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"hh:a";
    
    NSLog(@"%@",[timeFormatter stringFromDate:date2]);
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date1];
    NSInteger hour= [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];

    NSLog(@"%ld-%ld-%ld",(long)hour,(long)minute,(long)second);
    NSString *openCloseTime = [NSString stringWithFormat:@"%@-%@",[timeFormatter stringFromDate:date1],[timeFormatter stringFromDate:date2]];
    return openCloseTime;
}


-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    NSLog(@"View Controller get Location Logitute : %f",center.latitude);
    NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
}

//- (UIFont) setSystemBold16Font {
//    UIFont* boldFont = [UIFont boldSystemFontOfSize:16];
//    return boldFont;
//}


@end
