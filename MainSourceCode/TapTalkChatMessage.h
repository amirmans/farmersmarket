@protocol TapTalkChatMessageDelegate;

// Data model object that stores a single message
@interface TapTalkChatMessage : NSObject <NSCoding> {
    BOOL connectionIsAvailable;
    NSInteger senderID;
}

+ (NSDate *)convertDateToLocaltime:(NSDate *)inputDate;

- (id)initWithMessage:(NSDictionary *)messageDict;

- (id)initWithDelegate:(id)del;

- (void)setValuesFrom:(NSDictionary *)messageDict;

- (void)loadMessagesFromServer;

@property(atomic, assign) BOOL connectionIsAvailable;

// The complete history of messages this user has sent and received, in
// chronological order (oldest first).
//@property(nonatomic, retain) NSMutableArray *messages;
// The sender of the message. If nil, the message was sent by the user.
@property(nonatomic, copy) NSString *sender;
@property(nonatomic, assign) NSInteger senderID;

// When the message was sent
@property(nonatomic, copy) NSDate *dateAdded;

// The text of the message
@property(nonatomic, copy) NSString *textChat;

@property(nonatomic, retain) id <TapTalkChatMessageDelegate> myDelegate;

// This doesn't really belong in the data model, but we use it to cache the
// size of the speech bubble for this message.
@property(nonatomic, assign) CGSize bubbleSize;

// Determines whether this message as sent by the user of the app. We will
// display such messages on the right-hand side of the screen.
- (BOOL)isSentByUser;
- (BOOL)isSentByBusiness;
- (void)doToggleUpdatingChatMessages;

@end


@protocol TapTalkChatMessageDelegate

- (void)tapTalkChatMessageDidFinishLoadingData:(NSMutableArray *)objects;

- (void)tapTalkChatMessageDidFailWithError:(NSError *)error;

@end
