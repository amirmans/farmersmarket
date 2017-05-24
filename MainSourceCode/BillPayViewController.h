//
//  PayBillController.h
//  TapForAll
//
//  Created by Amir on 2/25/14.
//
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>
#import "APIUtility.h"
#import "ConsumerCCModelObject.h"
#import "MBProgressHUD.h"

@class Business;

@interface BillPayViewController : UIViewController <STPPaymentCardTextFieldDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate> {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withAmount:(NSDecimalNumber *)amt forBusiness:(Business *)biz;


//@property STPPaymentCardTextField* paymentView;
@property (strong, nonatomic) IBOutlet STPPaymentCardTextField *paymentView;

@property (strong, nonatomic) STPCard* stripeCard;

//@property (strong, nonatomic) STPPaymentCardTextField* paymentTextField;

@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (strong, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *changeCardButton;



- (IBAction)payAction:(id)sender;
- (IBAction)changeCardAction:(id)sender;

@property (nonatomic, weak) Business* business;
@property (nonatomic, strong) NSDecimalNumber* totalBillInDollars;

@property (strong, nonatomic) IBOutlet UITableView *cardsTable;

@property (strong, nonatomic) NSDictionary *orderInfoDict;

@property (weak, nonatomic) IBOutlet UITextField *txtCardHolderName;
@property (weak, nonatomic) IBOutlet UITextField *txtCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtExpMonth;
@property (weak, nonatomic) IBOutlet UITextField *txtExpYear;
@property (weak, nonatomic) IBOutlet UITextField *txtCVV;



//@property (nonatomic, weak) id<STPBackendCharging> backendCharger;


@end
