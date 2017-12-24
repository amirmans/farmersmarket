//
//  MenuOptionItemModel.h
//  TapForAll
//
//  Created by Harry on 4/21/16.
//
//

#import <Foundation/Foundation.h>


@interface MenuOptionItemModel : NSObject

@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemOption_ID;
@property (strong, nonatomic) NSString *itemPrice;
@property (assign, nonatomic) NSInteger availability_status;
@property (assign, nonatomic) BOOL isSelected;

@end
