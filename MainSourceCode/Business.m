//
//  MyLocationAnnotation.m
//  TapTalk
//
//  Created by Amir on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Business.h"
#import "SBJsonParser.h"




@interface Business() {
    NSString *imageFileName;
    NSString *imageFileExt;
@private
}

@property (atomic, retain) NSString *imageFileName;
@property (atomic, retain) NSString *imageFileExt;

@end


@implementation Business


@synthesize image, coordinate, title, subtitle, customerProfile, businessName, customerProfileName, imageFileName,
            imageFileExt, isCustomer, googlePlacesObject, delegate;
@synthesize isPinIconLoaded, isProductListLoaded, businessID;
@synthesize businessProducts;
@synthesize chatSystemURL;



- (void)initMemberData 
{    
    self.image = nil;
    self.isCustomer = FALSE;    
    self.customerProfileName = nil;
    self.imageFileName = nil;
    self.imageFileExt = nil;
    self.delegate = nil;
    self.googlePlacesObject = nil;
    self.isPinIconLoaded = FALSE;
    self.isProductListLoaded = FALSE; 
    self.businessProducts = nil;
    self.businessID = -1;  // -1 is invalid
    self.chatSystemURL = nil;
}


- (BusinessCustomerProfileManager *) customerProfile
{
//    [customerProfile setBusinessName:@"Coffee shop"];
    [customerProfile setBusinessName:self.businessName];
    return customerProfile;
}

/*
- (id) initWithCoordinate:(CLLocationCoordinate2D)argCoordicate
             BusinessName:(NSString *)bName
                    Title:(NSString *)tName
                 SubTitle:(NSString *)stName 
            ImageFileName:(NSString *)imgFName
       ImageFileExtension:(NSString *)imgXName;
{
    [self initMemberData];
    coordinate = argCoordicate;
    businessName = bName;
    title = tName;
    subtitle = stName;
    imageFileName = imgFName;
    imageFileExt = imgXName;
    

    return self;
}

*/ 

-(void) startLoadingBusinessProductCategoriesAndProducts 
{
    //TODO
    //        NSURL *wordsURL = [NSURL URLWithString:@"http://www.stanford.edu/class/cs193p/vocabwords.txt"];
    //		words = [[NSMutableDictionary dictionaryWithContentsOfURL:wordsURL] retain];
    //NSString *urlString = [NSString stringWithFormat:@"http://mydoosts.com/businessProducts.php?businessID=%i", businessID];
    NSString *urlString = [NSString stringWithFormat:@"http://www.stanford.edu/class/cs193p/vocabwords.txt"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    //        NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
    businessProducts = [NSDictionary dictionaryWithContentsOfURL:url];
    isProductListLoaded = TRUE;
    /*        
     NSURLResponse *resp = nil;
     NSError *err = nil;
     NSData *responseData;
     responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
     
     if (!err) {
     NSString *responseString    = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];	
     NSError *jsonError          = nil;
     SBJsonParser *json          = [[SBJsonParser alloc] init];
     businessProducts    = [json objectWithString:responseString error:&jsonError];
     //            businessProducts = [tempBusinessProducts objectForKey:@"products"];  //Needs to change if database table businessProducts "products" field change
     responseString = nil;
     
     isProductListLoaded = TRUE;
     }
     */

}

- (NSDictionary *)businessProducts 
{
    if (businessProducts == nil) {
        [self startLoadingBusinessProductCategoriesAndProducts];
    }
    
    return businessProducts;
}

// the only valid initializer
// we populate our Business object with google object and then call our own server to get additional information 
- (id)initWithGooglePlacesObject:(GooglePlacesObject *)googleObject
{
    // get what we can from the google object and then use "reference" to call the "detail method"
    // to get the rest of info
    [self initMemberData];
    self.googlePlacesObject = googleObject;
    businessName = googleObject.name;
    coordinate = googleObject.coordinate;
    title = googleObject.name;
    subtitle = [googleObject.type objectAtIndex:0];
 
    NSString *urlString = BusinessInformationServer;
    NSString *getValues = [NSString stringWithFormat:@"?businessName=%@", businessName];
    urlString = [urlString stringByAppendingString:getValues];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];

    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *responseData;
    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    //    NSLog(@"%@ was called to get additional information from our own server", urlString);
    isCustomer = FALSE;
    if (!err) {
        NSString *responseString    = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];	
        NSError *jsonError          = nil;
        SBJsonParser *json          = [[SBJsonParser alloc] init];
        NSDictionary *responseDictionary    = [json objectWithString:responseString error:&jsonError];
        
        if ([jsonError code]==0) 
        {
            if ( [responseDictionary count] > 0)
            {
                isCustomer = TRUE;
                self.businessID =  [[responseDictionary valueForKey:@"businessID"] intValue];
                customerProfileName = [responseDictionary valueForKey:@"customerProfileName"];
                self.chatSystemURL = [responseDictionary valueForKey:@"chat_system_url"];
//                [self businessProducts:businessID];
                NSString* iconPath  = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"icon"]];
                if (iconPath != nil)
                {
                    NSRange range = [[iconPath lowercaseString] rangeOfString:@"null"];
                    if (range.location == NSNotFound)
                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconPath]]];
                }
                NSLog(@"%@ is a customer", self.businessName);
            }
        }
    }
    
    // if the business isn't on of our customer sor it is our customer but we don't have an icon for it, use what google has given us, as the default image
    
    if (image == nil) {    
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:googleObject.icon]]];  
/*        NSString *defaultImageURL = [[NSString alloc] initWithString:googleObject.icon];         
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:defaultImageURL] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60.0];
        NSURLConnection *imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self startImmediately:YES];

        if (imageConnection) 
        {
            responseWithLargData = [NSMutableData data];
//          connectionIsActive = YES;
        }		
        else {
            NSLog(@"connection failed");
        } */
    }

    return self;
}


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response 
{
	[responseWithLargData setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data 
{
	[responseWithLargData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error 
{
    NSLog(@"error in connection when trying to get the google icon");
}



- (void)connectionDidFinishLoading:(NSURLConnection *)conn 
{
    NSLog(@"connection to get google image is back");
    image = [UIImage imageWithData:responseWithLargData];
}

- (void) getTaptalkBusinessesInformation {
    //call taptalk server
    //TODO
    
}

- (UIImage *)image
{
    //TODO
    if (image == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path;
        //        path = [bundle pathForResource: @"CoffeeStore" ofType: @"jpg"];
        path = [bundle pathForResource: self.imageFileName ofType: self.imageFileExt];
        image = [UIImage imageWithContentsOfFile:path];  
    }
    
    return image;
}


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}


- (CLLocationCoordinate2D)coordinate;
{
    return coordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return title;
}


- (NSString *)subtitle
{
    return subtitle;
}

/*
- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    operation.completionBlock = ^ {
        if ([self isCancelled]) {
            return;
        }
        
        if (error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(self, self.error);
                });
            }
        } else {
            dispatch_async(json_request_operation_processing_queue(), ^(void) {
                id JSON = self.responseJSON;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (self.JSONError) {
                        if (failure) {
                            failure(self, self.JSONError);
                        }
                    } else {
                        if (success) {
                            success(self, JSON);
                        }
                    }
                }); 
            });
        }
    };    
}
 
*/ 

 
@end
