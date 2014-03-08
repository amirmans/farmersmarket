//
//  PayBillController.h
//  TapForAll
//
//  Created by Amir on 2/25/14.
//
//

#import <UIKit/UIKit.h>
#import "Stripe.h"
#import "PKView.h"

@class PKCard;

@class Business;

@interface BillPayViewController : UIViewController <PKViewDelegate, UIAlertViewDelegate> {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withAmount:(NSDecimalNumber *)amt forBusiness:(Business *)biz;


@property IBOutlet PKView* paymentView;
@property (strong, nonatomic) STPCard* stripeCard;

@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *changeCardButton;

- (IBAction)payAction:(id)sender;
- (IBAction)changeCardAction:(id)sender;

@property (nonatomic, weak) Business* business;
@property (nonatomic, weak) NSDecimalNumber* totalBillInDollars;



@end
