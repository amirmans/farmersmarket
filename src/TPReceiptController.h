//
//  TPRewardsController.h
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import <UIKit/UIKit.h>
#import "APIUtility.h"
#import "DataModel.h"
#import "RewardDetailsModel.h"

@interface TPReceiptController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>{

//    NSMutableArray *FetchedRecordArray;

    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObject *currentObject;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Total;
@property (strong, nonatomic) NSMutableArray *fetchedRecordArray;
@property (strong, nonatomic) NSString *order_id;
@property (strong, nonatomic) NSString *reward_point;
@property (strong, nonatomic) NSString *cardType;
@property (strong, nonatomic) NSString *cardNumber;
@property (strong, nonatomic) NSString *cardExpDate;
@property (strong, nonatomic) NSString *redeem_point;



@property (assign) NSString *totalPaid;
@property (assign) double tipAmount;
@property (assign) double subTotal;
@property (strong, nonatomic) NSMutableArray *orderDataArray;
@property (strong, nonatomic) IBOutlet UILabel *lblOrderNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblEarnedReward;
@property (strong, nonatomic) IBOutlet UILabel *lblCardDetails;
@property (strong, nonatomic) IBOutlet UIView *thanyouView;
@property (strong, nonatomic) IBOutlet UILabel *lblRedeemReward;
@property (weak, nonatomic) IBOutlet UILabel *lblAverageWaitingTime;
@property (strong, nonatomic) IBOutlet UIButton *lblTextFromPayConfirmation;
@property (strong, nonatomic) IBOutlet UILabel *lbl_thankYou;
@property (strong, nonatomic) IBOutlet UILabel *lblBusinessName;
@property (strong, nonatomic) IBOutlet UILabel *lbl_emailSentShortly;
@property(strong,nonatomic) NSString *currency_code;
@property  (strong,nonatomic) NSString *currency_symbol;

@property (assign) double taxAmount;
@property (assign) double receiptPDCharge;

- (IBAction)btnTextFromPayConfirmation:(id)sender;

@end
