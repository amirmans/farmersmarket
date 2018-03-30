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
    NSMutableArray *businessListArray;
    NSMutableArray *corpBusinessListArray;
}

@property (strong, atomic) NSMutableArray *businessListArray;
@property (strong, atomic) NSMutableArray *corpBusinessListArray;

- (void)startGettingListofAllBusinesses;
- (void)startGettingListofAllBusinessesForCorp:(NSString *)businesses;

+ (id)sharedListofBusinesses;


@end
