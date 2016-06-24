//
//  BusinessDetailsContoller.m
//  TapForAll
//
//  Created by Sanjay on 2/8/16.
//
//

#import "BusinessDetailsContoller.h"
#import "BusinessDetailsTableCell.h"
#import "RateView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import "AppData.h"
#import "APIUtility.h"
//#import "ServicesForBusinessTableViewController.h"
#import "MenuItemViewController.h"
#import "KASlideShow.h"
#import <MBProgressHUD.h>
#import "AskForSeviceViewController.h"
//#import "MenuViewController.h"
//#import "BillViewController.h"
#import "StoreMapViewController.h"
#import "EventsTableViewController.h"
#import "CateringViewController.h"
#import "CurrentBusiness.h"
#import "UIAlertView+TapTalkAlerts.h"


@interface BusinessDetailsContoller  (){
    KASlideShow *picturesView;
    UIButton *customBarButton;
    BOOL flagHeartBarButton;
    NSInteger previousOrderCount;
    NSMutableArray *previousOrderArray;
}
@end


@implementation BusinessDetailsContoller
@synthesize ratingView;

@synthesize biz;
@synthesize timerToLoadProducts;


UIBarButtonItem *btn_heart;



#pragma mark - Initial Data from Parent VC

- (id)initWithData:(NSDictionary *)subAndMainChoices :(NSArray *)onlyMainChoices :(NSString *)chosenItem forBusiness:(Business *)argBiz {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        allChoices = subAndMainChoices;
        mainChoices = onlyMainChoices;
        chosenMainMenu = chosenItem;
        biz = argBiz;
        timerToLoadProducts = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.busicessBackgroundImage.image = biz.bg_image;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    _businessTableView.delegate=self;
    _businessTableView.dataSource=self;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.businessTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    
    
    
    
    //1.set backgroundColor property of tableView to clearColor, so that background image is visible
    [self.businessTableView setBackgroundColor:[UIColor clearColor]];
    
    //2.create an UIImageView that you want to appear behind the table
    UIImageView *tableBackgroundView = [[UIImageView alloc] initWithImage:biz.bg_image];
    
    //3.set the UIImageView’s frame to the same size of the tableView
    [tableBackgroundView setFrame: self.businessTableView.frame];
    
    //4.update tableView’s backgroundImage to the new UIImageView object
    [self.businessTableView setBackgroundView:tableBackgroundView];
    
    
    
    
    
    
    

    previousOrderArray = [[NSMutableArray alloc] init];
//    UIImage* image = [UIImage imageNamed:@"ic_heart.png"];
//    
//    btn_heart =[[UIBarButtonItem alloc] initWithTitle:@"Custom" style:UIBarButtonItemStylePlain target:self action:@selector(btn_heartClicked)];
//    [btn_heart setImage:image];
//    btn_heart.tintColor = [UIColor grayColor];

    // todo - to be used in a letar release
//    UIImage *image = [UIImage imageNamed:@"ic_heart.png"];
//    customBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    customBarButton.bounds = CGRectMake( 0, 0, 21, 19);
//    [customBarButton setImage:image forState:UIControlStateNormal];
//    [customBarButton addTarget:self action:@selector(btn_heartClicked) forControlEvents:UIControlEventTouchUpInside];
//    btn_heart =[[UIBarButtonItem alloc] initWithCustomView:customBarButton];
    [self.navigationItem setRightBarButtonItem:btn_heart];
    previousOrderCount = 0;
    
    self.title = [CurrentBusiness sharedCurrentBusinessManager].business.shortBusinessName;
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    barBtnItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = barBtnItem;
 
//    [[AppData sharedInstance] getCurruntLocation];
    
    NSLog(@"%@",[allChoices objectForKey:chosenMainMenu]);

    ratingView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    ratingView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    ratingView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    ratingView.rating = 0;
    ratingView.editable = NO;
    ratingView.maxRating = 5;

    if (biz != nil) {
        [self loadBusinessData:biz];
        [self getPreviousOrder];	
    }
    
//    NSLog(@"%@",biz.bg_color);
//    NSLog(@"%@",biz.text_color);
    
}

- (void) btn_heartClicked {
    
    if (!flagHeartBarButton) {
        UIImage *heartFillImage = [[UIImage imageNamed:@"img_Liked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        //    [btn_heart setImage:heartFillImage];
        customBarButton.bounds = CGRectMake( 0, 0, 19, 21);
        [customBarButton setImage:heartFillImage forState:UIControlStateNormal];
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",biz.businessID] rating:@"5"];
        flagHeartBarButton = true;
    }
    else {
        UIImage *image = [UIImage imageNamed:@"ic_heart.png"];
        customBarButton.bounds = CGRectMake( 0, 0, 21, 19);
        [customBarButton setImage:image forState:UIControlStateNormal];
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",biz.businessID] rating:@"0"];
        flagHeartBarButton = false;
    }
    //    NSLog(@"btn_heartClicked");
}

- (void) backButtonPressed {
    
    NSLog(@"backButtonPressed");
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([AppData sharedInstance].currentLocation != nil) {
        
        self.currentLocation = [AppData sharedInstance].currentLocation;
        
        CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
        NSLog(@"%f",coordinate.latitude);
        NSLog(@"%f",coordinate.longitude);
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (picturesView != nil) {
        [picturesView stop];
        picturesView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - TableView Delegate / DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *tempArr = [allChoices objectForKey:chosenMainMenu];
    return ([tempArr count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BusinessDetailsCell";
    BusinessDetailsTableCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
       [tableView registerNib:[UINib nibWithNibName:@"BusinessDetailsTableCell" bundle:nil] forCellReuseIdentifier:@"BusinessDetailsCell"];
       cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsCell"];
    }
    
    NSDictionary *choice = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    if ([[choice valueForKey:@"name"] isEqualToString:@"Order Food"] ) {
        cell.FoodView.hidden = false;
        cell.lbl_previousOrderCount.text = [NSString stringWithFormat:@"%ld",(long)previousOrderCount];
    }else{
        cell.FoodView.hidden = true;
    }
    if ([[choice valueForKey:@"name"] rangeOfString:@"Request"].location != NSNotFound) {
        cell.lbl_profileName.text = [NSString stringWithFormat:@"%@ %@", [choice valueForKey:@"display_name"], biz.shortBusinessName];
    }
    else {
        cell.lbl_profileName.text = [choice valueForKey:@"display_name"];
    }
//    if (biz.iconRelativeURL != (id)[NSNull null] && biz.iconRelativeURL.length != 0 )
//    {
//        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:biz.iconRelativeURL];
//        NSURL *imageURL = [NSURL URLWithString:imageURLString];
//        #ifdef __IPHONE_8_0
//        [cell.img_Profile sd_setImageWithURL:imageURL placeholderImage:nil];
//        #else
//        [cell.img_Profile setImageWithURL:imageURL placeholderImage:nil];
//        #endif
//    }
   
    [cell.btn_PreviousOrder addTarget:self action:@selector(btn_PreviousOrderClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    NSString *imageName = [NSString stringWithFormat:@"%@.png",[choice valueForKey:@"name"]];
    NSString *imageName = [choice valueForKey:@"icon"];
    cell.img_Profile.image = [UIImage imageNamed:imageName];
    
    return cell;
    
//    BusinessDetailsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsTableCell"];
//    if (cell == nil) {
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessDetailsTableCell" owner:nil options:nil];
//        for (id currentObject in topLevelObjects)
//        {
//            if ([currentObject isKindOfClass:[UITableViewCell class]])
//            {
//                cell = (BusinessDetailsTableCell *) currentObject;
//                break;
//            }
//        }
//    }
//    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    ServicesForBusinessTableViewController *serviceViewContoller = [[ServicesForBusinessTableViewController alloc] initWithNibName:@"ServicesForBusinessTableViewController" bundle:nil];
//    [self.navigationController pushViewController:serviceViewContoller animated:YES];
    
//    MenuItemViewController *serviceViewContoller = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
//    [self.navigationController pushViewController:serviceViewContoller animated:YES];
    
    NSDictionary *choice = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    NSString *tmpStr = [choice valueForKey:@"name"];
//    NSString *tmpStr = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    [self loadNextViewController:tmpStr forBusiness:self.biz inNavigationController:self.navigationController];

}

- (void) btn_PreviousOrderClicked : (UIButton *) sender {
    if (previousOrderCount > 0) {
        [self removeAllOrderFromCoreData];
        [self addPreviousOrdersToCoreData];
    }
}

- (void)loadNextViewController:(NSString *)service forBusiness:(Business *)function_biz inNavigationController:(UINavigationController *)navigationController {
    NSString* tmpStr = [service lowercaseString];
    NSUInteger whileIndex = 0;
    
    while (whileIndex < 7) {
        if (whileIndex == 0) {
            if ([tmpStr isEqualToString:@"order food"]) {
                [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProducts];
                [self removeOtherBusinessOrder];
                MenuItemViewController *menuViewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
                [navigationController pushViewController:menuViewController animated:YES];
                break;
            }
        }
        
        if (whileIndex == 1) {
            if ([tmpStr rangeOfString:@"service"].location != NSNotFound) {
                // TODO maybe for the future release when we want to save the messages
//                AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
//                [navigationController pushViewController:orderViewController animated:YES];
                [self textBusinessCustomer];
            }
        }
        if (whileIndex == 2) {
            if ([tmpStr rangeOfString:@"map"].location != NSNotFound) {
                StoreMapViewController *storeMapViewController = [[StoreMapViewController alloc] initWithNibName:nil bundle:nil];
                storeMapViewController.title = [NSString stringWithFormat:@"Map of %@",function_biz.shortBusinessName];
                [navigationController pushViewController:storeMapViewController animated:YES];
            }
        }
        
        if (whileIndex == 3) {
            
//            if (([tmpStr rangeOfString:@"items"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"have"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"show"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"food"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"item"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"product"].location != NSNotFound)
//                || ([tmpStr rangeOfString:@"catering"].location != NSNotFound)
//                )
            if ([tmpStr rangeOfString:@"catering"].location != NSNotFound)
            {
                NSLog(@"Catering");
                
                CateringViewController *cateringViewController = [[CateringViewController alloc] initWithNibName:nil bundle:nil];
                cateringViewController.business = biz;
                [navigationController pushViewController:cateringViewController animated:YES];

            }
        }
        
        if (whileIndex == 4) {
            if ([tmpStr rangeOfString:@"chat"].location != NSNotFound) {
                
//                if ([DataModel sharedDataModelManager].nickname.length < 1) {
//                    [UIAlertController showErrorAlert:@"You don't have a nick name yet.  Please go to the profile page and get one."];
//                }
//                else if (![UtilityConsumerProfile canUserChat]) {
//                    [UIAlertController showErrorAlert:@"You are NOT registered to particate in this chat.  Please ask the manager to add you."];
//                }
//                else {
//                    if (![[DataModel sharedDataModelManager] joinedChat]) {
//                        // show the user that are about to connect to a new business chatroom
//                        [DataModel sharedDataModelManager].shouldDownloadChatMessages = TRUE;
//                        LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
//                        loginController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
//                        
//                        [self presentViewController:loginController animated:YES completion:nil];
//                        loginController = nil;
//                    }
//                    
//                    ChatMessagesViewController *chatViewContoller = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
//                    [navigationController pushViewController:chatViewContoller animated:YES];
//                }
            }
            
        }
        
        if (whileIndex == 5) {
            if ([tmpStr rangeOfString:@"event"].location != NSNotFound) {
                EventsTableViewController *eventTableViewController = [[EventsTableViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:eventTableViewController animated:YES];
                
            }
            
        }
        
        if (whileIndex == 6) {
            if (([tmpStr rangeOfString:@"history"].location != NSNotFound) || ([tmpStr rangeOfString:@"shopping"].location != NSNotFound)) {
            }
        }
        whileIndex++;
    }  // while
    
}

#pragma mark - Custom Methods

- (void) loadBusinessData : (Business *) businessDataObj {
    
    self.lblHeaderTitle.text = businessDataObj.businessName;
    self.lbl_Address.text = businessDataObj.address;
    self.ratingView.rating = [businessDataObj.rating floatValue];
    
//    self.busicessBackgroundImage.image = businessDataObj.bg_image;
//    NSLog(@"%@",businessDataObj.bg_image_name);
//    //We have a valid icon path - retrieve the image from our own server
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadImageWithURL:iconUrl
//                          options:0
//                         progress:nil
//                        completed:^(UIImage *webImage, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url)
//     {
//         if (webImage && finished)
//         {
//             self.busicessBackgroundImage.image = webImage;
//         }
//     }];
//    [self.busicessBackgroundImage sd_setImageWithURL:iconUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//    }];
    
//    self.businessTableView.backgroundView.backgroundColor = [UIColor greenColor];
    
//    [self getDistanceFromLocation:businessDataObj.address];

//    self.busicessBackgroundImage.image = businessDataObj.bg_image;
    
    self.lbl_Title.text = biz.address;
    [self.btn_Address setTitle:biz.address forState:UIControlStateNormal];
    
    if([biz.website  isEqual: @""]) {
        [self.btn_Website setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [self.btn_Website setTitle:biz.website forState:UIControlStateNormal];
    }
    
    self.lbl_SubTitle.text = biz.customerProfileName;
    [self.lbl_SubTitle sizeToFit];
    NSLog(@"%@",biz.customerProfileName);
    NSLog(@"%@ %.1f m",biz.state,[[AppData sharedInstance]getDistance:biz.lat longitude:biz.lng]);
//    self.lbl_StateAndDist.text = [NSString stringWithFormat:@"%@ %.1f m",biz.state,[[AppData sharedInstance]getDistance:biz.lat longitude:biz.lng]];
    
    self.lbl_StateAndDist.text = biz.neighborhood;

    BgPictureArray = [[biz.picturesString componentsSeparatedByCharactersInSet:
                                      [NSCharacterSet characterSetWithCharactersInString:@", "]] mutableCopy];
    [BgPictureArray removeObject:@""];

    if([[APIUtility sharedInstance]isOpenBussiness:biz.opening_time CloseTime:biz.closing_time]){
        self.lbl_OpenNow.text = @"OPEN NOW";
        self.lbl_OpenNow.textColor = [UIColor greenColor];
    }else{
        self.lbl_OpenNow.text = @"CLOSED";
        self.lbl_OpenNow.textColor = [UIColor redColor];
    }
    self.lbl_time.text = [[APIUtility sharedInstance]getOpenCloseTime:biz.opening_time CloseTime:biz.closing_time];
    [self setSliderForImage];
}

- (void) setSliderForImage{

    if (biz.picturesString != nil) {
        
        //            CGRect picturesViewFrame = self.imageView.frame;
        picturesView = [[KASlideShow alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.imageView.frame.size.height)];
        [self.view addSubview:picturesView];
        
        [picturesView setDelay:1]; // Delay between transitions
        [picturesView setTransitionDuration:1]; // Transition duration
        [picturesView setTransitionType:KASlideShowTransitionSlide]; // Choose a transition type (fade or slide)
        [picturesView setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
        
        NSArray *bizpictureArray = [biz.picturesString componentsSeparatedByString:@","];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
            NSString *imageRelativePathString;
            UIImage  *image;
            //[[self view] bringSubviewToFront:picturesView_KSSlide];
            for (imageRelativePathString in bizpictureArray) {
                // construct the absolute path for the image
                imageRelativePathString = [imageRelativePathString stringByTrimmingCharactersInSet:
                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *imageURLString = BusinessCustomerIndividualDirectory;
                imageURLString = [imageURLString stringByAppendingFormat:@"%i/%@",biz.businessID, imageRelativePathString];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                if (image != nil) {
                    [picturesView addImage:image];
                }
                else {
                    NSLog(@"Image %@ didn't exist", imageURLString);
                }
            }
            picturesView.delegate = self;
            
            // we stated to show it in the parent view
            //        [MBProgressHUD hideHUDForView:self.view animated:YES];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.ImageProgress stopAnimating];
                [picturesView start];
            });
        });
    }
    else {
        //  typesOfBusiness.hidden = FALSE;
    }
}

- (void) getDistanceFromLocation : (NSString *) address {
    CLLocationCoordinate2D destinationCoordinate = [AppData getLocationFromAddressString:address];
    NSLog(@"%f",destinationCoordinate.latitude);
    CLLocationCoordinate2D currentCoodinate = [self.currentLocation coordinate];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:currentCoodinate.latitude longitude:currentCoodinate.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
    CLLocationDistance distance = [AppData getDistanceFromLocation:currentLocation Destination:destinationLocation];
    NSLog(@"%f KM",distance/1000);
}

- (void)setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) favRating {
    
    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":@"1",@"rating":favRating,@"id":businessId,@"type":@"1"};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        
    }];
}

- (void) getPreviousOrder {
    
    NSString *businessID = [NSString stringWithFormat:@"%d",biz.businessID];
    NSString *consumerID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    
    [previousOrderArray removeAllObjects];
    
    [[APIUtility sharedInstance] getPreviousOrderListWithConsumerID:consumerID BusinessID:businessID completiedBlock:^(NSDictionary *response) {
        if (![[response valueForKey:@"success"] isEqual: @"NO"]) {
            if ([[response valueForKey:@"status"] integerValue] == 1) {
                NSArray *dataArray = [response valueForKey:@"data"];
//                previousOrderCount = [dataArray count];
                [self.businessTableView reloadData];
                for (NSDictionary *orderDetail in dataArray) {
                    TPBusinessDetail *businessDetail = [TPBusinessDetail new];
                    
                    businessDetail.product_order_id = [[orderDetail valueForKey:@"order_item_id"] integerValue];
                    businessDetail.price = [NSString stringWithFormat:@"%f",[[orderDetail valueForKey:@"price"] doubleValue]] ;
                    businessDetail.short_description = [orderDetail valueForKey:@"product_short_description"];
                    businessDetail.product_id = [orderDetail valueForKey:@"product_id"];
                    businessDetail.name = [orderDetail valueForKey:@"product_name"];
                    businessDetail.quantity = [[orderDetail valueForKey:@"quantity"] integerValue];
                    businessDetail.ti_rating = [[orderDetail valueForKey:@"ti_rating"] doubleValue];
                    businessDetail.note = [orderDetail valueForKey:@"note"];
                    previousOrderCount = previousOrderCount + [[orderDetail valueForKey:@"quantity"] integerValue];
                    
                    NSArray *optionsArray = [orderDetail valueForKey:@"options"];
                    NSString *selectedItemString = @"";
                    NSMutableArray *productID_array = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *optionDict in optionsArray) {
                        selectedItemString = [selectedItemString stringByAppendingString:[NSString stringWithFormat:@"%@ ($%@) ,",[optionDict valueForKey:@"name"],[optionDict valueForKey:@"price"]]];
                        
                        [productID_array addObject:[optionDict valueForKey:@"option_id"]];
                    }
                    
                    businessDetail.product_option = selectedItemString;
                    businessDetail.selected_ProductID_array = [NSMutableArray arrayWithArray:productID_array];
                    
                    [previousOrderArray addObject:businessDetail];
                }
            }
        }
    }];
}

- (void) removeAllOrderFromCoreData {
    
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *object in results)
    {
        [managedObjectContext deleteObject:object];
    }
    
    error = nil;
    [managedObjectContext save:&error];
}

- (void) removeOtherBusinessOrder {
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"MyCartItem"];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *object in results)
    {
        NSArray *keys = [[[object entity] attributesByName] allKeys];
        NSDictionary *dictionary = [object dictionaryWithValuesForKeys:keys];

        NSInteger orderBusinessID = [[dictionary valueForKey:@"businessID"] integerValue];
        NSInteger businessID = self.biz.businessID;
        
        if (orderBusinessID != businessID) {
            [managedObjectContext deleteObject:object];
        }
    }
    
    error = nil;
    [managedObjectContext save:&error];

}

- (void) addPreviousOrdersToCoreData {
    if ([previousOrderArray count] > 0) {
        for (TPBusinessDetail *businessDetail in previousOrderArray) {
            [self addItemToCoreData:businessDetail];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your previous order was added to your cart, Proceed to" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *menuAction = [UIAlertAction actionWithTitle:@"Menu" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProducts];
            MenuItemViewController *menuViewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
            [self.navigationController pushViewController:menuViewController animated:YES];
        }];
        
        UIAlertAction *myCartAction = [UIAlertAction actionWithTitle:@"My Order" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TotalCartItemController *TotalCartItemVC = [[TotalCartItemController alloc] initWithNibName:@"TotalCartItemController" bundle:nil];
            [self.navigationController pushViewController:TotalCartItemVC animated:YES];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:menuAction];
        [alert addAction:myCartAction];
        [alert addAction:cancelAction];

        [self presentViewController:alert animated:true completion:^{
            
        }];
//        [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProducts];
//        MenuItemViewController *menuViewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
//        [self.navigationController pushViewController:menuViewController animated:YES];
    }
}

- (void) addItemToCoreData : (TPBusinessDetail *) businessDetail {
    
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    
//    NSNumber *order_id = @([self getUniqueOrderNumber]);
    
    NSManagedObject *storeManageObject = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"MyCartItem"
                                       inManagedObjectContext:managedObjectContext];
    [storeManageObject setValue:[NSString stringWithFormat:@"%d",self.biz.businessID]  forKey:@"businessID"];
    [storeManageObject setValue:businessDetail.price forKey:@"price"];
    [storeManageObject setValue:businessDetail.short_description forKey:@"product_descrption"];
    [storeManageObject setValue:businessDetail.product_id forKey:@"product_id"];
    [storeManageObject setValue:businessDetail.pictures forKey:@"product_imageurg"];
    [storeManageObject setValue:businessDetail.name forKey:@"productname"];
    [storeManageObject setValue:businessDetail.product_option forKey:@"product_option"];
    [storeManageObject setValue:businessDetail.note forKey:@"note"];
    [storeManageObject setValue:@(businessDetail.product_order_id) forKey:@"product_order_id"];
//    [storeManageObject setValue:[NSString stringWithFormat:@"0.0"]  forKey:@"ti_rating"];
    [storeManageObject setValue:[NSString stringWithFormat:@"%f",businessDetail.ti_rating]  forKey:@"ti_rating"];
    NSString * selected_ProductID_arrayString = [businessDetail.selected_ProductID_array componentsJoinedByString:@","];
    [storeManageObject setValue:selected_ProductID_arrayString forKey:@"selected_ProductID_array"];
    [storeManageObject setValue:[NSString stringWithFormat:@"%ld",(long)businessDetail.quantity] forKey:@"quantity"];
    NSError *error;
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (NSInteger) getUniqueOrderNumber {
    
    NSManagedObjectContext *managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];

    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyCartItem" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"product_order_id"]];
    
    NSError *error = nil;
    NSArray *existingIDs = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
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


#pragma mark - Button Actions

- (IBAction)btn_Website_clicked:(id)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:biz.website]];
}

- (IBAction)btn_GetDirection_Cllcked:(id)sender {
    
    CLLocationCoordinate2D coord1;
    CLLocationCoordinate2D coord2;
    
    NSLog(@"Lat :- %f",biz.lat);
    NSLog(@"Lat :- %f",biz.lng);
    
//    double dist = getDistanceMetresBetweenLocationCoordinates(coord1,coord2);
    double dist = [self getDistanceMetresBetweenLocationCoordinates:coord1 :coord2];

    CLLocation* location = [[CLLocation alloc] initWithLatitude:biz.lat longitude:biz.lng];

    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil]];
        toLocation.name = biz.businessName;
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
    NSLog(@"%f",dist);
}

- (IBAction)btn_CallClicked:(id)sender {
    
    NSString *str = [(UIButton *)sender currentTitle];
    NSString *cleanedString = [[str componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",cleanedString]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else {
        UIAlertView *callAlert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [callAlert show];
    }
}

//double getDistanceMetresBetweenLocationCoordinates(
//                                                   CLLocationCoordinate2D coord1,
//                                                   CLLocationCoordinate2D coord2)
//{
//    CLLocation* location1 = [[CLLocation alloc]initWithLatitude: coord1.latitude longitude: coord1.longitude];
//    CLLocation* location2 = [[CLLocation alloc]initWithLatitude: coord2.latitude longitude: coord2.longitude];
//    return [location1 distanceFromLocation: location2];
//}

- (double) getDistanceMetresBetweenLocationCoordinates : (CLLocationCoordinate2D) coord1 :  (CLLocationCoordinate2D) coord2{
        CLLocation* location1 = [[CLLocation alloc]initWithLatitude: coord1.latitude longitude: coord1.longitude];
        CLLocation* location2 = [[CLLocation alloc]initWithLatitude: coord2.latitude longitude: coord2.longitude];
        return [location1 distanceFromLocation: location2];
}


- (IBAction)btn_AddressClicked:(id)sender {
    NSString *baseUrl = @"http://maps.apple.com/?q=";
    
    NSString *addressString = self.btn_Address.titleLabel.text;
    
    NSString *encodedUrl = [addressString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *finalurl = [NSString stringWithFormat:@"%@%@",baseUrl,encodedUrl];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalurl]];
}

- (IBAction)btn_WebsiteClicked:(id)sender {
    
    NSString *websiteUrl = self.btn_Website.titleLabel.text;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:websiteUrl]];
}


- (void)textBusinessCustomer {
    NSString *my_sms_no = biz.sms_no;
    NSString *businessName = biz.businessName;
    if ((my_sms_no == nil) || (my_sms_no == (id)[NSNull null]))
    {
        NSString *message = [NSString stringWithFormat:@"%@ has not given us their service number yet!", businessName];
        
        [UIAlertController showErrorAlert:message];
        return;
    }

    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = @"How is my order coming?";
        
        controller.recipients = [NSArray arrayWithObjects:my_sms_no, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    controller = nil;
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    UIAlertView *alert;
    NSString *tempStr = @"Your text to ";
    NSString *confirmationTitle = [tempStr stringByAppendingString:biz.businessName];

    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"confirmationTitle" message:@"Message was not sent because of an unknown Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
        case MessageComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:confirmationTitle message:@"Message was sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
        default:
            break;
    }
    alert = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
