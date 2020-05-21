//
//  Corp.m
//  ManageMyMarket
//
//  Created by Amir on 5/4/20.
//

#import "Corp.h"

@implementation Corp

@synthesize chosenCorp;

+ (Corp *)sharedCorp {
    static Corp *sharedCorp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCorp = [[self alloc] init];
    });
    return sharedCorp;
}

@end
