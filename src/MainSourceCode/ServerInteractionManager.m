      //
//  ServerInteractionManager.m
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//

#import "ServerInteractionManager.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Consts.h"

@implementation ServerInteractionManager

@synthesize postProcessesDelegate;

- (void)serverCallToGetListofAllBusinesses
{
    NSString *urlString = BusinessInformationServer;
    NSDictionary *params = @{@"businessID":[NSNumber numberWithInt:0], @"cmd":@"getBusinessInfoWithConsumerRating"};

     NSLog(@"Getting list of businesses using server: %@, and business ID %@", urlString, params);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];

    NSString *path=[[NSString alloc]initWithFormat:@"%@",urlString];

//    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
//    [parameter setValue:@"123456" forKey:@"id"];

    NSDictionary *headers = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",@""]};

     [manager POST:[NSURL URLWithString:path].absoluteString parameters:params
           headers:headers progress:nil success:^(NSURLSessionTask *operation, id responseObject)
//        {
//         NSLog(@"Response Object response is....==%@",responseObject);
//         }
//             failure:^(NSURLSessionTask *operation, NSError *error)
//        {
//         NSLog(@"Error Last 2 Done: %@", [error localizedDescription]);
//     }];

    
    
    
    
    
    
    
//    NSString *urlString = BusinessInformationServer;
 

//    AFHTTPSessionManager *manager = [AFHTTPSessionManager  manager];


//    [manager GET:urlString parameters:params progress:nil
//          success:^(NSURLSessionTask *operation, id responseObject)
        {
              //remember in the data is already translated to NSDictionay - by AFJSONResponseSerializer
              [self.postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject for:IndividualType];
          }
          failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"Error in fetching list of businesses: %@", error);

              NSDictionary* responseObject = @{@"server_error_message":error.description, @"server_error":@"-1"};
              [self.postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject for:IndividualType];
          }
     ];

}

- (void)serverCallToGetListofAllBusinessesForCorp:(NSString*)businesses {
    NSString *urlString = BusinessInformationServer;
    NSDictionary *params = @{@"ids":businesses
                             ,@"cmd":@"get_all_businesses_for_set"};

    NSLog(@"Getting list of businesses for corp using server: %@, and params: %@", urlString, params);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager  manager];
    [manager.requestSerializer setTimeoutInterval:timeInterval];

    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSDictionary *headers = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",@""]};
    [manager GET:urlString parameters:params
          headers:headers progress:nil success:^(NSURLSessionTask *operation, id responseObject)
    {
             //remember in the data is already translated to NSDictionay - by AFJSONResponseSerializer
             [self.postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject for:CorpType];
         }
         failure:^(NSURLSessionTask *operation, NSError *error) {
             NSLog(@"Error in fetching list of businesses: %@", error);
             NSDictionary* responseObject = @{@"server_error_message":error.description, @"server_error":@"-1"};
             [self.postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject for:CorpType];
         }
     ];
}


- (BOOL)serverUpdateDeviceToken:(NSString *)deviceToken withUuid:(NSString *)uuid WithError:(NSError **)error
{
    NSString *urlString = ConsumerProfileServer;
    BOOL retcode = YES;

    AFHTTPSessionManager *manager;
    manager = [AFHTTPSessionManager manager];

    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];


//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];

//        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];

    NSDictionary *params = @{@"device_token": deviceToken, @"uuid":uuid};
    NSDictionary *headers = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",@""]};
    [manager POST:urlString parameters:params headers:headers progress:nil
          success:^(NSURLSessionTask *operation, id responseObject) {
//              NSError *jsonError = nil;
//              NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:kNilOptions error:&jsonError];
              [self.postProcessesDelegate postProcessForConsumerProfile:responseObject];
          }
          failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"Error in ServerUpdateDeviceToken: %@", error);
//              AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//              [appdelegate saveDeviceTokenAndUUID];

          }
     ];

    return retcode;
}

+ (NSString*)gtm_stringByEscapingForURLArgument:(NSString *)tmpString {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
//    CFStringRef escaped =
//    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                            (CFStringRef)tmpString,
//                                            NULL,
//                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                            kCFStringEncodingUTF8);
////    return GTMCFAutorelease(escaped);
//    return  (__bridge NSString *)escaped;
    return [tmpString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]];
}

+ (NSString*)gtm_stringByUnescapingFromURLArgument:(NSString *)tmpString {
    NSMutableString *resultString = [NSMutableString stringWithString:tmpString];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByRemovingPercentEncoding];
//    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

}


@end
