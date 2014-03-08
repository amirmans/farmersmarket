//
//  ServerInteractionManager.m
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//

#import "ServerInteractionManager.h"
#import "AFNetworking.h"

@implementation ServerInteractionManager

@synthesize postProcessesDelegate;

- (void)serverCallToGetListofAllBusinesses
{
    NSString *urlString = BusinessInformationServer;
    NSDictionary *params = @{@"businessID":[NSNumber numberWithInt:0]};
    
    AFHTTPRequestOperationManager *manager;
    manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:urlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //remember in the data is already translated to NSDictionay - by AFJSONResponseSerializer
              [postProcessesDelegate postProcessForListOfBusinessesSuccess:responseObject];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error in fetching list of businesses: %@", error);
              
          }
     ];
    
}


- (BOOL)serverUpdateDeviceToken:(NSString *)deviceToken withUserID:(long)uid WithError:(NSError **)error
{
    NSString *urlString = ConsumerProfileServer;
    BOOL retcode = YES;
    
    AFHTTPRequestOperationManager *manager;
    manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    NSDictionary *params = @{@"device_token": deviceToken, @"uid":[NSNumber numberWithUnsignedInteger:uid]};
    [manager POST:urlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [postProcessesDelegate postProcessForSuccess:operation.response.statusCode];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error in ServerUpdateDeviceToken: %@", error);
              
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
