//
//  TADateUtility.h
//  ManageMyMarket
//
//  Created by Amir on 5/2/20.
//

#ifndef TADateUtility_h
#define TADateUtility_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TADateUtility : NSObject {
    NSDateFormatter* displayFormatter;
    NSDateFormatter *formatter;
}

+ (TADateUtility *) sharedInstance;

@property(nonatomic, strong) NSDateFormatter *displayFormatter;
@property(nonatomic, strong) NSDateFormatter *formatter;


- (NSString *)displayDateFromString:(NSString *)dateStr;
- (NSString *)displayDateFromDate:(NSDate *)date;
- (NSInteger)nextOpeningDayIndex:(NSString *)weekDaysStr inCompareto:(long)todaysIndex;
- (NSString *)stringFromWeekday:(NSInteger)weekday;

- (NSString *)isDayandTimeValidForCorp:(NSDictionary *)corpDictionary;

@end




#endif /* TADateUtility_h */
