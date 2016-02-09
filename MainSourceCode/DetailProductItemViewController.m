//
//  DetailProductItemViewController.m
//  TapTalk
//
//  Created by Amir on 8/26/12.
//
//

#import "DetailProductItemViewController.h"
#import "ProductMoreInformationViewController.h"
#import "AskForSeviceViewController.h"
#import "TapTalkLooks.h"
#import "Consts.h"
#import "CurrentBusiness.h"
#import "MBProgressHUD.h"
#import "BillPayViewController.h"

// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>

typedef NS_ENUM(NSUInteger, ConfigurableButtonType) {
    Hide = (1 << 0),
    MoreInformation = (1 << 1),
    ContactForInquiry = (1<<2)
};


@interface DetailProductItemViewController () {
    
}

@property (nonatomic, assign) ConfigurableButtonType actionType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)displayReducedPrice;
- (void)displayEndOfSaleDate;
- (ConfigurableButtonType)determineConfigureableButtonType;

@end


@implementation DetailProductItemViewController

@synthesize productDictionary;
@synthesize picturesView;
@synthesize longDescription;
@synthesize rewardsTextField;
@synthesize rewardsNeededToBuyTextField;
@synthesize priceTextField;
@synthesize ratingTextField;
@synthesize runtimeField1Label;
@synthesize runtimeField1TextField;
@synthesize saleEndDate;
@synthesize reducedPriceTextField;
@synthesize reducedPriceLabel;
@synthesize configurableActionButton;
@synthesize actionType;
@synthesize shoppingCart_btn;


- (BOOL)isTherePriceReduction
{
    //TODO - check to see the expiration date of the sale prices isn't passed yet
    double price = [[productDictionary objectForKey:@"Price"] doubleValue];
    double reducedPrice = [[productDictionary objectForKey:@"ReducedPrice"] doubleValue];
    if (reducedPrice >0 && reducedPrice < price)
    {
        return true;
    }
    else
    {
        return false;
    }
}

- (void)displayEndOfSaleDate
{
    if (![self isTherePriceReduction])
    {
        saleEndDate.text =@"NA";
    }
    else
    {
        saleEndDate.textColor = [UIColor redColor];
        saleEndDate.text = [productDictionary objectForKey:@"ExpirationDate"];
    }
}

- (void)displayReducedPrice
{
    if (![self isTherePriceReduction])
    {
        reducedPriceTextField.text =@"NA";
    }
    else
    {
        // make it stand out
        reducedPriceTextField.textColor = [UIColor redColor];
        UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [reducedPriceTextField setFont:boldFont];
        reducedPriceTextField.text = [productDictionary objectForKey:@"ReducedPrice"];
        [reducedPriceLabel setFont:boldFont];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithNibName for DetailProductItemViewController needs data argument - refer to DetailProductItemViewController.h"
                                 userInfo:nil];
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)argDataModel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        productDictionary = argDataModel;
    }
    return self;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [TapTalkLooks setBackgroundImage:self.view withBackgroundImage:[CurrentBusiness sharedCurrentBusinessManager].business.bg_image];
}




- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.picturesView.layer.borderWidth = 0;
    self.picturesView.layer.borderColor = [UIColor clearColor].CGColor;
    NSString *stringOfPictures = [productDictionary objectForKey:@"PictureArray"];
    NSArray *pictureArray = [stringOfPictures componentsSeparatedByString:@","];
    if (pictureArray.count > 1) {
        dispatch_queue_t loadImageQueue = dispatch_queue_create("com_mydoosts_com_queue",NULL);
        dispatch_async(loadImageQueue, ^{
            picturesView.hidden = FALSE;
            NSString *imageURLString;
            UIImage *image;
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for (imageURLString in pictureArray) {
                imageURLString = [imageURLString stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                [images addObject:image];
            }
            
            [picturesView animateWithImages:images transitionDuration:3 initialDelay:0 loop:YES isLandscape:NO];
            images = nil;
        });
    } else {
        picturesView.hidden = TRUE;
        CGRect imageViewRect = [picturesView frame];
        UIImageView *onePictureImageView =[[UIImageView alloc] initWithFrame:imageViewRect];
        [self.view addSubview:onePictureImageView];
        NSURL *imageURL = [NSURL URLWithString:[pictureArray objectAtIndex:0]];
        [onePictureImageView Compatible_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    ///zzzzzzz
    shoppingCart_btn.hidden = true;
    // Do any additional setup after loading the view from its nib.
    self.title = [productDictionary objectForKey:@"Name"];
    longDescription.text = [productDictionary objectForKey:@"LongDescription"];
    
    //price could be an string or an real number
    if ([[productDictionary valueForKey:@"Price"] isKindOfClass:[NSString class]]) {
        priceTextField.text = [productDictionary objectForKey:@"Price"];
    }
    else {
        NSNumber *priceNumber = [productDictionary objectForKey:@"Price"];
        NSString *priceString = [priceNumber stringValue];
        priceTextField.text  = priceString;
    }
    
    rewardsTextField.text =@"NA";
    ratingTextField.text = [productDictionary objectForKey:@"Rating"];
    rewardsNeededToBuyTextField.text = @"NA";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading detaili product information...", @"");
    
    NSArray *runtimeFields;
    NSDictionary *runtimeField1;
    NSString *fieldName;
    @try {
        runtimeFields = [productDictionary objectForKey:@"RuntimeFields_detail"];
        runtimeField1 = [runtimeFields objectAtIndex:0];
        fieldName = [runtimeField1 objectForKey:@"value"];
    }
    @catch (NSException *exception) {
        // deal with the exception
        runtimeField1TextField.hidden = TRUE;
    }
    @finally {
        // optional block of clean-up code
        // executed whether or not an exception occurred
        if (fieldName == nil) {
            runtimeField1TextField.hidden = TRUE;
            runtimeField1Label.hidden = TRUE;
        }
        else {
            runtimeField1TextField.text = fieldName;
            runtimeField1Label.text = [runtimeField1 objectForKey:@"name"];
        }
    }
    
//    self.picturesView.layer.borderWidth = 1;
//    self.picturesView.layer.borderColor = [UIColor blueColor].CGColor;
//    NSString *stringOfPictures = [productDictionary objectForKey:@"PictureArray"];
//    NSArray *pictureArray = [stringOfPictures componentsSeparatedByString:@","];
//    if (pictureArray.count > 1) {
//        dispatch_queue_t loadImageQueue = dispatch_queue_create("com_mydoosts_com_queue",NULL);
//        dispatch_async(loadImageQueue, ^{
//            picturesView.hidden = FALSE;
//            NSString *imageURLString;
//            UIImage *image;
//            NSMutableArray *images = [[NSMutableArray alloc] init];
//            for (imageURLString in pictureArray) {
//                imageURLString = [imageURLString stringByTrimmingCharactersInSet:
//                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
//                [images addObject:image];
//            }
//            
//            [picturesView animateWithImages:images transitionDuration:3 initialDelay:0 loop:YES isLandscape:NO];
//            images = nil;
//        });
//    } else {
//        picturesView.hidden = TRUE;
//        CGRect imageViewRect = [picturesView frame];
//        UIImageView *onePictureImageView =[[UIImageView alloc] initWithFrame:imageViewRect];
//        [self.view addSubview:onePictureImageView];
//        NSURL *imageURL = [NSURL URLWithString:[pictureArray objectAtIndex:0]];
//        [onePictureImageView Compatible_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];
//    }
    
    [TapTalkLooks setToTapTalkLooks:configurableActionButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:shoppingCart_btn isActionButton:YES makeItRound:NO];
    
    actionType = [self determineConfigureableButtonType];
    NSInteger noOfActionTypes = 3;
    NSInteger checkStep = -1;
    while (checkStep < noOfActionTypes) {
        checkStep++;
        if (checkStep == 0) {
            if ((actionType & Hide) == Hide) {
//                configurableActionButton.hidden = TRUE;
                [configurableActionButton setTitle:@"Buy now" forState:UIControlStateNormal];
                break;
            }
            continue;
        }
        if (checkStep == 1) {
            if ((actionType & MoreInformation) == MoreInformation) {
                [configurableActionButton setTitle:@"More information" forState:UIControlStateNormal];
                break;
            }
            continue;
        }
        if (checkStep == 2) {
            if ((actionType & ContactForInquiry) == ContactForInquiry) {
                [configurableActionButton setTitle:@"Contact For Inquiry" forState:UIControlStateNormal];
                break;
            }
            continue;
        }
    }
    
    [TapTalkLooks setToTapTalkLooks:rewardsNeededToBuyTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:reducedPriceTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:saleEndDate isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:rewardsTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:longDescription isActionButton:NO makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:runtimeField1TextField isActionButton:NO makeItRound:NO];
    
    [self displayReducedPrice];
    [self displayEndOfSaleDate];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setPicturesView:nil];
    [self setLongDescription:nil];
    [self setRewardsTextField:nil];
    [self setPriceTextField:nil];
    [self setRatingTextField:nil];
    [self setRewardsNeededToBuyTextField:nil];
    [self setRuntimeField1Label:nil];
    [self setRuntimeField1TextField:nil];

//    [self setOtherBoughtButton:nil];
    [super viewDidUnload];
}

- (ConfigurableButtonType)determineConfigureableButtonType {
    ConfigurableButtonType tempActionType =0;
    NSArray *moreInfo = [productDictionary objectForKey:@"MoreInformation"];
    if ([moreInfo count] > 0)
    {
        tempActionType = tempActionType | MoreInformation;
    }
    if ([CurrentBusiness sharedCurrentBusinessManager].business.inquiryForProduct)
    {
        tempActionType = tempActionType | ContactForInquiry;
    }
    
    if (tempActionType == 0)
        tempActionType = Hide;

    return tempActionType;
}

- (IBAction)configurableAction:(id)sender {
    if ((actionType & MoreInformation) == MoreInformation) {
        BOOL displayInquiry = ((actionType & ContactForInquiry) != 0);
        ProductMoreInformationViewController *moreInfo = [[ProductMoreInformationViewController alloc] initWithNibName:nil bundle:nil data:productDictionary displayInquiryAction:displayInquiry];
        [self.navigationController pushViewController:moreInfo animated:YES];
    }
    else if ((actionType & ContactForInquiry) == ContactForInquiry) {
        //for now let's us it for seding an sms to the mananger of the business and iquiry about this product
        NSString *message = [NSString stringWithFormat:@"I want to know more about %@ with SKU of %@ ", [productDictionary objectForKey:@"Name"], [productDictionary objectForKey:@"SKU"]];
        AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:[CurrentBusiness sharedCurrentBusinessManager].business];
        orderViewController.initialMessage = message;
        
        [self.navigationController pushViewController:orderViewController animated:YES];
    }
    else {
        Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
        int r = arc4random() % 10000;
        NSDecimalNumber *billInDollar = [[NSDecimalNumber alloc] initWithInt:r];
        BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:billInDollar forBusiness:biz];
        [self.navigationController pushViewController:payBillViewController animated:YES];
        billInDollar = nil;
    }
    
}

- (IBAction)addToShoppingCart:(id)sender {
}


@end
