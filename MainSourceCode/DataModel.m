#import "DataModel.h"
#import "TapTalkChatMessage.h"


@implementation DataModel

@synthesize messages;
@synthesize businessMessages;
@synthesize notifications;
@synthesize chatSystemURL;
@synthesize businessName;
@synthesize shortBusinessName;
@synthesize chat_master_uid;
@synthesize ageGroup;
@synthesize password;
@synthesize emailAddress;
@synthesize userID;
@synthesize shouldDownloadChatMessages;
@synthesize qrImageFileName;
@synthesize zipcode;
@synthesize validate_chat;

static DataModel *sharedDataModel = nil;

+ (DataModel *)sharedDataModelManager
{
	@synchronized([DataModel class])
	{
		if (!sharedDataModel)
            return [[self alloc] init];
	}
    
	return sharedDataModel;
}

+ (id)alloc
{
	@synchronized([DataModel class])
	{
		NSAssert(sharedDataModel == nil,
                 @"Attempted to allocate a second instance of a singleton.");
		sharedDataModel = [super alloc];
		return sharedDataModel;
	}
    
	return nil;
}

- (id)init {
    if (self) {
        // Register default values for our settings
//        notifications = [[NSMutableArray alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.notifications = [[defaults objectForKey:@"Notifications"] mutableCopy];
        if (notifications == nil || notifications.count <=0)
        {
            notifications = [[NSMutableArray alloc] init];
        }
        businessMessages = [[NSMutableArray alloc] init];
        //TODO
//        [[NSUserDefaults standardUserDefaults] registerDefaults:@{NicknameKey: @""},
//         @{PasswordKey: @"N/A"},
//         @{JoinedChatKey: [NSNumber numberWithInt:12]},
//         @{DeviceTokenKey:@"walla"},
//         @{@"Notifications": @""}];
        // Load default defaults
// from Internet        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
        validate_chat = FALSE;
    }
    
    return self;
}

- (void)sortNotificationsinReverseChronologicalOrder
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTimeRecieved" ascending:NO];
    
    [notifications sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    descriptor = nil;
}

- (void)setNotifications:(NSMutableArray *)notificationArray
{
    notifications = notificationArray;
}

- (void)addNotification:(NSDictionary *)notificationDataFromServer {
    // Add our own stuff to the notification from the server
    NSMutableDictionary *notificationData = [[NSMutableDictionary alloc]
                                             initWithDictionary:[notificationDataFromServer objectForKey:@"aps"]];
    NSDate *dateAdded = [NSDate date];
    [notificationData setObject:dateAdded forKey:@"dateTimeRecieved"];
    //fetch the icon for the business identified by the given "business ID" from consumerprofile (database on our server)
    
    [self.notifications addObject:notificationData];
}

- (NSMutableArray *)notifications {
    [self sortNotificationsinReverseChronologicalOrder];
    return notifications;
}


- (void)saveNotifications {
    // we cannot put a mutable array in the NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:notifications forKey:@"Notifications"];
    [defaults synchronize];
}

- (void)buildBusinessChatMessages {
    [[DataModel sharedDataModelManager].businessMessages removeAllObjects];
    
    NSDictionary *arrayElement;
    TapTalkChatMessage *chatMessage = [TapTalkChatMessage alloc];
    
    for (arrayElement in [DataModel sharedDataModelManager].messages) {
        chatMessage = [chatMessage initWithMessage:arrayElement];
        if ([chatMessage isSentByBusiness]) {
            [[DataModel sharedDataModelManager].businessMessages addObject:arrayElement];
        }
    }
    chatMessage = nil;
}

- (NSString *)nickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NicknameKey];
}

- (void)setNickname:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:NicknameKey];
}

//????
//- (int)addMessage:(TapTalkChatMessage *)message {
//    [self.messages addObject:message];
//    //	[self saveMessages];
//    return self.messages.count - 1.0;
//}

- (short)ageGroup {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ageGroup"];
}

- (void)setAgeGroup:(short)argAgeGroup {
    [[NSUserDefaults standardUserDefaults] setInteger:argAgeGroup forKey:@"ageGroup"];
}


- (BOOL)joinedChat {
    return [[NSUserDefaults standardUserDefaults] boolForKey:JoinedChatKey];
}

- (void)setJoinedChat:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:JoinedChatKey];
}

- (NSString *)deviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
}

- (void)setDeviceToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}

- (void)setUserID:(long)uid {
    [[NSUserDefaults standardUserDefaults] setInteger:uid forKey:UserIDKey];
}

- (long)userID {
    return [[NSUserDefaults standardUserDefaults] integerForKey:UserIDKey];
}

- (void)setEmailAddress:(NSString *)emailAddr {
    [[NSUserDefaults standardUserDefaults] setObject:emailAddr forKey:EmailAddressKey];
}

- (NSString *)emailAddress {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EmailAddressKey];
}


- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PasswordKey];
}

- (void)setPassword:(NSString *)string {
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:PasswordKey];
}

- (NSString *)zipcode {
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Zipcode"] == nil) {
        return @"";
    }
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Zipcode"];
}

- (void)setZipcode:(NSString *)zip {
    [[NSUserDefaults standardUserDefaults] setObject:zip forKey:@"Zipcode"];
}

@end
