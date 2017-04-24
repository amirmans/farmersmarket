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
#import "TotalCartItemController.h"

@interface BusinessServicesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate, KASlideShowDelegate, MFMessageComposeViewControllerDelegate, KASlideShowDataSource, UIAlertViewDelegate> {

    NSDictionary *allChoices;
    NSArray *mainChoices;
    NSString *chosenMainMenu;
    Business *biz;
    NSMutableArray *BgPictureArray;

}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ImageProgress;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Title;

@property (weak, nonatomic) IBOutlet UIButton *btn_Address;
@property (weak, nonatomic) IBOutlet UIButton *btn_Website;

@property (weak, nonatomic) IBOutlet UILabel *lbl_SubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_StateAndDist;

@property(atomic, retain) Business *biz;
//@property (strong, nonatomic) UIImage *cellBackGroundImageForCustomer;

@property (strong, nonatomic) NSTimer *timerToLoadProducts;

- (id)initWithData:(NSDictionary *)allChoices :(NSArray *)mainChoices :(NSString *)chosenMainMenu forBusiness:(Business *)argBiz;

//-(double)getDistanceMetresBetweenLocationCoordinates;

@property (strong, nonatomic) IBOutlet RateView *ratingView;

@property (strong, nonatomic) IBOutlet UIView *DirectionView;

@property (strong, nonatomic) IBOutlet UIButton *btn_GetDirection;
- (IBAction)btn_GetDirection_Cllcked:(id)sender;

- (IBAction)btn_CallClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btn_Call;
- (IBAction)btn_Website_clicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UILabel *lbl_time;

@property (strong, nonatomic) IBOutlet UILabel *lbl_OpenNow;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Address;
@property (strong, nonatomic) IBOutlet UIView *imageView;

@property (strong, nonatomic) IBOutlet UIImageView *img_BusinessImage;
@property (strong, nonatomic) IBOutlet UITableView *businessTableView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;

@property (strong, nonatomic) IBOutlet UIImageView *busicessBackgroundImage;

- (IBAction)btn_AddressClicked:(id)sender;

- (IBAction)btn_WebsiteClicked:(id)sender;

@property(strong,nonatomic)NSArray *img_Array;
@property(strong,nonatomic)NSArray *name_Array;

@property(nonatomic, retain) CLLocation *currentLocation;

@end
