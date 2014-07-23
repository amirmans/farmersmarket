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
@synthesize picturesView;
@synthesize longDescription;
@synthesize rewardsTextField;
@synthesize rewardsNeededToBuyTextField;
@synthesize priceTextField;
@synthesize ratingTextField;
@synthesize runtimeField1Label;
@synthesize runtimeField1TextField;
@synthesize reducedPriceEndDate;
@synthesize reducedPriceTextField;
@synthesize reducedPriceLabel;
@synthesize moreInformationLabel;



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
    
    self.picturesView.layer.borderWidth = 1;
    self.picturesView.layer.borderColor = [UIColor blueColor].CGColor;
    NSString *stringOfPictures = [productDictionary objectForKey:@"PictureArray"];
    NSArray *pictureArray = [stringOfPictures componentsSeparatedByString:@","];
    if (pictureArray.count > 1) {
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
    } else {
        picturesView.hidden = TRUE;
        CGRect imageViewRect = [picturesView frame];
        UIImageView *onePictureImageView =[[UIImageView alloc] initWithFrame:imageViewRect];
        [self.view addSubview:onePictureImageView];
        NSURL *imageURL = [NSURL URLWithString:[pictureArray objectAtIndex:0]];
        [onePictureImageView setImageWithURL:imageURL placeholderImage:nil options:SDWebImageProgressiveDownload];
    }
    NSDictionary *moreInfo = [productDictionary objectForKey:@"MoreInformation"];
    if (moreInfo == nil)
    {
        moreInformationLabel.hidden = TRUE;
    }
    else {
        [TapTalkLooks setToTapTalkLooks:moreInformationLabel isActionButton:YES makeItRound:NO];
    }
    [TapTalkLooks setToTapTalkLooks:rewardsNeededToBuyTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:ratingTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:reducedPriceTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:reducedPriceEndDate isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:rewardsTextField isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:longDescription isActionButton:NO makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:runtimeField1TextField isActionButton:NO makeItRound:NO];
    
    [self displayReducedPrice];
    [self displayExpirationDate];
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

- (IBAction)moreInformationAction:(id)sender {
}

@end
