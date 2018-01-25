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
#import "AppData.h"
#import "MenuOptionItemModel.h"
#import "MenuItemOptionsCell.h"
#import "MenuItemNoImageTableViewCell.h"
#import "CartViewController.h"
@class MBProgressHUD;

@interface MenuItemViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SHMultipleSelectDelegate, SINavigationMenuDelegate, UITextFieldDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate> {
    int myCartCount;
//    UIButton *_btn;
    NSMutableArray *_dataSource;
    //NSString * flagstr;
    SINavigationMenuView *menu;
    
    CustomUIButton *selectedButton;
    TPBusinessDetail *selectedBusinessDetail;
    Business *business;
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteViewHeightConstraint;
@property(strong,nonatomic) NSString *currency_code;
@property  (strong,nonatomic) NSString *currency_symbol;
@property (strong, nonatomic) IBOutlet UIView *MenuItems_back_view;
@property (strong, nonatomic) IBOutlet UILabel *lbl_menuItems;
@property (strong, nonatomic) IBOutlet UITableView *MenuItemTableView;
@property (strong,nonatomic) NSMutableArray *nameArray;
@property (strong,nonatomic) NSMutableArray *discriptionArray;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelNote;
- (IBAction)btnCancelNoteClicked:(id)sender;

@property (nonatomic, strong) NSMutableArray *arrayForBool;

@property (strong,nonatomic) NSMutableArray *MainArray;
@property (strong,nonatomic) NSMutableArray *businessListDetailArray;
@property (strong,nonatomic) NSMutableArray *filteredResult;

@property (strong, atomic) NSMutableArray *filteredBusinessListArray;


@property (strong,nonatomic)NSMutableArray *sectionKeyArray;
@property (strong,nonatomic) NSMutableArray *sectionKeysWithCountArray;
@property (strong,nonatomic) NSMutableArray *sectionKeysImageArray;
@property (strong,nonatomic)BBBadgeBarButtonItem *rightButton;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic)NSMutableArray *FetchedRecordArray;
@property (strong) NSManagedObject *currentObject;
@property (assign) BOOL favesBeenInit;

@property (strong, nonatomic) IBOutlet UIView *removeFromCartView;
@property (strong, nonatomic) IBOutlet UITableView *tblRemoveFromCart;
@property (strong, nonatomic) IBOutlet UIView *removeFromCartContainerView;

@property (strong, nonatomic) IBOutlet UIView *menuItemOptionsView;
@property (weak, nonatomic) IBOutlet UITextField *txtNote;

#pragma mark - Tabs


- (IBAction)btnCancelRemoveFromCartViewClicked:(id)sender;

- (IBAction)btnCancelMenuItemOptionClicked:(id)sender;

- (IBAction)btnAddToCartMenuItemOptionClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *menuItemOptionViewBackground;

@property (strong, nonatomic) IBOutlet UIView *optionTab1View;
@property (strong, nonatomic) IBOutlet UIView *optionTab2View;
@property (strong, nonatomic) IBOutlet UIView *optionTab3View;

- (IBAction)optionTab1Clicked:(id)sender;
- (IBAction)optionTab2Clicked:(id)sender;
- (IBAction)optionTab3Clicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnOptionTab1;
@property (strong, nonatomic) IBOutlet UIButton *btnOptionTab2;
@property (strong, nonatomic) IBOutlet UIButton *btnOptionTab3;

@property (strong, nonatomic) NSMutableArray *optionTab1Array;
@property (strong, nonatomic) NSMutableArray *optionTab2Array;
@property (strong, nonatomic) NSMutableArray *optionTab3Array;


@property (assign, nonatomic) BOOL isOptionTab1Selected;
@property (assign, nonatomic) BOOL isOptionTab2Selected;
@property (assign, nonatomic) BOOL isOptionTab3Selected;

@property (strong, nonatomic) IBOutlet UITableView *tblMenuItemOption;

@end
