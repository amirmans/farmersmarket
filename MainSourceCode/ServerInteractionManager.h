//
//  ServerInteractionManager.h
//  TapTalk
//
//  Created by Amir on 12/12/13.
//
//

@protocol PostProcesses <NSObject>

@optional
- (void)postProcessForSuccess:(NSDictionary *)consumerInfo;
- (void)postProcessForListOfBusinessesSuccess:(NSData *)responseObject;
- (void)postProcessForFailure;

@end

#import <Foundation/Foundation.h>

@interface ServerInteractionManager : NSObject {
    __weak id <PostProcesses> postProcessesDelegate;
}

- (BOOL)serverUpdateDeviceToken:(NSString *)deviceToken withUuid:(NSString *)uuid WithError:(NSError **)error;
- (void)serverCallToGetListofAllBusinesses;


// borrowed from Google GTM
+ (NSString*)gtm_stringByEscapingForURLArgument:(NSString *)tmpString;
+ (NSString*)gtm_stringByUnescapingFromURLArgument:(NSString *)tmpString;

@property (nonatomic, weak) id <PostProcesses> postProcessesDelegate;

@end
