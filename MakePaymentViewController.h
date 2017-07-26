//
//  MakePaymentViewController.h
//  TapForAll
//
//  Created by Trushal on 5/20/17.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "AppDelegate.h"
#import "APIUtility.h"
#import "DataModel.h"
#import "MBProgressHUD.h"
#import "RewardDetailsModel.h"
#import "BillPayViewController.h"
#import "TPReceiptController.h"
#import "MakePaymentViewController.h"

@interface MakePaymentViewController : UIViewController{
    Business  *billBusiness;
    NSDictionary *defaultCardData;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIButton *btnRedeemPoint;
@property (weak, nonatomic) IBOutlet UILabel *lblRedeemPointText;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentPoints;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpDate;
@property (weak, nonatomic) IBOutlet UILabel *waitTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblPointsUsed;
@property (strong, nonatomic) IBOutlet UILabel *lblDefaultCard;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryLocation;

@property (strong,nonatomic) NSMutableArray *finalOrderItems;
@property (assign) NSInteger currentTipVal;
@property (assign) double totalVal;
@property (assign) double subTotalVal;
@property (assign) double taxVal;
@property (assign) double tipAmt;
@property (assign) double promotionalamt;
@property (assign) double deliveryAmountValue;
@property (assign) double deliveryamt;
@property (strong,nonatomic) NSString *noteText;
@property (strong,nonatomic) NSString *pd_noteText;
@property (strong,nonatomic) NSString *restTitle;


- (IBAction)btnAddCardCliked:(id)sender;
- (IBAction)btnRedeemPointClicked:(id)sender;
- (IBAction)btnPayNowClicked:(id)sender;


@end
