//
//  StoreMap.m
//  TapTalk
//
//  Created by Amir on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreMap.h"

@implementation StoreMap


@synthesize map = _map;

- (UIImage *)map {
    if (map == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"StoreMap" ofType:@"jpg"];
        map = [[UIImage alloc] initWithContentsOfFile:path];
    }
    return map;
}

- (UIImage *)getMapOfStore {
    return self.map;
}


- (id)init {
    self = [super init];
    return self;
}

@end
