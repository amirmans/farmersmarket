#import "TapTalkChatMessage.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "SBJson4Parser.h"
#import "DataModel.h"
//
//static NSString* const SenderNameKey = @"SenderName";
//static NSString* const DateKey = @"Date";
//static NSString* const TextKey = @"Text";

static NSString *const SenderNameKey = @"sender";
static NSString *const DateKey = @"dateAdded";
static NSString *const TextKey = @"textChat";
static NSString *const senderIDKey = @"sender_id";


// New additions for interact with central database to get others chat messages 
@interface TapTalkChatMessage () {
    NSURLConnection *connection;
    NSMutableData *responseData;
}

@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSURLConnection *connection;

@end


@implementation TapTalkChatMessage

@synthesize sender;
@synthesize senderID;
@synthesize dateAdded;
@synthesize textChat;
@synthesize bubbleSize;
@synthesize myDelegate;
//@synthesize messages;
@synthesize connectionIsAvailable;
@synthesize responseData;
@synthesize connection;

+ (NSDate *)convertDateToLocaltime:(NSDate *)inputDate {
    NSDate *sourceDate = [NSDate date];

    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];

    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;

    NSDate *destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];

    return destinationDate;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.sender = [decoder decodeObjectForKey:SenderNameKey];
        self.dateAdded = [decoder decodeObjectForKey:DateKey];
        self.textChat = [decoder decodeObjectForKey:TextKey];
        self.senderID = [[decoder decodeObjectForKey:senderIDKey] intValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.sender forKey:SenderNameKey];
    [encoder encodeObject:self.dateAdded forKey:DateKey];
    [encoder encodeObject:self.textChat forKey:TextKey];
    [encoder encodeObject:[NSString localizedStringWithFormat:@"%@", senderIDKey] forKey:senderIDKey];
}

- (id)initWithDelegate:(id)del {
    self.myDelegate = del;
    connectionIsAvailable = TRUE;

    return self;
}

- (id)initWithMessage:(NSDictionary *)messageDict {
    if (self = [super init]) {
        [self setValuesFrom:messageDict];
        connectionIsAvailable = TRUE;
    }
    return self;
}

// This is called to populate our data structure from the server's response, which is a set of key/value strings
- (void)setValuesFrom:(NSDictionary *)messageDict {
    self.textChat = [messageDict valueForKey:TextKey];
    self.sender = [messageDict valueForKey:SenderNameKey];
    self.senderID = [[messageDict valueForKey:senderIDKey] intValue];

    //date stuff
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //set for mysql date strings
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    self.dateAdded = [formatter dateFromString:[messageDict valueForKey:DateKey]];
    [formatter release];
}

- (BOOL)isSentByUser {
//    NSString *tempName = [DataModel sharedDataModelManager].nickname;
    NSInteger me = [DataModel sharedDataModelManager].userID;
//    return ((self.sender == nil) || ([self.sender isEqualToString:tempName]));
    return ((self.senderID == me)?TRUE:FALSE);
}

- (NSString *)businessNameIfMessageSentByBusiness {
    NSString *returnVal = nil;
    
    for (int i = 0; i <  [DataModel sharedDataModelManager].chat_masters.count; i++) {
        int id  = [[[[DataModel sharedDataModelManager].chat_masters objectAtIndex:i] valueForKey:@"id"] intValue];
        if (id == self.senderID) {
            returnVal = [[[DataModel sharedDataModelManager].chat_masters objectAtIndex:i] valueForKey:@"business_name"];
            break;
        }
    }
    
    return returnVal;
}


- (void)doToggleUpdatingChatMessages {
    if ([DataModel sharedDataModelManager].shouldDownloadChatMessages) {
        [DataModel sharedDataModelManager].shouldDownloadChatMessages = false;
    } else {
        [DataModel sharedDataModelManager].shouldDownloadChatMessages = TRUE;
        [self loadMessagesFromServer];
    }
    
}


- (void)loadMessagesFromServer {
    if (connectionIsAvailable != TRUE)
        return;

    NSString *chatRoom = [DataModel sharedDataModelManager].chatSystemURL;
    NSString *url = [NSString stringWithFormat:@"%@?chatroom=%@&past=%i&max_rows=%i", LoadChatServer,chatRoom, TimeIntervalForLoadingChatMessages, MaxRowsForLoadingChatMessages];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];

    NSLog(@"%@ was called to load messages", url);

    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection) {
        if (self.responseData != nil) {
            [self.responseData release];
        }
        self.responseData = [[NSMutableData data] retain];
        connectionIsAvailable = FALSE;
    }
    else {
        NSLog(@"connection to load chat messages failed");
    }
}


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [connection cancel];
    [connection release];
    connection = nil;
    connectionIsAvailable = TRUE;
    [myDelegate tapTalkChatMessageDidFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
//    SBJson4Parser *json = [[SBJson4Parser alloc] init];

    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    self.messages = [json objectWithString:responseString];
    if (responseString != nil) {
        NSError *jsonError;
//        NSLog(@"Got %l messages from the server", self.messages.count);
//        [DataModel sharedDataModelManager].messages  =  self.messages;
        NSMutableArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
        [myDelegate tapTalkChatMessageDidFinishLoadingData:parsedJSON];
    }
    else {
        // TODO
        [UIAlertController showErrorAlert:NSLocalizedString(@"Error in recieving messages from the server", nil)];
    }

    [connection cancel];
    [connection release];
    connection = nil;
    connectionIsAvailable = TRUE;
}

- (void)dealloc {
    [sender release];
    [dateAdded release];
    [textChat release];
    [super dealloc];
}

@end
