//
//  EventTableViewCell.h
//  TapForAll
//
//  Created by Amir on 12/12/13.
//
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblEventTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDateTime;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscription;
@property (strong, nonatomic) IBOutlet UIImageView *imgEventImage;
@property (strong, nonatomic) IBOutlet UIButton *btnLocation;
@property (strong, nonatomic) IBOutlet UIButton *btnAddToCalendar;

@property (strong, nonatomic) IBOutlet UIButton *btnEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblBudget;


@end
