//
//  PayBillController.m
//  TapForAll
//
//  Created by Amir on 2/25/14.
//
//
//


#define STRIPE_TEST_POST_URL


#import "BillPayViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "TapTalkLooks.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "Consts.h"
#import "Business.h"
#import <Stripe/Stripe.h>


@interface BillPayViewController () {

    NSNumberFormatter *currencyFormatter;
}

@end


@implementation BillPayViewController

@synthesize payButton;
@synthesize changeCardButton;
@synthesize amountTextField;
@synthesize stripeCard;
@synthesize business;
@synthesize totalBillInDollars;
@synthesize paymentView;

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

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                 /*
                                                  We'll implement this below in "Sending the token to your server".
                                                  Notice that we're passing the completion block through.
                                                  See the above comment in didAuthorizePayment to learn why.
                                                  */
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   completion(PKPaymentAuthorizationStatusSuccess);
                               }
                           }];
}


//- (IBAction)save:(id)sender {
//    STPCardParams *card = [[STPCardParams alloc] init];
//    card.number = self.paymentView.card.number;
//    card.expMonth = self.paymentView.card.expMonth;
//    card.expYear = self.paymentView.card.expYear;
//    card.cvc = self.paymentView.card.cvc;
//    [[STPAPIClient sharedClient] createTokenWithCard:card
//                                          completion:^(STPToken *token, NSError *error) {
//                                              if (error) {
//                                                  [self handleError:error];
//                                              } else {
//                                                  [self createBackendChargeWithToken:token];
//                                              }
//                                          }];
//}


// end

- (void)greyoutView:(UIButton *)button {
    button.enabled = FALSE;
    [button setBackgroundColor:[UIColor grayColor]];
}

- (void)enableView:(UIButton *)button {
    button.enabled = TRUE;
    [TapTalkLooks setToTapTalkLooks:button isActionButton:YES makeItRound:TRUE];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    CGFloat padding = 30;
//    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
//    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
//    float xPosition = (screenWidth - width)/2;
//    self.paymentView.frame = CGRectMake(xPosition, padding*3, width, padding);
    
//    self.activityIndicator.center = self.view.center;
    [self addStripView];
}

- (void)addStripView {
//    self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(15,70,290,105)
//                                              andKey:STRIPE_TEST_PUBLIC_KEY];
//    self.paymentView = [[STPCard alloc] initWithFrame:CGRectMake(15,70,290,105)];
//    
//    self.paymentView = [[STPPaymentCardTextField alloc] init];
//
//    self.paymentView.delegate = self;
//    [self.view addSubview:self.paymentView];
//    self.paymentView = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)];
//    self.paymentView.delegate = self;
//    [self.view addSubview:self.paymentView];
//
//    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
//    paymentTextField.delegate = self;
    
   paymentView = [[STPPaymentCardTextField alloc] init];
    paymentView.delegate = self;
    
 //   self.paymentView = paymentTextField;
    CGFloat padding = 30;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float xPosition = (screenWidth - width)/2;
    self.paymentView.frame = CGRectMake(xPosition, padding*3, width, padding);
    [self.view addSubview:self.paymentView];
    [TapTalkLooks setToTapTalkLooks:paymentView isActionButton:NO makeItRound:YES];
//    paymentTextField = nil;
}


//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
//    [textField reloadInputViews];
//    return YES;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    // Setup payment view
//    //STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)];
//    
//    paymentTextField.delegate = self;
//    self.paymentView = paymentTextField;
//    [self.view addSubview:paymentView];
//    [TapTalkLooks setToTapTalkLooks:paymentView isActionButton:NO makeItRound:YES];
    
//    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
//    paymentTextField.delegate = self;
//    self.paymentView = paymentTextField;
    [self addStripView];
    
    self.title = [NSString stringWithFormat:@"Pay %@", business.businessName];
    // Do any additional setup after loading the view from its nib.
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:payButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:changeCardButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:amountTextField isActionButton:NO makeItRound:YES];
    [self greyoutView:payButton];
    
    amountTextField.text = [currencyFormatter stringFromNumber:totalBillInDollars];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)payAction:(id)sender {
    [self greyoutView:payButton];
    [self greyoutView:changeCardButton];
//
    NSString *message = [NSString stringWithFormat:@"Paying %@ to %@", amountTextField.text, business.businessName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert setTag:1]; // to identify this alert in the delegate method
    [alert show];
    alert = nil;
    self.stripeCard = [[STPCard alloc] init];
//    self.stripeCard.name = self.nameTextField.text;
//    self.stripeCard.number = self.cardNumber.text;
//    self.stripeCard.cvc = self.CVCNumber.text;
//    self.stripeCard.expMonth = self.paymentView.card.expMonth;
//    self.stripeCard.expYear = [self.selectedYear integerValue];
//    
//    //2
//    if ([self validateCustomerInfo]) {
//        [self performStripeOperation];
//    }
}


- (void)prepareToGetStripeToken
{
//    [self.paymentView createToken:^(STPToken *token, NSError *error) {
//        if (error) {
//            // Handle error
//            [self handleStripeError:error];
//        } else {
//            // Send off token to your server
//            [self postStripeToken:token];
//        }
//    }];
    if (![self.paymentView isValid]) {
        return;
    }
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    
    [Stripe createTokenWithCard:card publishableKey:@"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi" completion:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [self handleStripeError:error];
        } else {
            // Send off token to your server
            [self postStripeToken:token];
        }
    }];
}


//- (void)save:(id)sender {
//    if (![self.paymentTextField isValid]) {
//        return;
//    }
//    if (![Stripe defaultPublishableKey]) {
//        NSError *error = [NSError errorWithDomain:StripeDomain
//                                             code:STPInvalidRequestError
//                                         userInfo:@{
//                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
//                                                    }];
//        [self.delegate paymentViewController:self didFinish:error];
//        return;
//    }
////    [self.activityIndicator startAnimating];
//    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.card
//                                          completion:^(STPToken *token, NSError *error) {
//                                              [self.activityIndicator stopAnimating];
//                                              if (error) {
//                                                  [self.delegate paymentViewController:self didFinish:error];
//                                              }
//                                              [self.backendCharger createBackendChargeWithToken:token
//                                                                                     completion:^(STPBackendChargeResult result, NSError *error) {
//                                                                                         if (error) {
//                                                                                             [self.delegate paymentViewController:self didFinish:error];
//                                                                                             return;
//                                                                                         }
//                                                                                         [self.delegate paymentViewController:self didFinish:nil];
//                                                                                     }];
//                                          }];
//}



- (void)handleStripeError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
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
//                                       [UIAlertView showErrorAlert:@"Something went BAD - Clean the place or first born?"];
                                       
//                                       
//                                       UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//                                                                                                      message:@"Something went BAD - Clean the place or first born?"
//                                                                                               preferredStyle:UIAlertControllerStyleAlert];
//                                       
//                                       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                             handler:^(UIAlertAction * action) {}];
//                                       
//                                       [alert addAction:defaultAction];

                                       
                            [UIAlertController showErrorAlert:@"Something went BAD - Clean the place or first born?"];
                                       
                                       
                                       
                                       [self enableView:payButton];
                                       [self enableView:changeCardButton];
                                   }
                                   else {
//                                       [UIAlertView showErrorAlert:@"Paid - Now you're free to move about the country"];
                                       
//                                       UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//                                                                                                      message:@"Paid - Now you're free to move about the country."
//                                                                                               preferredStyle:UIAlertControllerStyleAlert];
//                                       
//                                       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                             handler:^(UIAlertAction * action) {}];
//                                       
//                                       [alert addAction:defaultAction];
//
                                       
                                       [UIAlertController showErrorAlert:@"Paid - Now you're free to move about the country"];
                                       
                                       [self greyoutView:payButton];
                                       [self greyoutView:changeCardButton];
                                       
                                       paymentView.enabled = FALSE;
                                       [paymentView setBackgroundColor:[UIColor grayColor]];

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
            [self prepareToGetStripeToken];
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
            [self addStripView];
            [self greyoutView:payButton];
            [self.view setNeedsDisplay];
        }
        else {
        }
    }
}

//- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
//{
//    if (valid) {
//        [self enableView:payButton];
//    } else {
//        [UIAlertView showErrorAlert:@"Error from server - please try again"];
//    }
//}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    if (textField.isValid) {
//        STPCard *card = [[STPCard alloc] init];
//        card.number = textField.cardNumber;
//        card.expMonth = textField.expirationMonth;
//        card.expYear = textField.expirationYear;
//        card.cvc = textField.cvc;
//        [self doSomethingWithCard:card];
        [self enableView:payButton];
        
        
    }
}

@end

