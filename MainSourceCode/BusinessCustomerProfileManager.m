//
//  Choices.m
//  TapTalk
//
//  Created by Amir on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BusinessCustomerProfileManager.h"
#import "DataModel.h"

@implementation BusinessCustomerProfileManager

@synthesize customerProfileName;
@synthesize loadInfo; //If true, business has been changed so load customer profile information again
@synthesize mainChoices, allChoices/*, productItems*/;
@synthesize loadProducts;


static BusinessCustomerProfileManager *sharedChoicesManager = nil;

+ (BusinessCustomerProfileManager *)sharedBusinessCustomerProfileManager {
    if (sharedChoicesManager == nil) {
        sharedChoicesManager = [[super allocWithZone:NULL] init];
    }

    return sharedChoicesManager;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedBusinessCustomerProfileManager];
}


- (id)init {
    @synchronized ([BusinessCustomerProfileManager class]) {
        if (self == Nil) {
            self = [super init];
            if (self) {
                // Custom initialization
                self.customerProfileName = nil;
                loadInfo = YES;
            }
        }

        return self;
    }
}

//- (void)setBusinessName:(NSString *)custName {
//    if (customerProfileName != custName) {
//        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
//        customerProfileName = custName;
//        self.loadInfo = YES;
//    }
//}

-(void)setCustomerProfileName:(NSString *)custName {
    if (customerProfileName != custName) {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        customerProfileName = custName;
        self.loadInfo = YES;
    }
}

- (NSDictionary *)allChoices {
    if ((allChoices == nil) || (YES == self.loadInfo)) {
        NSBundle *bundle = [NSBundle mainBundle];

        if (self.customerProfileName == nil) {
            NSLog(@"Customer category is not set");
            return nil;
        }

        NSString *path = [bundle pathForResource:@"Businesses Property List" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];

        NSDictionary *tempAllChoices = [dictionary objectForKey:self.customerProfileName];
        NSNumber *tempNumberProductOffered = [tempAllChoices objectForKey:@"product_offered"];
        if (tempNumberProductOffered != nil)
            loadProducts = [tempNumberProductOffered boolValue];
        else
            loadProducts = 1; // default value, load products and later display to the consumers

        allChoices = [tempAllChoices objectForKey:@"main choices"];
        NSLog(@"%@",allChoices.debugDescription);
        
//        NSLog(@"Here are our main choices: %@", allChoices);
        self.loadInfo = NO;
    }

    return allChoices;
}




- (NSArray *)mainChoices {
    if ((mainChoices == nil) || (YES == self.loadInfo)) {
        mainChoices = [self.allChoices allKeys];
//        NSLog(@"Here are our sections: %@", mainChoices);
    }

    return mainChoices;
}


//- (NSDictionary *)productItems {
//    if ((productItems == nil) || (YES == self.loadInfo)) {
//        NSBundle *bundle = [NSBundle mainBundle];
//
//        if (self.customerProfileName == nil) {
//            NSLog(@"Customer category is not set");
//            return nil;
//        }
//
//        NSString *path = [bundle pathForResource:@"Businesses Property List" ofType:@"plist"];
//        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
//        NSDictionary *customerProfile = [dictionary objectForKey:self.customerProfileName];
//        productItems = [customerProfile valueForKey:@"store items"];
////        NSLog(@"in BusinessCustomerProfile, here are our productItems: %@", productItems);
//        self.loadInfo = NO;
//    }
//
//    return productItems;
//}

@end
