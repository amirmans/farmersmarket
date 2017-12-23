// The URL for the server API
@class NSString;

//#ifdef DEBUG
#define TapInEndpointHost @"https://tapforall.com/staging/tap-in/"
//#else
//#define TapInEndpointHost @"https://tapforall.com/merchants/tap-in/"
//#endif

#define TT_CommunicationWithServerQ dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define AddChatServer (TapInEndpointHost @"chatrooms/addchatmessage.php")
#define LoadChatServer (TapInEndpointHost @"chatrooms/loadchatmessages.php")
#define ChatSystemServer (TapInEndpointHost @"chatsystem/index.php"
//#define ChatSystemServer @"https://tapforall.com/staging/TapForAll/chatsystem/index.php"
//#define OrderServerURL @"http://tapit-servers.dev/businessinfo/model.php"
#define OrderServerURL (TapInEndpointHost @"include/model.php")
//static NSString *const ServerForBusiness = @"https://tapforall.com/staging/tap-in/include/model.php";

#define DefinedServerForBusiness (TapInEndpointHost @"include/model.php")

#define timeInterval 60 // network time interval

#define MaxRowsForLoadingChatMessages 150 // max number of messages
#define TimeIntervalForLoadingChatMessages 1440 //Hours - 1440 means 2 months
#define ChatValidationWorkflow_NoNeedToValidate 0
#define ChatValidationWorkflow_InProcess 1
#define ChatValidationWorkflow_Validated 2
#define ChatValidationWorkflow_Not_Valid 3
#define ChatValidationWorkflow_ErrorFromServer -1
#define BusinessAndProductionInformationServer (TapInEndpointHost @"include/model.php")
//#define BusinessInformationServer (TapInEndpointHost @"businessinfo/index.php"
#define BusinessInformationServer (TapInEndpointHost @"include/model.php")
#define ConsumerProfileServer (TapInEndpointHost @"profilesystem/consumerprofile.php")
#define SetFavoriteServer (TapInEndpointHost @"include/model.php")
#define GetRewardPoints (TapInEndpointHost @"include/model.php")
#define GetPrevious_order (TapInEndpointHost @"include/model.php")
#define Save_cc_info (TapInEndpointHost @"include/model.php")
#define save_notifications (TapInEndpointHost @"include/model.php")
#define Get_notifications (TapInEndpointHost @"include/model.php")
#define Get_consumer_all_cc_info (TapInEndpointHost @"include/model.php")
#define remove_cc (TapInEndpointHost @"include/model.php")
//data directories

#define BusinessCustomerIndividualDirectory (TapInEndpointHost @"customer_files/")
#define BusinessCustomerIndividualDirectory_ProductItems @"products"
#define BusinessCustomerIconDirectory (TapInEndpointHost @"customer_files/icons/")
#define BusinessCustomerBGImageDirectory (TapInEndpointHost @"customer_files/bg_images/")
#define QRImageDomain (TapInEndpointHost @"consumer_files/qr_images/")
#define BusinessCustomersMapDirectory (TapInEndpointHost @"customer_files/maps/")

//payment processing
//#define STRIPE_TEST_PUBLIC_KEY @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi"
//NSString * const StripePublishableKey = @"pk_test_zrEfGQzrGZAQ4iUqpTilP6Bi";
#define TapForAllPaymentServer (TapInEndpointHost @"paymentsystem/charge.php")

#define BusinessDelivaryInformationServer (TapInEndpointHost @"include/model.php?cmd=get_business_delivery_info")

#define ConsumerDelivaryInformationSaveServer (TapInEndpointHost @"include/model.php?cmd=save_consumer_delivery")


#define TapInApplicationThemeColor [UIColor colorWithRed:74.0/255.0 green:182.0/255.0 blue:190.0/255.0 alpha:1];

#define IsFromTotalCartNotification @"IsFromTotalCartNotification"

#define NoLogoForMenuItems 1

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
#define PICKUP_COUNTER @"1"
#define PICKUP_LOCATION @"2"
#define PICKUP_BOTH @"3"

#define DELIVERY_TABLE @"4"
#define DELIVERY_LOCATION @"8"
#define DELIVERY_BOTH @"12"

static const int PickUpAtCounter=1;
static const int PickUpAtLocation=2;
static const int DeliveryToTable=4;
static const int DeliveryToLocation=8;

// Time Format
static NSString *const TIME24HOURFORMAT = @"HH:mm:ss";
static NSString *const TIME12HOURFORMAT = @"h:mm a";
//#define TIME24HOURFORMAT @"HH:mm:ss";
//#define TIME12HOURFORMAT @"hh:mm a";


//character search limit in delievery screen
#define characterSearchLimit 2

// Maximum number of bytes that a text message may have. The payload data of
// a push notification is limited to 256 bytes and that includes the JSON
// overhead and the name of the sender.
#define MaxMessageLength 190

#define Default_Text_Color  @"rgb(0,0,0)";
#define Default_BG_Color    @"rgb(255, 134, 57)";

//points
static const int PointsValueMultiplier = 1;  // for each dollar you can one point -  acquiring
static const int Points_to_dollar=10;        // value of 1 point n points for a dollar to spend
#define RedeemPoints @"RedeemPoints" // Used in notification

// compatibility between different ios
#ifdef __IPHONE_8_0
#define Compatible_setImageWithURL sd_setImageWithURL
#else
#define Compatible_setImageWithURL setImageWithURL
#endif
