//
//  CurrentBusiness.h
//  TapForAll
//
//  Created by Amir on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "Business.h"

@interface CurrentBusiness : NSObject

+ (CurrentBusiness *)sharedCurrentBusinessManager;
@property (nonatomic, strong) Business *business;


@end
