//
//  OrderDetailViewController.h
//  TapForAll
//
//  Created by Trushal on 4/7/17.
//
//

#import <UIKit/UIKit.h>
#import "CartViewSecondScreenViewController.h"
#import "Business.h"
@class MBProgressHUD;

@interface OrderDetailViewController : UIViewController{
    Business  *billBusiness;
    MBProgressHUD *HUD;
}
@property (strong,nonatomic) NSString *subTotalOD;
@property (strong,nonatomic) NSString *noteTextOD;
@property (strong,nonatomic) NSString *pd_noteTextOD;
@property (assign) NSString* delivery_startTimeOD;
@property (assign) NSString* delivery_endTimeOD;
@property (strong,nonatomic) NSString *earnPtsOD;
@property (strong,nonatomic) NSDate *pickupTimeOD;
@property (strong,nonatomic) NSMutableArray *orderItemsOD;
@property (assign) double deliveryamtOD;
@property (strong, nonatomic) NSMutableArray *locationArray;
@property (strong, nonatomic) NSMutableArray *locationNameArray;

@property (weak, nonatomic) IBOutlet UIButton *btnCounter;
@property (weak, nonatomic) IBOutlet UIButton *btnTable;
@property (weak, nonatomic) IBOutlet UIButton *btnDesignatedLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnParking;
@property (weak, nonatomic) IBOutlet UIButton *tableDropDown;
@property (weak, nonatomic) IBOutlet UITextField *txtPickuptimeDL;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;

@property (weak, nonatomic) IBOutlet UIView *viewCounter;
@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIView *viewDesignationLocation;
@property (weak, nonatomic) IBOutlet UIView *viewParking;
@property (weak, nonatomic) IBOutlet UILabel *lblHotelName;
@property (weak, nonatomic) IBOutlet UILabel *lblBusinessNote;

@property (weak, nonatomic) IBOutlet UIButton *btnCounterPickupTime;
@property (weak, nonatomic) IBOutlet UIButton *btnParkingPickUp;
@property (weak, nonatomic) IBOutlet UIButton *btnDesignationLocationPickUp;
@property (weak, nonatomic) IBOutlet UITextView *txtNotes;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;

- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnOkClicked:(id)sender;
- (IBAction)tableDropDownClicked:(id)sender;
- (IBAction)btnCounterClicked:(id)sender;
- (IBAction)btnTableClicked:(id)sender;
- (IBAction)btnDesignatedLocationClicked:(id)sender;
- (IBAction)btnParkingClicked:(id)sender;
- (IBAction)btnPickupTimeDL:(id)sender;
- (IBAction)btnLocationClicked:(id)sender;
- (IBAction)btnCounterPickUpClicked:(id)sender;
- (IBAction)btnParkingPickUpClicked:(id)sender;
- (IBAction)btnDesignationLocationPickupClicked:(id)sender;

@end
