
// The URL for the server API
#define AddChatServerURL_APPENDIX @"addchatmessage.php"
#define LoadChatServerURL_APPENDIX @"loadchatmessages.php"
#define BusinessInformationServer @"http://mydoosts.com/index.php"
#define ConsumerProfileServer @"http://mydoosts.com/profilesystem/consumerprofile.php"
#define ChatSystemServer @"http://mydoosts.com/chatsystem/index.php"

// We store our settings in the NSUserDefaults dictionary using these keys
static NSString* const NicknameKey = @"nickname";
static NSString* const PasswordKey = @"password";
static NSString* const JoinedChatKey = @"joinedChat";
static NSString* const DeviceTokenKey = @"deviceToken";
static NSString* const EmailAddressKey = @"email1";
static NSString* const AgeGroupKey = @"age_group";
static NSString* const UserIDKey = @"userID";



// Maximum number of bytes that a text message may have. The payload data of
// a push notification is limited to 256 bytes and that includes the JSON 
// overhead and the name of the sender.
#define MaxMessageLength 190

// Convenience function to show a UIAlertView
//void ShowErrorAlert(NSString* text);
