//
//  NotificationDetailModel.h
//  TapForAll
//
//  Created by Harry on 5/31/16.
//
//

#import <Foundation/Foundation.h>

@interface NotificationDetailModel : NSObject

@property (assign, nonatomic) NSInteger business_id;
@property (assign, nonatomic) NSInteger consumer_id;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) NSInteger notification_id;
@property (strong, nonatomic) NSString *time_read;
@property (strong, nonatomic) NSString *time_sent;
@property (assign, nonatomic) BOOL isRead;
@property (assign, nonatomic) BOOL isDelete;
@end
