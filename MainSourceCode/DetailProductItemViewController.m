//
//  DetailProductItemViewController.m
//  TapTalk
//
//  Created by Amir on 8/26/12.
//
//

#import "DetailProductItemViewController.h"
#import "TapTalkLooks.h"

// github library to load the images asynchronously
#import <SDWebImage/UIImageView+WebCache.h>


@interface DetailProductItemViewController ()

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)displayReducedPrice;
- (void)displayExpirationDate;
@end


@implementation DetailProductItemViewController

@synthesize productDictionary;
@synthesize largePicture;
@synthesize longDescription;
@synthesize rewardsTextField;
@synthesize rewardsNeededToBuyTextField;
@synthesize priceTextField;
@synthesize ratingTextField;
@synthesize complementaryProductsText;
@synthesize otherBoughtButton;
@synthesize reducedPriceEndDate;
@synthesize reducedPriceTextField;
@synthesize reducedPriceLabel;


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

- (void)displayExpirationDate
{
    if (![self isTherePriceReduction])
    {
        reducedPriceEndDate.text =@"NA";
    }
    else
    {
        reducedPriceEndDate.textColor = [UIColor redColor];
        reducedPriceEndDate.text = [productDictionary objectForKey:@"ExpirationDate"];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [productDictionary objectForKey:@"Name"];
    longDescription.text = [productDictionary objectForKey:@"LongDescription"];
    priceTextField.text = [productDictionary objectForKey:@"Price"];
    rewardsTextField.text =@"NA";
    ratingTextField.text = [productDictionary objectForKey:@"Rating"];
    rewardsNeededToBuyTextField.text = @"NA";
    complementaryProductsText.text = [productDictionary objectForKey:@"ComplementaryProducts"];
    NSURL *imageURL = [NSURL URLWithString:[productDictionary objectForKey:@"LargePicture"]];
    [largePicture setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];
    [TapTalkLooks setToTapTalkLooks:otherBoughtButton isActionButton:YES makeItRound:NO];
    [self displayReducedPrice];
    [self displayExpirationDate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setLargePicture:nil];
    [self setLongDescription:nil];
    [self setRewardsTextField:nil];
    [self setPriceTextField:nil];
    [self setRatingTextField:nil];
    [self setRewardsNeededToBuyTextField:nil];
    [self setComplementaryProductsText:nil];
    [self setRecipesButton:nil];
    [self setOtherBoughtButton:nil];
    [super viewDidUnload];
}
- (IBAction)recipesAction:(id)sender {
}

- (IBAction)otherBoughtAction:(id)sender {
}
@end
