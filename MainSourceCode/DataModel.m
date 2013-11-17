#import "DataModel.h"
#import "TapTalkChatMessage.h"


@implementation DataModel

@synthesize messages;
@synthesize chatSystemURL;
@synthesize businessName;
@synthesize ageGroup;
@synthesize password;
@synthesize emailAddress;
@synthesize userID;

static DataModel *sharedDataModel = nil;

+ (DataModel *)sharedDataModelManager {
    if (sharedDataModel == nil) {
        sharedDataModel = [[super allocWithZone:NULL] init];
    }

    return sharedDataModel;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedDataModelManager];
}

- (id)init {
    @synchronized ([DataModel class]) {
        if (self == nil) {
            self = [super init];
            if (self) {
                // Register default values for our settings
                [[NSUserDefaults standardUserDefaults] registerDefaults:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                                @"", NicknameKey,
                                @"", PasswordKey,
                                [NSNumber numberWithInt:0], JoinedChatKey,
                                @"0", DeviceTokenKey,
                                nil]];
            }
        }

        return self;
    }
}


// Returns the path to the Messages.plist file in the app's Documents directory
//- (NSString*)messagesPath
//{
//    NSString *messageFilePath;
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                              NSUserDomainMask, YES) objectAtIndex:0];
//    messageFilePath = [rootPath stringByAppendingPathComponent:@"Messages.plist"];
////    if (![[NSFileManager defaultManager] fileExistsAtPath:messageFilePath]) {
////        messageFilePath = [[NSBundle mainBundle] pathForResource:@"Messages" ofType:@"plist"];
////    }
//    
//    return messageFilePath;
//}


- (void)saveMessages {
//	NSMutableData* data = [[NSMutableData alloc] init];
//	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//	[archiver encodeObject:self.messages forKey:@"Messages"];
//	[archiver finishEncoding];
//    
//    NSError* error;
////TODO	[data writeToFile:[self messagesPath] options:NSDataWritingAtomic error:&error];
//    if(error != nil)
//        NSLog(@"write error %@", error);
//    archiver = nil;
//    data = nil;    
}

- (int)addMessage:(TapTalkChatMessage *)message {
    [self.messages addObject:message];
//	[self saveMessages];
    return self.messages.count - 1;
}

- (NSString *)nickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NicknameKey];
}

- (void)setNickname:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:NicknameKey];
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

- (void)setUserID:(int)uid {
//    UIDevice* device = [UIDevice currentDevice];
//	return [device.uniqueIdentifier stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //TODO
    [[NSUserDefaults standardUserDefaults] setInteger:uid forKey:UserIDKey];
}

- (int)userID {
    return [[NSUserDefaults standardUserDefaults] integerForKey:UserIDKey];
}

- (void)setEmailAddress:(NSString *)emailAddr {
    [[NSUserDefaults standardUserDefaults] setObject:emailAddr forKey:EmailAddressKey];
}


- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PasswordKey];
}

- (void)setPassword:(NSString *)string {
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:PasswordKey];
}

- (BOOL)businessAllowedToSendNotification:(NSString *)businessName {
    
    //TODO
    return FALSE;
}


@end
