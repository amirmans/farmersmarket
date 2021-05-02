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


@interface AppDelegate : UIResponder <UIApplicationDelegate,/*CLLocationManagerDelegate,*/ UITabBarControllerDelegate, UIActionSheetDelegate, PostProcesses, UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tt_tabBarController;
    IBOutlet UINavigationController *enterBusinessNav;
    __strong id <NewNotificationProtocol> notificationDelegate; // default is strong which conflicts with the property

    NSDate* batchInformationDate;

    NSString *lat;
    NSString *lng;

}

+ (AppDelegate *) sharedInstance;

@property(strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) id <NewNotificationProtocol> notificationDelegate;
@property(atomic, retain) UITabBarController *tt_tabBarController;
@property(atomic, retain) UINavigationController *enterBusinessNav;
@property(nonatomic,retain) CLLocationManager *locationManager;
@property(nonatomic, strong) NSDate* informationDate;  //keeps track of date and time our information has been retrieved

//CoreData..

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (atomic, assign) BOOL corpMode;
@property (atomic, assign) BOOL viewMode;
@property (nonatomic, strong) NSMutableArray *corps;
@property (nonatomic, strong) NSArray *allCorps;
@property (atomic, assign) short corpIndex;
@property (atomic, assign) short pd_locations_id;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)managedObjectContext;

-(NSArray *)getRecord;// create this mathod for fetch data from any class...
- (void)saveDeviceTokenAndUUID;
- (void)getCorps:(NSString *)workEmail;
- (void)getAllCorps;


@end
