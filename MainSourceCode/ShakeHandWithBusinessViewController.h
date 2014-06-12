//
//  ShakeHandWithBusinessViewController.h
//  TapForAll
//
//  Created by Amir on 1/17/14.
//
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "QRData.h"

@interface ShakeHandWithBusinessViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil businessObject:(Business *)bizArg;


@property (strong, nonatomic) Business *shakeHandBiz;
@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (strong, nonatomic) IBOutlet UITextView *instructionTextView;
@property (strong, nonatomic) QRData *qrdata;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;


- (IBAction)CancelAction:(id)sender;

- (IBAction)DoneAction:(id)sender;

@end
