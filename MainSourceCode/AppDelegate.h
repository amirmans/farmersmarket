//
//  AppDelegate.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 2011-08-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewNotificationProtocol.h"
#import "ServerInteractionManager.h"
#import "CurrentBusiness.h"
#import "MenuItemViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, PostProcesses, UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tt_tabBarController;
    IBOutlet UINavigationController *enterBusinessNav;
    __weak id <NewNotificationProtocol> notificationDelegate; // default is strong which conflicts with the property
    
    NSString *lat;
    NSString *lng;

}

+ (AppDelegate *) sharedInstance;

@property(strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) id <NewNotificationProtocol> notificationDelegate;
@property(atomic, retain) UITabBarController *tt_tabBarController;
@property(atomic, retain) UINavigationController *enterBusinessNav;
@property(nonatomic,retain) CLLocationManager *locationManager;

//CoreData..

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)managedObjectContext;

-(NSArray *)getRecord;// create this mathod for fetch data from any class...


@end
