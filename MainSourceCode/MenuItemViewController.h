//
//  MenuItemViewController.h
//  TapForAll
//
//  Created by Harry on 2/9/16.
//
//

#import <UIKit/UIKit.h>
#import "SHMultipleSelect.h"
#import <BBBadgeBarButtonItem.h>
#import "CustomUIButton.h"
#import "TPBusinessDetail.h"
#import "SINavigationMenuView.h"

@interface MenuItemViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SHMultipleSelectDelegate, SINavigationMenuDelegate, UITextFieldDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate> {
    int myCartCount;
    UIButton *_btn;
    NSMutableArray *_dataSource;
    //NSString * flagstr;
    SINavigationMenuView *menu;
    
    CustomUIButton *selectedButton;
    TPBusinessDetail *selectedBusinessDetail;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;


@property (strong, nonatomic) IBOutlet UIView *MenuItems_back_view;
@property (strong, nonatomic) IBOutlet UILabel *lbl_menuItems;
@property (strong, nonatomic) IBOutlet UITableView *MenuItemTableView;
@property (strong,nonatomic) NSMutableArray *nameArray;
@property (strong,nonatomic)NSMutableArray *discriptionArray;

@property (strong,nonatomic)NSMutableArray *MainArray;
@property (strong,nonatomic)NSMutableArray *businessListDetailArray;
@property (strong,nonatomic)NSMutableArray *filteredResult;

@property (strong, atomic) NSMutableArray *filteredBusinessListArray;


@property (strong,nonatomic)NSArray *sectionKeyArray;
@property (strong,nonatomic)BBBadgeBarButtonItem *rightButton;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic)NSMutableArray *FetchedRecordArray;
@property (strong) NSManagedObject *currentObject;
@property (assign) BOOL favesBeenInit;



@end
