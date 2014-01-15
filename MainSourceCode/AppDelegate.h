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


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, PostProcesses> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tt_tabBarController;
    IBOutlet UINavigationController *enterBusinessNav;
    __weak id <NewNotificationProtocol> notificationDelegate; // default is strong which conflicts with the property
}

@property(strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) id <NewNotificationProtocol> notificationDelegate;

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(atomic, retain) UITabBarController *tt_tabBarController;
@property(atomic, retain) UINavigationController *enterBusinessNav;


- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end
