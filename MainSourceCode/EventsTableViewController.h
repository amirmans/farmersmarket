//
//  EventsTableViewController.h.h
//  TapForAll
//
//  Created by Amir on 1/3/16.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface EventsTableViewController : UITableViewController

@property(atomic, retain) Business *biz;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz;

@end
