//
//  DetailedInfoViewController.h
//  ScratchTabNav
//
//  Created by Amir on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"


@interface ServicesForBusinessViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSDictionary *allChoices;
    NSArray *mainChoices;
    NSString *chosenMainMenu;
    Business *biz;
    NSArray *sections; //sorted list of BusinessProducts 
}

@property(atomic, retain) Business *biz;
@property(atomic, retain) NSArray *sections;

- (id)initWithData:(NSDictionary *)allChoices :(NSArray *)mainChoices :(NSString *)chosenMainMenu;

- (id)initWithData:(Business *)bizArg;

@end
