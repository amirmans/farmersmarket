//
//  AppDelegate.h
//  meowcialize
//
//  Created by Amir Amirmansoury on 2011-08-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class DataModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tt_tabBarController;
    IBOutlet UINavigationController *enterBusinessNav;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (atomic, retain) UITabBarController *tt_tabBarController;
@property (atomic, retain) UINavigationController *enterBusinessNav;

//@property (atomic, strong) DataModel *dataModel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
