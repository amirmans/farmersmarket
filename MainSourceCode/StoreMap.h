//
//  StoreMap.h
//  TapTalk
//
//  Created by Amir on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreMap : NSObject {
    UIImage *map;
}

- (UIImage *)getMapOfStore;

@property(weak, nonatomic) UIImage *map;


@end
