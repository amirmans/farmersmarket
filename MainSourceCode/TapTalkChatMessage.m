#import "TapTalkChatMessage.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "SBJsonParser.h"
#import "DataModel.h"
//
//static NSString* const SenderNameKey = @"SenderName";
//static NSString* const DateKey = @"Date";
//static NSString* const TextKey = @"Text";

static NSString *const SenderNameKey = @"sender";
static NSString *const DateKey = @"dateAdded";
static NSString *const TextKey = @"textChat";


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
@synthesize dateAdded;
@synthesize textChat;
@synthesize bubbleSize;
@synthesize myDelegate;
@synthesize messages;
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

        connectionIsAvailable = TRUE;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.sender forKey:SenderNameKey];
    [encoder encodeObject:self.dateAdded forKey:DateKey];
    [encoder encodeObject:self.textChat forKey:TextKey];
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

    //date stuff
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //set for mysql date strings
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    self.dateAdded = [formatter dateFromString:[messageDict valueForKey:DateKey]];
    [formatter release];
}

- (BOOL)isSentByUser {
    NSString *tempName = [DataModel sharedDataModelManager].nickname;
    return ((self.sender == nil) || ([self.sender isEqualToString:tempName]));
}


- (void)loadMessagesFromServer {
    if (connectionIsAvailable != TRUE)
        return;
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = NSLocalizedString(@"Loading messages", @"");
    // remember chatSystemURL is loaded from the database
    NSString *url = [DataModel sharedDataModelManager].chatSystemURL;
    url = [url stringByAppendingString:LoadChatServerURL_APPENDIX];
    url = [url stringByAppendingString:@"?past=0&t=1339093812"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];

    NSLog(@"%@ was called to load messages", url);

    // this method could be called even before joining the chat room so in order to fetch
    // messages from the server we set it, knowing that joining will be done for sure
//    [DataModel sharedDataModelManager].joinedChat = TRUE;
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection) {
//        responseData = [NSMutableData data];
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
    SBJsonParser *json = [[SBJsonParser alloc] init];

    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    self.messages = [json objectWithString:responseString];
    if (self.messages != nil) {
        NSLog(@"Got %lui messages from the server", (unsigned long)self.messages.count);
//        [DataModel sharedDataModelManager].messages  =  self.messages;
        [myDelegate tapTalkChatMessageDidFinishLoadingData:self.messages];
    }
    else {
        // TODO
        [UIAlertView showErrorAlert:NSLocalizedString(@"Error in recieving messages from the server", nil)];
        NSLog(@"Error in getting the messages from the server.");
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
