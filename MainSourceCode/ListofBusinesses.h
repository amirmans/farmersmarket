//
//  ListofBusinesses.h
//  TapForAll
//
//  Created by Amir on 2/14/14.
//
//

#import <Foundation/Foundation.h>
#import "ServerInteractionManager.h"
@class  Business;

@interface ListofBusinesses : NSObject <PostProcesses> {
    Business *aBusiness;
    ServerInteractionManager *myServer;
    NSArray *businessListArray;
}

@property (strong, atomic) NSArray *businessListArray;

- (void)startGettingListofAllBusinesses;

+ (id)sharedListofBusinesses;


@end
