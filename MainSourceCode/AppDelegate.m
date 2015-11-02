
//
//  AppDelegate.m
//  TapTalk
//
//  Created by Amir on 10/26/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

#import "AppDelegate.h"

#import "ListofBusinesses.h"
#import "BusinessListViewController.h"

#import "ChatMessagesViewController.h"
#import "BusinessNotificationTableViewController.h"
#import "ConsumerProfileViewController.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "LoginViewController.h"
#import "UtilityConsumerProfile.h"



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


@synthesize enterBusinessNav, tt_tabBarController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Override point for customization after application launch
    NSBundle *bundle = [NSBundle mainBundle];
    
    ListofBusinesses *businessArrays = [ListofBusinesses sharedListofBusinesses];
    [businessArrays startGettingListofAllBusinesses];
    
    
    BusinessListViewController *listTableView = [[BusinessListViewController alloc] initWithNibName:nil bundle:nil];
    [listTableView.listBusinessesActivityIndicator hidesWhenStopped];
    [listTableView.listBusinessesActivityIndicator startAnimating];
    
    NSString *imagePath = [bundle pathForResource:@"EnterBusiness" ofType:@"png"];
    UIImage *locationImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *locationTabBar = [[UITabBarItem alloc] initWithTitle:@"Where?" image:locationImage tag:0];
    listTableView.tabBarItem = locationTabBar;
    enterBusinessNav = [[UINavigationController alloc] initWithRootViewController:listTableView];
    listTableView = nil;
    
    // messages from others
    imagePath = [bundle pathForResource:@"Messages" ofType:@"png"];
    UIImage *messagesImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *chatTabBar = [[UITabBarItem alloc] initWithTitle:@"Messages" image:messagesImage tag:1];
    ChatMessagesViewController *chatViewContoller = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
    chatViewContoller.tabBarItem = chatTabBar;
    UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatViewContoller];

    //consumer profile tab
    imagePath = [bundle pathForResource:@"ProfileTabBarIcon" ofType:@"png"];
    UIImage *profileTabBarImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *consumerProfileTabBar = [[UITabBarItem alloc] initWithTitle:@"Profile" image:profileTabBarImage tag:2];
    ConsumerProfileViewController *consumerProfileViewController = [[ConsumerProfileViewController alloc] initWithNibName:nil bundle:nil];
    consumerProfileViewController.tabBarItem = consumerProfileTabBar;
    profileTabBarImage = nil;

    // notifications from businesses
    imagePath = [bundle pathForResource:@"Notifications" ofType:@"png"];
    UIImage *notificationImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    notificationsTabBar = [[UITabBarItem alloc] initWithTitle:@"Notifications" image:notificationImage tag:3];

    notificationController = [[BusinessNotificationTableViewController alloc] initWithNibName:nil bundle:nil];
    notificationController.tabBarItem = notificationsTabBar;
    UINavigationController *notificationNav = [[UINavigationController alloc] initWithRootViewController:notificationController];
    
    // setup main window with the tabbarcontroller
    self.tt_tabBarController = [[UITabBarController alloc] init];
    self.tt_tabBarController.viewControllers = [NSArray arrayWithObjects:enterBusinessNav, chatNav, consumerProfileViewController, notificationNav, nil];

    
    // Override point for customization after application launch.
//    UIImage *navBackgroundImage = [UIImage imageNamed:@"navigation_background.png"];
//    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor,
//                                                           [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
//                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
//                                                           UITextAttributeTextShadowOffset,
//                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0f], UITextAttributeFont, nil]];
//
//    UIImage *backBarBackgroundImage = [UIImage imageNamed:@"Navigation_button.png"]; //] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//    [[UIBarButtonItem appearance] setBackgroundImage:backBarBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setTitleTextAttributes: [
//                                                           NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1.0],
//                                                           UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
//                                                           UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
//                                                           UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Verdana" size:16.0f],
//                                                           UITextAttributeFont, nil] forState:UIControlStateNormal];

    tt_tabBarController.delegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tt_tabBarController;
    [self.window makeKeyAndVisible];
    
    locationImage = nil;
    profileTabBarImage = nil;
    notificationImage = nil;
    messagesImage = nil;
    
    #ifdef __IPHONE_8_0
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIUserNotificationType notifictionTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSetting = [UIUserNotificationSettings settingsForTypes:notifictionTypes categories:nil];
     
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSetting];

    #else

    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
            (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    #endif
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
    NSLog(@"All contents of NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
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

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    BOOL returnVal = TRUE;
    // Check to see if Chat tabbar is selected
    if (tabBarController.tabBar.selectedItem.tag == 1) {
        returnVal = FALSE;
        if ([DataModel sharedDataModelManager].chatSystemURL == nil) {
//            [UIAlertController alertControllerWithTitle:nil message:@"Please enter a business first." preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertController * alert=   [UIAlertController
//                                          alertControllerWithTitle:@""
//                                          message:@"Please enter a business first."
//                                          preferredStyle:UIAlertControllerStyleAlert];
//            
//            [viewController presentViewController:alert animated:YES completion:nil];
            
            
//            
//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//                                                                           message:@"Please enter a business first."
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                  handler:^(UIAlertAction * action) {}];
//            
//            [alert addAction:defaultAction];
//            [[tabBarController.viewControllers objectAtIndex:1] presentViewController:alert animated:YES completion:nil];
            [UIAlertController showErrorAlert:@"Please enter a business first."];
            
            
            
            
            
            
            
            
//            [UIAlertView showErrorAlert:@"Please enter a business first"];
        }
        else if ([DataModel sharedDataModelManager].nickname.length < 1) {
            [UIAlertController showErrorAlert:@"You don't have a nickname yet.  Please go to the profile page and get one."];
        }
        else if (![UtilityConsumerProfile canUserChat]) {
            [UIAlertController alertControllerWithTitle:nil message:@"You are NOT registered to particate in this chat.  Please ask the manager to add you." preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            
//            [UIAlertView showErrorAlert:@"You are NOT registered to particate in this chat.  Please ask the manager to add you."];
        }
        else {
            if (![[DataModel sharedDataModelManager] joinedChat]) {
                // show the user that are about to connect to a new business chatroom
                [DataModel sharedDataModelManager].shouldDownloadChatMessages = TRUE;
                LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
                loginController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
                
                [viewController presentViewController:loginController animated:YES completion:nil];
                loginController = nil;
            }
            
            UINavigationController *nav = [tabBarController.viewControllers objectAtIndex:1];
            [nav popToRootViewControllerAnimated:YES];
            returnVal = TRUE;
        }
    }

    return returnVal;
}



#pragma mark - Core Data stack

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
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TapTalk" withExtension:@"momd"];
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

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TapTalk.sqlite"];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Methods for messages and notification stuff
- (void)doUpdateForRemoteNotification:(NSDictionary *)userInfo updateUI:(BOOL)updateUI {
    
    [self getReadyForNotification];
    ((UINavigationController *)[self.tt_tabBarController.viewControllers objectAtIndex:3]).tabBarItem.badgeValue = @"New";
    notificationsTabBar.badgeValue = @"New"; // stopped working
    // Add the Message to the data model to be inserted to the UINotificationsViewtable later.
    [[DataModel sharedDataModelManager] addNotification:userInfo];
    
    // At this point, the notification is recieved when the application is running.  So, lets update
    // the notification table with the new entry
	if (updateUI)
        [notificationDelegate updateUIWithNewNotification];

}

- (void) postProcessForSuccess:(long)givenUserID
{
    [DataModel sharedDataModelManager].userID = givenUserID;
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
    NSString *oldToken = [[DataModel sharedDataModelManager] deviceToken];
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
//    BOOL justTesting = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
//    UIUserNotificationSettings * notificationTypes = [[UIApplication sharedApplication] currentUserNotificationSettings];
    

    NSLog(@"My token is: %@", newToken);

    // If the token changed and we already sent the "join" request, we should
    // let the server know about the new device token.
    if (![newToken isEqualToString:oldToken]) {
        NSError *error;
        ServerInteractionManager *serverManager =[[ServerInteractionManager alloc] init];
        serverManager.postProcessesDelegate = self;
        
        long uid = [[DataModel sharedDataModelManager] userID];
        
        // a valid uid means we have a registered user, update user info with the
        // new deviceToken.  If not, just save the deviceToken in the default file, for the time
        // user registers.
        if (uid > 0 )
        {
            [serverManager serverUpdateDeviceToken:newToken withUserID:uid WithError:&error];
        }
        
        [[DataModel sharedDataModelManager] setDeviceToken:newToken];
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering to Remote Notification didn't work with error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }

    [self doUpdateForRemoteNotification:userInfo updateUI:YES];
    
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
