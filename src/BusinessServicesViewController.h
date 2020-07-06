//
//  BusinessServicesViewController.h
//  TapForAll
//
//  Created by Sanjay on 2/8/16.
//
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "Business.h"
#import "KASlideShow.h"
#import "DataModel.h"
#import "AppDelegate.h"


@interface BusinessServicesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate, KASlideShowDelegate, MFMessageComposeViewControllerDelegate, KASlideShowDataSource, UIAlertViewDelegate> {

    NSDictionary *allChoices;
    NSArray *mainChoices;
    NSString *chosenMainMenu;
    Business *biz;
    NSMutableArray *BgPictureArray;

}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ImageProgress;

@property (weak, nonatomic) IBOutlet UITextView *tv_address;

@property (weak, nonatomic) IBOutlet UITextView *tv_website;
@property (weak, nonatomic) IBOutlet UILabel *lbl_businessType;
@property (weak, nonatomic) IBOutlet UILabel *lbl_distance;
@property (weak, nonatomic) IBOutlet UITextField *tf_pickup_datatime;

@property(atomic, retain) Business *biz;
//@property (strong, nonatomic) UIImage *cellBackGroundImageForCustomer;i

@property (strong, nonatomic) NSTimer *timerToLoadProducts;

- (id)initWithData:(NSDictionary *)allChoices :(NSArray *)mainChoices :(NSString *)chosenMainMenu forBusiness:(Business *)argBiz;

- (void) getDistanceFromLocation : (NSString *)address;

//-(double)getDistanceMetresBetweenLocationCoordinates;
@property (strong, nonatomic) IBOutlet UITextView *tv_biz_website;

@property (strong, nonatomic) IBOutlet RateView *ratingView;

@property (strong, nonatomic) IBOutlet UIView *DirectionView;

@property (weak, nonatomic) IBOutlet UITextField *tf_pickup_location;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *lbl_time;

@property (strong, nonatomic) IBOutlet UILabel *lbl_cutoff_datetime;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Address;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIImageView *img_BusinessImage;
@property (strong, nonatomic) IBOutlet UITableView *businessTableView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;

@property (strong, nonatomic) IBOutlet UIImageView *busicessBackgroundImage;

@property(strong,nonatomic)NSArray *img_Array;
@property(strong,nonatomic)NSArray *name_Array;

@property(nonatomic, retain) CLLocation *currentLocation;

@end
