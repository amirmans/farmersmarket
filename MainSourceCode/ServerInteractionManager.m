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

- (BOOL)ServerUpdateDeviceToken:(NSString *)deviceToken withUserID:(int)uid WithError:(NSError **)error
{
    NSString *urlString = ConsumerProfileServer;
    BOOL retcode = YES;
    
    AFHTTPRequestOperationManager *manager;
    manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    NSDictionary *params = @{@"device_token": deviceToken, @"uid":[NSNumber numberWithInt:uid]};
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


@end
