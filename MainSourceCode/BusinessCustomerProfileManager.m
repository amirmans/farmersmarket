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

@synthesize businessName;
@synthesize loadInfo; //If true, business has been changed so load customer profile information again
@synthesize mainChoices, allChoices, productItems;

static BusinessCustomerProfileManager *sharedChoicesManager = nil;


+ (BusinessCustomerProfileManager *) sharedBusinessCustomerProfileManager
{
    if (sharedChoicesManager == nil)
    {
        sharedChoicesManager = [[super allocWithZone:NULL] init];
    }
    
    return sharedChoicesManager;
}



+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedBusinessCustomerProfileManager];
}



- (id)init
{
    @synchronized ([BusinessCustomerProfileManager class]) 
    {
        if (self == Nil)
        {
            self = [super init];
            if (self) {
                // Custom initialization
                self.businessName = nil;
                loadInfo = YES;
            }
        }

        return self;
    }    
}    

- (void)setBusinessName:(NSString *)bName
{   
    if (businessName != bName)
    {
        [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
        businessName = bName;
        self.loadInfo = YES;
    }
}


- (NSDictionary *)allChoices
{
    if ( (allChoices == nil) || (YES == self.loadInfo) )
    {
        NSBundle *bundle = [NSBundle mainBundle];
        
        if (self.businessName == nil)
        {    
            NSLog(@"Customer category is not set");
            return nil;
        }
        
        NSString *path = [bundle pathForResource: @"Businesses Property List" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *tempAllChoices = [dictionary objectForKey:self.businessName];
        allChoices = [tempAllChoices objectForKey:@"main choices"];
        NSLog(@"Here are our main choices: %@", allChoices);
        self.loadInfo = NO;
    }    
    
    return allChoices;
}


- (NSArray *) mainChoices
{
    if ( (mainChoices == nil) || (YES == self.loadInfo) )
    {        
        mainChoices = [self.allChoices allKeys];
        NSLog(@"Here are our sections: %@", mainChoices); 
    }    
    
    return mainChoices;
}


- (NSDictionary *)productItems
{
    if ( (productItems == nil) || (YES == self.loadInfo) )
    {
        NSBundle *bundle = [NSBundle mainBundle];
        
        if (self.businessName == nil)
        {    
            NSLog(@"Customer category is not set");
            return nil;
        }
        
        NSString *path = [bundle pathForResource: @"Businesses Property List" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *customerProfile = [dictionary objectForKey:self.businessName];
        productItems = [customerProfile valueForKey:@"store items"];
        NSLog(@"in BusinessCustomerProfile, here are our productItems: %@", productItems);
        self.loadInfo = NO;
    }    
    
    return productItems;
}

@end
