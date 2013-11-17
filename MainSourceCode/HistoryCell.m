//
//  HistoryCell.m
//  meowcialize
//
//  Created by Amir Amirmansoury on 9/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

@synthesize date;
@synthesize timeAtPlace;
@synthesize myNote;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
