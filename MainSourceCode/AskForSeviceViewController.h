//
//  MeowToOrderController.h
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "RateView.h"
#import "APIUtility.h"
@class Business;

@interface AskForSeviceViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate> {
    UITextField *errorMessageView;
    UITextView *orderView;
    Business *myBusiness;
    NSString *initialMessage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz intialMessage:(NSString *)initialMessage;

@property(weak, nonatomic) IBOutlet UIButton *cancelUIButton;
@property(weak, nonatomic) IBOutlet UIButton *askUIButton;
@property(atomic, retain) IBOutlet UITextView *orderView;
@property(atomic, retain) IBOutlet UITextField *errorMessageView;
@property(atomic, retain) Business *myBusiness;
@property(nonatomic, strong) NSString *initialMessage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIImageView *businessBackgroundImage;

@property (weak, nonatomic) IBOutlet UIButton *btn_Address;
@property (weak, nonatomic) IBOutlet UIButton *btn_Website;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_StateAndDist;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OpenNow;

@property (weak, nonatomic) IBOutlet RateView *ratingView;

- (IBAction)btn_AddressClicked:(id)sender;
- (IBAction)btn_WebsiteClicked:(id)sender;

- (IBAction)meow;
- (IBAction)Cancel:(id)sender;

@end
