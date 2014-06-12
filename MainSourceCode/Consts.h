// The URL for the server API
@class NSString;

#define TT_CommunicationWithServerQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define AddChatServer @"http://mydoosts.com/taptalk/chatrooms/addchatmessage.php"
#define LoadChatServer @"http://mydoosts.com/taptalk/chatrooms/loadchatmessages.php"
#define MaxRowsForLoadingChatMessages 150 // max number of messages
#define TimeIntervalForLoadingChatMessages 1440 //Hours - 1440 means 2 months



#define BusinessInformationServer @"http://mydoosts.com/taptalk/businessinfo/index.php"
#define ConsumerProfileServer @"http://mydoosts.com/taptalk/profilesystem/consumerprofile.php"
//#define ConsumerProfileServer @"http://localhost/TapForAll/profilesystem/consumerprofile.php"
#define ChatSystemServer @"http://mydoosts.com/taptalk/chatsystem/index.php"
#define BusinessCustomerIconDirectory @"http://www.mydoosts.com/taptalk/customer_files/icons/"
#define QRImageDomain @"http://www.mydoosts.com/taptalk/consumer_files/qr_images/"
#define BusinessCustomersMapDirectory @"http://www.mydoosts.com/taptalk/customer_files/maps/"

//payment processing
#define STRIPE_TEST_PUBLIC_KEY @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"
#define TapForAllPaymentServer @"http://mydoosts.com/taptalk/paymentsystem/charge.php"



// We store our settings in the NSUserDefaults dictionary using these keys
static NSString *const NicknameKey = @"nickname";
static NSString *const PasswordKey = @"password";
static NSString *const JoinedChatKey = @"joinedChat";

static NSString *const DeviceTokenKey = @"deviceToken";
static NSString *const EmailAddressKey = @"email1";
//TODO
static NSString *const AgeGroupKey = @"age_group";
static NSString *const UserIDKey = @"userID";

static int NumberOfMessagesOnOnePage = 6;



// Maximum number of bytes that a text message may have. The payload data of
// a push notification is limited to 256 bytes and that includes the JSON 
// overhead and the name of the sender.
#define MaxMessageLength 190
