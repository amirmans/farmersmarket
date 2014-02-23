// The URL for the server API
@class NSString;

#define TT_CommunicationWithServerQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define AddChatServerURL_APPENDIX @"addchatmessage.php"
#define LoadChatServerURL_APPENDIX @"loadchatmessages.php"
#define BusinessInformationServer @"http://mydoosts.com/taptalk/businessinfo/index.php"
#define ConsumerProfileServer @"http://mydoosts.com/taptalk/profilesystem/consumerprofile.php"
//#define ConsumerProfileServer @"http://localhost/TapForAll/profilesystem/consumerprofile.php"
#define ChatSystemServer @"http://mydoosts.com/taptalk/chatsystem/index.php"
#define BusinessCustomerIconDirectory @"http://www.mydoosts.com/taptalk/customer_files/icons/"

// We store our settings in the NSUserDefaults dictionary using these keys
static NSString *const NicknameKey = @"nickname";
static NSString *const PasswordKey = @"password";
static NSString *const JoinedChatKey = @"joinedChat";
static NSString *const DeviceTokenKey = @"deviceToken";
static NSString *const EmailAddressKey = @"email1";
//TODO
static NSString *const AgeGroupKey = @"age_group";
static NSString *const UserIDKey = @"userID";



// Maximum number of bytes that a text message may have. The payload data of
// a push notification is limited to 256 bytes and that includes the JSON 
// overhead and the name of the sender.
#define MaxMessageLength 190
