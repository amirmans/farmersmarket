//
//  ConsumerProfileDataModel.m
//  TapForAll
//
//  Created by Amir on 5/6/14.
//
//

#import "ConsumerProfileDataModel.h"

@implementation ConsumerProfileDataModel

@synthesize consumerProfileDataArray;

- (id)init
{
    self = [super init];
    if (self)
    {
        consumerProfileDataArray = [[NSArray alloc] init];
        consumerProfileDataArray = @[@{@"lable title name": @"", @"system name": @"", @"value":@"", @"validation method": @"", },
                                     @{@"fieldX": @4, @"fieldY": @7}
                                     ];
    }
    return self;
}


@end
