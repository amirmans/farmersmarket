//
//  ConsumerCCModelObject.h
//  TapForAll
//
//  Created by Harry on 6/9/16.
//
//

#import <Foundation/Foundation.h>

@interface ConsumerCCModelObject : NSObject

@property (strong, nonatomic) NSString *consumer_cc_info_id;
@property (strong, nonatomic) NSString *consumer_id;
@property (strong, nonatomic) NSString *name_on_card;
@property (strong, nonatomic) NSString *cc_no;
@property (strong, nonatomic) NSString *expiration_date;
@property (strong, nonatomic) NSString *cvv;
@property (strong, nonatomic) NSString *zip_code;
@property (strong, nonatomic) NSNumber *verified;
@property (strong, nonatomic) NSNumber *is_default;

@end
