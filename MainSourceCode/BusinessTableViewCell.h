//
//  BusinessTableViewCell.h
//  TapForAll
//
//  Created by Amir on 2/17/14.
//
//

#import <UIKit/UIKit.h>

@interface BusinessTableViewCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *businessTypesTextField;
@property (weak, nonatomic) IBOutlet UITextField *neighborhoodTextField;
@property (weak, nonatomic) IBOutlet UIImageView *businessIconImageView;

@end
