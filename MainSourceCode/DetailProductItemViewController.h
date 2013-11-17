//
//  DetailProductItemViewController.h
//  TapTalk
//
//  Created by Amir on 8/26/12.
//
//

#import <UIKit/UIKit.h>

@interface DetailProductItemViewController : UIViewController {
    NSDictionary *productDictionary;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)argDataModel;


@property (weak, nonatomic) IBOutlet UITextField *reducedPriceEndDate;

@property (weak, nonatomic) IBOutlet UITextField *reducedPriceTextField;
@property (nonatomic, retain) NSDictionary *productDictionary;
@property (weak, nonatomic) IBOutlet UIImageView *largePicture;
@property (weak, nonatomic) IBOutlet UITextView *longDescription;
@property (weak, nonatomic) IBOutlet UITextField *rewardsTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardsNeededToBuyTextField;
@property (weak, nonatomic) IBOutlet UITextField *ratingTextField;
@property (weak, nonatomic) IBOutlet UITextField *complementaryProductsText;
@property (weak, nonatomic) IBOutlet UIButton *recipesButton;
@property (weak, nonatomic) IBOutlet UIButton *otherBoughtButton;


- (IBAction)recipesAction:(id)sender;
- (IBAction)otherBoughtAction:(id)sender;


@end
