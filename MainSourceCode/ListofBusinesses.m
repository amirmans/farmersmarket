//
//  ListofBusinesses.m
//  TapForAll
//
//  Created by Amir on 2/14/14.
//
//

#import "ListofBusinesses.h"



@interface ListofBusinesses () {
    
@private

    
}

@end



@implementation ListofBusinesses

@synthesize businessListArray;


+ (id)sharedListofBusinesses {
    static ListofBusinesses *sharedListofBusinesses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedListofBusinesses = [[self alloc] init];
    });
    return sharedListofBusinesses;
}


- (id)init
{
   self = [super init];
    if (self)
    {
        myServer = [[ServerInteractionManager alloc] init];
        myServer.postProcessesDelegate = self;
    }
    return self;
}

- (void)startGettingListofAllBusinesses
{
    [myServer serverCallToGetListofAllBusinesses];
}


- (void)postProcessForListOfBusinessesSuccess:(NSDictionary *)responseData
{
    //    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
//    int status = [[responseData objectForKey:@"status"] intValue];
//        NSAssert(status == 0, @"We could not get list of our businesses");
    businessListArray = [responseData objectForKey:@"data"];
//    NSLog(@"The status is: %i and our list of businesses is: %@", status, businessListArray);
}


@end
