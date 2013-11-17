//
//  BusinessProductsUtils.h
//  TapTalk
//
//  Created by Amir on 8/25/12.
//
//

#import <Foundation/Foundation.h>

@interface BusinessProductsUtils : NSObject
{
    
}

- (id)initWithProduct:(NSDictionary *)argProduct;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *shortDescription;
@property (nonatomic, retain) NSString *longDescription;
@property (nonatomic, retain) NSString *package;
@property (nonatomic, assign) float price;
@property (nonatomic, assign) float rating;

@end
