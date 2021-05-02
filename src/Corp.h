//
//  Corp.h
//  ManageMyMarket
//
//  Created by Amir on 5/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Corp : NSObject {
    NSMutableDictionary *chosenCorp;
}

@property (strong, atomic) NSMutableDictionary *chosenCorp;
+ (Corp *)sharedCorp;

@end




NS_ASSUME_NONNULL_END
