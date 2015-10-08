//
//  ShakeHandWithBusinessViewController.m
//  TapForAll
//
//  Created by Amir on 1/17/14.
//
//

#import "ShakeHandWithBusinessViewController.h"
#import "ServicesForBusinessTableViewController.h"
#import "TapTalkLooks.h"
#import "UIAlertView+TapTalkAlerts.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataModel.h"
#import "CurrentBusiness.h"
#import "Consts.h"
#import "AFNetworking.h"

@interface ShakeHandWithBusinessViewController ()

@end

@implementation ShakeHandWithBusinessViewController

@synthesize qrdata, feedbackTextView, qrImageView, doneButton, instructionTextView, cancelButton, shakeHandBiz;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil businessObject:(Business *)bizArg
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        shakeHandBiz = bizArg;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TapTalkLooks setBackgroundImage:self.view];
    [TapTalkLooks setToTapTalkLooks:doneButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:cancelButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:instructionTextView isActionButton:NO makeItRound:NO];
//    [TapTalkLooks setToTapTalkLooks:feedbackTextView isActionButton:NO makeItRound:NO];
    
    UIImage *savedQRImage = [qrdata loadQRImage];
    if (savedQRImage != nil) {
        qrImageView.image = savedQRImage;
    } else {
        NSString *imageDirectory = [DataModel sharedDataModelManager].qrImageFileName;
        if (imageDirectory != nil) {
            NSString *imageURLString = [QRImageDomain stringByAppendingString:imageDirectory];
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            [qrImageView Compatible_setImageWithURL:imageURL placeholderImage:nil];
        }
        else {
            NSString *urlString = ConsumerProfileServer;
            long uid = [DataModel sharedDataModelManager].userID;
            if (uid == 0) {
                feedbackTextView.text = @"You don't have a QR code because you have not Registered. Please go to the profile page and do so.";
                imageDirectory = nil;
                return;
            }
            
            AFHTTPRequestOperationManager *manager;
            manager = [AFHTTPRequestOperationManager manager];
            
            [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
            
            NSDictionary *params = @{@"cmd":@"getQRImage", @"uid":[NSNumber numberWithUnsignedInteger:uid]};
            [manager POST:urlString parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSString *imageDirectory = [responseObject objectForKey:@"qrcode_file"];
                      if ( (imageDirectory == nil) || imageDirectory == (id)[NSNull null])  {
                          feedbackTextView.text = @"We have not produced a QR code for you.  Please check back in a few minutes";
                      }
                      else {
                          [DataModel sharedDataModelManager].qrImageFileName  = imageDirectory;
                          NSString *imageURLString = [QRImageDomain stringByAppendingString:imageDirectory];
                          NSURL *imageURL = [NSURL URLWithString:imageURLString];
                          [qrImageView Compatible_setImageWithURL:imageURL placeholderImage:nil];
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"Error in getting QRImage from server: %@", error);
                      
                  }
             ];
            
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)DoneAction:(id)sender {
    [[DataModel sharedDataModelManager] setJoinedChat:FALSE];
    [[CurrentBusiness sharedCurrentBusinessManager] setBusiness:shakeHandBiz];
    [[BusinessCustomerProfileManager sharedBusinessCustomerProfileManager] setCustomerProfileName:shakeHandBiz.customerProfileName];
    
    [[DataModel sharedDataModelManager] setChatSystemURL:shakeHandBiz.chatSystemURL];
    [[DataModel sharedDataModelManager] setChat_masters:shakeHandBiz.chat_masters];
    [[DataModel sharedDataModelManager] setValidate_chat:shakeHandBiz.validate_chat];
    [[DataModel sharedDataModelManager] setBusinessName:shakeHandBiz.businessName];
    [[DataModel sharedDataModelManager] setShortBusinessName:shakeHandBiz.shortBusinessName];
    
    NSDictionary *allChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].allChoices;
    NSArray *mainChoices = [BusinessCustomerProfileManager sharedBusinessCustomerProfileManager].mainChoices;
    ServicesForBusinessTableViewController *detailInfo = [[ServicesForBusinessTableViewController alloc]
                                                          initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:0] forBusiness:shakeHandBiz];
    [shakeHandBiz startLoadingBusinessProductCategoriesAndProducts];
    [self.navigationController pushViewController:detailInfo animated:YES];

}

@end
