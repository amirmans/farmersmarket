//
//  ServerInteractionManager.h
//  TapTalk
//
//  Created by Amir on 12/12/13.
//
//

@protocol PostProcesses <NSObject>

@required
- (void)postProcessForSuccess:(int)givenUserID;

@optional
- (void)postProcessForFailure;

@end

#import <Foundation/Foundation.h>

@interface ServerInteractionManager : NSObject {
    __weak id <PostProcesses> postProcessesDelegate;
}

- (BOOL)ServerUpdateDeviceToken:(NSString *)deviceToken withUserID:(int)uid WithError:(NSError **)error;
@property (nonatomic, weak) id <PostProcesses> postProcessesDelegate;

@end
