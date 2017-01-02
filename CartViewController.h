//
//  CartViewController.h
//  TapForAll
//
//  Created by Lalit on 11/17/16.
//
//

#import <UIKit/UIKit.h>
#import "CartViewTableViewCell.h"
#import "Business.h"
#import "MBProgressHUD.h"


@interface CartViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    Business  *billBusiness;
    NSDecimalNumber *billInDollar;
    NSDecimalNumber *zero;
    NSDictionary *defaultCardData;
}


@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtotalAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblEarnPoints;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnPickUpFoodClicked:(id)sender;
- (IBAction)btnDeliverToMeClicked:(id)sender;
- (IBAction)btnScheduleForLaterClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnDeliverToMe;
@property (weak, nonatomic) IBOutlet UIButton *btnPickUpFood;
@property (weak, nonatomic) IBOutlet UIButton *btnScheduleForLater;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic)NSMutableArray *FetchedRecordArray;
@property (strong) NSManagedObject *currentObject;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpAt;
- (IBAction)btnPickUpAtContinueClicked:(id)sender;

@end
