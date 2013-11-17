//
//  BusinessProductsUtils.m
//  TapTalk
//
//  Created by Amir on 8/25/12.
//
//

#import "BusinessProductsUtils.h"

@implementation BusinessProductsUtils

@synthesize name, location, shortDescription, longDescription, package;
@synthesize price, rating;


- (id)initWithProduct:(NSDictionary *)argProduct {
    
    return self;
}

@end
