//
//  ServicesForBusinessTableViewController.h
//  ScratchTabNav
//
//  Created by Amir on 7/24/11.
//  Copyright 2011 Mydoost.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"


@interface ServicesForBusinessTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSDictionary *allChoices;
    NSArray *mainChoices;
    NSString *chosenMainMenu;
    Business *biz;

}

@property(atomic, retain) Business *biz;

- (id)initWithData:(NSDictionary *)allChoices :(NSArray *)mainChoices :(NSString *)chosenMainMenu forBusiness:(Business *)argBiz;

@end