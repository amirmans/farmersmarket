 //
//  MyLocationAnnotation.m
//  TapTalk
//
//  Created by Amir on 10/15/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

#import "Business.h"
#import "GooglePlacesConnection.h"
#import "SBJsonParser.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIAlertView+TapTalkAlerts.h"

@interface Business () {
    NSString *imageFileName;
    NSString *imageFileExt;
@private

}

@property(nonatomic, retain) NSString *imageFileName;
@property(nonatomic, retain) NSString *imageFileExt;


- (void)fetchResponseData:(NSData *)responseData;
- (void)prepareToGetGoogleDetailedData;

@end


@implementation Business


@synthesize image, coordinate, title, subtitle,businessName, customerProfileName, imageFileName, imageFileExt, googlePlacesObject, businessDelegate;

@synthesize rating;
@synthesize website;
@synthesize address;
@synthesize phone;
@synthesize sms_no;
@synthesize isProductListLoaded, businessID;
@synthesize businessProducts;
@synthesize chatSystemURL;
@synthesize referenceData;
@synthesize businessTypes;
@synthesize businessError;
@synthesize neighborhood;
@synthesize paymentProcessingEmail;
@synthesize paymentProcessingID;
@synthesize email;
@synthesize chat_master_uid;
@synthesize map_image_url;


- (void)initMemberData {
    self.image = nil;
    self.isCustomer = -1;
    self.customerProfileName = nil;
    self.imageFileName = nil;
    self.imageFileExt = nil;
    self.businessDelegate = nil;
    self.googlePlacesObject = nil;
    self.isProductListLoaded = FALSE;
    self.businessProducts = nil;
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
    chat_master_uid = 0;
    map_image_url = nil;
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
    NSURL *url = [NSURL URLWithString:urlString];

//    isProductListLoaded = TRUE;
    dispatch_async(TT_CommunicationWithServerQ, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchResponseData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchResponseData:(NSData *)responseData {
    //parse out the json data
    NSError* error =nil;

    NSDictionary *tempBusinessProducts = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    businessProducts = [tempBusinessProducts objectForKey:@"products"];

    if ([businessProducts isKindOfClass: [NSDictionary class]]) {
    }
    else if ([businessProducts isKindOfClass:[NSString class]]) {
        NSData* tempData = [(NSString* )businessProducts  dataUsingEncoding:NSUTF8StringEncoding];
        NSPropertyListFormat format;
        businessProducts = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListXMLFormat_v1_0 format:&format error:&error];
        if(error){
            NSLog(@"Error: %@",error);
        }
    }
    else
    {
        NSLog(@"in Business:fetchResponseData for %@ - I don't know what I am.", businessName);
        NSMutableDictionary* errorUserInfo = [NSMutableDictionary dictionary];
        [errorUserInfo setValue:@"No product items found!" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Business:loadProducts" code:-1 userInfo:errorUserInfo];
    }
    if (error)
    {
        [UIAlertView showErrorAlert:[error localizedDescription]];
    }
    isProductListLoaded = TRUE;
}


- (NSDictionary *)businessProducts {
    if (businessProducts == nil) {
        [self startLoadingBusinessProductCategoriesAndProducts];
    }

    return businessProducts;
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
    customerProfileName = [self stringFromDataDictionary:data forKey:@"customerProfileName"];
    image = [data objectForKey:@"icon"];
    businessName = [self stringFromDataDictionary:data forKey:@"name"];
    chatSystemURL = [self stringFromDataDictionary:data forKey:@"chatroom_table"];
    businessID = [[data objectForKey:@"businessID"] intValue];
    chat_master_uid = [self integerFromDataDictionary:data forKey:@"chat_master_uid"];
    map_image_url = [self stringFromDataDictionary:data forKey:@"map_image_url"];
 
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
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
                    self.chat_master_uid = [self integerFromDataDictionary:responseDictionary forKey:@"chat_master_uid"];
                    sms_no = [self stringFromDataDictionary:responseDictionary forKey:@"sms_no"];
                    if ((sms_no == nil) && (phone != nil)) {
                        sms_no = phone;
                    }
                    map_image_url = [self stringFromDataDictionary:responseDictionary forKey:@"map_image_url"];

                    NSString *iconPath = [NSString stringWithFormat:@"%@", [responseDictionary valueForKey:@"icon"]];
                    if (iconPath != nil) {
                        NSURL *iconUrl = [NSURL URLWithString:iconPath];
                        NSRange range = [[iconPath lowercaseString] rangeOfString:@"null"];
                        //We have a valid icon path - retrieve the image from our own server
                        if (range.location == NSNotFound) {
                            SDWebImageManager *manager = [SDWebImageManager sharedManager];

                            [manager downloadWithURL:iconUrl
                            options:0
                            progress:nil
                            completed:^(UIImage *webImage, NSError *error, SDImageCacheType cacheType, BOOL finished)
                            {
                                if (webImage)
                                {
                                    // do something with image
                                    image = webImage;
                                }
                            }];
                        }
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


- (UIImage *)image {
    return image;
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

- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)gError {
    businessError = gError;
}



@end
