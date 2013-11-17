//
//  DetailedInfoViewController.h
//  ScratchTabNav
//
//  Created by Amir on 7/24/11.
//  Copyright 2011 Mydoost.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailedInfoViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSDictionary *allChoices;
    NSArray *mainChoices;
    NSString *chosenMainMenu;

}

- (id)initWithData:(NSDictionary *)allChoices :(NSArray *)mainChoices :(NSString *)chosenMainMenu;

@end