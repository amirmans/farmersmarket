//
//  DetailBusinessInformation.h
//  TapTalk
//
//  Created by Amir on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "GooglePlacesConnection.h"

@class GooglePlacesObject;

@interface DetailBusinessInformation : UIViewController <GooglePlacesConnectionDelegate> {
    NSString *businessNameData;
    NSString *customerProfileName;
    NSString *distanceInMileString;
    NSString *referenceData;
    NSArray  *typesData;
    BOOL isCustomer;
    Business *biz;

    __weak IBOutlet UIButton *addToCustomersOrService;
    GooglePlacesConnection  *googlePlacesConnection;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *typesOfBusiness;
@property (weak, nonatomic) IBOutlet UITextView *contactInfo;
@property (weak, nonatomic) IBOutlet UITextField *rating;


@property (atomic, retain) NSString *distanceInMileString;
@property (atomic, retain) NSString *referenceData;
@property (atomic, retain) NSString *businessNameData;
@property (atomic, retain) NSString *customerProfileName;
@property (nonatomic, retain) NSArray *typesData;

@property (atomic, retain)  Business *biz;
@property (atomic, assign) BOOL isCustomer;



- (id)initWithBusinessObject:(Business *)biz;

- (IBAction)addToCustomersOrGotoServicePage:(id)sender;


@end
