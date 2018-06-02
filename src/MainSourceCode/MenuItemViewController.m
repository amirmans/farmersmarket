//
//  MenuItemViewController.m
//  TapForAll
//
//  Created by Harry on 2/9/16.
//
//

#import "APIUtility.h"
#import "AppDelegate.h"
#import "CurrentBusiness.h"
#import "DataModel.h"
#import "MenuItemTableViewCell.h"
#import "MenuItemViewController.h"
#import "SHMultipleSelect.h"
#import "TotalCartItemCell.h"
#import "TPBusinessDetail.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "UIImageView+WebCache.h"
#import "BBBadgeBarButtonItem.h"

#import "MBProgressHUD.h"

@interface MenuItemViewController ()<UITextFieldDelegate,CAAnimationDelegate,UIAlertViewDelegate>{
    UIButton *customButton;
}

@end

@implementation MenuItemViewController

@synthesize MenuItemTableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize favesBeenInit;
@synthesize currency_symbol;
@synthesize currency_code;
#pragma mark - Life Cycle

UIBarButtonItem *backButton;
bool shouldOpenOptionMenu = false;

- (void)DisplayAlertForViewOnly {
    NSString *errorMessage = @"The ordering window is closed.\nPlease enjoy viewing the menus.";
    
    
    UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert1 addAction:okAction];
    [self presentViewController:alert1 animated:true completion:^{
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProducts];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(BusinessListAPICall)
//                                                     name:@"GotProductData"
//                                                   object:nil];
    self.view.backgroundColor = [UIColor orangeColor];

    [self setMyCartValue];
}

- (void)doSomeFunkyStuff {
    float progress = 0.0;

    while (progress < 1.0) {
        progress += 0.01;
        HUD.progress = progress;
        usleep(50000);
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.noteViewHeightConstraint.constant = 1.0;
     self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;
//    NSString *openTime = [CurrentBusiness sharedCurrentBusinessManager].business.opening_time;
//    NSString *closeTime = [CurrentBusiness sharedCurrentBusinessManager].business.closing_time;
//
//    BOOL businessIsClosed = false;
//    if(openTime == (id)[NSNull null] || closeTime == (id)[NSNull null]) {
//        businessIsClosed = true;
//    } else if (![[APIUtility sharedInstance] isOpenBussiness:openTime CloseTime:closeTime]) {
//        businessIsClosed = true;
//    }
//
//    if (businessIsClosed) {
//        NSString *openCivilianTime = [[APIUtility sharedInstance] getCivilianTime:openTime];
//        NSString *waitTime = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
//        NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
//        NSString *message = [NSString stringWithFormat:@"You may add items to your cart.\nBut if you pay, your order will be ready after the opening time (%@).\n\n%@ after opening.", openCivilianTime, waitTime];
//        NSString *title = [NSString stringWithFormat:@"%@ is\nclosed now!", businessName];
//        [UIAlertController showInformationAlert:message withTitle:title];
//    }

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.label.text = @"Updating products...";
//    HUD.detailsLabel.text = @"It is worth the wait!";
//    HUD.bezelView.color =[UIColor orangeColor];
//    HUD.backgroundView.color = [UIColor orangeColor];
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    [HUD.bezelView setBackgroundColor:[UIColor orangeColor]];
    HUD.bezelView.color = [UIColor orangeColor];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;

    [self.view addSubview:HUD];
    self.txtNote.delegate = self;
    
    
//    [HUD showWhileExecuting:@selector(doSomeFunkyStuff) onTarget:self withObject:nil animated:YES];
    [HUD showAnimated:YES];

    business = [CurrentBusiness sharedCurrentBusinessManager].business;
    //flagstr = @"false";
    favesBeenInit = false;
//    self.title =[ NSString stringWithFormat:@"%@ Menu", business.businessName];
    self.navigationItem.hidesBackButton = true;
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    backButton.tintColor = [UIColor whiteColor];

    customButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-85, 20, 80, 40)];
    [customButton setTitle:@"Order" forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    self.rightButton.badgeOriginX = 65.0f;
    self.rightButton.badgeOriginY = 2.0f;

    self.navigationItem.rightBarButtonItem = self.rightButton;

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10; // it was -6 in iOS 6 not points

    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, self.rightButton] animated:NO];

    self.removeFromCartView = [[[NSBundle mainBundle] loadNibNamed:@"RemoveFromCartView" owner:self options:nil] firstObject];
    [self.removeFromCartView setFrame:self.removeFromCartContainerView.bounds];
    [self.removeFromCartContainerView addSubview:self.removeFromCartView];
    self.removeFromCartContainerView.hidden = true;

    self.menuItemOptionsView = [[[NSBundle mainBundle] loadNibNamed:@"MenuItemOptionsView" owner:self options:nil] firstObject];
    [self.menuItemOptionsView setFrame:[self.view bounds]];
    [self.view addSubview:self.menuItemOptionsView];
    self.menuItemOptionsView.hidden = true;

    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.MenuItemTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

    [customButton  addTarget:self action:@selector(myCartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    self.MenuItemTableView.delegate = self;
    self.MenuItemTableView.dataSource = self;

    self.tblMenuItemOption.delegate = self;
    self.tblMenuItemOption.dataSource = self;

    self.MainArray = [[NSMutableArray alloc]init];
    self.businessListDetailArray = [[NSMutableArray alloc]init];

    self.optionTab1Array = [[NSMutableArray alloc] init];
    self.optionTab2Array = [[NSMutableArray alloc] init];
    self.optionTab3Array = [[NSMutableArray alloc] init];

    [self populateInternalDataStructureWithProductList];

    [self setMyCartValue];

    self.automaticallyAdjustsScrollViewInsets = NO;
    

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;

    self.MenuItemTableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       self.searchController.searchBar.frame.size.width, 44.0);

    self.definesPresentationContext = NO;
//    self.searchController.searchBar.translucent = NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                                      selector:@selector(BusinessListAPICall)
//                                                      name:@"GotProductData"
//                                                       object:nil];
    self.rightButton.enabled = true;
    
//    NSString *openTime = [CurrentBusiness sharedCurrentBusinessManager].business.opening_time;
//    NSString *closeTime = [CurrentBusiness sharedCurrentBusinessManager].business.closing_time;
//    BOOL businessIsClosed = false;
//    if(openTime == (id)[NSNull null] || closeTime == (id)[NSNull null]) {
//        businessIsClosed = true;
//    } else if (![[APIUtility sharedInstance] isBusinessOpen:openTime CloseTime:closeTime]) {
//        businessIsClosed = true;
//    }
//
//
//    if (businessIsClosed) {
//        if (business.accept_orders_when_closed) {
////            NSString *openCivilianTime = [[APIUtility sharedInstance] getCivilianTime:openTime];
////            NSString *waitTime = [CurrentBusiness sharedCurrentBusinessManager].business.process_time;
//            NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
//            NSString *message = [NSString stringWithFormat:@"You may add items to your cart.\nAlthough, you cannot place your order, but it will be saved in your cart for the next time around."];
//            NSString *title = [NSString stringWithFormat:@"%@ is closed to accepting orders now!", businessName];
//            [UIAlertController showInformationAlert:message withTitle:title];
//        } else {
//            NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
//            NSString *title = [NSString stringWithFormat:@"%@ is closed now and has chosen not to accept orders", businessName];
//            NSString *message = [NSString stringWithFormat:@"However, you may view the menu items"];
//            [UIAlertController showInformationAlert:message withTitle:title];
//
//            self.rightButton.enabled = false; // this doesn't work. That is why we are disallowing the selector to continue running
//        }
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    menu.menuButton.isActive = false;
    [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    shouldOpenOptionMenu = false;
//    [self.navigationController popViewControllerAnimated:true];


    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc {
    [self.searchBar removeFromSuperview];
    [self.searchController.view removeFromSuperview];
}

- (IBAction) backBUttonClicked: (id) sender; {
    menu.menuButton.isActive = false;
    [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    shouldOpenOptionMenu = false;
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)didSelectItemAtIndex:(NSUInteger)index {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [MenuItemTableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
//    NSLog(@"did selected item at index %lu", (unsigned long)index);
}


//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
//shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
//    return YES;
//}

//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
//    [self.filteredBusinessListArray removeAllObjects]; // First clear the filtered array.
//    for (NSDictionary *bizDict in businessListArray)
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:
//                                  @"(SELF contains[cd] %@)", searchText];
//        if ([predicate evaluateWithObject:[bizDict objectForKey:@"name"]])
//        {
//            [filteredBusinessListArray addObject:bizDict];
//        }
//    }
//}
#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.txtNote.text.length > 0)
    {
        self.btnCancelNote.hidden = false;
    }
    else
    {
        self.btnCancelNote.hidden = true;
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.txtNote){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
//        NSLog(@"%lu",(unsigned long)newLength);
        if(newLength > 0)
        {
            self.btnCancelNote.hidden = false;
        }
        else
        {
            self.btnCancelNote.hidden = true;
        }
    }
    return YES;
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.btnCancelNote.hidden = true;
    
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.btnCancelNote.hidden = true;
    return YES;
}

#pragma mark - Search

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{

    NSMutableArray *mainCategoryArray = [[NSMutableArray alloc] init];

    for (NSArray *tempSection in self.MainArray) {
        for (TPBusinessDetail *businessDetail in tempSection) {
            [mainCategoryArray addObject:businessDetail];
        }
    }

    [self.filteredResult removeAllObjects];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name beginswith[c] %@",
                           searchText];
    NSPredicate *filter2 = [NSPredicate predicateWithFormat:@"product_keywords contains[c] %@",
                       searchText];
    
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[filter, filter2]];
    
    NSArray * dataArray = [[NSArray alloc]init];
    dataArray = [mainCategoryArray filteredArrayUsingPredicate:predicate];
    self.filteredResult = [[NSMutableArray alloc]initWithArray:dataArray];
//    NSLog(@"%ld",(unsigned long)self.filteredResult.count);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.MenuItemTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)arg_searchController
{
    NSString *searchString = arg_searchController.searchBar.text;

    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];

    [self.MenuItemTableView reloadData];
}

//-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//        double yDiff = self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height - statusBarFrame.size.height;
//        self.navigationController.navigationBar.frame = CGRectMake(0, yDiff, 320, self.navigationController.navigationBar.frame.size.height);
//        self.navigationController.navigationBar.hidden = true;
//    }];
//
//}
//
//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//        double yDiff = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + statusBarFrame.size.height;
//        self.navigationController.navigationBar.frame = CGRectMake(0, yDiff, 320, self.navigationController.navigationBar.frame.size.height);
//        self.navigationController.navigationBar.hidden = false;
//    }];
//}
//Tableview

#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (self.sectionKeyArray == nil) return  0;
    
    if (self.searchController.active) {
        return 1;
    }
    
    if (self.searchController.active) {
        //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 1;
    }
    else if(tableView == self.tblRemoveFromCart) {
        return 1;
    }
    else if (tableView == self.tblMenuItemOption) {
        return 1;
    }
    else {
        return self.sectionKeyArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sectionKeyArray == nil) return  0;

    if (self.searchController.active) {
        //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
//        NSLog(@"%ld",self.filteredResult.count);
        return self.filteredResult.count;
    }
    else if(tableView == self.tblRemoveFromCart) {
        return _FetchedRecordArray.count;
    }
    else if (tableView == self.tblMenuItemOption) {
        if (self.isOptionTab1Selected) {
            return [self.optionTab1Array count];
        }
        else if (self.isOptionTab2Selected) {
            return [self.optionTab2Array count];

        }
        else if (self.isOptionTab3Selected) {
            return [self.optionTab3Array count];
        }
        return 0;
    }
    else {
        NSInteger numberOfRows = [[self.MainArray objectAtIndex:section] count];
        return numberOfRows;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tblRemoveFromCart) {
        return 120;
    }
    else if (tableView == self.tblMenuItemOption) {
        return 44;
    }
    else if (self.searchController.active) {
//        return self.filteredResult.count;

        TPBusinessDetail *businessDetail = [self.filteredResult objectAtIndex:indexPath.row];

        if (NoLogoForMenuItems == 1) {
            NSString *pictureURL = businessDetail.pictures;

            if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {
                // Image available
                return 265;
            }

            else {
                // Image not available
                return 125;
            }
        }
        else {
            return 265;
        }

    }
    else {
        NSArray *catArray = [self.MainArray objectAtIndex:indexPath.section];

        if (NoLogoForMenuItems == 1) {
            NSString *pictureURL = [catArray[indexPath.row] valueForKey:@"pictures"];

            if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {
                // Image available
                return 265;
            }

            else {
                // Image not available
                return 135;
            }
        }
        else {
            // Image available
            return 265;
        }
    }

    return 265;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return 0;
    }
    if(tableView == self.tblRemoveFromCart) {
        return 0;
    }
    else if (tableView == self.tblMenuItemOption) {
        return 0;
    }

    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *headerView;
//
//    if (self.searchController.active) {
//        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,0)];
//    }
//    else if(tableView == self.tblRemoveFromCart) {
//        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,0)];
//        return headerView;
//    }
//    else{
//        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
//    }

    NSInteger rowCount = 0;

    if (self.searchController.active) {
        rowCount = self.filteredResult.count;
    }
    else if(tableView == self.tblRemoveFromCart) {
        rowCount = _FetchedRecordArray.count;
    }
    else {
        rowCount = [[self.MainArray objectAtIndex:section] count];
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width,40)]; //10px top and 10px bottom. Just for illustration purposes.
    
    UIImageView *sectionHeaderBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 15, 30, 30)];
    [sectionHeaderBG sd_setImageWithURL:[NSURL URLWithString:self.sectionKeysImageArray[section]]];
    [sectionHeaderBG layoutIfNeeded];
    sectionHeaderBG.layer.cornerRadius = sectionHeaderBG.frame.size.width / 2;
    sectionHeaderBG.clipsToBounds = YES;
//    [sectionHeaderBG setImageWithURL:[NSURL URLWithString:self.sectionKeysImageArray[section]]];
//    [sectionHeaderBG setBackgroundColor:[UIColor redColor]];
    
    NSString *headerText = [NSString stringWithFormat:@"%@ (%ld)",self.sectionKeyArray[section],(long)rowCount];
//    NSUInteger length = [headerText length];
//    NSLog(@"%lu",(unsigned long)length);
    
    
    UILabel *sectionTitle = [[UILabel alloc] init];
//    NSLog(@"Frame %@", NSStringFromCGRect(sectionTitle.frame));
    sectionTitle.text = headerText;
    sectionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    sectionTitle.textAlignment = NSTextAlignmentCenter;
    sectionTitle.textColor = [UIColor whiteColor];
    sectionTitle.backgroundColor = [UIColor clearColor];
//    CGSize expectedLabelSize = [headerText sizeWithFont:sectionTitle.font
//                                      constrainedToSize:tableView.frame.size
//                                          lineBreakMode:sectionTitle.lineBreakMode];
    
    CGRect textRect = [headerText boundingRectWithSize:tableView.frame.size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:sectionTitle.font}
                                         context:nil];
    
    CGSize expectedLabelSize = textRect.size;
    
    sectionTitle.frame = CGRectMake(35.0, 15.0, expectedLabelSize.width, 30);
    
    
    headerView.backgroundColor = [[UIColor colorWithRed:98.0/255.0f green:200.0/255.0f blue:207.0/255.0f alpha:1]colorWithAlphaComponent:1.0f];
    
    [AppData setBusinessBackgroundColor:headerView];
    
    
//    NSLog(@"Frame %@", NSStringFromCGRect(sectionTitle.frame));
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0,10,expectedLabelSize.width+40, 50)];
//    NSLog(@"Frame %@", NSStringFromCGRect(innerView.frame));
    
    UIButton *headerButton = [[UIButton alloc] initWithFrame:innerView.bounds];
    [headerButton addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [innerView addSubview:headerButton];

    [innerView addSubview: sectionHeaderBG];
    [innerView addSubview: sectionTitle];
    innerView.center = CGPointMake(headerView.bounds.size.width/2, headerView.bounds.size.height/2);
    [headerView addSubview: innerView];
    
    return headerView;


//    headerView.backgroundColor = [[UIColor colorWithRed:98.0/255.0f green:200.0/255.0f blue:207.0/255.0f alpha:1]colorWithAlphaComponent:1.0f];
//    [[AppData sharedInstance] setBusinessBackgroundColor:headerView];

//    [AppData setBusinessBackgroundColor:headerView];
//
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10,[UIScreen mainScreen].bounds.size.width-5, 40)];
//    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
//    headerLabel.textAlignment = NSTextAlignmentCenter;
//
//
//    headerLabel.text = [NSString stringWithFormat:@"%@ (%ld)",self.sectionKeyArray[section],(long)rowCount];
//
//    headerLabel.textColor = [UIColor whiteColor];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    [headerView addSubview:headerLabel];
//
//    UIButton *headerButton = [[UIButton alloc] initWithFrame:headerView.bounds];
//    [headerButton addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [headerView addSubview:headerButton];
//    return headerView;
}

-(void)myFunction :(id) sender
{
//    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    [UIAlertController showErrorAlert:@"Please register on profile page to set your favorites. \nYou can order them next time around."];
    return;
//    NSLog(@"Tag = %d", gesture.view.tag);
}




- (void) headerClicked :(id)sender {
    menu.menuButton.isActive = true;
    [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *catArray = [self.MainArray objectAtIndex:indexPath.section];

    if (self.searchController.active) {

        TPBusinessDetail *businessDetail = [self.filteredResult objectAtIndex:indexPath.row];

        if (NoLogoForMenuItems == 1) {
            NSString *pictureURL = businessDetail.pictures;

            if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {
                // Image available
                MenuItemTableViewCell *cell = [self createMenuItemCellWithImageWithIndexpathForSearch:tableView indexPath:indexPath];
                return cell;
            }

            else {
                // Image not available
                MenuItemNoImageTableViewCell *cell = [self createMenuItemCellWithoutImageWithIndexpathForSearch:tableView indexPath:indexPath];
                return cell;
            }
        }
        else {
            MenuItemTableViewCell *cell = [self createMenuItemCellWithImageWithIndexpathForSearch:tableView indexPath:indexPath];
            return cell;
        }

    }
    else if(tableView == self.tblRemoveFromCart) {
        static NSString *simpleTableIdentifier = @"TotalCartItemCell";
        TotalCartItemCell *cell = (TotalCartItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }

        _currentObject = _FetchedRecordArray[indexPath.row];
        cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];

        CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
        val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
        CGFloat rounded_down = floorf(val * 100) / 100;

        cell.lbl_Price.text = [NSString stringWithFormat:@"%@%.2f",self.currency_symbol, rounded_down];
        cell.lbl_OrderOption.text = [self.currentObject valueForKey:@"product_option"];
        cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
        cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];


        cell.btn_minus.tag = indexPath.row;
        cell.btn_minus.section = indexPath.section;
        cell.btn_minus.row = indexPath.row;

//        [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        //    cell.btn_plus.tag = indexPath.row;
        //    cell.btn_plus.section = indexPath.section;
        //    cell.btn_plus.row = indexPath.row;
        //    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        cell.btn_minus.tag = indexPath.row;
        cell.btn_minus.section = indexPath.section;
        cell.btn_minus.row = indexPath.row;

        [cell.btn_minus addTarget:self action:@selector(removeFromCartMinusButton:) forControlEvents:UIControlEventTouchUpInside];

        cell.btn_plus.hidden = true;

//        cell.btn_plus.tag = indexPath.row;
//        cell.btn_plus.section = indexPath.section;
//        cell.btn_plus.row = indexPath.row;
//        [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
        return cell;
    }
    else if (tableView == self.tblMenuItemOption) {
        static NSString *simpleTableIdentifier = @"MenuItemOptionsCell";
        MenuItemOptionsCell *optionCell = (MenuItemOptionsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (optionCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemOptionsCell" owner:self options:nil];
            optionCell = [nib objectAtIndex:0];
        }

        MenuOptionItemModel *itemModel;

        if (self.isOptionTab1Selected) {
            itemModel = [self.optionTab1Array objectAtIndex:indexPath.row];
        }
        else if (self.isOptionTab2Selected) {
            itemModel = [self.optionTab2Array objectAtIndex:indexPath.row];
        }
        else if (self.isOptionTab3Selected) {
            itemModel = [self.optionTab3Array objectAtIndex:indexPath.row];
        }

        if (itemModel.availability_status == 1) {
            optionCell.availabilityStatusView.hidden = true;
        }
        else {
            optionCell.availabilityStatusView.hidden = false;
        }

        NSString *str = [NSString stringWithFormat:@"%@ (%@%@)",itemModel.itemName,self.currency_symbol,itemModel.itemPrice];

        optionCell.lblItemName.text = str;

        if (itemModel.isSelected) {
            optionCell.img_CheckMark.image = [UIImage imageNamed:@"ic_check_blue_fill"];
        }
        else {
            optionCell.img_CheckMark.image = [UIImage imageNamed:@"ic_check_blue_blank"];
        }

        return optionCell;
    }
    else
    {
        if (NoLogoForMenuItems == 1) {
            NSString *pictureURL = [catArray[indexPath.row] valueForKey:@"pictures"];

            if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {
                    // Image available
                MenuItemTableViewCell *cell = [self createMenuItemCellWithImageWithIndexpath:tableView indexPath:indexPath dataSource:catArray];

                cell.imageView.userInteractionEnabled = YES;
                cell.imageView.tag = indexPath.row;

                UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFunction:)];
                tapped.numberOfTapsRequired = 1;
                [cell.imageView addGestureRecognizer:tapped];
                tapped = nil;


                return cell;
            }

            else {
                    // Image not available
                MenuItemNoImageTableViewCell *cell = [self createMenuItemCellWithoutImageWithIndexpath:tableView indexPath:indexPath dataSource:catArray];
                return cell;
            }
        }
        else {
            MenuItemTableViewCell *cell = [self createMenuItemCellWithImageWithIndexpath:tableView indexPath:indexPath dataSource:catArray];

            cell.imageView.userInteractionEnabled = YES;
            cell.imageView.tag = indexPath.row;

            UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFunction:)];
            tapped.numberOfTapsRequired = 1;
            [cell.imageView addGestureRecognizer:tapped];
            tapped = nil;

            return cell;
        }
    }
}

- (MenuItemTableViewCell *) createMenuItemCellWithImageWithIndexpath : (UITableView *) tableView indexPath : (NSIndexPath *)indexPath  dataSource: (NSArray *) catArray {
    static NSString *simpleTableIdentifier = @"MenuItemCell";
    MenuItemTableViewCell *cell = (MenuItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    TPBusinessDetail *businessDetail = [catArray objectAtIndex:indexPath.row];

    cell.btnFevorite.selected = NO;

    id idRating = [catArray[indexPath.row] valueForKey:@"ti_rating"];
    if ([idRating isKindOfClass:[NSString class]]) {
        if (idRating != (id)[NSNull null]) {
            if ([idRating doubleValue] > 4.5) {
                cell.btnFevorite.selected = YES;
            }
        }
    }
    else {
        if ([idRating doubleValue] > 4.5) {
            cell.btnFevorite.selected = YES;
        }
    }

    cell.ImageView.tag = 1;

    NSString *imageURLString = BusinessCustomerIndividualDirectory;
    NSString *pictureURL = [catArray[indexPath.row] valueForKey:@"pictures"];

    
    if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {

        imageURLString = [imageURLString stringByAppendingFormat:@"%@/%@/%@",
                          [catArray[indexPath.row] valueForKey:@"businessID"], BusinessCustomerIndividualDirectory_ProductItems,
                          pictureURL];
        [cell.ImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:nil];
        cell.ImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        NSString *tmpIconName = business.iconRelativeURL;
        if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
        {
            NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            //                [[cell businessIconImageView] Compatible_setImageWithURL:imageURL placeholderImage:nil];
            [cell.ImageView sd_setImageWithURL:imageURL placeholderImage:nil];
            cell.ImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }

    NSString* short_desc = [catArray[indexPath.row] valueForKey:@"short_description"];
    if(![short_desc isKindOfClass:[NSNull class]])
        cell.lbl_description.text = short_desc;
    else
        cell.lbl_description.text = @"";
    
    
    NSString *productIconURL = [catArray[indexPath.row] valueForKey:@"product_icon"];
    NSString *iconDirectory = BusinessCustomerIconDirectory;
    
    if (productIconURL != (id)[NSNull null] && productIconURL.length != 0 ) {
        
        iconDirectory = [iconDirectory stringByAppendingFormat:@"%@",
                          productIconURL];
        [cell.imgProductIcon sd_setImageWithURL:[NSURL URLWithString:iconDirectory] placeholderImage:nil];
        cell.imgProductIcon.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    
    cell.lbl_title.text = [catArray[indexPath.row] valueForKey:@"name"];

    cell.lbl_money.text = [NSString stringWithFormat:@"%@%@",self.currency_symbol,[catArray[indexPath.row] valueForKey:@"price"]];

    CGFloat val = [[catArray[indexPath.row] valueForKey:@"price"] floatValue];
    int rounded_down = [AppData calculateRoundPoints:val];
    cell.lbl_Pts.text = [NSString stringWithFormat:@"Earn %d Pts",rounded_down];

    if(businessDetail.availability_status == 1) {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcell"];
        cell.addedItemView.hidden = false;
        cell.tempItemOutView.hidden = true;
    }
    else {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcellGray"];
        cell.addedItemView.hidden = true;
        cell.tempItemOutView.hidden = false;
    }

    cell.btnFevorite.tag = indexPath.row;
    cell.btnFevorite.section = indexPath.section;
    cell.btnFevorite.row = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.btn_plus.tag = indexPath.row;
    cell.btn_plus.section = indexPath.section;
    cell.btn_plus.row = indexPath.row;
    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (MenuItemNoImageTableViewCell *) createMenuItemCellWithoutImageWithIndexpath : (UITableView *) tableView indexPath : (NSIndexPath *)indexPath  dataSource: (NSArray *) catArray {
    
    static NSString *simpleTableIdentifier = @"MenuItemNoImageTableViewCell";
    MenuItemNoImageTableViewCell *cell = (MenuItemNoImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemNoImageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    TPBusinessDetail *businessDetail = [catArray objectAtIndex:indexPath.row];
    cell.btnFevorite.selected = NO;

    id idRating = [catArray[indexPath.row] valueForKey:@"ti_rating"];
    if ([idRating isKindOfClass:[NSString class]]) {
        if (idRating != (id)[NSNull null]) {
            if ([idRating doubleValue] > 4.5) {
                cell.btnFevorite.selected = YES;
            }
        }
    }
    else {
        if ([idRating doubleValue] > 4.5) {
            cell.btnFevorite.selected = YES;
        }
    }

    cell.ImageView.tag = 1;

    NSString* short_desc = [catArray[indexPath.row] valueForKey:@"short_description"];
    if(![short_desc isKindOfClass:[NSNull class]])
        cell.lbl_description.text = short_desc;
    else
        cell.lbl_description.text = @"";
    
    NSString *productIconURL = [catArray[indexPath.row] valueForKey:@"product_icon"];
    NSString *iconDirectory = BusinessCustomerIconDirectory;
    
    if (productIconURL != (id)[NSNull null] && productIconURL.length != 0 ) {
        
        iconDirectory = [iconDirectory stringByAppendingFormat:@"%@",
                         productIconURL];
        [cell.imgProductIcon sd_setImageWithURL:[NSURL URLWithString:iconDirectory] placeholderImage:nil];
        cell.imgProductIcon.contentMode = UIViewContentModeScaleAspectFill;
        
       
    }
    
    cell.lbl_title.text = [catArray[indexPath.row] valueForKey:@"name"];

    cell.lbl_money.text = [NSString stringWithFormat:@"%@%@",self.currency_symbol,[catArray[indexPath.row] valueForKey:@"price"]];

    CGFloat val = [[catArray[indexPath.row] valueForKey:@"price"] floatValue];
    int rounded_down = [AppData calculateRoundPoints:val];
    cell.lbl_Pts.text = [NSString stringWithFormat:@"Earn %d Pts",rounded_down];

    if(businessDetail.availability_status == 1) {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcell"];
        cell.addedItemView.hidden = false;
        cell.tempItemOutView.hidden = true;
    }
    else {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcellGray"];
        cell.addedItemView.hidden = true;
        cell.tempItemOutView.hidden = false;
    }

    cell.btnFevorite.tag = indexPath.row;
    cell.btnFevorite.section = indexPath.section;
    cell.btnFevorite.row = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.btn_plus.tag = indexPath.row;
    cell.btn_plus.section = indexPath.section;
    cell.btn_plus.row = indexPath.row;
    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (MenuItemTableViewCell *) createMenuItemCellWithImageWithIndexpathForSearch : (UITableView *) tableView indexPath : (NSIndexPath *)indexPath {

    static NSString *simpleTableIdentifier = @"MenuItemCell";
    MenuItemTableViewCell *cell = (MenuItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    TPBusinessDetail *businessDetail = [self.filteredResult objectAtIndex:indexPath.row];

    cell.ImageView.tag = 1;

    if(businessDetail.availability_status == 1) {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcell"];
        cell.addedItemView.hidden = false;
        cell.tempItemOutView.hidden = true;
    }
    else {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcellGray"];
        cell.addedItemView.hidden = true;
        cell.tempItemOutView.hidden = false;
    }

    cell.ImageView.tag = 1;

    NSString *imageURLString = BusinessCustomerIndividualDirectory;
    NSString *pictureURL = businessDetail.pictures;

    if (pictureURL != (id)[NSNull null] && pictureURL.length != 0 ) {

        imageURLString = [imageURLString stringByAppendingFormat:@"%@/%@/%@",
                          businessDetail.businessID, BusinessCustomerIndividualDirectory_ProductItems,
                          pictureURL];
        [cell.ImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:nil];
        cell.ImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        NSString *tmpIconName = business.iconRelativeURL;
        if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
        {
            NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            [cell.ImageView sd_setImageWithURL:imageURL placeholderImage:nil];
            cell.ImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }


    if(![businessDetail.short_description isKindOfClass:[NSNull class]])
        cell.lbl_description.text = businessDetail.short_description;
    else
        cell.lbl_description.text = @"";

    cell.lbl_title.text = businessDetail.name;

    cell.lbl_money.text = businessDetail.price;

    CGFloat val = [businessDetail.price floatValue];
    int rounded_down = [AppData calculateRoundPoints:val];
    cell.lbl_Pts.text = [NSString stringWithFormat:@"Earn %d Pts",rounded_down];

    return cell;
}


- (MenuItemNoImageTableViewCell *) createMenuItemCellWithoutImageWithIndexpathForSearch : (UITableView *) tableView indexPath : (NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MenuItemNoImageTableViewCell";
    MenuItemNoImageTableViewCell *cell = (MenuItemNoImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemNoImageTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    TPBusinessDetail *businessDetail = [self.filteredResult objectAtIndex:indexPath.row];

    cell.ImageView.tag = 1;

    if(businessDetail.availability_status == 1) {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcell"];
        cell.addedItemView.hidden = false;
        cell.tempItemOutView.hidden = true;
    }
    else {
        cell.imgContentBackGround.image = [UIImage imageNamed:@"bg_menuItemcellGray"];
        cell.addedItemView.hidden = true;
        cell.tempItemOutView.hidden = false;
    }

    if(![businessDetail.short_description isKindOfClass:[NSNull class]])
        cell.lbl_description.text = businessDetail.short_description;
    else
        cell.lbl_description.text = @"";

    cell.lbl_title.text = businessDetail.name;

    cell.lbl_money.text = businessDetail.price;

    CGFloat val = [businessDetail.price floatValue];
    int rounded_down = [AppData calculateRoundPoints:val];
    cell.lbl_Pts.text = [NSString stringWithFormat:@"Earn %d Pts",rounded_down];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == self.tblMenuItemOption) {
        MenuOptionItemModel *itemModel;

        if (self.isOptionTab1Selected) {
            itemModel = [self.optionTab1Array objectAtIndex:indexPath.row];
            int mutually_exclusive = [[[selectedBusinessDetail.arrOptions objectAtIndex:0] valueForKey:@"only_choose_one"] intValue];
            if (mutually_exclusive > 0) {
                for (MenuOptionItemModel *model in self.optionTab1Array) {
                    if (model.isSelected) {
                        model.isSelected = false;
                    }
                }
            }

        }
        else if (self.isOptionTab2Selected) {
            itemModel = [self.optionTab2Array objectAtIndex:indexPath.row];
            int mutually_exclusive = [[[selectedBusinessDetail.arrOptions objectAtIndex:1] valueForKey:@"only_choose_one"] intValue];
            if (mutually_exclusive > 0) {
                for (MenuOptionItemModel *model in self.optionTab2Array) {
                    if (model.isSelected) {
                        model.isSelected = false;
                    }
                }
            }

        }
        else if (self.isOptionTab3Selected) {
            itemModel = [self.optionTab3Array objectAtIndex:indexPath.row];
            int mutually_exclusive = [[[selectedBusinessDetail.arrOptions objectAtIndex:2] valueForKey:@"only_choose_one"] intValue];
            if (mutually_exclusive > 0) {
                for (MenuOptionItemModel *model in self.optionTab3Array) {
                    if (model.isSelected) {
                        model.isSelected = false;
                    }
                }
            }
        }

        if (itemModel.availability_status == 0) {
            itemModel.isSelected = false;
        }
        else {
            if (itemModel.isSelected) {
                itemModel.isSelected = false;
            }
            else {
                itemModel.isSelected = true;
            }
        }

        [tableView reloadData];
    }

//    SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
//    TPBusinessDetail *BusinessDetail = [self.MainArray[indexPath.section] objectAtIndex:indexPath.row];
//
//    if (BusinessDetail.arrOptions.count > 0) {
//        _dataSource = BusinessDetail.arrOptions;
//        NSLog(@"datasource %@",_dataSource);
////        multipleSelect.arrOPT = BusinessDetail.arrOptions;
//        multipleSelect.delegate = self;
//        multipleSelect.rowsCount = _dataSource.count;
//        [multipleSelect show];
//    }
//    else {
//
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"No Options to Dispaly" preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:ok];
//
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

#pragma mark - Button Actions

- (IBAction)FevoriteButtonClicked:(CustomUIButton *)sender
{
    long uid = [[DataModel sharedDataModelManager] userID];
    if (uid <= 0) {
        [UIAlertController showErrorAlert:@"Please register on profile page to set your favorites. \nYou can order them next time around."];
        return;
    }
    favesBeenInit = true;
    NSString *stringUid = [NSString stringWithFormat:@"%ld", uid];
    NSInteger section = sender.section;
    NSInteger row = sender.row;
    NSString *rating = @"";
    if(sender.selected) {
        sender.selected = false;
        rating = @"0.0";
        [[[self.MainArray objectAtIndex:section] objectAtIndex:row] setValue:@"0.0" forKey:@"ti_rating"];
    }
    else {
        sender.selected = true;
        rating = @"5.0";
        [[[self.MainArray objectAtIndex:section] objectAtIndex:row] setValue:@"5.0" forKey:@"ti_rating"];
    }

    if (self.searchController.active) {
        NSArray *businessArray = [self.filteredResult objectAtIndex:section];
        TPBusinessDetail *businessDetail = [businessArray objectAtIndex:row];
        [self addToFavoriteItems:businessDetail];
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%@",businessDetail.product_id] rating:rating forUser:stringUid];
    }
    else {
        NSArray *businessArray = [self.MainArray objectAtIndex:section];
        TPBusinessDetail *businessDetail = [businessArray objectAtIndex:row];
        [self addToFavoriteItems:businessDetail];
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%@",businessDetail.product_id] rating:rating forUser:stringUid];
    }
//    if(sender.selected) {
//        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"0"];
//        sender.selected = false;
//    }
//    else {
//        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"5"];
//        sender.selected = true;
//    }
}

- (void) addToFavoriteItems : (TPBusinessDetail *) businessDetail {
//    if ([self.MainArray count] == 3) {
//        NSMutableArray *favoriteCategoryArray = [[NSMutableArray alloc]init];
//        [favoriteCategoryArray addObject:businessDetail];
//        [self.MainArray addObject:favoriteCategoryArray];
//
//        [self.sectionKeyArray addObject:@"Favorite"];
//        NSString *sectionString = [NSString stringWithFormat:@"Favorite (%ld)",[favoriteCategoryArray count]];
//        [self.sectionKeysWithCountArray addObject:sectionString];
//    }
//    else {
//        NSMutableArray *favoriteCategoryArray = [self.MainArray objectAtIndex:3];
//        [favoriteCategoryArray addObject:businessDetail];
//        NSString *sectionString = [NSString stringWithFormat:@"Favorite (%ld)",[favoriteCategoryArray count]];
//        [self.sectionKeysWithCountArray removeLastObject];
//        [self.sectionKeysWithCountArray addObject:sectionString];
//        NSLog(@"%@",self.sectionKeysWithCountArray);
//    }

    NSString *lastString = [self.sectionKeyArray lastObject];

    if ([lastString isEqualToString: @"Favorites"]) {
        [self.sectionKeyArray removeLastObject];
        [self.sectionKeysWithCountArray removeLastObject];
        [self.sectionKeysImageArray removeLastObject];
        [self.MainArray removeLastObject];
    }

    NSMutableArray *favoriteCategoryArray = [[NSMutableArray alloc] init];

    for (NSArray *arrayObject in self.MainArray) {
        for (TPBusinessDetail *businessObject in arrayObject) {
            if (businessObject.ti_rating == 5) {
                [favoriteCategoryArray addObject:businessObject];
            }
        }
    }

    if (favoriteCategoryArray.count > 0) {
        [self.sectionKeyArray addObject:@"Favorites"];
        NSString *sectionString = [NSString stringWithFormat:@"Favorites (%ld)",(unsigned long)[favoriteCategoryArray count]];
        [self.sectionKeysWithCountArray addObject:sectionString];
        [self.MainArray addObject:favoriteCategoryArray];
    }

    menu.items =  self.sectionKeysWithCountArray;
    menu.table.items = self.sectionKeysWithCountArray;
//    menu.itemsImage = self.sectionKeysImageArray;
    [menu.table.table reloadData];
    [self.MenuItemTableView reloadData];
}

- (void) removeFromFavoriteItems : (TPBusinessDetail *) businessDetail {
}

- (IBAction)MinusButtonClicked:(CustomUIButton *)sender {

    NSLog(@"Minus Button Clicked");
//    NSLog(@"%@", [[self.MainArray[sender.section] objectAtIndex:sender.row]valueForKey:@"name"]);
    TPBusinessDetail *BusinessDetail = [self.MainArray[sender.section] objectAtIndex:sender.row];
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSLog(@"%@",_managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities);
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];

    NSMutableArray *fetchedRecords = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    self.FetchedRecordArray = [[NSMutableArray alloc]init];

    for (NSManagedObject *content in fetchedRecords) {
        if ([[content valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]) {
            [self.FetchedRecordArray addObject:content];
        }
    }

//    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];

    if(_FetchedRecordArray.count > 0) {

        if (_FetchedRecordArray.count == 1) {
            NSManagedObject *content = [self.FetchedRecordArray objectAtIndex:0];
            [self removeOrderFromCart:content];
        }
        else {
            self.removeFromCartContainerView.hidden = false;
            [self.tblRemoveFromCart reloadData];
//            NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);
//            NSLog(@"%@",_FetchedRecordArray.description);
        }
    }


//
//    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
//    NSError *error = nil;
//    NSArray *results = [context executeFetchRequest:request error:&error];
//
//    if (error != nil) {
//
//    }
//    else {
//        BOOL itemFound = false;
//        for (NSManagedObject *obj in results) {
//            NSArray *keys = [[[obj entity] attributesByName] allKeys];
//            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
//            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
//            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
//            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
//            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
//            NSLog(@"------------");
//            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
//                itemFound = true;
//                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
//                [context deleteObject:obj];
//                ItemQty = ItemQty - 1;
//                if(ItemQty > 0){
//                    NSManagedObject *failedBankInfo = [NSEntityDescription
//                                                       insertNewObjectForEntityForName:@"MyCartItem"
//                                                       inManagedObjectContext:context];
//                    [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
//                    [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
//                    [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
//                    [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
//                    [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
//                    [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
//                    NSError *error;
//                    if (![context save:&error]) {
//                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//                    }
//                }
//                break;
//            }
//        }
//    }
//    [self setMyCartValue];
}

- (IBAction)removeFromCartMinusButton:(CustomUIButton *)sender {
    NSManagedObject *content = [self.FetchedRecordArray objectAtIndex:sender.tag];
    [self removeOrderFromCart:content];
}

- (void) removeOrderFromCart : (NSManagedObject *) content {

    TPBusinessDetail *businessDetail = [[TPBusinessDetail alloc] init];
    businessDetail.price = [content valueForKey:@"price"];
    businessDetail.short_description = [content valueForKey:@"product_descrption"];
    businessDetail.product_id = [content valueForKey:@"product_id"];
    businessDetail.pictures = [content valueForKey:@"product_imageurg"];
    businessDetail.name = [content valueForKey:@"productname"];
    businessDetail.quantity = [[content valueForKey:@"quantity"] integerValue];
    businessDetail.product_order_id = [[content valueForKey:@"product_order_id"] integerValue];
    businessDetail.product_option = [content valueForKey:@"product_option"];
    businessDetail.item_note = [content valueForKey:@"item_note"];
    businessDetail.note = [content valueForKey:@"note"];
    businessDetail.product_keywords = [content valueForKey:@"product_keywords"];
    
    businessDetail.item_note = [content valueForKey:@"item_note"];
    //    NSManagedObjectContext *context = [self managedObjectContext];
    
    //    NSLog(@"%@",_managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities);
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
    //    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    //    NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);
    //    NSLog(@"%@",_FetchedRecordArray.description);
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
    }
    else {
        BOOL itemFound = false;
        for (NSManagedObject *obj in results) {
            NSArray *keys = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
            //            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
            //            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
            //            NSLog(@"Business P_ID :- %@",businessDetail.product_id);
            //            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
            //            NSLog(@"------------");
            if([[dictionary valueForKey:@"product_order_id"] integerValue] == businessDetail.product_order_id ){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [_managedObjectContext deleteObject:obj];
                ItemQty = ItemQty - 1;
                if(ItemQty > 0){
                    NSManagedObject *storeManageObject = [NSEntityDescription
                                                          insertNewObjectForEntityForName:@"MyCartItem"
                                                          inManagedObjectContext:_managedObjectContext];
                    [storeManageObject setValue:businessDetail.price forKey:@"price"];
                    [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
                    [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
                    [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
                    [storeManageObject setValue:businessDetail.name forKey:@"productname"];
                    [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
                    [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
                    [storeManageObject setValue:@(businessDetail.product_order_id) forKey:@"product_order_id"];
                    [storeManageObject setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                    [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];
                    [storeManageObject setValue:businessDetail.note forKey:@"note"];
                    [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
                    NSError *error;
                    if (![_managedObjectContext save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
                else {
                    if (![_managedObjectContext save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
                break;
            }
        }
    }
    [self setMyCartValue];
    [self refreshRemoveFromCartDataWithProductId:businessDetail.product_id];
}

- (void) refreshRemoveFromCartDataWithProductId : (NSString *) product_id {
    
    NSMutableArray *fetchedRecords = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    self.FetchedRecordArray = [[NSMutableArray alloc]init];
    for (NSManagedObject *content in fetchedRecords) {
        if ([[content valueForKey:@"product_id"] isEqualToString:product_id]) {
            [self.FetchedRecordArray addObject:content];
        }
    }
    [self.tblRemoveFromCart reloadData];
}

- (IBAction)PlusButtonClicked:(CustomUIButton *)sender { // addbutton
    //
    //    NSString *openTime = [CurrentBusiness sharedCurrentBusinessManager].business.opening_time;
    //    NSString *closeTime = [CurrentBusiness sharedCurrentBusinessManager].business.closing_time;
    //    BOOL businessIsClosed = false;
    //    if(openTime == (id)[NSNull null] || closeTime == (id)[NSNull null]) {
    //        businessIsClosed = true;
    //    } else if (![[APIUtility sharedInstance] isBusinessOpen:openTime CloseTime:closeTime]) {
    //        businessIsClosed = true;
    //    }
    //
    //    if ( (businessIsClosed) && !(business.accept_orders_when_closed) ) {
    //        NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
    //        NSString *title = [NSString stringWithFormat:@"%@ is closed now and has chosen not to accept orders", businessName];
    //        NSString *message = [NSString stringWithFormat:@"However, you may view the menu items"];
    //        [UIAlertController showInformationAlert:message withTitle:title];
    //
    //        return;
    //    }
    //
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode) {
        [self DisplayAlertForViewOnly];
        
        return;
    }
    else {
        
        self.txtNote.text = @"";
        self.btnCancelNote.hidden = YES;
        
        //    NSLog(@"%@", [[self.MainArray[sender.section] objectAtIndex:sender.row]valueForKey:@"name"]);
        //    NSLog(@"%@",[[self.MainArray[sender.section] objectAtIndex:sender.row]valueForKey:@"price"]);
        
        //    SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
        TPBusinessDetail *businessDetail;
        
        if (self.searchController.active) {
            businessDetail = [self.filteredResult objectAtIndex:sender.row];
        }
        else {
            businessDetail = [self.MainArray[sender.section] objectAtIndex:sender.row];
        }
        businessDetail.product_option = @"";
        businessDetail.item_note = @"";
        
        self.searchController.active = false;
        
        //    TPBusinessDetail *BusinessDetail = [[TPBusinessDetail alloc]init];
        //    BusinessDetail.product_id = [responseData objectForKey:@"product_id"];
        //    BusinessDetail.businessID = [responseData objectForKey:@"businessID"];
        //    BusinessDetail.name = [responseData objectForKey:@"name"];
        //    BusinessDetail.pictures = [responseData objectForKey:@"pictures"];
        //    BusinessDetail.short_description = [responseData objectForKey:@"short_description"];
        //    BusinessDetail.long_description = [responseData objectForKey:@"long_description"];
        //
        //    NSString* field = [responseData objectForKey:@"ti_rating"];
        //    if (field == (id)[NSNull null] || field.length == 0 )
        //    {
        //        BusinessDetail.ti_rating = 0.0;
        //    }
        //    else {
        //        BusinessDetail.ti_rating = [[responseData objectForKey:@"ti_rating"] doubleValue];
        //    }
        //
        //    BusinessDetail.price = [responseData objectForKey:@"price"];
        //    BusinessDetail.category_name = [responseData objectForKey:@"category_name"];
        //    NSMutableArray * arr = [responseData objectForKey:@"options"];
        //
        //    NSLog(@"%@",responseData);
        //    NSMutableArray *arrOP = [responseData objectForKey:@"options"];
        //    BusinessDetail.arrOptions = arrOP;
        //
        //    NSLog(@"%@",arr.debugDescription);
        //    BusinessDetail.optionArray = arr;
        
        if (businessDetail.arrOptions.count > 0) {
            _dataSource = businessDetail.arrOptions;
            selectedButton = sender;
            //        selectedBusinessDetail = BusinessDetail;
            selectedBusinessDetail = [[TPBusinessDetail alloc] init];
            selectedBusinessDetail.product_id = businessDetail.product_id;
            selectedBusinessDetail.businessID = businessDetail.businessID;
            selectedBusinessDetail.name = businessDetail.name;
            selectedBusinessDetail.pictures = businessDetail.pictures;
            selectedBusinessDetail.short_description = businessDetail.short_description;
            selectedBusinessDetail.long_description = businessDetail.long_description;
            selectedBusinessDetail.ti_rating = businessDetail.ti_rating;
            selectedBusinessDetail.price = businessDetail.price;
            selectedBusinessDetail.arrOptions = businessDetail.arrOptions;
            selectedBusinessDetail.product_order_id = businessDetail.product_order_id;
            selectedBusinessDetail.product_option = businessDetail.product_option;
            selectedBusinessDetail.note = businessDetail.note;
            
            selectedBusinessDetail.item_note = businessDetail.item_note;
            //        multipleSelect.delegate = self;
            //        multipleSelect.rowsCount = _dataSource.count;
            //        [multipleSelect show];
            BOOL flag = false;
            
            for (NSDictionary *itemOptions in businessDetail.arrOptions) {
                NSArray *optionDataArray = [itemOptions valueForKey:@"optionData"];
                if ([optionDataArray count] > 0) {
                    flag = true;
                }
            }
            
            if (flag) {
                [self setMenuItemOptionsViewWithDataSource:businessDetail.arrOptions];
            }
            else {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Tapin"
                                              message:@"Add Note For This Item (Optional)."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"Ok"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         NSLog(@"Resolving UIAlert Action for tapping OK Button");
                                         NSArray * textfields = alert.textFields;
                                         UITextField * notefield = textfields[0];
                                         businessDetail.item_note = notefield.text;
                                         //                                     NSLog(@"%@",notefield.text);
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self AddItemInCart:businessDetail CustomUIButton:sender];
                                     }];
                [alert addAction:ok];
                
                [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
                    textField.accessibilityIdentifier = @"";
                    textField.placeholder = @"";
                    textField.accessibilityLabel = @"";
                    textField.returnKeyType = UIReturnKeyDone;
                }];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
        }
        else{
            [self AddItemInCart:businessDetail CustomUIButton:sender];
        }
    }
    NSLog(@"Plus Button Clicked");
}

- (IBAction)myCartButtonClicked:(UIButton *)sender
{
//    NSString *openTime = [CurrentBusiness sharedCurrentBusinessManager].business.opening_time;
//    NSString *closeTime = [CurrentBusiness sharedCurrentBusinessManager].business.closing_time;
//    BOOL businessIsClosed = false;
//    if(openTime == (id)[NSNull null] || closeTime == (id)[NSNull null]) {
//        businessIsClosed = true;
//    } else if (![[APIUtility sharedInstance] isBusinessOpen:openTime CloseTime:closeTime]) {
//        businessIsClosed = true;
//    }
//    
//    if ( (businessIsClosed) && !(business.accept_orders_when_closed) ) {
//        NSString *businessName = [CurrentBusiness sharedCurrentBusinessManager].business.businessName;
//        NSString *title = [NSString stringWithFormat:@"%@ is closed now and has chosen not to accept orders", businessName];
//        NSString *message = [NSString stringWithFormat:@"However, you may view the menu items"];
//        [UIAlertController showInformationAlert:message withTitle:title];
//        
//        return;
//    }
//    
//    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode) {
        [self DisplayAlertForViewOnly];
        return;
    } else {
        menu.menuButton.isActive = false;
        [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        shouldOpenOptionMenu = false;
        //    TotalCartItemController *TotalCartItemVC = [[TotalCartItemController alloc] initWithNibName:@"TotalCartItemController" bundle:nil];
        //    [self.navigationController pushViewController:TotalCartItemVC animated:YES];
        CartViewController *TotalCartItemVC = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
        [self.navigationController pushViewController:TotalCartItemVC animated:YES];
    }
}



#pragma mark - Custom Methods

- (void)setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) rating forUser: (NSString *) stringUid {

    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];

    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":stringUid,@"rating":rating,@"id":businessId,@"type":@"2"};
    NSLog(@"param=%@",param);

    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        if ([[response valueForKey:@"success"] isEqualToString:@"YES"]) {
            [self.MenuItemTableView reloadData];
        }
    }];
}

- (void)setMyCartValue {
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    myCartCount = 0;
    for (NSManagedObject *obj in self.FetchedRecordArray) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        myCartCount += [[dictionary valueForKey:@"quantity"] integerValue];
    }
//    NSLog(@"%@",self.FetchedRecordArray);
//  myCartCount = self.FetchedRecordArray.count;
    self.rightButton.badgeValue = [NSString stringWithFormat:@"%d",myCartCount];
}

- (void)populateInternalDataStructureWithProductList {

    if ([CurrentBusiness sharedCurrentBusinessManager].business.isProductListLoaded) {
        [self BusinessListAPICall];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(BusinessListAPICall)
                                                     name:@"GotProductData"
                                                   object:nil];
    }
}

//*****************************
- (void)BusinessListAPICall {
//    NSDictionary *products;
//    if ([CurrentBusiness sharedCurrentBusinessManager].business.isProductListLoaded) {
//        products = [CurrentBusiness sharedCurrentBusinessManager].business.businessProducts;
//    } else {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(BusinessListAPICall)
//                                                 name:@"GotProductData"
//                                                  object:nil];
//        return;
//
//    }

//    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
//    [[APIUtility sharedInstance]BusinessListAPICall:data completiedBlock:^(NSDictionary *response) {
//        NSLog(@"asd");
    shouldOpenOptionMenu = true;
    NSString* ServerForBusiness = DefinedServerForBusiness;

    NSDictionary *products = [CurrentBusiness sharedCurrentBusinessManager].business.businessProducts;

        NSInteger status = [[products valueForKey:@"status"] integerValue];
//    NSLog(@"%@",products);
        if ((status == 1) && products)  {
            NSDictionary *data = [products valueForKey:@"data"];
            if (data.count <1)
            {
//                NSLog(@"For %d product items not loaded or don't exist.", [CurrentBusiness sharedCurrentBusinessManager].business.businessID);
                [HUD hideAnimated:YES];
                return;
            }
            [self.businessListDetailArray removeAllObjects];

            self.sectionKeyArray = [[NSMutableArray alloc] initWithArray:[data allKeys]];
            

//            NSLog(@"%@",self.sectionKeyArray);

//            NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:data.allKeys];
//            [self.sectionKeyArray sortUsingSelector:@selector(localizedStandardCompare:)];

            self.sectionKeysWithCountArray = [[NSMutableArray alloc] init];
            self.sectionKeysImageArray = [[NSMutableArray alloc] init];

            [self.MainArray removeAllObjects];
//            NSMutableArray *catArray = [[NSMutableArray alloc] init];
            for (NSString *categoryString in self.sectionKeyArray) {
                NSArray *categoryArray = [data valueForKey:categoryString];
//                [catArray removeAllObjects];

                NSString *sectionString = [NSString stringWithFormat:@"%@ (%ld)",categoryString,(unsigned long)[categoryArray count]];
                [self.sectionKeysWithCountArray addObject:sectionString];

              
                
                NSMutableArray *catArray = [[NSMutableArray alloc] init];
                for (NSDictionary* responseData  in categoryArray) {
                    TPBusinessDetail *businessDetail = [[TPBusinessDetail alloc]init];
                    businessDetail.product_id = [responseData objectForKey:@"product_id"];
                    businessDetail.businessID = [responseData objectForKey:@"businessID"];
                    businessDetail.name = [responseData objectForKey:@"name"];
                    businessDetail.pictures = [responseData objectForKey:@"pictures"];
                    businessDetail.short_description = [responseData objectForKey:@"short_description"];
                    businessDetail.long_description = [responseData objectForKey:@"long_description"];
                    businessDetail.product_icon = [responseData objectForKey:@"product_icon"];
                    businessDetail.category_icon = [responseData objectForKey:@"category_icon"];

                    NSString *URLString = [NSString stringWithFormat:@"%@/%@",BusinessCustomerIconDirectory,[responseData objectForKey:@"product_icon"]];
                    [self.sectionKeysImageArray addObject:URLString];
//                    [self.sectionKeysImageArray addObject:[responseData objectForKey:@"product_icon"]];
                    
//                    NSString* field = [responseData objectForKey:@"ti_rating"];
//                    if (field == (id)[NSNull null] || field.length == 0 )
//                    {
//                        businessDetail.ti_rating = 0.0;
//                    }
//                    else {
//                        businessDetail.ti_rating = [[responseData objectForKey:@"ti_rating"] doubleValue];
//                    }
                    businessDetail.ti_rating = [[responseData objectForKey:@"ti_rating"] doubleValue];

//                    if ([businessDetail.name  isEqual: @"Mexican coke"]) {
//                        businessDetail.ti_rating = 5.0;
//                    }

                    businessDetail.price = [responseData objectForKey:@"price"];
                    businessDetail.category_name = [responseData objectForKey:@"category_name"];
                    businessDetail.note = @"";
                    businessDetail.availability_status = [[responseData objectForKey:@"availability_status"] integerValue];
                    businessDetail.product_keywords = [responseData objectForKey:@"product_keywords"];
                    NSMutableArray * arr = [responseData objectForKey:@"options"];

                    if (arr.count > 0) {
                        businessDetail.arrOptions = arr;
                        businessDetail.optionArray = arr;
                    }

                    [catArray addObject:businessDetail];
                }
                [self.MainArray addObject:catArray];
                catArray = nil;
            }

            [self setFavoriteItems];

            CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
            menu = [[SINavigationMenuView alloc] initWithFrame:frame title:[NSString stringWithFormat:@"%@ Menu", business.shortBusinessName]];
            [menu displayMenuInView:self.navigationController.view];
            menu.items =  self.sectionKeysWithCountArray;
//            menu.itemsImage = self.sectionKeysImageArray;
            
            menu.delegate = self;
            self.navigationItem.titleView = menu;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(shouldOpenOptionMenu) {
                    self->menu.menuButton.isActive = true;
                    [self->menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            });

            [MenuItemTableView reloadData];

            NSNumber *bizID= [NSNumber numberWithInt:business.businessID];
            NSDictionary *inDataDict = @{@"cmd":@"get_average_wait_time_for_business",@"business_id":bizID};

            [[APIUtility sharedInstance] getAverageWaitTimeForBusiness:inDataDict server:ServerForBusiness completiedBlock:^(NSDictionary *response) {
                if([response valueForKey:@"data"] != nil) {

                    NSDictionary *dataDict = [response valueForKey:@"data"];

                    NSString* process_time = [dataDict valueForKey:@"process_time"];
                    if (process_time == (id)[NSNull null] || process_time.length == 0 )
                    {

                    } else {
                        self->business.process_time = [dataDict valueForKey:@"process_time"];
                    }

                }
            }];

            [HUD hideAnimated:YES];

            //            [self.MainArray removeAllObjects];
            //            for(int i = 0 ; i < self.sectionKeyArray.count; i++){
            //                NSString *cat = self.sectionKeyArray[i];
            //                NSPredicate *pred = [NSPredicate predicateWithFormat:@"category_name =[cd] %@", cat];
            //                NSArray * catArray = [self.businessListDetailArray filteredArrayUsingPredicate:pred];
            //                [self.MainArray addObject:catArray];
            //            }
            //            [MenuItemTableView reloadData];
        }
//    }];
    [self setMyCartValue];
}

-(void)setTopmenu{
}

- (void) setFavoriteItems {

    NSMutableArray *favoriteCategoryArray = [[NSMutableArray alloc] init];

    for (NSArray *arrayObject in self.MainArray) {
        for (TPBusinessDetail *businessObject in arrayObject) {
            if (businessObject.ti_rating == 5) {
                [favoriteCategoryArray addObject:businessObject];
            }
        }
    }

    if (favoriteCategoryArray.count > 0) {
        [self.sectionKeyArray addObject:@"Favorites"];
        NSString *sectionString = [NSString stringWithFormat:@"Favorites (%ld)",(unsigned long)[favoriteCategoryArray count]];
        [self.sectionKeysWithCountArray addObject:sectionString];
        [self.MainArray addObject:favoriteCategoryArray];
    }

//    self.MainArray;
}

//*******************************
//
//

- (void)AddItemInCart : (TPBusinessDetail *)businessDetail CustomUIButton:(CustomUIButton *)sender {

    
    NSManagedObjectContext *context = [self managedObjectContext];
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil) {

    }
    else {
        BOOL itemFound = false;

        for (NSManagedObject *obj in results) {
            NSArray *keys = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
//            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
//            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
//            NSLog(@"Business P_ID :- %@",businessDetail.product_id);
//            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
//            NSLog(@"------------");

            if([[dictionary valueForKey:@"product_id"] isEqualToString:businessDetail.product_id]) {

                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];

                ItemQty = ItemQty + 1;

                if([businessDetail.product_option isEqualToString:@""] || businessDetail.product_option == nil) {

                    if ([[dictionary valueForKey:@"product_option"]  isEqual: @""]) {
                        itemFound = true;

                        NSManagedObject *storeManageObject = [NSEntityDescription
                                                           insertNewObjectForEntityForName:@"MyCartItem"
                                                           inManagedObjectContext:context];

                        [context deleteObject:obj];
                        [storeManageObject setValue:businessDetail.price forKey:@"price"];
                        [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
                        [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
                        [storeManageObject setValue:businessDetail.businessID forKey:@"businessID"];
                        [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
                        [storeManageObject setValue:businessDetail.name forKey:@"productname"];
                        [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
                        
                        [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
                        
                        [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
                        [storeManageObject setValue:@([[dictionary valueForKey:@"product_order_id"] integerValue]) forKey:@"product_order_id"];
                        if([dictionary valueForKey:@"selected_ProductID_array"] == [NSNull null])
                            [storeManageObject setValue:@"" forKey:@"selected_ProductID_array"];
                        else
                            [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];
                        [storeManageObject setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                        [storeManageObject setValue:[dictionary valueForKey:@"note"] forKey:@"note"];
                        NSError *error;

                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        break;
                    }
                }
                else {

                    NSString *selected_product_id_String = [dictionary valueForKey:@"selected_ProductID_array"];

                    NSArray *dict_selected_productid = [selected_product_id_String componentsSeparatedByString:@","];

                    if ([businessDetail.selected_ProductID_array isEqualToArray:dict_selected_productid]) {
                        itemFound = true;
                        NSManagedObject *storeManageObject = [NSEntityDescription
                                                           insertNewObjectForEntityForName:@"MyCartItem"
                                                           inManagedObjectContext:context];

                        [context deleteObject:obj];
                        [storeManageObject setValue:businessDetail.price forKey:@"price"];
                        [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
                        [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
                        [storeManageObject setValue:businessDetail.businessID forKey:@"businessID"];
                        [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
                        [storeManageObject setValue:businessDetail.name forKey:@"productname"];
                        [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
                        
                        [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
                        
                        [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
                        [storeManageObject setValue:@([[dictionary valueForKey:@"product_order_id"] integerValue]) forKey:@"product_order_id"];
                        [storeManageObject setValue:[dictionary valueForKey:@"selected_ProductID_array"] forKey:@"selected_ProductID_array"];

                        [storeManageObject setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                        [storeManageObject setValue:[dictionary valueForKey:@"note"] forKey:@"note"];

                        NSError *error;

                        if (![context save:&error]) {
//                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        break;
                    }
                }
            }
        }

        if(!itemFound){

            NSNumber *order_id = @([self getUniqueOrderNumber]);

            NSManagedObject *storeManageObject = [NSEntityDescription
                                               insertNewObjectForEntityForName:@"MyCartItem"
                                               inManagedObjectContext:context];
            [storeManageObject setValue:businessDetail.price forKey:@"price"];
            [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
            [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
            [storeManageObject setValue:businessDetail.businessID forKey:@"businessID"];
            [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
            [storeManageObject setValue:businessDetail.name forKey:@"productname"];
            [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
            
            [storeManageObject setValue:businessDetail.item_note forKey:@"item_note"];
            
            [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
            [storeManageObject setValue:order_id forKey:@"product_order_id"];
            NSString * selected_ProductID_arrayString = [businessDetail.selected_ProductID_array componentsJoinedByString:@","];
            [storeManageObject setValue:selected_ProductID_arrayString forKey:@"selected_ProductID_array"];
            [storeManageObject setValue:@"1" forKey:@"quantity"];
            [storeManageObject setValue:businessDetail.note forKey:@"note"];
            NSError *error;

            if (![context save:&error]) {
//                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }

    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.row inSection:sender.section];
    [self addToCartTapped:ip];
    [self setMyCartValue];
}

- (void)addToCartTapped:(NSIndexPath*)indexPath {

    // grab the cell using indexpath
    UITableViewCell *cell = [MenuItemTableView cellForRowAtIndexPath:indexPath];
    // grab the imageview using cell
    UIImageView *imgV = (UIImageView*)[cell viewWithTag:1];

    // get the exact location of image
    CGRect rect = [imgV.superview convertRect:imgV.frame fromView:nil];
    rect = CGRectMake(5, (rect.origin.y*-1)-10, imgV.frame.size.width, imgV.frame.size.height);
//    NSLog(@"rect is %f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);

    // create new duplicate image
    UIImageView *starView = [[UIImageView alloc] initWithImage:imgV.image];
    [starView setFrame:rect];
    starView.layer.cornerRadius=5;
    starView.layer.borderColor=[[UIColor blackColor]CGColor];
    starView.layer.borderWidth=1;
    starView.backgroundColor = [UIColor whiteColor];
    [starView setContentMode:UIViewContentModeCenter];
    starView.clipsToBounds = true;
    [self.view addSubview:starView];

    // begin ---- apply position animation
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration=0.65;
    pathAnimation.delegate=self;

    // tab-bar right side item frame-point = end point
//    CGPoint endPoint = CGPointMake(200+rect.size.width/2, 50);

//    CGPoint endPoint = CGPointMake(rect.size.width, 50);

    CGPoint endPoint = CGPointMake(self.view.frame.size.width, self.view.frame.origin.y);

    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, starView.frame.origin.x, starView.frame.origin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x-100, starView.frame.origin.y-100, endPoint.x-100, starView.frame.origin.y-100, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    // end ---- apply position animation

    // apply transform animation
    CABasicAnimation *basic=[CABasicAnimation animationWithKeyPath:@"transform"];
    [basic setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 0.25)]];
    [basic setAutoreverses:NO];
    [basic setDuration:0.65];

    [starView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    [starView.layer addAnimation:basic forKey:@"transform"];

    [starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.65];
    //  [self performSelector:@selector(reloadBadgeNumber) withObject:nil afterDelay:0.65];
}

- (NSInteger) getUniqueOrderNumber {

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyCartItem" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"product_order_id"]];

    NSError *error = nil;
    NSArray *existingIDs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];


    if (error != nil) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    NSInteger newID = 1;

    for (NSDictionary *dict in existingIDs) {
        NSInteger IDToCompare = [[dict valueForKey:@"product_order_id"] integerValue];

        if (IDToCompare >= newID) {
            newID = IDToCompare + 1;
        }
    }
    return newID;
}

- (void) disableBarButtons {
    self.rightButton.enabled = false;
    [customButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    backButton.enabled = false;
    menu.userInteractionEnabled = false;
}

- (void) enableBarButtons {
    self.rightButton.enabled = true;
    [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.enabled = true;
    menu.userInteractionEnabled = true;
}

#pragma mark - SHMultipleSelectDelegate

- (void)multipleSelectView:(SHMultipleSelect*)multipleSelectView clickedBtnAtIndex:(NSInteger)clickedBtnIndex withSelectedIndexPaths:(NSArray *)selectedIndexPaths {

    if (clickedBtnIndex == 1) {

        NSString *selectedItemString = @"";

        double optionTotal = 0;

        TPBusinessDetail *businessDetail = selectedBusinessDetail;
        NSMutableArray *productID_array = [[NSMutableArray alloc] init];

        for (NSIndexPath *indexPath in selectedIndexPaths) {
            NSLog(@"%@", _dataSource[indexPath.row]);

            selectedItemString = [selectedItemString stringByAppendingString:[NSString stringWithFormat:@"%@ (%@%@) ,",[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"name"],self.currency_symbol,[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]]];

            [productID_array addObject:[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"option_id"]];

            optionTotal = optionTotal + [[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]doubleValue];
        }

        NSArray *sortedArray = [productID_array sortedArrayUsingDescriptors:
                            @[[NSSortDescriptor sortDescriptorWithKey:@"integerValue"
                                                            ascending:YES]]];

        NSLog(@"Sorted: %@", sortedArray);

        businessDetail.selected_ProductID_array = [NSMutableArray arrayWithArray:sortedArray];

        NSLog(@"%@",selectedItemString);

        businessDetail.product_option = selectedItemString;

        double product_price = [businessDetail.price doubleValue];

        double totalCartPrice = product_price + optionTotal;

        NSLog(@"origional price = %@ , optional total= %f , total Cart price= %f",businessDetail.price,optionTotal,totalCartPrice);
        businessDetail.price = [NSString stringWithFormat:@"%f",(double)totalCartPrice];
        [self AddItemInCart:businessDetail  CustomUIButton:selectedButton];
    }
}

- (NSString*)multipleSelectView:(SHMultipleSelect*)multipleSelectView titleForRowAtIndexPath:(NSIndexPath*)indexPath {

    NSString *str = [NSString stringWithFormat:@"%@ (%@%@)",[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"name"],self.currency_symbol,[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]];
    return str;
}

- (BOOL)multipleSelectView:(SHMultipleSelect*)multipleSelectView setSelectedForRowAtIndexPath:(NSIndexPath*)indexPath {

    BOOL canSelect = NO;

    if (indexPath.row == _dataSource.count) {
        canSelect = YES;
    }
    return canSelect;
}

#pragma mark - Custom Options View


- (void) setMenuItemOptionsViewWithDataSource : (NSArray *) optionsArray {
    [AppData setBusinessBackgroundColor:self.menuItemOptionViewBackground];
    [self setMenuItemsArray:optionsArray];
    self.isOptionTab1Selected  = true;
    self.isOptionTab2Selected  = false;
    self.isOptionTab3Selected  = false;
    self.menuItemOptionsView.hidden = false;

    [self disableBarButtons];
}

- (void)setMenuItemsArray : (NSArray *) optionsArray{

    [self.optionTab1Array removeAllObjects];
    [self.optionTab2Array removeAllObjects];
    [self.optionTab3Array removeAllObjects];

    NSInteger optionsArrayCount = [optionsArray count];

    for (NSInteger i = 0; i < optionsArrayCount; i++) {
        NSDictionary *itemOptions = [optionsArray objectAtIndex:i];
        if (i == 0) {
            NSArray *optionDataArray = [itemOptions valueForKey:@"optionData"];
            NSString *option_category_name = [itemOptions valueForKey:@"option_category_name"];
            [self.btnOptionTab1 setTitle:option_category_name forState:UIControlStateNormal];

            for (NSDictionary *options in optionDataArray) {
                MenuOptionItemModel *model = [MenuOptionItemModel new];
                model.itemDescription = [options valueForKey:@"description"];
                model.itemName = [options valueForKey:@"name"];
                model.itemOption_ID = [options valueForKey:@"option_id"];
                model.itemPrice = [options valueForKey:@"price"];
                model.availability_status = [[options valueForKey:@"availability_status"] integerValue];

                [self.optionTab1Array addObject:model];
            }
            
            if([optionDataArray count] == 0) {
                self.btnOptionTab1.userInteractionEnabled = false;
                [self.btnOptionTab1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            else {
                self.btnOptionTab1.userInteractionEnabled = true;
                [self.btnOptionTab1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        else if (i == 1) {
            NSArray *optionDataArray = [itemOptions valueForKey:@"optionData"];
            NSString *option_category_name = [itemOptions valueForKey:@"option_category_name"];
            [self.btnOptionTab2 setTitle:option_category_name forState:UIControlStateNormal];

            for (NSDictionary *options in optionDataArray) {
                MenuOptionItemModel *model = [MenuOptionItemModel new];
                model.itemDescription = [options valueForKey:@"description"];
                model.itemName = [options valueForKey:@"name"];
                model.itemOption_ID = [options valueForKey:@"option_id"];
                model.itemPrice = [options valueForKey:@"price"];
                model.availability_status = [[options valueForKey:@"availability_status"] integerValue];

                [self.optionTab2Array addObject:model];
            }
            
            if([optionDataArray count] == 0) {
                self.btnOptionTab2.userInteractionEnabled = false;
                [self.btnOptionTab2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            else {
                self.btnOptionTab2.userInteractionEnabled = true;
                [self.btnOptionTab2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }

        }
        else if (i == 2) {
            NSArray *optionDataArray = [itemOptions valueForKey:@"optionData"];
            NSString *option_category_name = [itemOptions valueForKey:@"option_category_name"];
            [self.btnOptionTab3 setTitle:option_category_name forState:UIControlStateNormal];

            for (NSDictionary *options in optionDataArray) {
                MenuOptionItemModel *model = [MenuOptionItemModel new];
                model.itemDescription = [options valueForKey:@"description"];
                model.itemName = [options valueForKey:@"name"];
                model.itemOption_ID = [options valueForKey:@"option_id"];
                model.itemPrice = [options valueForKey:@"price"];
                model.availability_status = [[options valueForKey:@"availability_status"] integerValue];

                [self.optionTab3Array addObject:model];
            }
            
            if([optionDataArray count] == 0) {
                self.btnOptionTab3.userInteractionEnabled = false;
                [self.btnOptionTab3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            else {
                self.btnOptionTab3.userInteractionEnabled = true;
                [self.btnOptionTab3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }

    [self optionTab1Clicked:self];
}

- (NSMutableArray *) getArrayFromSelectedOption {
    NSMutableArray *selectedItemsArray = [[NSMutableArray alloc] init];

    for (MenuOptionItemModel *model in self.optionTab1Array) {
        if (model.isSelected) {
            [selectedItemsArray addObject:model];
        }
    }

    for (MenuOptionItemModel *model in self.optionTab2Array) {
        if (model.isSelected) {
            [selectedItemsArray addObject:model];
        }
    }

    for (MenuOptionItemModel *model in self.optionTab3Array) {
        if (model.isSelected) {
            [selectedItemsArray addObject:model];
        }
    }

    return selectedItemsArray;
}

- (IBAction)btnCancelRemoveFromCartViewClicked:(id)sender {
    self.removeFromCartContainerView.hidden = true;
}

//- (IBAction)btnCancelMenuItemOptionClicked:(id)sender {
//    [self enableBarButtons];
//
//    self.menuItemOptionsView.hidden = true;
//}
- (IBAction)btnCancelMenuItemOptionClicked:(id)sender {
    
    [self enableBarButtons];
    
    if( self.noteViewHeightConstraint.constant == 57.0){
        
        self.noteViewHeightConstraint.constant = 1.0;
    }
    else{
        self.noteViewHeightConstraint.constant = 57.0;
    }
        self.menuItemOptionsView.hidden = true;
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    
//    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
//    
//    [self addItemToMenuCart];}

- (IBAction)btnAddToCartMenuItemOptionClicked:(id)sender {
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).viewMode) {
        NSString *errorMessage = @"At this time, please only enjoy viewing the businesses and the menus";
        
        
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert1 addAction:okAction];
        [self presentViewController:alert1 animated:true completion:^{
        }];
        
        return;
    } else {
        [self addItemToMenuCart];
    }
}

-(void)addItemToMenuCart{

    [self enableBarButtons];
    
    NSMutableArray *selectedItemsArray = [self getArrayFromSelectedOption];
    
    NSString *selectedItemString = @"";
    
    double optionTotal = 0;
    
    TPBusinessDetail *businessDetail = selectedBusinessDetail;
    NSMutableArray *productID_array = [[NSMutableArray alloc] init];
    
    //    for (NSIndexPath *indexPath in selectedIndexPaths) {
    //        NSLog(@"%@", _dataSource[indexPath.row]);
    //
    //        selectedItemString = [selectedItemString stringByAppendingString:[NSString stringWithFormat:@"%@ ($%@) ,",[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"name"],[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]]];
    //
    //        [productID_array addObject:[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"option_id"]];
    //
    //        optionTotal = optionTotal + [[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]doubleValue];
    //    }
    
    
    for (MenuOptionItemModel *model in selectedItemsArray) {
        selectedItemString = [selectedItemString stringByAppendingString:[NSString stringWithFormat:@"%@ (%@%@) ,",model.itemName,self.currency_symbol,model.itemPrice]];
        [productID_array addObject:model.itemOption_ID];
        
        optionTotal = optionTotal + [model.itemPrice doubleValue];
    }
    
    NSArray *sortedArray = [productID_array sortedArrayUsingDescriptors:
                            @[[NSSortDescriptor sortDescriptorWithKey:@"integerValue"
                                                            ascending:YES]]];
    
    NSLog(@"Sorted: %@", sortedArray);
    
    businessDetail.selected_ProductID_array = [NSMutableArray arrayWithArray:sortedArray];
    
    NSLog(@"%@",selectedItemString);
    
    businessDetail.product_option = selectedItemString;
    
    if(self.txtNote.text.length != 0){
        businessDetail.item_note = self.txtNote.text;
    }
    double product_price = [businessDetail.price doubleValue];
    
    double totalCartPrice = product_price + optionTotal;
    
    NSLog(@"origional price = %@ , optional total= %f , total Cart price= %f",businessDetail.price,optionTotal,totalCartPrice);
    businessDetail.price = [NSString stringWithFormat:@"%f",(double)totalCartPrice];
    [self AddItemInCart:businessDetail  CustomUIButton:selectedButton];
    
    self.menuItemOptionsView.hidden = true;
    
}

- (IBAction)optionTab1Clicked:(id)sender {
    self.optionTab1View.backgroundColor = [UIColor whiteColor];
    [AppData setBusinessBackgroundColor:self.optionTab2View];
    [AppData setBusinessBackgroundColor:self.optionTab3View];

    self.isOptionTab1Selected = true;
    self.isOptionTab2Selected = false;
    self.isOptionTab3Selected = false;

    [self.tblMenuItemOption reloadData];
}

- (IBAction)optionTab2Clicked:(id)sender {
    [AppData setBusinessBackgroundColor:self.optionTab1View];
    self.optionTab2View.backgroundColor = [UIColor whiteColor];
    [AppData setBusinessBackgroundColor:self.optionTab3View];

    self.isOptionTab1Selected = false;
    self.isOptionTab2Selected = true;
    self.isOptionTab3Selected = false;

    [self.tblMenuItemOption reloadData];
}

- (IBAction)optionTab3Clicked:(id)sender {
    [AppData setBusinessBackgroundColor:self.optionTab1View];
    [AppData setBusinessBackgroundColor:self.optionTab2View];
    self.optionTab3View.backgroundColor = [UIColor whiteColor];

    self.isOptionTab1Selected = false;
    self.isOptionTab2Selected = false;
    self.isOptionTab3Selected = true;

    [self.tblMenuItemOption reloadData];
}

- (IBAction)btnCancelNoteClicked:(id)sender {
    self.txtNote.text = @"";
    self.btnCancelNote.hidden = YES;
}
@end
