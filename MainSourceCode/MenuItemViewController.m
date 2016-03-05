//
//  MenuItemViewController.m
//  TapForAll
//
//  Created by Harry on 2/9/16.
//
//

#import "MenuItemViewController.h"
#import "MenuItemTableViewCell.h"
#import "SHMultipleSelect.h"
#import "APIUtility.h"
#import "TPBusinessDetail.h"
#import <BBBadgeBarButtonItem.h>
#import "AppDelegate.h"
#import "TotalCartItemController.h"

@interface MenuItemViewController ()

@end

@implementation MenuItemViewController

@synthesize MenuItemTableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    flagstr = @"false";
    self.title = @"Menu";
    self.navigationItem.hidesBackButton = true;
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-85, 20, 80, 40)];
    [customButton setTitle:@"My Cart" forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    self.rightButton.badgeOriginX = 70.0f;
    self.rightButton.badgeOriginY = 2.0f;
    self.navigationItem.rightBarButtonItem = self.rightButton;
    
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.MenuItemTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

    
    [customButton  addTarget:self action:@selector(myCartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    self.MenuItemTableView.delegate = self;
    self.MenuItemTableView.dataSource = self;
    
    self.MainArray = [[NSMutableArray alloc]init];
    self.businessListDetailArray = [[NSMutableArray alloc]init];
    [self BusinessListAPICall];
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
    
    self.definesPresentationContext = YES;
}

- (IBAction) backBUttonClicked: (id) sender;
{
    menu.menuButton.isActive = false;
    [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)didSelectItemAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [MenuItemTableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    NSLog(@"did selected item at index %lu", (unsigned long)index);
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


#pragma mark - Search

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredResult removeAllObjects];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name beginswith[c] %@",
                           searchText];
    NSArray * dataArray = [[NSArray alloc]init];
    dataArray = [self.businessListDetailArray filteredArrayUsingPredicate:filter];
    self.filteredResult = [[NSMutableArray alloc]initWithArray:dataArray];
    NSLog(@"%ld",self.filteredResult.count);
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
    if (self.searchController.active) {
        //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 1;
    }
    else {
        return self.sectionKeyArray.count;
    }
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        NSLog(@"%lda",self.filteredResult.count);
        return self.filteredResult.count;
    }
    else {
//        NSString *cat = self.sectionKeyArray[section];
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"category_name =[cd] %@", cat];
//        NSArray * catArray = [self.businessListDetailArray filteredArrayUsingPredicate:pred];
//        return catArray.count;
//        
        return [[self.MainArray objectAtIndex:section] count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 265;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView;
    if (self.searchController.active) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,0)];
    }else{
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
    }
    headerView.backgroundColor = [[UIColor colorWithRed:98.0/255.0f green:200.0/255.0f blue:207.0/255.0f alpha:1]colorWithAlphaComponent:1.0f];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10,[UIScreen mainScreen].bounds.size.width-5, 40)];
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = self.sectionKeyArray[section];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"MenuItemCell";
    MenuItemTableViewCell *cell = (MenuItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
//    NSArray *catArray = [self.MainArray objectAtIndex:indexPath.section];
    

    if (self.searchController.active)
        //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        TPBusinessDetail *businessDetail = [self.filteredResult objectAtIndex:indexPath.row];
        
        cell.ImageView.tag = 1;
        
        cell.lbl_description.text = businessDetail.short_description;
        cell.lbl_title.text = businessDetail.name;
        
        cell.lbl_money.text = businessDetail.price;
        
        CGFloat val = [businessDetail.price floatValue];
        int rounded_down = floorf(val * 100) / 10;
        cell.lbl_Pts.text = [NSString stringWithFormat:@"%d Pts",rounded_down];
        
        
        cell.btnFevorite.tag = indexPath.row;
        [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_minus.tag = indexPath.row;
        cell.btn_minus.section = indexPath.section;
        cell.btn_minus.row = indexPath.row;
        
        [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_plus.tag = indexPath.row;
        cell.btn_plus.section = indexPath.section;
        cell.btn_plus.row = indexPath.row;
        [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    }
    else
    {
        NSArray *catArray = [self.MainArray objectAtIndex:indexPath.section];
        
        cell.ImageView.tag = 1;
        
        cell.lbl_description.text = [catArray[indexPath.row] valueForKey:@"short_description"];
        cell.lbl_title.text = [catArray[indexPath.row] valueForKey:@"name"];
        
        cell.lbl_money.text = [catArray[indexPath.row] valueForKey:@"price"];
        
        CGFloat val = [[catArray[indexPath.row] valueForKey:@"price"] floatValue];
        int rounded_down = floorf(val * 100) / 10;
        cell.lbl_Pts.text = [NSString stringWithFormat:@"%d Pts",rounded_down];
        
        cell.btnFevorite.tag = indexPath.row;
        cell.btnFevorite.section = indexPath.section;
        cell.btnFevorite.row = indexPath.row;
        [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_minus.tag = indexPath.row;
        cell.btn_minus.section = indexPath.section;
        cell.btn_minus.row = indexPath.row;
        
        [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_plus.tag = indexPath.row;
        cell.btn_plus.section = indexPath.section;
        cell.btn_plus.row = indexPath.row;
        [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
    NSInteger section = sender.section;
    NSInteger row = sender.row;
    if(sender.selected)
        sender.selected = false;
    else
        sender.selected = true;
    
    if (self.searchController.active) {
        NSArray *businessArray = [self.filteredResult objectAtIndex:section];
        TPBusinessDetail *businessDetail = [businessArray objectAtIndex:row];
        
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%@",businessDetail.product_id] rating:@"0"];
    }
    else {
        NSArray *businessArray = [self.MainArray objectAtIndex:section];
        TPBusinessDetail *businessDetail = [businessArray objectAtIndex:row];
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%@",businessDetail.product_id] rating:@"0"];
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

- (IBAction)MinusButtonClicked:(CustomUIButton *)sender {
    
    NSLog(@"Minus Button Clicked");
    NSLog(@"%@", [[self.MainArray[sender.section] objectAtIndex:sender.row]valueForKey:@"name"]);
    TPBusinessDetail *BusinessDetail = [self.MainArray[sender.section] objectAtIndex:sender.row];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSLog(@"%@",_managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities);
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    NSLog(@"%@",_FetchedRecordArray.description);
    
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
            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
            NSLog(@"------------");
            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [context deleteObject:obj];
                ItemQty = ItemQty - 1;
                if(ItemQty > 0){
                NSManagedObject *failedBankInfo = [NSEntityDescription
                                                   insertNewObjectForEntityForName:@"MyCartItem"
                                                   inManagedObjectContext:context];
                [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
                [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
                [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
                [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
                [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
                [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                }
                break;
            }
        }
    }
    [self setMyCartValue];
}

- (IBAction)PlusButtonClicked:(CustomUIButton *)sender {
    
    NSLog(@"%@", [[self.MainArray[sender.section] objectAtIndex:sender.row]valueForKey:@"name"]);
    SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
    TPBusinessDetail *BusinessDetail = [self.MainArray[sender.section] objectAtIndex:sender.row];
    
    if (BusinessDetail.arrOptions.count > 0) {
        _dataSource = BusinessDetail.arrOptions;
        selectedButton = sender;
        selectedBusinessDetail = BusinessDetail;
        multipleSelect.delegate = self;
        multipleSelect.rowsCount = _dataSource.count;
        [multipleSelect show];

    }else{
        [self AddItemInCart:BusinessDetail CustomUIButton:sender];
    }

    NSLog(@"Plus Button Clicked");
}

- (IBAction)myCartButtonClicked:(UIButton *)sender
{
    menu.menuButton.isActive = false;
    [menu.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    TotalCartItemController *TotalCartItemVC = [[TotalCartItemController alloc] initWithNibName:@"TotalCartItemController" bundle:nil];
    [self.navigationController pushViewController:TotalCartItemVC animated:YES];
}

#pragma mark - Custom Methods

- (void)setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) favRating {
    
    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":@"1",@"rating":favRating,@"id":businessId,@"type":@"2"};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        
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
//  myCartCount = self.FetchedRecordArray.count;
    self.rightButton.badgeValue = [NSString stringWithFormat:@"%d",myCartCount];
}


- (void)BusinessListAPICall {
    
    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    [[APIUtility sharedInstance]BusinessListAPICall:data completiedBlock:^(NSDictionary *response) {
        NSLog(@"asd");
        
        [self.businessListDetailArray removeAllObjects];
        
        NSInteger status = [[response valueForKey:@"status"] integerValue];
        
        if (status == 1) {
            NSDictionary *data = [response valueForKey:@"data"];
            self.sectionKeyArray = [data allKeys];
            [self.MainArray removeAllObjects];
            NSMutableArray *catArray = [[NSMutableArray alloc] init];
            
            for (NSString *categoryString in self.sectionKeyArray) {
                NSArray *categoryArray = [data valueForKey:categoryString];
                [catArray removeAllObjects];
                
                for (NSDictionary* responseData  in categoryArray) {
                    TPBusinessDetail *BusinessDetail = [[TPBusinessDetail alloc]init];
                    BusinessDetail.product_id = [responseData objectForKey:@"product_id"];
                    BusinessDetail.businessID = [responseData objectForKey:@"businessID"];
                    BusinessDetail.name = [responseData objectForKey:@"name"];
                    BusinessDetail.pictures = [responseData objectForKey:@"pictures"];
                    BusinessDetail.short_description = [responseData objectForKey:@"short_description"];
                    BusinessDetail.long_description = [responseData objectForKey:@"long_description"];
                    
                    BusinessDetail.price = [responseData objectForKey:@"price"];
                    BusinessDetail.category_name = [responseData objectForKey:@"category_name"];
                    NSMutableArray * arr = [responseData objectForKey:@"options"];
                    
                    NSLog(@"%@",responseData);
                    NSMutableArray *arrOP = [responseData objectForKey:@"options"];
                    BusinessDetail.arrOptions = arrOP;
                    
                    NSLog(@"%@",arr.debugDescription);
                    BusinessDetail.optionArray = arr;
                    
                    [catArray addObject:BusinessDetail];
                }
                [self.MainArray addObject:catArray];
            }
            
            
            //            for (NSDictionary* responseData in response) {
            //
            //                TPBusinessDetail *BusinessDetail = [[TPBusinessDetail alloc]init];
            //                BusinessDetail.product_id = [responseData objectForKey:@"product_id"];
            //                BusinessDetail.businessID = [responseData objectForKey:@"businessID"];
            //                BusinessDetail.name = [responseData objectForKey:@"name"];
            //                BusinessDetail.pictures = [responseData objectForKey:@"pictures"];
            //                BusinessDetail.short_description = [responseData objectForKey:@"short_description"];
            //                BusinessDetail.long_description = [responseData objectForKey:@"long_description"];
            //
            //                BusinessDetail.price = [responseData objectForKey:@"price"];
            //                BusinessDetail.category_name = [responseData objectForKey:@"category_name"];
            //                NSMutableArray * arr = [responseData objectForKey:@"options"];
            //
            //                NSLog(@"%@",responseData);
            //                NSMutableArray *arrOP = [responseData objectForKey:@"options"];
            //                BusinessDetail.arrOptions = arrOP;
            //
            //                NSLog(@"%@",arr.debugDescription);
            //                BusinessDetail.optionArray = arr;
            //                NSLog(@"%@",BusinessDetail.optionArray);
            //
            //                [self.businessListDetailArray addObject:BusinessDetail];
            //
            //                NSLog(@"%@",[responseData objectForKey:@"price"]);
            //            }
            
            //            NSArray *states = [self.businessListDetailArray valueForKey:@"category_name"];
            //            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:states];
            //            NSSet *uniqueStates = [orderedSet set];
            //            self.sectionKeyArray = [uniqueStates allObjects];
            
            CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
            menu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"Menu"];
            [menu displayMenuInView:self.navigationController.view];
            menu.items =  self.sectionKeyArray;
            menu.delegate = self;
            self.navigationItem.titleView = menu;
            [MenuItemTableView reloadData];
            
            
            //            [self.MainArray removeAllObjects];
            //            for(int i = 0 ; i < self.sectionKeyArray.count; i++){
            //                NSString *cat = self.sectionKeyArray[i];
            //                NSPredicate *pred = [NSPredicate predicateWithFormat:@"category_name =[cd] %@", cat];
            //                NSArray * catArray = [self.businessListDetailArray filteredArrayUsingPredicate:pred];
            //                [self.MainArray addObject:catArray];
            //            }
            //            [MenuItemTableView reloadData];
        }
    }];
    [self setMyCartValue];
}

- (void)AddItemInCart : (TPBusinessDetail *)BusinessDetail CustomUIButton:(CustomUIButton *)sender {
    
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
            NSLog(@"%@",[dictionary valueForKey:@"quantity"]);
            NSLog(@"Business PID :- %@",[dictionary valueForKey:@"product_id"]);
            NSLog(@"Business P_ID :- %@",BusinessDetail.product_id);
            NSLog(@"%ld",[[dictionary valueForKey:@"quantity"]integerValue]);
            NSLog(@"------------");
            if([[dictionary valueForKey:@"product_id"] isEqualToString:BusinessDetail.product_id]){
                itemFound = true;
                int ItemQty = [[dictionary valueForKey:@"quantity"]intValue];
                [context deleteObject:obj];
                ItemQty = ItemQty + 1;
                
                NSManagedObject *failedBankInfo = [NSEntityDescription
                                                   insertNewObjectForEntityForName:@"MyCartItem"
                                                   inManagedObjectContext:context];
                [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
                [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
                [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
                [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
                [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
                [failedBankInfo setValue:[NSString stringWithFormat:@"%d",ItemQty] forKey:@"quantity"];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                break;
            }
        }
        
        if(!itemFound){
            NSManagedObject *failedBankInfo = [NSEntityDescription
                                               insertNewObjectForEntityForName:@"MyCartItem"
                                               inManagedObjectContext:context];
            [failedBankInfo setValue:BusinessDetail.price forKey:@"price"];
            [failedBankInfo setValue:BusinessDetail.short_description forKey:@"product_descrption"];
            [failedBankInfo setValue:BusinessDetail.product_id forKey:@"product_id"];
            [failedBankInfo setValue:BusinessDetail.pictures forKey:@"product_imageurg"];
            [failedBankInfo setValue:BusinessDetail.name forKey:@"productname"];
            [failedBankInfo setValue:@"1" forKey:@"quantity"];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
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
    NSLog(@"rect is %f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    // create new duplicate image
    UIImageView *starView = [[UIImageView alloc] initWithImage:imgV.image];
    [starView setFrame:rect];
    starView.layer.cornerRadius=5;
    starView.layer.borderColor=[[UIColor blackColor]CGColor];
    starView.layer.borderWidth=1;
    [self.view addSubview:starView];
    
    // begin ---- apply position animation
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration=0.65;
    pathAnimation.delegate=self;
    
    // tab-bar right side item frame-point = end point
    CGPoint endPoint = CGPointMake(200+rect.size.width/2, 50);
    
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


#pragma mark - SHMultipleSelectDelegate

- (void)multipleSelectView:(SHMultipleSelect*)multipleSelectView clickedBtnAtIndex:(NSInteger)clickedBtnIndex withSelectedIndexPaths:(NSArray *)selectedIndexPaths {
    

    if (clickedBtnIndex == 1) { // ADD TO ORDER Button
        [self AddItemInCart:selectedBusinessDetail  CustomUIButton:selectedButton];
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            NSLog(@"%@", _dataSource[indexPath.row]);
        }
    }
}

- (NSString*)multipleSelectView:(SHMultipleSelect*)multipleSelectView titleForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    NSString *str = [NSString stringWithFormat:@"%@ ($%@)",[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"name"],[[_dataSource objectAtIndex:indexPath.row] valueForKey:@"price"]];
    
    return str;
}

//- (NSString*)multipleSelectView:(SHMultipleSelect*)multipleSelectView titleForRowAtIndexPath:(NSIndexPath*)indexPath {
//    
//    return _dataSource[indexPath.row];
//}

- (BOOL)multipleSelectView:(SHMultipleSelect*)multipleSelectView setSelectedForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    BOOL canSelect = NO;
    
    if (indexPath.row == _dataSource.count) { // last object
        canSelect = YES;
    }
    return canSelect;
}

@end
