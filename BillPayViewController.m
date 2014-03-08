//
//  PayBillController.m
//  TapForAll
//
//  Created by Amir on 2/25/14.
//
//

#import "BillPayViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "TapTalkLooks.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "Consts.h"
#import "Business.h"
#import "PKTextField.h"

@interface BillPayViewController () {

    NSNumberFormatter *currencyFormatter;
}

@end


@implementation BillPayViewController

@synthesize payButton;
@synthesize changeCardButton;
@synthesize amountTextField;
@synthesize paymentView;
@synthesize stripeCard;
@synthesize business;
@synthesize totalBillInDollars;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withAmount:(NSDecimalNumber *)amt forBusiness:(Business *)biz
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setMinimumFractionDigits:2];
        [currencyFormatter setMaximumFractionDigits:2];

        business = biz;
        totalBillInDollars = amt;
        
    }
    return self;
}


- (void)greyoutView:(UIButton *)button {
    button.enabled = FALSE;
    [button setBackgroundColor:[UIColor grayColor]];
}

- (void)enableView:(UIButton *)button {
    button.enabled = TRUE;
    [TapTalkLooks setToTapTalkLooks:button isActionButton:YES makeItRound:TRUE];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Pay %@", business.businessName];
    // Do any additional setup after loading the view from its nib.
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:payButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:changeCardButton isActionButton:YES makeItRound:YES];
    [self greyoutView:payButton];
    
    self.paymentView = [[PKView alloc] initWithFrame:CGRectMake(15, 75, 290, 105)];
    PKCardNumber* cardNumber = [PKCardNumber cardNumberWithString:@"4242424242424242"];
    
    self.paymentView.cardNumberField.placeholder = cardNumber.string;
    paymentView.cardNumberField.text =cardNumber.string;
;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    
    amountTextField.text = [currencyFormatter stringFromNumber:totalBillInDollars];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//pkview delegate method
- (void) paymentView:(PKView*)paymentView withCard:(PKCard *)card isValid:(BOOL)valid
{
//    NSLog(@"Card number: %@", card.number);
//    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
//    NSLog(@"Card cvc: %@", card.cvc);
//    NSLog(@"Address zip: %@", card.addressZip);
    
    [self enableView:payButton];
}

- (IBAction)payAction:(id)sender {
    [self greyoutView:payButton];
    [self greyoutView:changeCardButton];
//    NSDecimalNumber *decAmount = [NSDecimalNumber decimalNumberWithString:amountTextField.text];
    NSString *message = [NSString stringWithFormat:@"Paying %@ to %@", amountTextField.text, business.businessName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert setTag:1]; // to identify this alert in the delegate method
    [alert show];
    alert = nil;
}

- (void)createStripCard
{
    self.stripeCard = [[STPCard alloc] init];
    self.stripeCard.number = paymentView.cardNumber.string;
    self.stripeCard.cvc = paymentView.cardCVC.string;
    self.stripeCard.expMonth = paymentView.cardExpiry.month;
    self.stripeCard.expYear = paymentView.cardExpiry.year;
    
    //Create our payment token from Stripe server
    [Stripe createTokenWithCard:self.stripeCard
                 publishableKey:STRIPE_TEST_PUBLIC_KEY
                     completion:^(STPToken* token, NSError* error) {
                         if(error)
                             [self handleStripeError:error];
                         else
//                             [self postStripeToken:token.tokenId];
                             [self postStripeToken:token];
                     }];
}

- (void)handleStripeError:(NSError *)error
{
    [self enableView:payButton];
    [self enableView:changeCardButton];
}

- (void)postStripeToken:(STPToken *)token
{
//    NSLog(@"In postStripeToken - So far so good - and the tokenId is: %@", token.tokenId);
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = NSLocalizedString(@"Accessing payment processig server", @"");
//    
//    NSString *urlString = TapForAllPaymentServer;
//    
//    AFHTTPRequestOperationManager *manager;
//    manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
//    
//    NSDictionary *params = @{@"stripeToken": token, @"amount":amountTextField.text, @"currency":@"usd"};
//    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         if ([self isViewLoaded]) {
//             [MBProgressHUD hideHUDForView:self.view animated:YES];
//             
//             //status code = 200 is html code for OK - so anything else means not OK
//             if (operation.response.statusCode != 200) {
//                 [UIAlertView showErrorAlert:NSLocalizedString(@"Error in accessing Payment processing server.  Please try again in a few min", nil)];
//             }
//             else {                 
//                 [UIAlertView showErrorAlert:@"Paid successfully"];
//             }
//         }
//     }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              NSLog(@"Error: %@", error);
//              if ([self isViewLoaded]) {
//                  [MBProgressHUD hideHUDForView:self.view animated:YES];
//                  [UIAlertView showErrorAlert:@"Error in accessing Payment processing server.  Please try again in a few min"];
//              }
//              
//          }];
//    
//------------
    NSLog(@"Payment - Received Stripe token %@", token.tokenId);
    // convert dollars to cents
    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *totalBillInCents= [totalBillInDollars decimalNumberByMultiplyingBy:cents];
    
    NSString *amountInCentsString= [totalBillInCents stringValue];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:TapForAllPaymentServer]];
        request.HTTPMethod = @"POST";
        NSString *body     = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&currency=usd&customerPaymentID=%@&customerPaymentProcessingEmail=%@", token.tokenId, amountInCentsString, business.paymentProcessingID, business.paymentProcessingEmail];
        request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       [UIAlertView showErrorAlert:@"Something went BAD - Clean the place or first born?"];
                                       [self enableView:payButton];
                                       [self enableView:changeCardButton];
                                   }
                                   else {
                                       [UIAlertView showErrorAlert:@"Paid - Now you're free to move about the country"];
                                       [self greyoutView:payButton];
                                       [self greyoutView:changeCardButton];

                                   }
                               }];
    }
    

- (IBAction)changeCardAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert setTag:0];
    [alert show];
    alert = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        // this is called for the payment option
        if (buttonIndex == 1) {
            [self createStripCard];
        }
        else
        {
            //Cancelled enable the buttons
            [self enableView:payButton];
            [self enableView:changeCardButton];
        }
    }
    else
    {
        // this is called for clearing the card information
        if (buttonIndex == 1) {
            // now we need to clear the card box.
            [paymentView removeFromSuperview];
            paymentView = nil;
            self.paymentView = [[PKView alloc] initWithFrame:CGRectMake(15, 75, 290, 105)];
            self.paymentView.delegate = self;
            [self.view addSubview:self.paymentView];
            payButton.enabled = FALSE;
            [self.view setNeedsDisplay];
        }
        else {
        }
    }
}

@end

