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
#import "ServicesForBusinessTableViewController.h"
#import "MenuItemViewController.h"
#import "KASlideShow.h"
#import <MBProgressHUD.h>
#import "AskForSeviceViewController.h"
#import "MenuViewController.h"
#import "BillViewController.h"
#import "StoreMapViewController.h"
#import "EventsTableViewController.h"

@interface BusinessDetailsContoller  (){
    KASlideShow *picturesView;
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

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setNeedsStatusBarAppearanceUpdate];

    _businessTableView.delegate=self;
    _businessTableView.dataSource=self;
    
    UIImage* image = [UIImage imageNamed:@"ic_heart.png"];
    
    btn_heart =[[UIBarButtonItem alloc] initWithTitle:@"Custom" style:UIBarButtonItemStylePlain target:self action:@selector(btn_heartClicked)];
    [btn_heart setImage:image];
    [self.navigationItem setRightBarButtonItem:btn_heart];
    
    self.title = @"KOI Fusion";
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    barBtnItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = barBtnItem;
 
    [[AppData sharedInstance] getCurruntLocation];
    
    NSLog(@"%@",[allChoices objectForKey:chosenMainMenu]);
    
    ratingView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    ratingView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    ratingView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    ratingView.rating = 0;
    ratingView.editable = NO;
    ratingView.maxRating = 5;

    
    if (biz != nil) {
        
        [self loadBusinessData:biz];
    }
}

- (void) btn_heartClicked {

    [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",biz.businessID] rating:@"5"];
//    NSLog(@"btn_heartClicked");
}

- (void) backButtonPressed {
    
    NSLog(@"backButtonPressed");
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([AppData sharedInstance].currentLocation != nil) {
        
        self.currentLocation = [AppData sharedInstance].currentLocation;
        
        CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
        NSLog(@"%f",coordinate.latitude);
        NSLog(@"%f",coordinate.longitude);
    }
}

- (void)viewWillDisappear:(BOOL)animated{
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
    
    if([[[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row] isEqualToString:@"Order Food"]){
        cell.FoodView.hidden = false;
    }else{
        cell.FoodView.hidden = true;
    }
    cell.lbl_profileName.text = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
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
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row]];
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

   // return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    ServicesForBusinessTableViewController *serviceViewContoller = [[ServicesForBusinessTableViewController alloc] initWithNibName:@"ServicesForBusinessTableViewController" bundle:nil];
//    [self.navigationController pushViewController:serviceViewContoller animated:YES];
    
//    MenuItemViewController *serviceViewContoller = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
//    [self.navigationController pushViewController:serviceViewContoller animated:YES];
    
    NSString *tmpStr = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    [self loadNextViewController:tmpStr forBusiness:self.biz inNavigationController:self.navigationController];

}

- (void)loadNextViewController:(NSString *)service forBusiness:(Business *)function_biz inNavigationController:(UINavigationController *)navigationController {
    NSString* tmpStr = [service lowercaseString];
    NSUInteger whileIndex = 0;
    
    while (whileIndex < 8) {
        if (whileIndex == 0) {
            if ([tmpStr isEqualToString:@"order food"]) {
                MenuItemViewController *menuViewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemViewController" bundle:nil];
                [navigationController pushViewController:menuViewController animated:YES];
                break;
            }
        }
        
        if (whileIndex == 1) {
            if ([tmpStr rangeOfString:@"service"].location != NSNotFound) {
                AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:orderViewController animated:YES];
            }
        }
        
        if (whileIndex == 2) {
            if ( ([tmpStr rangeOfString:@"bill"].location != NSNotFound) ||
                ([tmpStr rangeOfString:@"pay"].location != NSNotFound) ) {
                BillViewController *billViewController = [[BillViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:billViewController animated:YES];
            }
        }
        
        if (whileIndex == 3) {
            if ([tmpStr rangeOfString:@"map"].location != NSNotFound) {
                StoreMapViewController *storeMapViewController = [[StoreMapViewController alloc] initWithNibName:nil bundle:nil];
                storeMapViewController.title = [NSString stringWithFormat:@"Map of %@",function_biz.shortBusinessName];
                [navigationController pushViewController:storeMapViewController animated:YES];
            }
        }
        
        if (whileIndex == 4) {
            
            if (([tmpStr rangeOfString:@"items"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"have"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"show"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"food"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"item"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"product"].location != NSNotFound)
                )
            {
//                if (function_biz.isProductListLoaded) {
//                    [self displayProduct];
//                }
//                else {
//                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                    timerToLoadProducts = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayProduct) userInfo:nil repeats:YES];
//                }
            }
        }
        
        if (whileIndex == 5) {
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
        
        if (whileIndex == 6) {
            if ([tmpStr rangeOfString:@"event"].location != NSNotFound) {
                EventsTableViewController *eventTableViewController = [[EventsTableViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:eventTableViewController animated:YES];
                
            }
            
        }
        if (whileIndex == 7) {
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
    [self getDistanceFromLocation:businessDataObj.address];

    self.lbl_Title.text = biz.address;
    self.lbl_SubTitle.text = biz.customerProfileName;
    self.lbl_StateAndDist.text = [NSString stringWithFormat:@"%@  %.1f m",biz.state,[[AppData sharedInstance]getDistance:biz.lat longitude:biz.lng]];

    BgPictureArray = [[biz.picturesString componentsSeparatedByCharactersInSet:
                                      [NSCharacterSet characterSetWithCharactersInString:@", "]] mutableCopy];
    [BgPictureArray removeObject:@""];

    if([[APIUtility sharedInstance]isOpenBussiness:biz.opening_time CloseTime:biz.closing_time]){
        self.lbl_OpenNow.text = @"OPEN NOW";
        self.lbl_OpenNow.textColor = [UIColor greenColor];
    }else{
        self.lbl_OpenNow.text = @"CLOSE";
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


@end
