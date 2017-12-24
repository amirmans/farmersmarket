//
//  ConsumerProfile.m
//  TapForAll
//
//  Created by Amir on 4/2/14.
//
//

#import "UtilityConsumerProfile.h"
#import "CurrentBusiness.h"

@implementation UtilityConsumerProfile

+ (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
 
    return [emailTest evaluateWithObject:emailStr];
}

+ (BOOL)canUserChat {
    NSInteger validateStatus = [CurrentBusiness sharedCurrentBusinessManager].business.validate_chat;
    
    if (validateStatus == ChatValidationWorkflow_NoNeedToValidate) {
        return TRUE;
    }
    else if (validateStatus == ChatValidationWorkflow_Validated) {
        return TRUE;
    }
    else if (validateStatus == ChatValidationWorkflow_Not_Valid) {
        return FALSE;
    }
    else if (validateStatus == ChatValidationWorkflow_ErrorFromServer) {
        return FALSE;
    }
    else {
        return FALSE;
    }
}


@end
