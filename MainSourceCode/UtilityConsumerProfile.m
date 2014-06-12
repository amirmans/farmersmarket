//
//  ConsumerProfile.m
//  TapForAll
//
//  Created by Amir on 4/2/14.
//
//

#import "UtilityConsumerProfile.h"

@implementation UtilityConsumerProfile

+ (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
 
    return [emailTest evaluateWithObject:emailStr];
}


@end
