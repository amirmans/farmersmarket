//
//  TotalCartItemController.h
//  TapForAll
//
//  Created by Harry on 2/15/16.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface TotalCartItemController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    Business  *billBusiness;
    NSDecimalNumber *billInDollar;
    NSDecimalNumber *zero;
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

@end
