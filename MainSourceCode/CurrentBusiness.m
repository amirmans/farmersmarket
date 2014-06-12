//
//  CurrentBusiness.m
//  TapForAll
//
//  Created by Amir on 3/29/14.
//
//

#import "CurrentBusiness.h"

@implementation CurrentBusiness

static CurrentBusiness *sharedCurrentBusiness = nil;

@synthesize business;

+ (CurrentBusiness *)sharedCurrentBusinessManager
{
	@synchronized([CurrentBusiness class])
	{
		if (!sharedCurrentBusiness)
            return [[self alloc] init];
	}
    
	return sharedCurrentBusiness;
}

+ (id)alloc
{
	@synchronized([CurrentBusiness class])
	{
		NSAssert(sharedCurrentBusiness == nil,
                 @"Attempted to allocate a second instance of a sharedCurrentBusiness.");
		sharedCurrentBusiness = [super alloc];
		return sharedCurrentBusiness;
	}
    
	return nil;
}

- (id)init {
    if (self) {
    }
    
    return self;
}


@end
