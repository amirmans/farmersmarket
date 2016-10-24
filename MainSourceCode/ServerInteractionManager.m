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

@implementation ServerInteractionManager

@synthesize postProcessesDelegate;

- (void)serverCallToGetListofAllBusinesses
{
    NSString *urlString = BusinessInformationServer;
    NSDictionary *params = @{@"businessID":[NSNumber numberWithInt:0]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager  manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:urlString parameters:params progress:nil
          success:^(NSURLSessionTask *operation, id responseObject) {
              //remember in the data is already translated to NSDictionay - by AFJSONResponseSerializer
              [postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject];
          }
          failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"Error in fetching list of businesses: %@", error);
              
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
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];


//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
//        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    NSDictionary *params = @{@"device_token": deviceToken, @"uuid":uuid};
    [manager POST:urlString parameters:params progress:nil
          success:^(NSURLSessionTask *operation, id responseObject) {
//              NSError *jsonError = nil;
//              NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:kNilOptions error:&jsonError];
              [postProcessesDelegate postProcessForSuccess:responseObject];
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
    CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)tmpString,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
//    return GTMCFAutorelease(escaped);
    return  (__bridge NSString *)escaped;
}

+ (NSString*)gtm_stringByUnescapingFromURLArgument:(NSString *)tmpString {
    NSMutableString *resultString = [NSMutableString stringWithString:tmpString];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


@end
