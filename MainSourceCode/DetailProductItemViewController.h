//
//  DetailProductItemViewController.h
//  TapTalk
//
//  Created by Amir on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface DetailProductItemViewController : UIViewController {
    NSDictionary *productDictionary;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)argDataModel;


@property (weak, nonatomic) IBOutlet UITextField *saleEndDate;

@property (weak, nonatomic) IBOutlet UITextField *reducedPriceTextField;
@property (nonatomic, retain) NSDictionary *productDictionary;
@property (strong, nonatomic) IBOutlet JBKenBurnsView *picturesView;

@property (weak, nonatomic) IBOutlet UITextView *longDescription;
@property (weak, nonatomic) IBOutlet UITextField *rewardsTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardsNeededToBuyTextField;
@property (weak, nonatomic) IBOutlet UITextField *ratingTextField;
@property (weak, nonatomic) IBOutlet UILabel *reducedPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *runtimeField1Label;
@property (strong, nonatomic) IBOutlet UITextField *runtimeField1TextField;
@property (weak, nonatomic) IBOutlet UIButton *configurableActionButton;

- (IBAction)configurableAction:(id)sender;




@end
