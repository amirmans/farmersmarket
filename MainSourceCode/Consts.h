// The URL for the server API
@class NSString;

#define TT_CommunicationWithServerQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define AddChatServer @"https://tapforall.com/servers/tap-in/chatrooms/addchatmessage.php"
#define LoadChatServer @"https://tapforall.com/servers/tap-in/chatrooms/loadchatmessages.php"
#define ChatSystemServer @"https://tapforall.com/servers/tap-in/chatsystem/index.php"
//#define ChatSystemServer @"http://127.0.0.1/TapForAll/chatsystem/index.php"
//#define OrderServerURL @"http://tapit-servers.dev/businessinfo/model.php"
#define OrderServerURL @"https://tapforall.com/servers/tap-in/include/model.php"
static NSString *const ServerForBusiness = @"https://tapforall.com/servers/tap-in/include/model.php";


#define MaxRowsForLoadingChatMessages 150 // max number of messages
#define TimeIntervalForLoadingChatMessages 1440 //Hours - 1440 means 2 months
#define ChatValidationWorkflow_NoNeedToValidate 0
#define ChatValidationWorkflow_InProcess 1
#define ChatValidationWorkflow_Validated 2
#define ChatValidationWorkflow_Not_Valid 3
#define ChatValidationWorkflow_ErrorFromServer -1
#define BusinessAndProductionInformationServer @"https://tapforall.com/servers/tap-in/include/model.php"
#define BusinessInformationServer @"https://tapforall.com/servers/tap-in/businessinfo/index.php"
#define ConsumerProfileServer @"https://tapforall.com/servers/tap-in/profilesystem/consumerprofile.php"
#define SetFavoriteServer @"https://tapforall.com/servers/tap-in/include/model.php"
#define GetRewardPoints @"https://tapforall.com/servers/tap-in/include/model.php"
#define GetPrevious_order @"https://tapforall.com/servers/tap-in/include/model.php"
#define Save_cc_info @"https://tapforall.com/servers/tap-in/include/model.php"
#define save_notifications @"https://tapforall.com/servers/tap-in/include/model.php"
#define Get_notifications @"https://tapforall.com/servers/tap-in/include/model.php"
#define Get_consumer_all_cc_info @"https://tapforall.com/servers/tap-in/include/model.php"
#define remove_cc @"https://tapforall.com/servers/tap-in/include/model.php"
//data directories

#define BusinessCustomerIndividualDirectory @"https://tapforall.com/servers/tap-in/customer_files/"
#define BusinessCustomerIndividualDirectory_ProductItems @"products"
#define BusinessCustomerIconDirectory @"https://tapforall.com/servers/tap-in/customer_files/icons/"
#define BusinessCustomerBGImageDirectory @"https://tapforall.com/servers/tap-in/customer_files/bg_images/"
#define QRImageDomain @"https://tapforall.com/servers/tap-in/consumer_files/qr_images/"
#define BusinessCustomersMapDirectory @"https://tapforall.com/servers/tap-in/customer_files/maps/"

//payment processing
//#define STRIPE_TEST_PUBLIC_KEY @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"
//NSString * const StripePublishableKey = @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi";
#define TapForAllPaymentServer @"https://tapforall.com/servers/tap-in/paymentsystem/charge.php"


#define TapInApplicationThemeColor [UIColor colorWithRed:74.0/255.0 green:182.0/255.0 blue:190.0/255.0 alpha:1];

#define IsFromTotalCartNotification @"IsFromTotalCartNotification"
#define RedeemPoints @"RedeemPoints"

#define NoLogoForMenuItems 1
static const int PointsValueMultiplier = 1;

// We store our settings in the NSUserDefaults dictionary using these keys
static NSString *const NicknameKey = @"nickname";
static NSString *const PasswordKey = @"password";
static NSString *const JoinedChatKey = @"joinedChat";
static NSString *const DeviceTokenKey = @"deviceToken";
static NSString *const EmailAddressKey = @"email1";
static NSString *const AgeGroupKey = @"age_group";
static NSString *const UserIDKey = @"userID";
static int NumberOfMessagesOnOnePage = 6;

static NSString *const stripeArrayKey = @"stripeDataArray";
static NSString *const StripeDefaultCard = @"stripeDefaultCard";
static NSString *const Default_Process_Time = @"Average wait time: 25 min";



// Maximum number of bytes that a text message may have. The payload data of
// a push notification is limited to 256 bytes and that includes the JSON
// overhead and the name of the sender.
#define MaxMessageLength 190

// compatibility between different ios
#ifdef __IPHONE_8_0
#define Compatible_setImageWithURL sd_setImageWithURL
#else
#define Compatible_setImageWithURL setImageWithURL
#endif
