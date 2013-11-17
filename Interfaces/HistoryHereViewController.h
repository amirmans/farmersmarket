//
//  HistoryHereTableViewController.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HistoryInSimilarPlaces;

@interface HistoryHereViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>
{
    UITableView *tableViewOfHistory;
    UIToolbar *toolbar;
    UINavigationController *toolbarNav;
    HistoryInSimilarPlaces * m_historyInSimilarPlaceViewController;
}

@property (atomic, retain) IBOutlet UITableView *tableViewOfHistory; 
@property (atomic, retain) NSDictionary *historyData;
@property (atomic, retain) IBOutlet UIImageView *foodRating;
@property (atomic, retain) IBOutlet UIImageView *servicRating;
@property (nonatomic, retain)HistoryInSimilarPlaces * m_historyInSimilarPlaceViewController; 
//@property (atomic, retain) IBOutlet UIToolbar *toolbar; 
@property (nonatomic, retain) IBOutlet UINavigationController *toolbarNav;
- (IBAction)showHistoryInSimilarPlaces:(id)sender;

//- (id)initWithStyle:(UITableViewStyle)style;

@end
