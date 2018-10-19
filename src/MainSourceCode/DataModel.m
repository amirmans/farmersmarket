#import "DataModel.h"
#import "APIUtility.h"
//#import "TapTalkChatMessage.h"
#import "SAMKeychain.h"


@implementation DataModel

@synthesize messages;
@synthesize businessMessages;
@synthesize notifications;
@synthesize chatSystemURL;
@synthesize businessName;
@synthesize shortBusinessName;
@synthesize chat_masters;
@synthesize ageGroup;
@synthesize password;
@synthesize emailAddress;
@synthesize emailWorkAddress;
@synthesize shouldDownloadChatMessages;
@synthesize qrImageFileName;
@synthesize zipcode;
@synthesize sms_no;
@synthesize validate_chat;
@synthesize uuid;
@synthesize userID;

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
        userID = 0;
        uuid = nil;
        ageGroup = 0;
        emailAddress = @"";
        emailWorkAddress = @"";
        password = @"";
        qrImageFileName = @"";
        zipcode = @"";
        sms_no = @"";
    }
    
    return self;
}

- (void)sortNotificationsinReverseChronologicalOrder
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTimeRecieved" ascending:NO];
    
    [notifications sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    descriptor = nil;
}

- (NSMutableArray *) sortNotificationsinReverseChronologicalOrder : (NSMutableArray *) notificationArray {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time_sent" ascending:NO];
    
    [notificationArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    descriptor = nil;
    
    return notificationArray;
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
    
//    NSMutableDictionary *arrayElement;
//    TapTalkChatMessage *chatMessage = [TapTalkChatMessage alloc];
//    
//    
//    for (int i = 0; i < [DataModel sharedDataModelManager].messages.count; i++) {
//        arrayElement = [[[DataModel sharedDataModelManager].messages objectAtIndex:i] mutableCopy];
//        
//        chatMessage = [chatMessage initWithMessage:arrayElement];
//        NSString *bizNameForChatMessage = [chatMessage businessNameIfMessageSentByBusiness];
//        if ([bizNameForChatMessage length] > 0 ) {
//            [arrayElement setObject:bizNameForChatMessage forKey:@"business_name"];
//            [[DataModel sharedDataModelManager].businessMessages addObject:arrayElement];
//        }
//    }
    
//    for (arrayElement in [DataModel sharedDataModelManager].messages) {
//        chatMessage = [chatMessage initWithMessage:arrayElement];
//        NSString *bizNameForChatMessage = [chatMessage businessNameIfMessageSentByBusiness];
//        if ([bizNameForChatMessage length] > 0 ) {
//            [arrayElement setObject:bizNameForChatMessage forKey:@"business_name"];
//            [[DataModel sharedDataModelManager].businessMessages addObject:arrayElement];
//        }
//    }
//    chatMessage = nil;
}

- (NSString *)nickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NicknameKey];
}

- (void)setNickname:(NSString *)name {
    if (name == (id)[NSNull null] || name.length == 0 )
    {
        name = @"";
    }

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

- (void)setAgeGroupWithString:(NSString *)age {
    if (age == (id)[NSNull null] || age.length == 0 )
    {
        age = @"0";
    }
    
    ageGroup = [age intValue];
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
    if (token == (id)[NSNull null] || token.length == 0 )
    {
        token = @"";
    }

    [[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}

//________
- (NSString *)uuid {
    if (uuid) {
        return uuid;
    }
    NSString *tempuuid;

    tempuuid = [SAMKeychain passwordForService:@"TapIn_uuid" account:@"TapForAll"];
    if (tempuuid == nil) {
        tempuuid = [[NSUUID UUID] UUIDString];
        [self setUuid:tempuuid];
    }
    
    return (tempuuid);
}


- (void)setUuid:(NSString *)tempuuid {
    if ([SAMKeychain setPassword:tempuuid forService:@"TapIn_uuid" account:@"TapForAll"]) {
 //       [[NSUserDefaults standardUserDefaults] setObject:tempuuid forKey:UserIDKey];
        self.uuid = tempuuid;
    }
}

- (void)setUserID:(long)uid {

    userID = uid;
}


- (void)setUserIDWithString:(NSString *)uid {
    if (uid == (id)[NSNull null] || uid.length == 0 )
    {
        uid = @"0";
    }
    
    userID = [uid intValue];
}

- (long)userID {
    return userID;
}

//_________

- (void)setEmailAddress:(NSString *)emailAddr {
    if (emailAddr == (id)[NSNull null] || emailAddr.length == 0 )
    {
        emailAddr = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:emailAddr forKey:EmailAddressKey];
}

- (NSString *)emailAddress {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EmailAddressKey];
}

- (void)setEmailWorkAddress:(NSString *)emailWorkAddr {
    if (emailWorkAddr == nil || emailWorkAddr == (id)[NSNull null] || emailWorkAddr.length == 0)
    {
        emailWorkAddr = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:emailWorkAddr forKey:EmailWorkAddressKey];
}

- (NSString *)emailWorkAddress {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EmailWorkAddressKey];
}

- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PasswordKey];
}

- (void)setPassword:(NSString *)string {

    if (string == (id)[NSNull null] || string.length == 0 )
    {
        string = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:PasswordKey];
}

- (NSString *)zipcode {
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Zipcode"] == nil) {
        return @"";
    }
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Zipcode"];
}

- (NSString *)sms_no {
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"SMS_No"] == nil) {
        return @"";
    }
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SMS_No"];
}

- (void)setZipcode:(NSString *)zip {
    
    if (zip == (id)[NSNull null])
    {
        zip = @"";
    }
    if (zip == nil) {
        zip = @"";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:zip forKey:@"Zipcode"];
}

- (void)setSms_no:(NSString *)sms {
    
    if (sms == (id)[NSNull null])
    {
        sms = @"";
    }
    if (sms == nil) {
        sms = @"";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:sms forKey:@"SMS_No"];
}
//- (void)setChat_masters:(NSArray *)ids {
//    chat_masters = ids;
//}
//
//- (NSArray *)chat_masters {
//    return chat_masters;
//}
//
//- (NSString *)businessNameForChatMasterId:(NSInteger)businessID {
//    //TODO
//    return @"";
//}

@end
