//
//  AddressVC.h
//  TapForAll
//
//  Created by Lalit on 10/11/16.
//
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@class MBProgressHUD;


@interface AddressVC : UIViewController
{
    MBProgressHUD *HUD;

}
- (IBAction)btnBackClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UITextField *delivery_Location_Textfield;
@property (weak, nonatomic) IBOutlet UITextField *selceted_Location_TextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTime_TextField;

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) NSMutableArray *locationArr;
@property (strong, nonatomic) NSMutableArray *locationNameArr;

@property (strong, nonatomic) NSArray *filterArray;
@property (strong, nonatomic) NSArray *latestDeliveryInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryStartEndTime;

@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (weak, nonatomic) IBOutlet AsyncImageView *mapImageAsyncView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (assign) BOOL isPickerOpen;
@property (weak, nonatomic) IBOutlet UIButton *btnDateTime;
@property (weak, nonatomic) IBOutlet UITextField *txtNote;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryTIme;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelSearch;

- (IBAction)btnOk_Clicked:(id)sender;
- (IBAction)btnCancel_Clicked:(id)sender;
- (IBAction)BtnDateTimeClicked:(id)sender;
- (IBAction)btnCancelSearch:(id)sender;

@end
