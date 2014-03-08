//
//  MeowToOrderController.h
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Business;

@interface AskForSeviceViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate> {
    UITextField *errorMessageView;
    UITextView *orderView;
    Business *myBusiness;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz;

@property(weak, nonatomic) IBOutlet UIButton *cancelUIButton;
@property(weak, nonatomic) IBOutlet UIButton *askUIButton;
@property(atomic, retain) IBOutlet UITextView *orderView;
@property(atomic, retain) IBOutlet UITextField *errorMessageView;
@property(atomic, retain) Business *myBusiness;


- (IBAction)meow;
- (IBAction)Cancel:(id)sender;

@end
