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
#import "TPReceiptController.h"
#import "SavedCardTableCell.h"
#import "AppDelegate.h"
#import "STPCardValidator.h"

@interface BillPayViewController ()<UITextFieldDelegate> {
    NSNumberFormatter *currencyFormatter;
}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

NSMutableArray *cardDataArray;


@implementation BillPayViewController

@synthesize hud;
@synthesize payButton;
@synthesize changeCardButton;
@synthesize amountTextField;
@synthesize stripeCard;
@synthesize business;
@synthesize totalBillInDollars;
@synthesize paymentView;

#pragma mark - Life Cycle

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    paymentView.delegate = self;
    cardDataArray = [[NSMutableArray alloc] init];
    //    self.title = [NSString stringWithFormat:@"Pay %@", business.businessName];
    self.title = @"Add Card";
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.txtCardNumber.showsCardLogo = YES;
    self.txtCardHolderName.delegate = self;
    self.txtCardNumber.delegate = self;
    self.txtExpMonth.delegate = self;
    self.txtExpYear.delegate = self;
    self.txtCVV.delegate = self;
    
    //    [self getStripeDataArray];
    
    
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.cardsTable.delegate = self;
    self.cardsTable.dataSource = self;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.label.text = @"";
    hud.detailsLabel.text = @"";
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud.bezelView setBackgroundColor:[UIColor orangeColor]];
    hud.bezelView.color = [UIColor orangeColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:hud];
    
    self.cardsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.txtZipCode.delegate = self;
    
    [self greyoutView:payButton];
    
    amountTextField.text = [currencyFormatter stringFromNumber:totalBillInDollars];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self getCCForConsumer];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)greyoutView:(UIButton *)button {
    button.enabled = FALSE;
    [button setBackgroundColor:[UIColor grayColor]];
}

- (void)enableView:(UIButton *)button {
    button.enabled = TRUE;
    [button setBackgroundColor:[UIColor blackColor]];
    //    [TapTalkLooks setToTapTalkLooks:button isActionButton:YES makeItRound:TRUE];
}

- (void) removeAllOrderFromCoreData {
    
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *object in results)
    {
        [managedObjectContext deleteObject:object];
    }
    
    error = nil;
    [managedObjectContext save:&error];
}

- (void) getCCForConsumer {
    
    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    [[APIUtility sharedInstance] getAllCCInfo:userID completiedBlock:^(NSDictionary *response) {
        [cardDataArray removeAllObjects];
        if (response != nil) {
            if ([[response valueForKey:@"status"] integerValue] >= 0){
                if ([response valueForKey:@"data"] != nil) {
                    NSArray *data = [response valueForKey:@"data"];
                    
                    for (NSDictionary *dataDict in data) {
                        ConsumerCCModelObject *ccModel = [ConsumerCCModelObject new];
                        ccModel.consumer_cc_info_id = [dataDict valueForKey:@"consumer_cc_info_id"];
                        ccModel.consumer_id = [dataDict valueForKey:@"consumer_id"];
                        ccModel.name_on_card = [dataDict valueForKey:@"name_on_card"];
                        ccModel.cc_no = [dataDict valueForKey:@"cc_no"];
                        ccModel.expiration_date = [dataDict valueForKey:@"expiration_date"];
                        ccModel.cvv = [dataDict valueForKey:@"cvv"];
                        ccModel.verified = [dataDict valueForKey:@"verified"];
                        ccModel.is_default = [dataDict valueForKey:@"default"];
                        ccModel.zip_code = [dataDict valueForKey:@"zip_code"];
                        
                        [cardDataArray addObject:ccModel];
                    }
                }
            }
            else
            {
               // [self showAlert:@"Info" :@"Please save card information for as default card"];
            }
        }
        
        [self.cardsTable reloadData];
    }];
}

- (void) deleteCard : (NSDictionary *) cardDict  {
    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    NSString *card_no = [cardDict valueForKey:@"cc_no"];
    NSString *card_type = [self getTypeFromCardNumber:card_no];
    NSArray *dataArray = [NSArray arrayWithObjects:cardDict, nil];
    
    NSDictionary *param = @{@"cmd":@"remove_cc",@"consumer_id":userID,@"card_type":card_type,@"data":dataArray};
    
    
    [[APIUtility sharedInstance] remove_cc_info:param completiedBlock:^(NSDictionary *response) {
        [self getCCForConsumer]; // todelete
    }];
}

- (void) checkDefaultCard : (NSString *) cardNumber {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:StripeDefaultCard] != nil) {
        //        NSDictionary *cardDataDict = @{ @"number":cardNumber,@"cardName":cardName,@"expMonth":cardExpMonth,@"expYear":cardExpYear ,@"cvc":cardCvc };
        
        NSDictionary *defaultCardDict = [defaults objectForKey:StripeDefaultCard];
        NSString *defaultCardNumber = [defaultCardDict valueForKey:@"cc_no"];
        
        if ([defaultCardNumber isEqualToString:cardNumber]) {
            [defaults setObject:nil forKey:StripeDefaultCard];
            [defaults synchronize];
        }
    }
}
#pragma mark - Button Actions

- (IBAction) backBUttonClicked: (id) sender;
{
    [self.navigationController popViewControllerAnimated:true];
    //    [self.navigationController popToRootViewControllerAnimated:true];
    
}

- (IBAction)payAction:(id)sender {
    
    NSString *userId = [NSString stringWithFormat:@"%ld", [DataModel sharedDataModelManager].userID];
    if([userId isEqualToString:@"0"] || [DataModel sharedDataModelManager].uuid.length < 1)
    {
        [UIAlertController showErrorAlert:@"Please register on profile page.\nThen save your card information."];
    }
    else if ([DataModel sharedDataModelManager].emailAddress.length < 1) {
        UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"" message:@"we are taking you to profile page. please update your profile info \n then go to home for save card information" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.tabBarController.selectedIndex = 1;
        }];
        [alert2 addAction:okAction];
        [self presentViewController:alert2 animated:true completion:^{
        }];
    }
    else
    {
        
        NSString *zipCode = self.txtZipCode.text;
        if([self.txtCardNumber.text isEqualToString:@""] || [self.txtExpMonth.text isEqualToString:@""] || [self.txtExpYear.text isEqualToString:@""] || [self.txtCVV.text isEqualToString:@""] || [self.txtZipCode.text isEqualToString:@""]){
            [self showAlert:@"Error" :@"Please fill all fields."];
        }
        else if(self.txtCardNumber.cardNumberFormatter.cardPatternInfo == NULL){
            [self showAlert:@"Error" :@"Enter Valid Card Number."];
        }
        else if([self.txtExpMonth.text intValue] > 12){
            [self showAlert:@"Error" :@"Enter Valid Card Expiration Month."];
        }
        else if ([[APIUtility sharedInstance] isZipCodeValid:zipCode]) {
            [self greyoutView:payButton];
            [self greyoutView:changeCardButton];
            //
            //            if ([self.paymentView isValid]) {
            STPCardParams *card = [[STPCardParams alloc] init];
            
            //                card.number = self.paymentView.cardParams.number;
            //                card.expMonth = self.paymentView.cardParams.expMonth;
            //                card.expYear = self.paymentView.cardParams.expYear;
            //                card.cvc = self.paymentView.cardParams.cvc;
            
            card.number = self.txtCardNumber.text;
            card.expMonth = [self.txtExpMonth.text intValue];
            card.expYear = [self.txtExpYear.text intValue];
            card.cvc = self.txtCVV.text;
            [self saveAsDefaultCard:card];
        }
        else {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Stop!"
                                         message:@"Please enter valid Zipcode to continue your payment."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* OKButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self dismissViewControllerAnimated:true completion:nil];
                                       }];
            
            [alert addAction:OKButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (IBAction)changeCardAction:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - TableView DataSource / Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cardDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SavedCardTableCell";
    
    SavedCardTableCell *cell = (SavedCardTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SavedCardTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //    NSDictionary *cardDict = [cardDataArray objectAtIndex:indexPath.row];
    
    ConsumerCCModelObject *ccModel = [cardDataArray objectAtIndex:indexPath.row];
    
    NSString *cardNo = ccModel.cc_no;
    
    NSString *trimmedString=[cardNo substringFromIndex:MAX((int)[cardNo length]-4, 0)];
    
    NSString *cardDisplayNumber = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",trimmedString];
    
    //    NSString *cardName = ccModel.name_on_card;
    cell.lblCardType.text = [self getTypeFromCardNumber:cardNo];
    cell.lblCardNo.text = cardDisplayNumber;
    
    NSString *cardExpirationDateString = ccModel.expiration_date;
    
    NSDateFormatter *severDateFormatter = [[NSDateFormatter alloc] init];
    
    severDateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date =  [severDateFormatter dateFromString:cardExpirationDateString];
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    localDateFormatter.dateFormat = @"yyyy/MM";
    
    NSString *localDateString = [localDateFormatter stringFromDate:date];
    
    //    cell.lblMonthYear.text = [NSString stringWithFormat:@"%@/%@",[cardDict valueForKey:@"expMonth"],[cardDict valueForKey:@"expYear"]];
    cell.lblMonthYear.text = localDateString;
    
    cell.lblCVC.text = @"XXX";
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ConsumerCCModelObject *ccModel = [cardDataArray objectAtIndex:indexPath.row];
    
    //    NSDictionary *cardDict = [cardDataArray objectAtIndex:indexPath.row];
    NSString *cardNo = ccModel.cc_no;
    
    NSDateFormatter *severDateFormatter = [[NSDateFormatter alloc] init];
    NSString *cardExpirationDateString = ccModel.expiration_date;
    severDateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date =  [severDateFormatter dateFromString:cardExpirationDateString];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components
    
    [components month]; //gives you month
    [components day]; //gives you day
    [components year]; // gives you year
    
    NSString *expMonth = [NSString stringWithFormat:@"%ld",(long)[components month]];
    NSString *expYear = [NSString stringWithFormat:@"%ld",(long)[components year]];
    NSString *cardCvc = ccModel.cvv;
    //    NSString *cardName = [self getNameFromCardNumber:card.number];
    STPCardParams *card = [[STPCardParams alloc] init];
    
    card.number = cardNo;
    card.expMonth = [expMonth integerValue];
    card.expYear = [expYear integerValue];
    card.cvc = cardCvc;
    card.address.postalCode = ccModel.zip_code;
    
    [self saveAsDefaultCard:card];
    [self.navigationController popViewControllerAnimated:true];
    
    card = nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ConsumerCCModelObject *ccModel = [cardDataArray objectAtIndex:indexPath.row];
        NSString *cardNo = ccModel.cc_no;
        NSString *cardExpirationDateString = ccModel.expiration_date;
        NSString *zipCode = ccModel.zip_code;
        NSString *cvv = ccModel.cvv;
        
        NSDictionary *dataDict = @{@"cc_no":cardNo,@"expiration_date":cardExpirationDateString,@"zip_code":zipCode,@"cvv":cvv};
        
        [self checkDefaultCard:cardNo];
        [self deleteCard:dataDict];
        
        
        [cardDataArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - UITextfield Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.txtZipCode) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 5;
        
    }
    else{
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if(textField == self.txtCardNumber){
            return newLength <= 19;
        }
        else if(textField == self.txtExpMonth){
            return newLength <= 2;
        }
        else if(textField == self.txtExpYear){
            return newLength <= 2;
        }
        else if(textField == self.txtCVV){
            return newLength <= 4;
        }
    }
    return true;
}

#pragma mark - Show Alertbox
- (void)showAlert:(NSString *)Title :(NSString *)Message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:Title
                                 message:Message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self dismissViewControllerAnimated:true completion:nil];
                               }];
    
    [alert addAction:OKButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Stripe Payment Delegate


- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    if (textField.isValid) {
        if ([[APIUtility sharedInstance] isZipCodeValid:self.txtZipCode.text]) {
            [self enableView:payButton];
        }
        //        [self enableView:payButton];
    }
    else {
        [self greyoutView:payButton];
    }
}
- (NSString *) getTypeFromCardNumber : (NSString *) cardNumber  {
    STPCardBrand brand = [STPCardValidator brandForNumber:cardNumber];
    
    switch (brand) {
        case STPCardBrandVisa:
            NSLog(@"Visa");
            return @"Visa";
            break;
        case STPCardBrandAmex:
            NSLog(@"Amex");
            return @"Amex";
            //do something
            break;
        case STPCardBrandMasterCard:
            NSLog(@"Master Card");
            return @"Master Card";
            //do something
            break;
        case STPCardBrandDiscover:
            //do something
            NSLog(@"Discover");
            return @"Discover";
            break;
        case STPCardBrandJCB:
            //do something
            NSLog(@"JCB");
            return @"JCB";
            break;
        case STPCardBrandDinersClub:
            //do something
            NSLog(@"DinersClub");
            return @"Diners Club";
            break;
        case STPCardBrandUnknown:
            //do something
            NSLog(@"Unknown");
            return @"Unknown";
            break;
        default:
            return @"Unknown";
            break;
    }
}
- (void)handleStripeError:(NSError *)error
{
    [self showAlert:NSLocalizedString(@"Error", @"Error") :[error localizedDescription]];
    [self enableView:payButton];
    [self enableView:changeCardButton];
}
- (void) getStripeDataArray {
    [cardDataArray removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:stripeArrayKey] != nil) {
        [cardDataArray addObjectsFromArray:[defaults objectForKey:stripeArrayKey]];
        [self.cardsTable reloadData];
    }
}
- (void) showAlertForAddingCard : (STPCardParams *) card {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your credit card information is saved securely" message:@"You can use this card for your future transactions" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popViewControllerAnimated:true];
        
        //        [self saveCardToServer:card];
        
        
        //        [self createStripeTokenWithCard:card];
    }];
    //    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //          [self saveCardToServer:card];
    ////        [self saveAsDefaultCard:card];
    ////        [self createStripeTokenWithCard:card];
    //    }];
    //
    //    [alert addAction:noAction];
    [alert addAction:yesAction];
    
    [self presentViewController:alert animated:true completion:^{
        
    }];
}
- (void) checkForUniqeCard : (STPCardParams *) cardData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:stripeArrayKey] == nil) {
        [self showAlertForAddingCard:cardData];
    }
    else {
        NSString *cardNumber = cardData.number;
        
        NSMutableArray *stripeDataArray = [defaults objectForKey:stripeArrayKey];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number CONTAINS[cd] %@",cardNumber];
        
        NSArray *dataArray = [[stripeDataArray filteredArrayUsingPredicate:predicate] mutableCopy];
        
        NSLog(@"%ld",(unsigned long)[dataArray count]);
        if ([dataArray count] > 0) {
            [self saveAsDefaultCard:cardData];
            [self.navigationController popViewControllerAnimated:true];
            //            [self createStripeTokenWithCard:cardData];
        }
        else {
            [self showAlertForAddingCard:cardData];
        }
    }
}

- (BOOL)validateCustomerInfo {
    
    //2. Validate card number, CVC, expMonth, expYear
    [STPCardValidator validationStateForExpirationMonth:self.txtExpMonth.text];
    [STPCardValidator validationStateForExpirationYear:self.txtExpYear.text inMonth:self.txtExpMonth.text];
    NSString *txt_cc_type = [self getTypeFromCardNumber:self.txtCardNumber.text];
    if ([txt_cc_type isEqualToString:@"Visa"]) {
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandVisa];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandVisa];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"Master Card"]){
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandMasterCard];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandMasterCard];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"American Express"]){
        
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandAmex];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandAmex];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"Discover"]){
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandDiscover];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandDiscover];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"Diners Club"]){
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandDinersClub];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandDinersClub];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"JCB"]){
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandJCB];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandJCB];
        return YES;
    }
    else if ([txt_cc_type isEqualToString:@"Unknown"]){
        [STPCardValidator validationStateForCVC:_txtCVV.text cardBrand:STPCardBrandUnknown];
        [STPCardValidator validationStateForNumber:_txtCardNumber.text validatingCardBrand:STPCardBrandUnknown];
        return YES;
    }
    
    
    return NO;
}
- (void)performStripeOperation : (STPCardParams *) cardData {
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud.bezelView setBackgroundColor:[UIColor orangeColor]];
    hud.bezelView.color = [UIColor orangeColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [self.view addSubview:hud];
    [hud showAnimated:YES];
    
    [[STPAPIClient sharedClient] createTokenWithCard:cardData
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  //                                           [self handleError:error];
                                                  NSLog(@"ERRRRR = %@",error);
                                                  [self->hud hideAnimated:YES];
                                                  self->hud = nil;
                                                  
                                                  [self showAlert:@"Please try again" :[NSString stringWithFormat:@"%@",error.localizedDescription]];
                                              } else {
                                                  
                                                  //when credit card details is correct code here
                                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                  
                                                  NSString *cardNumber = [cardData.number stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                  NSString *cardExpMonth = [NSString stringWithFormat:@"%tu",cardData.expMonth];
                                                  NSString *cardExpYear = [NSString stringWithFormat:@"%tu",cardData.expYear];
                                                  
                                                  if ([cardExpMonth length] < 2)
                                                  {
                                                      cardExpMonth = [NSString stringWithFormat:@"0%@",cardExpMonth];
                                                  }
                                                  
                                                  NSString *expiration_date = [NSString stringWithFormat:@"%@-%@-01", cardExpYear, cardExpMonth];
                                                  NSString *zip_code = self.txtZipCode.text;
                                                  if ([zip_code length] == 0) {
                                                      zip_code = cardData.address.postalCode;
                                                  }
                                                  NSString *cardCvc = cardData.cvc;
                                                  NSString *cardType = [self getTypeFromCardNumber:cardData.number];
                                                  NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
                                                  
                                                  //    [defaults setObject:defaultsParam forKey:StripeDefaultCard];
                                                  NSDictionary *defaultsParam = @{@"consumer_id":userID,@"cc_no":cardNumber
                                                                                  ,@"expMonth":cardExpMonth,@"expYear":cardExpYear,@"cvv":cardCvc,@"zip_code":zip_code, @"card_type":cardType};
                                                  
                                                  
                                                  NSDictionary *severParam = @{@"cmd":@"save_cc_info",@"consumer_id":userID,@"cc_no":cardNumber
                                                                               ,@"expiration_date":expiration_date,@"cvv":cardCvc,@"zip_code":zip_code, @"card_type":cardType
                                                                               ,@"default":@"1"};
                                                  [[APIUtility sharedInstance]save_cc_info:severParam completiedBlock:^(NSDictionary *response) {
                                                      //        [self getCCForConsumer];
                                                      NSLog(@"%@",response);
                                                      [self->hud hideAnimated:YES];
                                                      self->hud = nil;
                                                      
                                                      if(![[response objectForKey:@"status"] boolValue])
                                                      {
                                                          NSLog(@"%@",[response objectForKey:@"message"]);
                                                          [defaults setObject:defaultsParam forKey:StripeDefaultCard];
                                                          //    [defaults registerDefaults:defaultsParam];
                                                          [defaults synchronize];
                                                          [self showAlertForAddingCard:cardData];
                                                          
                                                          NSLog(@"Saved this info for card default: %@", defaultsParam);
                                                          [self getCCForConsumer];                                                   }
                                                      else
                                                      {
                                                          
                                                          NSLog(@"%@",[response objectForKey:@"message"]);
                                                          UIAlertController * alert = [UIAlertController
                                                                                       alertControllerWithTitle:@"Error"
                                                                                       message:@"Something went wrong."
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                                                          
                                                          UIAlertAction* OKButton = [UIAlertAction
                                                                                     actionWithTitle:@"OK"
                                                                                     style:UIAlertActionStyleDefault
                                                                                     handler:^(UIAlertAction * action) {
                                                                                         [self dismissViewControllerAnimated:true completion:nil];
                                                                                     }];
                                                          
                                                          [alert addAction:OKButton];
                                                          
                                                          [self presentViewController:alert animated:YES completion:nil];
                                                          //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          //                                                            message:@"Something went wrong."
                                                          //                                                           delegate:nil
                                                          //                                                  cancelButtonTitle:@"OK"
                                                          //                                                  otherButtonTitles:nil];
                                                          //            [alert show];
                                                      }
                                                      
                                                  }];
                                                  
                                              }
                                          }];
}

- (void) saveAsDefaultCard : (STPCardParams *) cardData {
    
    STPCardParams *param = [[STPCardParams alloc]init];
    param.number = self.txtCardNumber.text;
    param.cvc = self.txtCVV.text;
    param.expMonth =[self.txtExpMonth.text integerValue];
    param.expYear = [self.txtExpYear.text integerValue];
    
    if ([self validateCustomerInfo]) {
        if([self.txtCardNumber.text isEqualToString:@""]){
            [self performStripeOperation:cardData];
        }
        else{
            [self performStripeOperation:param];
        }
    }else{
        
        [self showAlert:@"Error" :@"Card is not valid . Please enter valid card number"];
        
    }
}




- (IBAction)btnExpYearClicked:(id)sender {
}

- (IBAction)btnExpMonthClicked:(id)sender {
}
@end

