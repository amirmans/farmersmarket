//
//  HistoryCell.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell {

    IBOutlet UILabel *date;
    IBOutlet UILabel *timeAtPlace;
    IBOutlet UILabel *myNote;

    IBOutlet UIImageView *imageView;
    IBOutlet UIView *viewForBackground;
}
    
@property (atomic, retain) IBOutlet UILabel *date;
@property (atomic, retain) IBOutlet UILabel *timeAtPlace;
@property (atomic, retain) IBOutlet UILabel *myNote;


@end
