//
//  TPBusinessDetail.h
//  TapForAll
//
//  Created by Harry on 2/15/16.
//
//

#import <Foundation/Foundation.h>

@interface TPBusinessDetail : NSObject


@property(nonatomic, retain) NSString *product_id;
@property(nonatomic, retain) NSString *customer_product_id;
@property(nonatomic, retain) NSString *businessID;
@property(nonatomic, retain) NSString *SKU;
@property(nonatomic, retain) NSString *product_category_id;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *pictures;
@property(nonatomic, retain) NSString *short_description;
@property(nonatomic, retain) NSString *long_description;
@property(nonatomic, retain) NSString *more_information;
@property(nonatomic, retain) NSString *runtime_fields;
@property(nonatomic, retain) NSString *runtime_fields_detail;
@property(nonatomic, retain) NSString *price;
@property(nonatomic, retain) NSString *sales_price;
@property(nonatomic, retain) NSString *sales_start_date;
@property(nonatomic, retain) NSString *sales_end_date;
@property(nonatomic, retain) NSString *availability_status;
@property(nonatomic, retain) NSString *has_option;
@property(nonatomic, retain) NSString *detail_information;
@property(nonatomic, retain) NSString *bought_with_rewards;
@property(nonatomic, retain) NSString *category_name;
@property(nonatomic,strong) NSMutableArray *optionArray;
@property(nonatomic,retain) NSString *totalcount;
@property(nonatomic, assign) double ti_rating;
@property(nonatomic, strong) NSMutableArray *arrOptions;
@property(nonatomic, assign) NSInteger quantity;

@end
