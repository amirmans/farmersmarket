//
//  TotalCartItemController.h
//  TapForAll
//
//  Created by Harry on 2/15/16.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "RewardDetailsModel.h"
#import "TotalCartItemsTableCell.h"
// zzzz #import <Stripe/Stripe.h>
#import "STPCardValidator.h"
#import "TPReceiptController.h"
#import "MBProgressHUD.h"
#import "TPRewardPointController.h"
@interface TotalCartItemController : UIViewController<UITableViewDelegate,UITableViewDataSource, UIAlertViewDelegate, UITextViewDelegate> {
    Business  *billBusiness;
    NSDecimalNumber *billInDollar;
    NSDecimalNumber *zero;
    NSDictionary *defaultCardData;
//    NSDecimalNumber *billDollar;
}

@property (weak, nonatomic) IBOutlet UILabel *lblSubTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblQty;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalPrice;
- (IBAction)btnPayButtonClicked:(id)sender;
- (IBAction)btnCancelButtonClicked:(id)sender;
- (IBAction)btnQuestionClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *itemCartTableView;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic)NSMutableArray *FetchedRecordArray;
@property (strong) NSManagedObject *currentObject;

@property (strong, nonatomic) IBOutlet UIButton *btnRedeemPoint;

//@property (strong, nonatomic) IBOutlet UILabel *lblTotalEarnedPoint;

@property (strong, nonatomic) IBOutlet UIView *paymentView;

- (IBAction)btnRedeemPointClicked:(id)sender;

- (IBAction)btnCloseChangeOrderClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *changeOrderView;
@property (strong, nonatomic) IBOutlet UILabel *waitTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *lblItemTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblItemPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblItemQuantity;

@property (strong, nonatomic) IBOutlet UILabel *lblCurrentPoints;

@property (strong, nonatomic) IBOutlet UILabel *lblSubtotalAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblEarnedPoint;
@property (strong, nonatomic) IBOutlet UILabel *lblPointsUsed;

- (IBAction)btnAddItemClicked:(id)sender;
- (IBAction)btnRemoveItemClicked:(id)sender;

- (IBAction)btnChangePaymentMethodClicked:(id)sender;


@property (strong, nonatomic) IBOutlet UILabel *lblDefaultCard;

- (IBAction)btnUsePointClicked:(id)sender;
- (IBAction)btnAddNoteClicked:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *btnUsePoints;

@property (strong, nonatomic) IBOutlet UIButton *btnNoTip;
@property (strong, nonatomic) IBOutlet UIButton *btnOther;
@property (strong, nonatomic) IBOutlet UIButton *btnTip10;
@property (strong, nonatomic) IBOutlet UIButton *btnTip15;
@property (strong, nonatomic) IBOutlet UIButton *btnTip20;

- (IBAction)btnNoTipClicked:(id)sender;
- (IBAction)btnOtherClicked:(id)sender;
- (IBAction)btnTip10Clicked:(id)sender;
- (IBAction)btnTip15Clicked:(id)sender;
- (IBAction)btnTip20Clicked:(id)sender;

@end
