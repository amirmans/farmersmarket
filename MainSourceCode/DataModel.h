@class TapTalkChatMessage;


//
//@interface NotificationData : NSDictionary {
//    NSDictionary *tt_notification;
//    
//    NSString *alertMessage;
//    NSString *businessSendingNotification;
//    NSString *sound;
//    NSString *additionalInformation;  // more information - optional
//    UIImage *notificationIcon;
//    NSString *notificationIconURL;
//    short badge;
//    NSDate *dateAdded;
//    NSDate *dateTappedOn;
//}
//
//- (id)init;
//
//@property(nonatomic, retain) NSString *alertMessage;
//@property(nonatomic, retain) NSString *businessSendingNotification;
//@property(nonatomic, retain) NSString *sound;
//@property(nonatomic, retain) NSString *additionalInformation;
////@property(nonatomic, retain) UIImage *notificationIcon;
//@property(nonatomic, retain) NSString *notificationIconURL;
////@property(atomic) short badge;
//@property(nonatomic, retain) NSDate *dateAdded;
//@property(nonatomic, retain) NSDate *dateTappedOn;
//
//@end
//

// The main data model object
@interface DataModel : NSObject {
    NSMutableArray *notifications;
}

+ (DataModel *)sharedDataModelManager;

//Notification stuff
//- (id)initNotification;
- (void)addNotification:(NSDictionary *)notificationData;
- (void)setNotifications:(NSMutableArray *)notificationArray;
- (void)saveNotifications;
// Get and set the user's nickname.
- (NSString *)nickname;
- (void)setNickname:(NSString *)name;


// Determines whether the user has successfully joined a chat.
- (BOOL)joinedChat;
- (void)setJoinedChat:(BOOL)value;
//Chat Messages
//- (int)addMessage:(TapTalkChatMessage *)message;

// Get and set the device token. We cache the token so we can determine whether
// to send an "update" request to the server.
- (NSString *)deviceToken;- (void)setDeviceToken:(NSString *)token;

- (NSMutableArray *) sortNotificationsinReverseChronologicalOrder : (NSMutableArray *) notificationArray;

@property(nonatomic, assign) long  userID; // determined and given by the server
@property(nonatomic, assign) NSString*  uuid;
@property(nonatomic, retain) NSString *chatSystemURL;
@property(nonatomic, retain) NSString *businessName;
@property(nonatomic, retain) NSString *shortBusinessName;
@property(nonatomic, retain) NSArray *chat_masters;

@property(nonatomic, retain) NSString *password;
@property(atomic, assign) short ageGroup;
@property(nonatomic, retain) NSString *emailAddress;
@property(nonatomic, retain) NSMutableArray *notifications;
@property(nonatomic, retain) NSMutableArray *messages;
@property(nonatomic, retain) NSMutableArray *businessMessages;
@property(atomic, assign) BOOL shouldDownloadChatMessages;
@property(nonatomic, strong) NSString *qrImageFileName;
@property(nonatomic, strong) NSString *zipcode;
@property(atomic, assign) BOOL validate_chat;

- (void)setUserIDWithString:(NSString *)uid;
- (void)setAgeGroupWithString:(NSString *)age;

- (void)buildBusinessChatMessages;


@end

