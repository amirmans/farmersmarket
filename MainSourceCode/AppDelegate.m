//
//  AppDelegate.m
//  TapTalk
//
//  Created by Amir on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import "AppDelegate.h"

#import "MyLocationViewController.h"

#import "ChatMessagesViewController.h"
#import "Notifications.h"
#import "ConsumerProfileViewController.h"
#import "LoginViewController.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


@synthesize enterBusinessNav, tt_tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    // Override point for customization after application launch
    NSBundle *bundle = [NSBundle mainBundle];
    
    //map of businesses around and set it up as the first page
    MyLocationViewController *myLocation = [[MyLocationViewController alloc] initWithNibName:nil bundle:nil];
    NSString *imagePath = [bundle pathForResource: @"EnterBusiness" ofType: @"png"];
    UIImage *locationImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *locationTabBar = [[UITabBarItem alloc] initWithTitle:@"Where?" image:locationImage tag:0];
    myLocation.tabBarItem = locationTabBar;
    enterBusinessNav = [[UINavigationController alloc] initWithRootViewController:myLocation];

    // messages from others
    imagePath = [bundle pathForResource: @"Messages" ofType: @"png"];
    UIImage *messagesImage =  [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *messagesTabBar = [[UITabBarItem alloc] initWithTitle:@"Messages" image:messagesImage tag:1];
    ChatMessagesViewController *openMessages = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
    openMessages.tabBarItem = messagesTabBar;
    
    //consumer profile tab
    imagePath = [bundle pathForResource: @"ProfileTabBarIcon" ofType: @"png"];
    UIImage *profileTabBarImage =  [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *consumerProfileTabBar = [[UITabBarItem alloc] initWithTitle:@"Profile" image:profileTabBarImage tag:2];
    ConsumerProfileViewController *consumerProfileViewController = [[ConsumerProfileViewController alloc]initWithNibName:nil bundle:nil];
    consumerProfileViewController.tabBarItem = consumerProfileTabBar;
    profileTabBarImage = nil;
    
    // notifications from businesses
    imagePath = [bundle pathForResource: @"Notifications" ofType: @"png"];
    UIImage *notificationImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    UITabBarItem *notificationsTabBar = [[UITabBarItem alloc] initWithTitle:@"Notifications" image:notificationImage tag:3];
    Notifications *notificationController = [[Notifications alloc] initWithNibName:nil bundle:nil];
    notificationController.tabBarItem = notificationsTabBar;
    
    // setup main window with the tabbarcontroller
    self.tt_tabBarController = [[UITabBarController alloc] init];
    self.tt_tabBarController.viewControllers = [NSArray arrayWithObjects:enterBusinessNav, openMessages, consumerProfileViewController, notificationController, nil];
    
    tt_tabBarController.delegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tt_tabBarController;
    [self.window makeKeyAndVisible];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
	// Register for sound and alert push notifications.
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
	// Check if the app was launched in response to the user tapping on a
	// push notification. If so, we add the new message to the data model.
	if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
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
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.tabBar.selectedItem.tag == 1)
    {
        if ([DataModel sharedDataModelManager].chatSystemURL == nil)
        {
            [UIAlertView showErrorAlert:@"Please enter a business first"]; 
            return FALSE;
        }
    }
    
    if (tabBarController.tabBar.selectedItem.tag == 1)
    {
        if ([DataModel sharedDataModelManager].nickname == nil)
        {
            [UIAlertView showErrorAlert:@"You need a nickname to chat.  Please go to Profile page to get one"];
            return FALSE;
        }
    }

    return TRUE;
}



#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
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
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TapTalk.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
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
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Methods for messages and notification stuff
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
	// Create a new Message object
	TapTalkChatMessage* message = [[TapTalkChatMessage alloc] init];
	message.dateAdded = [NSDate date];
    
	// The JSON payload is already converted into an NSDictionary for us.
	// We are interested in the contents of the alert message.
	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
	// The server API formatted the alert text as "sender: message", so we
	// split that up into a sender name and the actual message text.
	NSMutableArray* parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
	message.sender = [parts objectAtIndex:0];
	[parts removeObjectAtIndex:0];
	message.textChat = [parts componentsJoinedByString:@": "];
    
	// Add the Message to the data model's list of messages
	[[DataModel sharedDataModelManager] addMessage:message];
    
	// If we are called from didFinishLaunchingWithOptions, we should not
	// tell the ChatViewController's table view to insert the new Message.
	// At that point, the table view isn't loaded yet and it gets confused.
//	if (updateUI)
//		[self.chatViewController didSaveMessage:message atIndex:index];
    
//	[message release];
}


#pragma mark - UIApplicationDelegate for notification

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// We have received a new device token. This method is usually called right
	// away after you've registered for push notifications, but there are no
	// guarantees. It could take up to a few seconds and you should take this
	// into consideration when you design your app. In our case, the user could
	// send a "join" request to the server before we have received the device
	// token. In that case, we silently send an "update" request to the server 
	// API once we receive the token.
    
	NSString* oldToken = [[DataModel sharedDataModelManager] deviceToken];
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", newToken);
    
	[[DataModel sharedDataModelManager] setDeviceToken:newToken];
    
	// If the token changed and we already sent the "join" request, we should
	// let the server know about the new device token.
	if ([[DataModel sharedDataModelManager] joinedChat] && ![newToken isEqualToString:oldToken])
	{
//TODO		[self postUpdateRequest];
	}
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Registering to Remote Notification didn't work");
}

@end
