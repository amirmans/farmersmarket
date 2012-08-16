//
//  FirstTabViewController.h
//  ScratchTabNav
//
//  Created by Amir on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface EnterBusinessViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSDictionary *allChoices;
    NSArray *mainChoices;
}

- (id) initWithData: (NSDictionary *) subAndMainChoices :(NSArray *) onlyMainChoices;


@end
