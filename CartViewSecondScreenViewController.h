//
//  CartViewSecondScreenViewController.h
//  TapForAll
//
//  Created by Harry on 1/6/17.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "APIUtility.h"
#import "DataModel.h"
#import "Business.h"
#import "MBProgressHUD.h"
#import "RewardDetailsModel.h"
#import "BillPayViewController.h"
#import "TPReceiptController.h"
#import "MakePaymentViewController.h"

@interface CartViewSecondScreenViewController : UIViewController{
    Business  *billBusiness;
    NSDictionary *defaultCardData;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) NSString *subTotal;
@property (strong,nonatomic) NSString *noteText;
@property (strong,nonatomic) NSString *pd_noteText;
@property (assign) NSString* delivery_startTime;
@property (assign) NSString* delivery_endTime;
@property (strong,nonatomic) NSString *earnPts;
@property (strong,nonatomic) NSDate *pickupTime;
@property (strong,nonatomic) NSMutableArray *orderItems;
@property (assign) double deliveryamt;
@property (assign) NSInteger selectedButtonNumber;

@property (strong, nonatomic) IBOutlet UIButton *btnNoTip;
@property (strong, nonatomic) IBOutlet UIButton *btnOther;
@property (strong, nonatomic) IBOutlet UIButton *btnTip10;
@property (strong, nonatomic) IBOutlet UIButton *btnTip15;
@property (strong, nonatomic) IBOutlet UIButton *btnTip20;
@property (strong, nonatomic) IBOutlet UIButton *btnRedeemPoint;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionCode;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionalAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentPoints;
@property (weak, nonatomic) IBOutlet UILabel *lblPointsUsed;
@property (strong, nonatomic) IBOutlet UILabel *lblDefaultCard;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPromotionalText;
@property (weak, nonatomic) IBOutlet UILabel *waitTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblSubtotalAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblEarnedPoint;
@property (weak, nonatomic) IBOutlet UILabel *lblPayNow;
@property (weak, nonatomic) IBOutlet UILabel *lblTaxRate;


@property (weak, nonatomic) IBOutlet UIView *viewDeliveryAndPickup;

- (IBAction)btnNoTipClicked:(id)sender;
- (IBAction)btnTip10Clicked:(id)sender;
- (IBAction)btnTip15Clicked:(id)sender;
- (IBAction)btnTip20Clicked:(id)sender;
- (IBAction)btnRedeemPointClicked:(id)sender;
- (IBAction)btnChangePaymentMethodClicked:(id)sender;
- (IBAction)btnPayNowClicked:(id)sender;

@end
