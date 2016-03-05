//
//  TPRewardsController.h
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import <UIKit/UIKit.h>

@interface TPReceiptController : UIViewController<UITableViewDataSource, UITableViewDelegate>{

    NSMutableArray *FetchedRecordArray;

    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObject *currentObject;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Total;



@end
