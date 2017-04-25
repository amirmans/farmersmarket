// The URL for the server API
@class NSString;

#define TT_CommunicationWithServerQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define AddChatServer @"https://tapforall.com/staging/tap-in/chatrooms/addchatmessage.php"
#define LoadChatServer @"https://tapforall.com/staging/tap-in/chatrooms/loadchatmessages.php"
#define ChatSystemServer @"https://tapforall.com/staging/tap-in/chatsystem/index.php"
//#define ChatSystemServer @"https://tapforall.com/staging/TapForAll/chatsystem/index.php"
//#define OrderServerURL @"http://tapit-servers.dev/businessinfo/model.php"
#define OrderServerURL @"https://tapforall.com/staging/tap-in/include/model.php"
static NSString *const ServerForBusiness = @"https://tapforall.com/staging/tap-in/include/model.php";

#define timeInterval 60 // network time interval

#define MaxRowsForLoadingChatMessages 150 // max number of messages
#define TimeIntervalForLoadingChatMessages 1440 //Hours - 1440 means 2 months
#define ChatValidationWorkflow_NoNeedToValidate 0
#define ChatValidationWorkflow_InProcess 1
#define ChatValidationWorkflow_Validated 2
#define ChatValidationWorkflow_Not_Valid 3
#define ChatValidationWorkflow_ErrorFromServer -1
#define BusinessAndProductionInformationServer @"https://tapforall.com/staging/tap-in/include/model.php"
#define BusinessInformationServer @"https://tapforall.com/staging/tap-in/businessinfo/index.php"
#define ConsumerProfileServer @"https://tapforall.com/staging/tap-in/profilesystem/consumerprofile.php"
#define SetFavoriteServer @"https://tapforall.com/staging/tap-in/include/model.php"
#define GetRewardPoints @"https://tapforall.com/staging/tap-in/include/model.php"
#define GetPrevious_order @"https://tapforall.com/staging/tap-in/include/model.php"
#define Save_cc_info @"https://tapforall.com/staging/tap-in/include/model.php"
#define save_notifications @"https://tapforall.com/staging/tap-in/include/model.php"
#define Get_notifications @"https://tapforall.com/staging/tap-in/include/model.php"
#define Get_consumer_all_cc_info @"https://tapforall.com/staging/tap-in/include/model.php"
#define remove_cc @"https://tapforall.com/staging/tap-in/include/model.php"
//data directories

#define BusinessCustomerIndividualDirectory @"https://tapforall.com/staging/tap-in/customer_files/"
#define BusinessCustomerIndividualDirectory_ProductItems @"products"
#define BusinessCustomerIconDirectory @"https://tapforall.com/staging/tap-in/customer_files/icons/"
#define BusinessCustomerBGImageDirectory @"https://tapforall.com/staging/tap-in/customer_files/bg_images/"
#define QRImageDomain @"https://tapforall.com/staging/tap-in/consumer_files/qr_images/"
#define BusinessCustomersMapDirectory @"https://tapforall.com/staging/tap-in/customer_files/maps/"

//payment processing
//#define STRIPE_TEST_PUBLIC_KEY @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"
//NSString * const StripePublishableKey = @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi";
#define TapForAllPaymentServer @"https://tapforall.com/staging/tap-in/paymentsystem/charge.php"

#define BusinessDelivaryInformationServer @"https://tapforall.com/staging/tap-in/include/model.php?cmd=get_business_delivery_info"

#define ConsumerDelivaryInformationSaveServer @"https://tapforall.com/staging/tap-in/include/model.php?cmd=save_consumer_delivery"


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

//order status
#define ORDER_STATUS_DONE @"10";

#define ORDER_STATUS_COMPLETE @"3";
#define ORDER_STATUS_APPROVED @"2";
#define ORDER_STATUS_REJECTED @"0";
#define ORDER_STATUS_NEW = 1;

// pick up  and delivery modes
#define PICKUP_COUNTER @"1";
#define PICKUP_LOCATION @"2";
#define PICKUP_BOTH @"3";

#define DELIVERY_TABLE @"4";
#define DELIVERY_LOCATION @"8";
#define DELIVERY_BOTH @"12";

//character search limit in delievery screen
#define characterSearchLimit 2

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
