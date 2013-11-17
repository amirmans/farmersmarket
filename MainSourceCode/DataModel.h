@class TapTalkChatMessage;

// The main data model object
@interface DataModel : NSObject {

}

+ (DataModel *)sharedDataModelManager;

// The complete history of messages this user has sent and received, in
// chronological order (oldest first).
@property(nonatomic, retain) NSMutableArray *messages;

// Loads the list of messages from a file.
//- (void)loadMessages;

// Saves the list of messages to a file.
- (void)saveMessages;

// Adds a message that the user composed himself or that we received through
// a push notification. Returns the index of the new message in the list of
// messages.
- (int)addMessage:(TapTalkChatMessage *)message;

// Get and set the user's nickname.
- (NSString *)nickname;

- (void)setNickname:(NSString *)name;


// Determines whether the user has successfully joined a chat.
- (BOOL)joinedChat;

- (void)setJoinedChat:(BOOL)value;

// Get and set the device token. We cache the token so we can determine whether
// to send an "update" request to the server.
- (NSString *)deviceToken;

- (void)setDeviceToken:(NSString *)token;

- (BOOL)businessAllowedToSendNotification:(NSString *)businessName;

@property(nonatomic, assign) int userID; // determined and given by the server
@property(nonatomic, retain) NSString *chatSystemURL;
@property(nonatomic, retain) NSString *businessName;
@property(nonatomic, retain) NSString *password;
@property(atomic, assign) short ageGroup;
@property(nonatomic, retain) NSString *emailAddress;

@end

