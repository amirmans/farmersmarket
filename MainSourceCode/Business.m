//
//  MyLocationAnnotation.m
//  TapTalk
//
//  Created by Amir on 10/15/11.
//  Copyright (c) 2011 MyDoosts.com All rights reserved.
//

#import "Business.h"
#import "SBJsonParser.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface Business () {
    NSString *imageFileName;
    NSString *imageFileExt;
@private

}

@property(nonatomic, retain) NSString *imageFileName;
@property(nonatomic, retain) NSString *imageFileExt;

- (void)fetchResponseData:(NSData *)responseData;

@end


@implementation Business


@synthesize image, coordinate, title, subtitle, customerProfile, businessName, customerProfileName, imageFileName, imageFileExt, googlePlacesObject, delegate;
@synthesize isProductListLoaded, businessID;
@synthesize businessProducts;
@synthesize chatSystemURL;


- (void)initMemberData {
    self.image = nil;
    self.isCustomer = -1;
    self.customerProfileName = nil;
    self.imageFileName = nil;
    self.imageFileExt = nil;
    self.delegate = nil;
    self.googlePlacesObject = nil;
    self.isProductListLoaded = FALSE;
    self.businessProducts = nil;
    self.businessID = -1;  // -1 is invalid like nil -  0 is a valid businessID
    self.chatSystemURL = nil;
}

- (int)isCustomer {
    return isCustomer;
}

- (void)setIsCustomer:(int)isCust {
    isCustomer = isCust;
}

- (void)startLoadingBusinessProductCategoriesAndProducts {
    //TODO
    NSString *urlString = [NSString stringWithFormat:@"%@?businessID=%i", BusinessProductListServer, businessID];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
//
//    businessProducts = [NSDictionary dictionaryWithContentsOfURL:url];
//    isProductListLoaded = TRUE;

    dispatch_async(TT_CommunicationWithServerQ, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchResponseData:) withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchResponseData:(NSData *)responseData {
    //parse out the json data
    NSError* error;

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
            // do something with error
            NSLog(@"Error: %@",error);
            
        }
    }
    else
    {
        NSLog(@"in Business:fetchResponseData - I don't know what I am.");
    }
    
    isProductListLoaded = TRUE;
}


- (NSDictionary *)businessProducts {
    if (businessProducts == nil) {
        [self startLoadingBusinessProductCategoriesAndProducts];
    }

    return businessProducts;
}

// the only valid initializer
// we populate our Business object with google object and then call our own server to get additional information 
- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject {
    // get what we can from the google object and then use "reference" to call the "detail method"
    // to get the rest of info
    [self initMemberData];
    self.googlePlacesObject = googleObject;
    self.businessName = googleObject.name;
    coordinate = googleObject.coordinate;
    title = googleObject.name;
    subtitle = [googleObject.type objectAtIndex:0];

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
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        SBJsonParser *json = [[SBJsonParser alloc] init];
        NSDictionary *responseDictionary = [json objectWithString:responseString];


        if (nil != responseDictionary) {
            if ([responseDictionary count] > 0) {
                isCustomer = 1;
                self.businessID = [[responseDictionary valueForKey:@"businessID"] intValue];
                customerProfileName = [responseDictionary valueForKey:@"customerProfileName"];
                self.chatSystemURL = [responseDictionary valueForKey:@"chat_system_url"];
                //                [self businessProducts:businessID];
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



@end
