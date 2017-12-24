//
//  CateringViewController.h
//  TapForAll
//
//  Created by Sanjay on 3/31/16.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "AppData.h"
#import <MessageUI/MessageUI.h>
#import "RateView.h"
#import "APIUtility.h"
@interface CateringViewController : UIViewController<UITextFieldDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Business *business;
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtDate;
@property (strong, nonatomic) IBOutlet UITextField *txtTime;
@property (strong, nonatomic) IBOutlet UITextField *txtAttendess;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtAdditionalNotes;
@property (strong, nonatomic) IBOutlet UITextField *txtBudget;
@property (strong, nonatomic) IBOutlet UIButton *btnSendRequest;
@property (strong,nonatomic)NSMutableArray *Attendeesarray;

- (IBAction)btnSendRequestClicked:(id)sender;

- (IBAction)btnDateClicked:(id)sender;
- (IBAction)btnTimeClicked:(id)sender;
- (IBAction)btnAttendeesClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *businessBackgroundImage;


@property (strong, nonatomic) IBOutlet UIView *firstNameView;
@property (strong, nonatomic) IBOutlet UIView *lastNameView;
@property (strong, nonatomic) IBOutlet UIView *phoneNumberView;
@property (strong, nonatomic) IBOutlet UIView *emailView;
@property (strong, nonatomic) IBOutlet UIView *dateView;
@property (strong, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) IBOutlet UIView *attendeesView;
@property (strong, nonatomic) IBOutlet UIView *locationView;
@property (strong, nonatomic) IBOutlet UIView *notesView;
@property (strong, nonatomic) IBOutlet UIView *budgetView;

@property (weak, nonatomic) IBOutlet UIButton *btn_Address;
@property (weak, nonatomic) IBOutlet UIButton *btn_Website;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_StateAndDist;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OpenNow;

@property (weak, nonatomic) IBOutlet RateView *ratingView;

- (IBAction)btn_AddressClicked:(id)sender;
- (IBAction)btn_WebsiteClicked:(id)sender;

@end
