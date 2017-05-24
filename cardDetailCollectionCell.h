//
//  cardDetailCollectionCell.h
//  TapForAll
//
//  Created by Trushal on 5/20/17.
//
//

#import <UIKit/UIKit.h>

@interface cardDetailCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblCardNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblCardHolderName;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgCard;

@end
