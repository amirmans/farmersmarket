//
//  MyLocationAnnotation.m
//  TapTalk
//
//  Created by Amir on 10/15/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

#import "Business.h"
#import "GooglePlacesConnection.h"
#import "SBJson4Parser.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIAlertView+TapTalkAlerts.h"
#import "Consts.h"
#import "DataModel.h"
#import "AFNetworking.h"

@interface Business () {
//    NSString *imageFileName;
//    NSString *imageFileExt;
@private

}

//@property(nonatomic, retain) NSString *imageFileName;
//@property(nonatomic, retain) NSString *imageFileExt;


- (void)fetchProductData:(NSData *)responseData;
- (void)prepareToGetGoogleDetailedData;

@end


@implementation Business


@synthesize iconRelativeURL, iconImage, coordinate, title, subtitle,businessName, shortBusinessName, customerProfileName, imageFileName, imageFileExt, googlePlacesObject, businessDelegate;

@synthesize rating;
@synthesize website;
@synthesize address;
@synthesize phone;
@synthesize sms_no;
@synthesize isProductListLoaded, businessID;
@synthesize businessProducts;
@synthesize businessEvents;
@synthesize chatSystemURL;
@synthesize referenceData;
@synthesize businessTypes;
@synthesize businessError;
@synthesize neighborhood;
@synthesize paymentProcessingEmail;
@synthesize paymentProcessingID;
@synthesize email;
@synthesize chat_masters;
@synthesize map_image_url;
@synthesize picturesString;
@synthesize validate_chat;
@synthesize inquiryForProduct, needsBizChat;
@synthesize bg_image, marketing_statement;


- (void)initMemberData {
    self.iconRelativeURL = nil;
    self.isCustomer = -1;
    self.customerProfileName = nil;
    self.imageFileName = nil;
    self.imageFileExt = nil;
    self.businessDelegate = nil;
    self.googlePlacesObject = nil;
    self.isProductListLoaded = FALSE;
    self.businessProducts = nil;
    self.businessEvents = nil;
    self.businessID = -1;  // -1 is invalid like nil -  0 is a valid businessID
    self.chatSystemURL = nil;
    self.website = nil;
    self.phone = nil;
    self.sms_no = nil;
    self.address = nil;
    businessError = nil;
    googlePlacesConnection = [[GooglePlacesConnection alloc] initWithDelegate:self];
    neighborhood = nil;
    ServerInteractionManager *serverManager = [[ServerInteractionManager alloc] init];
    serverManager.postProcessesDelegate = self;
    chat_masters = nil;
    map_image_url = nil;
    validate_chat = FALSE;
    picturesString = nil;
    iconImage = nil;
    bg_image = nil;
    needsBizChat = true;
    marketing_statement = nil;
}

- (int)isCustomer {
    return isCustomer;
}

- (void)setIsCustomer:(int)isCust {
    isCustomer = isCust;
}

- (void)startLoadingBusinessProductCategoriesAndProducts {
    NSString *urlString = [NSString stringWithFormat:@"%@?businessID=%i", BusinessInformationServer, businessID];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];

//    isProductListLoaded = TRUE;
    dispatch_async(TT_CommunicationWithServerQ, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchProductData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchProductData:(NSData *)responseData {
    //parse out the json data
    NSError* error =nil;

    businessProducts = [NSJSONSerialization
                        JSONObjectWithData:responseData
                        options:kNilOptions
                        error:&error];
    if (error)
    {
        NSLog(@"Error in fetching product items.  Description of error is: %@", [error localizedDescription]);
        [UIAlertController showErrorAlert: @"Error in fetching product items."];
    }
    isProductListLoaded = TRUE;
}


- (NSDictionary *)businessProducts {
    if (businessProducts == nil) {
        [self startLoadingBusinessProductCategoriesAndProducts];
    }

    return businessProducts;
}


- (void)startLoadingBusinessEvents {
    NSString *urlString = [NSString stringWithFormat:@"%@?businessID=%i", BusinessInformationServer, businessID];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //    isProductListLoaded = TRUE;
    dispatch_async(TT_CommunicationWithServerQ, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchProductData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchEventData:(NSData *)responseData {
    //parse out the json data
    NSError* error =nil;
    
    businessEvents  = [NSJSONSerialization
                       JSONObjectWithData:responseData
                       options:kNilOptions
                       error:&error];
    if (error)
    {
        NSLog(@"Error in fetching event information.  Description of error is: %@", [error localizedDescription]);
        [UIAlertController showErrorAlert: @"Error in fetching events."];
    }
    isProductListLoaded = TRUE;
}


- (NSDictionary *)businessEvents {
    if (businessProducts == nil) {
        [self startLoadingBusinessEvents];
    }
    
    return businessEvents;
}

- (NSString *)stringFromDataDictionary:(NSDictionary *)data forKey:(NSString *)key
{
    NSString* field = [data objectForKey:key];
    if (field == (id)[NSNull null] || field.length == 0 )
    {
        field = nil;
    }
    
    return field;

}

- (NSMutableString *)mutableStringFromDataDictionary:(NSDictionary *)data forKey:(NSString *)key
{
    NSMutableString *field = [data objectForKey:key];
    if (field == (id)[NSNull null] || field.length == 0 )
    {
        field = nil;
    }
    
    return field;
    
}


- (NSInteger)integerFromDataDictionary:(NSDictionary *)data forKey:(NSString *)key
{
    NSString* field = [data objectForKey:key];
    if (field == (id)[NSNull null] || field.length == 0 )
    {
        field = @"0";
    }
    
    return [field intValue];
}


- (NSArray *)nsArrayFromDataDictionary:(NSDictionary *)data forKey:(NSString *)key {
    NSString *jsonString = [data objectForKey:key];
    
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error=nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSArray *jsonArray = nil;
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSLog(@"its an array!");
        jsonArray = (NSArray *)jsonObject;
        NSLog(@"jsonArray - %@",jsonArray);
    }
    else {
        NSLog(@"its probably a dictionary");
        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
        NSLog(@"jsonDictionary - %@",jsonDictionary);
    }

    
    return jsonArray;
}

- (id)initWithDataFromDatabase:(NSDictionary *)data {
//    [self initMemberData];
    isCustomer = 1;
    
    // since these values are coming from db, we should take care "[Null]" - database marks for null
    title = [data objectForKey:@"name"];
    rating = [self stringFromDataDictionary:data forKey:@"rating"];
    website = [self stringFromDataDictionary:data forKey:@"website"];
    phone = [self stringFromDataDictionary:data forKey:@"phone"];
    sms_no = [self stringFromDataDictionary:data forKey:@"sms_no"];
    if ((sms_no == nil) && (phone != nil)) {
        sms_no = phone;
    }
    email = [self stringFromDataDictionary:data forKey:@"email"];
    paymentProcessingID = [self stringFromDataDictionary:data forKey:@"payment_processing_id"];
    paymentProcessingEmail = [self stringFromDataDictionary:data forKey:@"payment_processing_email"];
    if ((paymentProcessingEmail == nil) && (email != nil)) {
        paymentProcessingEmail = email;
    }
    businessTypes = [self mutableStringFromDataDictionary:data forKey:@"businessTypes"];
    neighborhood = [self stringFromDataDictionary:data forKey:@"neighborhood"];
    address = [self stringFromDataDictionary:data forKey:@"address"];
    customerProfileName = [self stringFromDataDictionary:data forKey:@"customerProfileName"];
    iconRelativeURL = [data objectForKey:@"icon"];
    businessName = [self stringFromDataDictionary:data forKey:@"name"];
    shortBusinessName = [self stringFromDataDictionary:data forKey:@"short_name"];
    if (shortBusinessName == nil)
        shortBusinessName = businessName;
    chatSystemURL = [self stringFromDataDictionary:data forKey:@"chatroom_table"];
    businessID = [[data objectForKey:@"businessID"] intValue];
    chat_masters = [self nsArrayFromDataDictionary:data forKey:@"chat_masters"];
    map_image_url = [self stringFromDataDictionary:data forKey:@"map_image_url"];
    picturesString = [self stringFromDataDictionary:data forKey:@"pictures"];
    validate_chat = [[data objectForKey:@"validate_chat"] boolValue];
    is_collection = [[data objectForKey:@"is_collection"] boolValue];
    inquiryForProduct = [[data objectForKey:@"inquiry_for_product"] boolValue];
    
    NSString* bg_image_URLString = [self stringFromDataDictionary:data forKey:@"bg_image"];
    [self setBGImageFromString:bg_image_URLString];
    marketing_statement = [self stringFromDataDictionary:data forKey:@"marketing_statement"];
    
    if (validate_chat) {
        validate_chat = ChatValidationWorkflow_InProcess; // means in the process of validation
        // Create the HTTP request object for our URL
        AFHTTPRequestOperationManager *manager;
        manager = [AFHTTPRequestOperationManager manager];
        
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        NSInteger userID = [DataModel sharedDataModelManager].userID;
        NSString *businessIDString = [NSString stringWithFormat:@"%i", businessID];
        NSString  *userIDString = [NSString stringWithFormat:@"%lu", (unsigned long)userID];
        NSDictionary *params = @{@"cmd":@"validate", @"business_id":businessIDString, @"userID":userIDString};
        [manager POST:ChatSystemServer parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Response from chat system server for validation the user:%@", responseObject);
                  NSError *jsonError = nil;
                  NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:kNilOptions error:&jsonError];
                  NSInteger statusCode = [[jsonResponse objectForKey:@"status_code"] integerValue];
                  NSInteger permissionCode = [[jsonResponse objectForKey:@"permission"] integerValue];
                  
                  if ( (operation.response.statusCode != 200) || (statusCode != 0) ) {
                      [UIAlertController showErrorAlert:NSLocalizedString(@"No connection to Business's Chatroom", nil)];
                      validate_chat = ChatValidationWorkflow_ErrorFromServer; // error
                  }
                  if (permissionCode == 1)
                      validate_chat = ChatValidationWorkflow_Validated; //validated
                  else
                      validate_chat = ChatValidationWorkflow_Not_Valid; 
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  validate_chat = ChatValidationWorkflow_ErrorFromServer; //error
                  NSLog(@"Response from chat system server for validation the user indicates error:%@", error);
                  
              }
         ];
        
    } else {
        validate_chat = ChatValidationWorkflow_NoNeedToValidate;
    };
    
    return self;
}

// we populate our Business object with google object and then call our own server to get additional information from
// Database
- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject {
    // get what we can from the google object and then use "reference" to call the "detail method"
    // to get the rest of info
    [self initMemberData];
    rating = googleObject.rating;
    address = googleObject.vicinity;
    phone = googleObject.formattedPhoneNumber;

    self.googlePlacesObject = googleObject;
    self.businessName = googleObject.name;
    coordinate = googleObject.coordinate;
    title = googleObject.name;
    referenceData = googleObject.reference; // we need this to get detailed data from google
    subtitle = [googleObject.type objectAtIndex:0];
    businessTypes = [NSMutableString string];
    for (NSObject * obj in googleObject.type)
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%@, ",obj];
        [businessTypes appendString:tmpStr];
    }
    NSString *urlString = BusinessInformationServer;
    NSString *getValues = [NSString stringWithFormat:@"?businessName=%@", businessName];
    urlString = [urlString stringByAppendingString:getValues];
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request =
            [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];

    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData;
    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    isCustomer = 0;
    if (!err) {
        NSDictionary *responseDictionaryWithStatus = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];

        if (nil != responseDictionaryWithStatus) {
            if ([[responseDictionaryWithStatus objectForKey:@"status"] integerValue ] == 0)  {
                NSDictionary *responseDictionary = [responseDictionaryWithStatus objectForKey:@"data"];
                if ([responseDictionary count] > 0) {
                    isCustomer = 1;
                    
                    [self prepareToGetGoogleDetailedData];
                    
                    self.businessID = [[responseDictionary valueForKey:@"businessID"] intValue];
                    customerProfileName = [responseDictionary valueForKey:@"customerProfileName"];
                    self.chatSystemURL = [responseDictionary valueForKey:@"chatroom_table"];
                    self.chat_masters = [self nsArrayFromDataDictionary:responseDictionary forKey:@"chat_masters"];
                    sms_no = [self stringFromDataDictionary:responseDictionary forKey:@"sms_no"];
                    if ((sms_no == nil) && (phone != nil)) {
                        sms_no = phone;
                    }
                    map_image_url = [self stringFromDataDictionary:responseDictionary forKey:@"map_image_url"];
                    picturesString = [self stringFromDataDictionary:responseDictionary forKey:@"pictures"];
                    
                    NSString *iconPath = [NSString stringWithFormat:@"%@", [responseDictionary valueForKey:@"icon"]];
                    if (iconPath != (id)[NSNull null] && iconPath.length != 0 ) {
                        NSString *iconURLString = [BusinessCustomerIconDirectory stringByAppendingString:iconPath];
                        NSURL *iconUrl = [NSURL URLWithString:iconURLString];
                        //We have a valid icon path - retrieve the image from our own server
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        [manager downloadImageWithURL:iconUrl
                                         options:0
                                        progress:nil
                                       completed:^(UIImage *webImage, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url)
                         {
                             if (webImage && finished)
                             {
                                 iconImage = webImage;
                             }
                         }];
                    }
                }
            }
        }
    }
    
#if (0)
    NSLog(@"In Business:initWithGooglePlacesObject for %@ with isCustomer of %d - %@ was called to get additional information from our own server", self.businessName, self.isCustomer, urlString);
#endif
    return self;
}


- (NSString *)iconRelativeURL {
    return iconRelativeURL;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}


- (CLLocationCoordinate2D)coordinate; {
    return coordinate;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title {
    return title;
}


- (NSString *)subtitle {
    return subtitle;
}


- (void)prepareToGetGoogleDetailedData
{
    [googlePlacesConnection getGoogleObjectDetails:self.referenceData];
}


- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)objects {
    
    if ([objects count] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Error in getting detailed information from google."};
        businessError = [NSError errorWithDomain:@"Business"
                                                   code:-10
                                               userInfo:userInfo];
    } else {
        //        locations = objects;
        //UPDATED locationFilterResults for filtering later on
        GooglePlacesObject *googleDetailObject = [objects objectAtIndex:0];
        
        if (googleDetailObject.rating)
        {
            rating = googleDetailObject.rating;
        }
        else
            rating = @"N/A";
        if (googleDetailObject.formattedAddress != nil)
            address = googleDetailObject.formattedAddress;
        
        if (googleDetailObject.website)
            website = googleDetailObject.website;
        else
            website = @"";
        if (googleDetailObject.formattedPhoneNumber)
            phone = googleDetailObject.formattedPhoneNumber;
        else
            phone = @"Phone number not provided.";
    }
    
}

- (void)setBGImageFromString:(NSString *)bgImageString {
    if (!bgImageString) {
        bg_image = [UIImage imageNamed:@"bg_image"];
        return;
    }
    
    NSString *iconURLString = [BusinessCustomerBGImageDirectory stringByAppendingString:bgImageString];
    NSURL *iconUrl = [NSURL URLWithString:iconURLString];
    //We have a valid icon path - retrieve the image from our own server
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:iconUrl
                          options:0
                         progress:nil
                        completed:^(UIImage *webImage, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url)
     {
         if (webImage && finished)
         {
             bg_image = webImage;
         }
     }];
}

- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)gError {
    businessError = gError;
}



@end
