//
//  TADateUtility.m
//  ManageMyMarket
//
//  Created by Amir on 5/2/20.
//

#import <Foundation/Foundation.h>
#import "TADateUtility.h"


static TADateUtility *sharedObj;

@implementation TADateUtility

static id sharedInstance;
@synthesize  displayFormatter, formatter;

+ (TADateUtility *) sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (TADateUtility *)init {
    if (sharedInstance) {
        return sharedInstance;
    }
    @synchronized(self) {
        self = [super init];
        if (self) {
            sharedInstance = self;
            
            sharedObj = [[TADateUtility alloc] init];
            
           if (formatter == nil) {
               formatter = [[NSDateFormatter alloc]init];
               [formatter setDateFormat:@"HH:mm:ss"];
               [formatter setTimeZone:[NSTimeZone localTimeZone]];

           }
           if (displayFormatter == nil) {
               displayFormatter = [[NSDateFormatter alloc]init];
               [displayFormatter setDateFormat:@"hh:mm a"];
               [displayFormatter setTimeZone:[NSTimeZone localTimeZone]];
           }

            
        }
        return self;
    }
}

- (NSString *)displayDateFromString:(NSString *)dateStr {
    
    NSDate *displayDate = [formatter dateFromString:dateStr];
    NSString *displayDateStr = [displayFormatter stringFromDate:displayDate];
    
    return displayDateStr;
}

- (NSString *)displayDateFromDate:(NSDate *)date {
    
    NSString *displayDateStr = [displayFormatter stringFromDate:date];
    
    return displayDateStr;
}

- (NSInteger)nextOpeningDayIndex:(NSString *)weekDaysStr inCompareto:(long)todaysIndex {
    NSInteger nextBusinessDayIndex = 0;
    NSArray *arr = [weekDaysStr componentsSeparatedByString:@","];
    if (arr.count < 2) {
        nextBusinessDayIndex = [arr[0] integerValue];
        
        return nextBusinessDayIndex;
    }
        
    [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([obj1 intValue] == [obj2 intValue])
            return NSOrderedSame;
        
        else if ([obj1 intValue] < [obj2 intValue])
            return NSOrderedAscending;
        
        else
            return NSOrderedDescending;
        
    }];
    
    NSLog(@"The sorted weekday str is %@", arr);
    
    if (todaysIndex >= [arr[(arr.count -1)] integerValue]) {
        nextBusinessDayIndex = [arr[0] integerValue];
        
        return nextBusinessDayIndex;
    }
    
    for (int i = 0; i < arr.count; i++) {
        if (todaysIndex < [arr[i] integerValue]) {
            nextBusinessDayIndex = [arr[i] integerValue];
            break;
        }
    }
    
    return(nextBusinessDayIndex);
}

- (NSString *)stringFromWeekday:(NSInteger)weekday {
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return dateFormatter.shortWeekdaySymbols[weekday];
}


- (NSString *)isDayandTimeValidForCorp:(NSDictionary *)corpDictionary {
    NSString *returnMessage = @"";

    // make sure we have not passed the cutoff time and user can still order for lunch
    NSString *nowString = [formatter stringFromDate:[NSDate date]];
    NSDate* dayInhms = [formatter dateFromString:nowString];


    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    long weekday = [comps weekday];
    NSString *weekDayStr = [NSString stringWithFormat: @"%ld", weekday];
    NSString *businessWeekDaysStr = [corpDictionary objectForKey:@"delivery_week_days"];
    if ([businessWeekDaysStr rangeOfString:weekDayStr].location == NSNotFound) {
        NSInteger nextDeliveryDayIndex = [self nextOpeningDayIndex:businessWeekDaysStr inCompareto:weekday];
        NSString *nextDeliveryDayStr =  [self stringFromWeekday:nextDeliveryDayIndex];
        returnMessage = [NSString stringWithFormat:@"There is no delivery today!\nThe next delivery day is: %@.\nYou may view the menus without ordering.", nextDeliveryDayStr];
    } else {
        NSString *cutoffStr = [corpDictionary objectForKey:@"cutoff_time"];
        NSDate *cutoff  = [formatter dateFromString:cutoffStr];
        
   
        NSDate *cuttoffDisplayDate = [formatter dateFromString:cutoffStr];
        NSString *cutoffDisplayDateStr = [self displayDateFromDate:cuttoffDisplayDate];
        
        if ([cutoff compare:dayInhms] == NSOrderedAscending) {
            returnMessage = [NSString stringWithFormat:@"For today's delivery cut-off time (%@) is past!\nHowever, you may view the menus without ordering.",cutoffDisplayDateStr ];
        } else
        {
            returnMessage = [NSString stringWithFormat:@"Based on your work email, corp delivery service is open until %@.", cutoffDisplayDateStr];
        }
    }
    return returnMessage;
}



@end
