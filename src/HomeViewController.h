//
//  HomeViewController.h
//  TapForAll
//
//  Created by Trushal on 4/9/17.
//
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
- (IBAction)btnNewOrderClicked:(id)sender;
- (IBAction)btnPickOrderClicked:(id)sender;
- (IBAction)ShowCorpsAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnPickupOrder;
@property (strong, nonatomic) IBOutlet UITextView *textViewMessageToConsumers;
@property (strong, nonatomic) IBOutlet UIButton *btnNewOrder;
@property (strong, nonatomic) IBOutlet UIButton *corpButton;
@property (strong, nonatomic) IBOutlet UIButton *individualButton;


@end
