
//
//  AppDelegate.m
//  TapTalk
//
//  Created by Amir on 10/26/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

@import GoogleMaps;
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"
#import "ListofBusinesses.h"
#import "BusinessListViewController.h"
#import "TPRewardPointController.h"
//#import "ChatMessagesViewController.h"
#import "BusinessNotificationTableViewController.h"
#import "ConsumerProfileViewController.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "AFNetworkActivityIndicatorManager.h"
//#import "LoginViewController.h"
#import "UtilityConsumerProfile.h"
#import "AppData.h"
#import "APIUtility.h"
#import <Stripe/Stripe.h>
//#import "DeliveryViewController.h"
#import "IQKeyboardManager.h"
#import "Business.h"
//#import "HomeViewController.h"
#import "MarketListViewController.h"
#import "ReferralViewController.h"
#import "Corp.h"

@interface AppDelegate () {
    BusinessNotificationTableViewController *notificationController;
    UITabBarItem *notificationsTabBar;
}
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize notificationDelegate;
@synthesize informationDate, viewMode, corpMode, corps, corpIndex, allCorps;

@synthesize enterBusinessNav, tt_tabBarController;

static AppDelegate *sharedObj;
+ (AppDelegate *) sharedInstance
{
    if(sharedObj == nil)
    {
        sharedObj = [[AppDelegate alloc] init];
    }
    return sharedObj;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    corps = [[NSArray  alloc] init];
    corpMode = false;
    viewMode = false;

    informationDate = [NSDate date];

    [AppData sharedInstance].Current_Selected_Tab = @"0";
    [AppData sharedInstance].is_Profile_Changed = false;
    [AppData sharedInstance].market_mode = false;
//    [GMSServices provideAPIKey:@"AIzaSyD7WfHjPssiG_nJi5P0rF4GJHUxxrFCono"];
//      [GMSServices provideAPIKey:@"AIzaSyAnP9ELVL1xHQqJGhba_3gH9nWLXV5N5n8"];
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"];
    [GMSServices provideAPIKey:@"AIzaSyAcCD7rG0woreg6af3_AyFsa3V1J1vgK_k"];
//    [Stripe setDefaultPublishableKey:@"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"];

//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _locationManager = [[CLLocationManager alloc] init];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 500; // meters
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];

//    NSLog(@"%@",[DataModel sharedDataModelManager].emailAddress);

//    [[AppData sharedInstance] getCurruntLocation];

//    [GMSServices provideAPIKey:@"AIzaSyBjJcsPVsRERXqA5SKas-nseCmrZaajEeE"];

    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Override point for customization after application launch
//    NSBundle *bundle = [NSBundle mainBundle];

//    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
//    [businessArrays startGettingListofAllBusinesses];

//    BusinessListViewController *listTableView = [[BusinessListViewController alloc] initWithNibName:nil bundle:nil];
     MarketListViewController *listTableView = [[MarketListViewController alloc] init];

//    AddressVC *listTableView = [[AddressVC alloc] initWithNibName:nil bundle:nil];


//    [listTableView.listBusinessesActivityIndicator hidesWhenStopped];
//    [listTableView.listBusinessesActivityIndicator startAnimating];

//    UIImage *locationImage = [UIImage imageNamed:@"ic_biz_partners_normal.png"];
    UIImage *locationImage = [UIImage imageNamed:@"tab_home"];
    UITabBarItem *locationTabBar = [[UITabBarItem alloc] initWithTitle:@"Home" image:locationImage tag:0];
    listTableView.tabBarItem = locationTabBar;
//    locationTabBar.selectedImage = [UIImage imageNamed:@"ic_biz_partners_selected.png"];
    locationTabBar.selectedImage = [UIImage imageNamed:@"tab_home1"];
    enterBusinessNav = [[UINavigationController alloc] initWithRootViewController:listTableView];

//    enterBusinessNav.navigationBar.barTintColor = [UIColor blackColor];
    enterBusinessNav.navigationBar.barTintColor = [UIColor colorWithDisplayP3Red:255.0/255.0 green:112.0/255.0 blue:39.0/255.0 alpha:1.0];
    enterBusinessNav.navigationBar.translucent = true;
    enterBusinessNav.extendedLayoutIncludesOpaqueBars = YES;
    enterBusinessNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};


    // messages from others - chat to be offered in the next release
//    UIImage *messagesImage = [UIImage imageNamed:@"ic_messages_normal.png"];
//    UITabBarItem *chatTabBar = [[UITabBarItem alloc] initWithTitle:@"Messages" image:messagesImage tag:1];
//    ChatMessagesViewController *chatViewContoller = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
//    chatViewContoller.tabBarItem = chatTabBar;
//    chatTabBar.selectedImage = [UIImage  imageNamed:@"ic_messages_selected.png"];
//    UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatViewContoller];

    //consumer profile tab
//    UIImage *profileTabBarImage = [UIImage imageNamed:@"ic_profile_normal.png"];
    UIImage *profileTabBarImage = [UIImage imageNamed:@"tab_profile"];
    UITabBarItem *consumerProfileTabBar = [[UITabBarItem alloc] initWithTitle:@"Profile" image:profileTabBarImage tag:1];
//    consumerProfileTabBar.selectedImage = [UIImage imageNamed:@"ic_profile_selected.png"];
    consumerProfileTabBar.selectedImage = [UIImage imageNamed:@"tab_profile1"];
    ConsumerProfileViewController *consumerProfileViewController = [[ConsumerProfileViewController alloc] init];
    consumerProfileViewController.tabBarItem = consumerProfileTabBar;
    profileTabBarImage = nil;
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:consumerProfileViewController];
//    profileNav.navigationBar.barTintColor = [UIColor blackColor];
    profileNav.navigationBar.barTintColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
    profileNav.navigationBar.translucent = true;
    profileNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};


    // notifications from businesses
//    UIImage *notificationImage = [UIImage imageNamed:@"ic_notifications_normal.png"];
    UIImage *notificationImage = [UIImage imageNamed:@"tab_notification"];
    notificationsTabBar = [[UITabBarItem alloc] initWithTitle:@"Notifications" image:notificationImage tag:2];


//    notificationsTabBar.selectedImage = [UIImage imageNamed:@"ic_notifications_selected.png"];
    notificationsTabBar.selectedImage = [UIImage imageNamed:@"tab_notification1"];
    notificationController = [[BusinessNotificationTableViewController alloc] init];
    notificationController.tabBarItem = notificationsTabBar;
    UINavigationController *notificationNav = [[UINavigationController alloc] initWithRootViewController:notificationController];
//    notificationNav.navigationBar.barTintColor = [UIColor blackColor];
    notificationNav.navigationBar.barTintColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
    notificationNav.navigationBar.translucent = true;
    notificationNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

// referral
    UIImage *referralImage = [UIImage imageNamed:@"tab_referral"];
    ReferralViewController *referralViewController = [[ReferralViewController alloc] init];
    UITabBarItem *referralTabbar = [[UITabBarItem alloc] initWithTitle:@"Refer" image:referralImage tag:3];
    //    payTabBar.selectedImage = [UIImage imageNamed:@"ic_pay_selected.png"];
//    referralTabbar.selectedImage = [UIImage imageNamed:@"tab_referral"];
    //    [PointsTabbar setBadgeValue:@"1"];
    //    PointsTabbar.
    referralViewController.tabBarItem = referralTabbar;

    UINavigationController *refrerralNav = [[UINavigationController alloc] initWithRootViewController:referralViewController];
    refrerralNav.navigationBar.barTintColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
    refrerralNav.navigationBar.translucent = true;
    refrerralNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    // points
    UIImage *pointImage = [UIImage imageNamed:@"tab_points"];
    TPRewardPointController *pointsViewController = [[TPRewardPointController alloc] init];
    UITabBarItem *PointsTabbar = [[UITabBarItem alloc] initWithTitle:@"Points" image:pointImage tag:4];
//    payTabBar.selectedImage = [UIImage imageNamed:@"ic_pay_selected.png"];
    PointsTabbar.selectedImage = [UIImage imageNamed:@"tab_points1"];
//    [PointsTabbar setBadgeValue:@"1"];
//    PointsTabbar.
    pointsViewController.tabBarItem = PointsTabbar;

    // setup main window with the tabbarcontroller
    self.tt_tabBarController = [[UITabBarController alloc] init];

//    self.tt_tabBarController.viewControllers = [NSArray arrayWithObjects:enterBusinessNav, chatNav, consumerProfileViewController, notificationNav, pointsViewController, nil];
    self.tt_tabBarController.viewControllers = [[NSArray alloc] initWithObjects:enterBusinessNav, /*chatNav,*/ profileNav, pointsViewController, /*notificationNav, */refrerralNav, nil];

//    self.tt_tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.tt_tabBarController.tabBar.tintColor = [UIColor colorWithDisplayP3Red:249.0/255.0 green:122.0/255.0 blue:18.0/255.0 alpha:1.0];
//    self.tt_tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bgTabBar.png"];
    self.tt_tabBarController.tabBar.backgroundColor = [UIColor whiteColor];

    tt_tabBarController.delegate = self;
    pointsViewController = nil;
    notificationController = nil;
    consumerProfileViewController = nil;
    listTableView = nil;
//    pointsViewController = nil;


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tt_tabBarController;
    [self.window makeKeyAndVisible];

//    locationImage = nil;
//    profileTabBarImage = nil;
//    notificationImage = nil;
//    referralImage = nil;
    /*messagesImage = nil;  chat to be offered in the next release */
    [[UIApplication sharedApplication]
     setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Error in request authorization!");
//                                  [self showAlert];
                              }
                          }];

//    #ifdef __IPHONE_8_0
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIUserNotificationType notifictionTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSetting = [UIUserNotificationSettings settingsForTypes:notifictionTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSetting];

//    #else
//
//    // Let the device know we want to receive push notifications
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//            (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    #endif
    // Check if the app was launched in response to the user tapping on a
    // push notification.
    if (launchOptions != nil) {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil) {
            NSLog(@"Launched from push notification: %@", dictionary);
            [self doUpdateForRemoteNotification:dictionary updateUI:YES];
        }
    }
    return YES;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}
//
//-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
//{
////    NSString *myString = [NSString stringWithFormat:[CLLocationManager locationServicesEnabled] ? @"YES" : @"NO"];
////    NSLog(@"%@",myString);
////    NSLog(@"LocationManagerStatus %i",[CLLocationManager authorizationStatus]);
//
//}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSString *myString = [NSString stringWithFormat:[CLLocationManager locationServicesEnabled] ? @"YES" : @"NO"];
    NSLog(@"%@",myString);
    NSLog(@"LocationManagerStatus %i",[CLLocationManager authorizationStatus]);

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
//    CLLocation *oldLocation;
//    if (locations.count > 1) {
//        oldLocation = locations[locations.count - 2];
//    }

    // saving new location in nsuserdefaults
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [defaults setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [defaults synchronize];

//    [manager stopUpdatingLocation];
}

//- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    UIApplicationState state = [application applicationState];
//    // user tapped notification while app was in background
//    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
//        // go to screen relevant to Notification content
//        [self doUpdateForRemoteNotification:userInfo updateUI:TRUE];
//    } else {
//            // App is in UIApplicationStateActive (running in foreground)
//            // perhaps show an UIAlertView
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[DataModel sharedDataModelManager] saveNotifications];
//    NSLog(@"All contents of NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {

    NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(NSArray *)getRecord
{
    NSFetchRequest *fetchreq = [NSFetchRequest fetchRequestWithEntityName:@"MyCartItem"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"productname" ascending:YES selector:@selector(localizedStandardCompare:)];

    [fetchreq setSortDescriptors:@[sortDescriptor]];

//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyCartItem" inManagedObjectContext:self.managedObjectContext];

//    [fetchreq setEntity:entity];

    NSError *err;

    NSArray *fetcheRecord = [self.managedObjectContext executeFetchRequest:fetchreq error:&err];
    return fetcheRecord;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    BOOL returnVal = false;
    NSString *currenttab = [AppData sharedInstance].Current_Selected_Tab;
    BOOL ProfileChanged = [AppData sharedInstance].is_Profile_Changed;


        if([currenttab isEqualToString:@"1"] && ProfileChanged)
        {
            [self showAlert:@"Alert" :@"Unsaved information in the profile.\nPlease use buttons to save or cancel" : 0];

//            UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                            topWindow.rootViewController = [UIViewController new];
//                            topWindow.windowLevel = UIWindowLevelAlert + 1;
//
//                            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Possible unsaved information in the profile page.\nLeave page?" preferredStyle:UIAlertControllerStyleAlert];
//
//                            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                // continue your work
//                                [AppData sharedInstance].is_Profile_Changed = false;
//                                // important to hide the window after work completed.
//                                // this also keeps a reference to the window until the action is invoked.
//                                topWindow.hidden = YES; // if you want to hide the topwindow then use this
//                //                topWindow = nil; // if you want to remove the topwindow then use this
//                            }]];
//                            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                                            // continue your work
//                                            // important to hide the window after work completed.
//                                            // this also keeps a reference to the window until the action is invoked.
//                                topWindow.hidden = YES; // if you want to hide the topwindow then use this
////                                            topWindow = nil; // if you want to remove the topwindow then use this
//                                [self.tt_tabBarController.delegate tabBarController:tabBarController didSelectViewController:viewController];
//
//                            }]];
//
//
//                            [topWindow makeKeyAndVisible];
//                            [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//
//
//







//            [self alertWithResponse:^(BOOL didCancel) {
//                if(didCancel) {
//                    //alert returned Cancel
//
//                } else {
//                    //alert returned OK
//                    [AppData sharedInstance].is_Profile_Changed = false;
//
//                }
//            }];
//






















//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirmation!"
//                                                                           message:@"You have unsaved information in the profile page.\nLeave page?"
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//                [AppData sharedInstance].is_Profile_Changed = false;
////                [self.tabBarController setSelectedIndex:0];
//                return  TRUE;
//
//            }];
//            UIAlertAction *cancelAction = [UIAlertAction
//                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                           style:UIAlertActionStyleCancel
//                                           handler:^(UIAlertAction *action)
//                                           {
//                                               return FALSE;
//                                           }];
//
//            [alert addAction:okAction];
//            [alert addAction:cancelAction];
//            UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//            alertWindow.rootViewController = [[UIViewController alloc] init];
//            alertWindow.windowLevel = UIWindowLevelAlert + 1;
//            [alertWindow makeKeyAndVisible];
//            [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];

        } else if ([currenttab isEqualToString:@"5"])
        {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"You have NOT placed your order yet. Are you sure you want to exit the page?" preferredStyle:  UIAlertControllerStyleAlert];
//            UIAlertAction *defaultAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){}];
//            [alert addAction:defaultAction];
//            [self persentViewController:alert animaited:YES completion:nil];
//
//        }
//        else {
//            returnVal = TRUE;
//        }
            [self showAlert:@"Alert" :@"You have NOT placed your order yet.\nPlease use the back button to get back to where you want.": 0];
        } else {
            returnVal = TRUE;
        }
//    } else if (tabBarController.tabBar.selectedItem.tag == 1){
//        [AppData sharedInstance].Current_Selected_Tab = @"1";
//         returnVal = TRUE;
//
//    } else if (tabBarController.tabBar.selectedItem.tag == 2){
//        if([currenttab isEqualToString:@"1"] && ProfileChanged){
//           [self showAlert:@"Alert" :@"Make sure you save your profile if you have made any changes":2];
//        }else{
//            returnVal = TRUE;
//        }
//
//    } else if (tabBarController.tabBar.selectedItem.tag == 3){
//        if([currenttab isEqualToString:@"1"] && ProfileChanged){
//            [self showAlert:@"Alert" :@"Make sure you save your profile if you have made any changes" : 3];
//        }else{
//             returnVal = TRUE;
//        }
//
//    } else {
//        returnVal = TRUE;
//    }

    return returnVal;
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {

    // The directory the application uses to store the Core Data store file. This code uses a directory named "stu.coredata_model" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {

        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (__managedObjectModel != nil) {

        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TapForAll" withExtension:@"momd"];

    NSLog(@"ManagedObjectModel: %@",modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    // Create the coordinator and store

    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };

    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (__persistentStoreCoordinator == nil)
        return __persistentStoreCoordinator;

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TapForAll.sqlite"];

    NSLog(@"%@",storeURL);

    NSError *error = nil;

    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */

#pragma mark - Methods for messages and notification stuff
- (void)doUpdateForRemoteNotification:(NSDictionary *)userInfo updateUI:(BOOL)updateUI {

    [self getReadyForNotification];
//    ((UINavigationController *)[self.tt_tabBarController.viewControllers objectAtIndex:3]).tabBarItem.badgeValue = @"New";
    notificationsTabBar.badgeValue = @"New"; // stopped working

    // Add the Message to the data model to be inserted to the UINotificationsViewtable later.
    [[DataModel sharedDataModelManager] addNotification:userInfo];

    // At this point, the notification is recieved when the application is running.  So, lets update
    // the notification table with the new entry
    if (updateUI)
        [notificationDelegate updateUIWithNewNotification];
}

- (void) getDefaultCCForConsumer {
    NSString *userID = [NSString stringWithFormat:@"%ld",[DataModel sharedDataModelManager].userID];
    [[APIUtility sharedInstance] getDefaultCCInfo:userID completiedBlock:^(NSDictionary *response) {
        if (response != nil) {
            if ([response valueForKey:@"data"] != nil) {
                NSArray *data = [response valueForKey:@"data"];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults  removeObjectForKey:StripeDefaultCard];
                [defaults synchronize];
                for (NSDictionary *dataDict in data) {
                    NSString *cardName = [dataDict valueForKey:@"name_on_card"];
                    NSString *cardNumber = [dataDict valueForKey:@"cc_no"];
                    NSString *cardExpDate  = [dataDict valueForKey:@"expiration_date"];
                    NSString *cardType  = [dataDict valueForKey:@"card_type"];
                    if (cardType == (id)[NSNull null] || cardType.length == 0 )
                    {
                        cardType = @"";
                    }

                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"yyyy-mm-dd"];
                    NSDate *date = [formatter dateFromString:cardExpDate];
                    NSString *cardCvc = [dataDict valueForKey:@"cvv"];
                    NSString *zipcode = [dataDict valueForKey:@"zip_code"];
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"MM"];
                    NSString *cardExpMonth = [df stringFromDate:date];
                    [df setDateFormat:@"yy"];
                    NSString *cardExpYear = [df stringFromDate:date];

                    NSDictionary *cardDataDict = @{ @"cc_no":cardNumber,@"card_name":cardName,@"expMonth":cardExpMonth,@"expYear":cardExpYear ,@"cvc":cardCvc
                                                    , @"zip_code":zipcode, @"card_type":cardType};
                    [defaults setObject:cardDataDict forKey:StripeDefaultCard];
                    [defaults synchronize];

                    break;
                }
            }
        }
    }];

//    NSLog (@"In appdelegate:getdefaultccforcustomer %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}


- (void)getAllCorps {
    if (corps || [corps count]) {
        [corps removeAllObjects];
    }

    NSDictionary* paramDict = @{@"cmd":@"getAllCorps"};
    [[APIUtility sharedInstance] callServer:paramDict server:BusinessAndProductionInformationServer method:@"GET" completiedBlock:^(NSDictionary *response) {
        if ( ([[response valueForKey:@"status"] integerValue] >= 0) && ([response valueForKey:@"server_error"] == 0) )
        {
            self->allCorps = [[response objectForKey:@"data"] mutableCopy];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GotAllCorps" object:nil];
        }
        else
        {
            NSLog(@"Could not get corps from the server");

        }
    }];
}



- (void)getCorps:(NSString *)workEmail {
    if (corps || [corps count]) {
        [corps removeAllObjects];
    }
    if(workEmail == nil || [workEmail isKindOfClass:[NSNull class]] || workEmail.length==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GotCorps" object:nil];
        return;
    }

    NSRange r1 = [workEmail rangeOfString:@"@"];
    NSRange r2 = [workEmail rangeOfString:@"." options:NSBackwardsSearch];
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    NSString *domain = [workEmail substringWithRange:rSub];
    if (domain == (id)[NSNull null] || domain.length == 0)
    {
        domain = @"";
    }
    NSString *param = @"domain";
    NSDictionary* paramDict = @{@"cmd":@"getCorpsForDomain",param:domain};
    [[APIUtility sharedInstance] callServer:paramDict server:BusinessAndProductionInformationServer method:@"GET" completiedBlock:^(NSDictionary *response) {
        if ( ([[response valueForKey:@"status"] integerValue] >= 0) && ([response valueForKey:@"server_error"] == 0) )
        {
            self->corps = [[response objectForKey:@"data"] mutableCopy];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GotCorps" object:nil];
        }
        else
        {
            NSLog(@"Could not get corps from the server");

        }
    }];
}
//
- (void)postProcessForConsumerProfile:(NSDictionary *)consumerInfo {
    [[DataModel sharedDataModelManager] setUserIDWithString:consumerInfo[@"uid"]];

    if ([DataModel sharedDataModelManager].userID != 0) {
        NSDictionary *param = @{@"cmd":@"get_all_points",@"consumerID":[NSNumber numberWithInteger:[DataModel sharedDataModelManager].userID],@"businessID":@"", @"corp_id":@""};
        [[APIUtility sharedInstance]getRewardpointsForBusiness:param completiedBlock:^(NSDictionary *points_data) {
            int status = [[points_data objectForKey:@"status"] intValue];
            if (status == 1) {
                [RewardDetailsModel sharedInstance].rewardDict = points_data;
                NSString *total_earned_points = [points_data valueForKey:@"total_point"];


                [[self.tt_tabBarController.tabBar.items objectAtIndex:Points_Tabbar_Position]
                    setBadgeValue:total_earned_points];
            }
        }];
    }

    [DataModel sharedDataModelManager].nickname = consumerInfo[@"nickname"];
    [[DataModel sharedDataModelManager] setAgeGroupWithString:consumerInfo[@"age_group"]];
    [DataModel sharedDataModelManager].zipcode = consumerInfo[@"zipcode"];
    [DataModel sharedDataModelManager].sms_no = consumerInfo[@"sms_no"];
    [DataModel sharedDataModelManager].zipcode = consumerInfo[@"zipcode"];
    [DataModel sharedDataModelManager].emailAddress = consumerInfo[@"email1"];
    [DataModel sharedDataModelManager].emailWorkAddress = consumerInfo[EmailWorkAddressKey];

    [self getDefaultCCForConsumer];

//    NSString* workEmail = consumerInfo[EmailWorkAddressKey];
    [self getAllCorps];
//    [self getCorps:workEmail];
}


- (void)saveDeviceTokenAndUUID {

//    NSString *string = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Config"];
//    long longID = [NSBundle mainBundle].bundleIdentifier;

#ifdef DEBUG
    NSLog(@"I am in Debug mode.");
#elif STAGING
    NSLog(@"I am in Staging mode.");
#else
    NSLog(@"PRODUCTION");
#endif




//    NSString *newToken = [deviceToken description];
//    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *newToken = @"";
    //    BOOL justTesting = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    //    UIUserNotificationSettings * notificationTypes = [[UIApplication sharedApplication] currentUserNotificationSettings];

//    NSLog(@"My token is: %@", newToken);

    // If the token changed and we already sent the "join" request, we should
    // let the server know about the new device token.
    //    if (![newToken isEqualToString:oldToken]) {
    NSError *error;
    ServerInteractionManager *serverManager =[[ServerInteractionManager alloc] init];
    serverManager.postProcessesDelegate = self;

    NSString *uuid = [DataModel sharedDataModelManager].uuid;
    NSLog(@"My uuid is: %@", uuid);

    // a valid uid means we have a registered user, update user info with the
    // new deviceToken.  If not, just save the deviceToken in the default file, for the time
    // user registers.
    if (uuid)
    {
        [serverManager serverUpdateDeviceToken:newToken withUuid:uuid WithError:&error];
    }

    [[DataModel sharedDataModelManager] setDeviceToken:newToken];
    serverManager = nil;
    //    }
}

#pragma mark - UIApplicationDelegate for notification

//- (void)registerForRemoteNotificationTypes:(NSUInteger)notificationTypes categories:(NSSet *)categories
//{
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)] && [UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)])
//    {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:notificationTypes categories:categories]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//    else if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotificationTypes:)])
//    {
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
//    }
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // We have received a new device token. This method is usually called right
    // away after you've registered for push notifications, but there are no
    // guarantees. It could take up to a few seconds and you should take this
    // into consideration when you design your app. In our case, the user could
    // send a "join" request to the server before we have received the device
    // token. In that case, we silently send an "update" request to the server
    // API once we receive the token.
//    NSString *oldToken = [[DataModel sharedDataModelManager] deviceToken];
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
//    BOOL justTesting = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
//    UIUserNotificationSettings * notificationTypes = [[UIApplication sharedApplication] currentUserNotificationSettings];

    NSLog(@"My token is: %@", newToken);

    // If the token changed and we already sent the "join" request, we should
    // let the server know about the new device token.
//    if (![newToken isEqualToString:oldToken]) {
        NSError *error;
        ServerInteractionManager *serverManager =[[ServerInteractionManager alloc] init];
        serverManager.postProcessesDelegate = self;

        NSString *uuid = [DataModel sharedDataModelManager].uuid;
        NSLog(@"My uuid is: %@", uuid);

        // a valid uid means we have a registered user, update user info with the
        // new deviceToken.  If not, just save the deviceToken in the default file, for the time
        // user registers.
        if (uuid)
        {
            [serverManager serverUpdateDeviceToken:newToken withUuid:uuid WithError:&error];
        }

        [[DataModel sharedDataModelManager] setDeviceToken:newToken];
        serverManager = nil;

    [Corp sharedCorp].chosenCorp = nil;
//    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering to Remote Notification didn't work with error: %@", error);
    [self saveDeviceTokenAndUUID];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        NSLog(@"%@",[[userInfo objectForKey:key]valueForKey:@"type"]);
    }
    [self doUpdateForRemoteNotification:userInfo updateUI:YES];

    UINavigationController *navController = [self.tt_tabBarController.viewControllers objectAtIndex:0];

    NSDictionary *aps = [userInfo valueForKey:@"aps"];

//    NSNumber *notification_type = [aps objectForKey:@"notification_type"];

//    NSString *notification_type = [aps valueForKey:@"notification_type"];

//    NSInteger notification_type = ;

//    int notification_type = [[aps valueForKey:@"notification_type"] intValue];
    int notification_type = [[aps valueForKey:@"type"] intValue];
//    NSLog(@"%d",notification_type);
    if (notification_type == 1 || notification_type == 2) {

        [self.tt_tabBarController setSelectedIndex:0];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Standard notification arrive" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        [alert addAction:defaultAction];
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else if (notification_type == 3) {
        if ([CurrentBusiness sharedCurrentBusinessManager].business != nil) {
            NSInteger businessID = [[aps valueForKey:@"business_id"] integerValue];
            NSLog(@"%d",[CurrentBusiness sharedCurrentBusinessManager].business.businessID);
            if ([CurrentBusiness sharedCurrentBusinessManager].business.businessID == businessID) {
                [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProducts];
                MenuItemViewController *menuItemVC = [[MenuItemViewController alloc] initWithNibName:nil bundle:nil];
                [navController.visibleViewController.navigationController pushViewController:menuItemVC animated:true];
            }
        }
    }
    else if (notification_type == 4) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                       message:@"You have pending orders to confirm."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else if(notification_type == 5){
        Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
        if ([CurrentBusiness sharedCurrentBusinessManager].business != nil) {
            NSInteger businessID = [[aps valueForKey:@"business_id"] integerValue];
            NSLog(@"%d",[CurrentBusiness sharedCurrentBusinessManager].business.businessID);
            if ([CurrentBusiness sharedCurrentBusinessManager].business.businessID == businessID) {
                [[RewardDetailsModel sharedInstance] getRewardData:biz completiedBlock:^(NSDictionary *response) {
                    if (1) {
                        if(response != nil) {
                            NSDictionary *reward = response;
                            NSLog(@"%@",reward);
                            NSString *total_available_points = [[[reward valueForKey:@"data"] valueForKey:@"total_available_points"] stringValue];

                            [[self.tt_tabBarController.tabBar.items objectAtIndex:Points_Tabbar_Position] setBadgeValue:total_available_points];
                        }
                    }
                }];
            }
        }
    }

//    Business *biz = [Business new];
//    biz.businessID = [[aps valueForKey:@"business_id"] integerValue];
//    [CurrentBusiness sharedCurrentBusinessManager].business = biz;
//    NSString *businessID = [NSString stringWithFormat:@"%d",[[aps valueForKey:@"business_id"] integerValue]] ;
//    [biz startLoadingBusinessProductCategoriesAndProductsWithBusincessID:businessID];
//    MenuItemViewController *menuItemVC = [[MenuItemViewController alloc] initWithNibName:nil bundle:nil];
//    [navController.visibleViewController.navigationController pushViewController:menuItemVC animated:true];


//    if ([type isEqualToString:@"6"]) {
//        NSString *businessID = [type valueForKey:@"business_id"];
//        [[CurrentBusiness sharedCurrentBusinessManager].business startLoadingBusinessProductCategoriesAndProductsWithBusincessID:businessID];
//        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
//        MenuItemViewController *menuItemVC = [[MenuItemViewController alloc] initWithNibName:nil bundle:nil];
//        [navController.visibleViewController.navigationController pushViewController:menuItemVC animated:true];
//    }
}

- (void)alertWithResponse:(void (^)(BOOL didCancel))response {
                UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                topWindow.rootViewController = [UIViewController new];
                topWindow.windowLevel = UIWindowLevelAlert + 1;

                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Possible unsaved information in the profile page.\nLeave page?" preferredStyle:UIAlertControllerStyleAlert];

                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // continue your work
                    [AppData sharedInstance].is_Profile_Changed = false;
                    // important to hide the window after work completed.
                    // this also keeps a reference to the window until the action is invoked.
                    topWindow.hidden = YES; // if you want to hide the topwindow then use this
    //                topWindow = nil; // if you want to remove the topwindow then use this
//                    returnVal= true;
    //                return false;
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                // continue your work
//                    returnVal = false;
                                // important to hide the window after work completed.
                                // this also keeps a reference to the window until the action is invoked.
                    topWindow.hidden = YES; // if you want to hide the topwindow then use this
                //                topWindow = nil; // if you want to remove the topwindow then use this

                }]];


                [topWindow makeKeyAndVisible];
                [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)Title :(NSString *)Message :(int)CurrentTab{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Title message:Message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//
//
//                                                              [alert dismissViewControllerAnimated:YES completion:nil];
//                                                          }];
//    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              self.tt_tabBarController.selectedIndex = CurrentTab;
//                                                              [AppData sharedInstance].is_Profile_Changed = FALSE;
//                                                              [alert dismissViewControllerAnimated:YES completion:nil];
//                                                          }];
//    [alert addAction:noAction];
//    [alert addAction:yesAction];
//    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    alertWindow.rootViewController = [[UIViewController alloc] init];
//    alertWindow.windowLevel = UIWindowLevelAlert + 1;
//    [alertWindow makeKeyAndVisible];
//    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];


    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;

//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"APNS" message:@"received Notification" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // continue your work

        // important to hide the window after work completed.
        // this also keeps a reference to the window until the action is invoked.
        topWindow.hidden = YES; // if you want to hide the topwindow then use this
//        topWindow = nil; // if you want to remove the topwindow then use this
    }]];

    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];


}


#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // user has allowed receiving user notifications of the following types
    UIUserNotificationType allowedTypes = [notificationSettings types];
    NSInteger intAllowedTypes = [[NSNumber numberWithInteger:(NSInteger)allowedTypes] intValue];
    NSLog(@"in didRegisterUserNotificationSettings - allowedTypes is : %li", (long)intAllowedTypes);
}
#endif

- (void)getReadyForNotification {
    #ifdef __IPHONE_8_0
    // check to make sure we still need to show notification
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    NSLog(@"in getReadyForNotification - current Settings is : %@", currentSettings);
//    [self checkSettings:currentSettings];
    #endif
}

@end
