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
#import "KASlideShow.h"

@interface DetailBusinessViewController : UIViewController <KASlideShowDelegate> {
    NSString *businessNameData;
    NSString *customerProfileName;
    NSString *distanceInMileString;
    int isCustomer;
    Business *biz;

    __weak IBOutlet UIButton *enterAndGetService;
}

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(weak, nonatomic) IBOutlet UITextView *contactInfo;
@property(weak, nonatomic) IBOutlet UITextField *rating;
@property(weak, nonatomic) IBOutlet UITextView *typesOfBusiness;
@property (weak, nonatomic) IBOutlet UIButton *showCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *voteTobeCustomerButton;

@property(atomic, retain) NSString *distanceInMileString;
@property(atomic, retain) NSString *businessNameData;
@property(atomic, retain) NSString *customerProfileName;
@property(nonatomic, assign) int isCustomer;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIView *picturesView_KSSlide;

@property(atomic, retain) Business *biz;

- (id)initWithBusinessObject:(Business *)biz;
- (IBAction)enterAndGetServiceAction:(id)sender;
- (IBAction)showCode:(id)sender;
- (IBAction)voteTobeCustomerAction:(id)sender;

- (void)doPopulateDisplayFields;


@end
