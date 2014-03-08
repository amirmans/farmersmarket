//
//  Choices.h
//  TapTalk
//
//  Created by Amir on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessCustomerProfileManager : NSObject {
    NSString *customerProfileName;
    NSDictionary *allChoices;
    NSArray *mainChoices;
//    NSDictionary *productItems;
    BOOL loadInfo;
}


+ (BusinessCustomerProfileManager *)sharedBusinessCustomerProfileManager;

@property(nonatomic, retain) NSString *customerProfileName;
@property(nonatomic, retain) NSDictionary *allChoices;
@property(nonatomic, retain) NSArray *mainChoices;
//@property(nonatomic, retain) NSDictionary *productItems;

@property(atomic, assign) BOOL loadInfo;


@end
