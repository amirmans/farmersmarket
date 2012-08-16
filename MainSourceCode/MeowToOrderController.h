//
//  MeowToOrderController.h
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeowToOrderController : UIViewController <UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate> {
    UITextField *errorMessageView;
    UITextView *orderView;
}

@property (weak, nonatomic) IBOutlet UIButton *cancelUIButton;
@property (weak, nonatomic) IBOutlet UIButton *askUIButton;
@property (atomic, retain) IBOutlet UITextView *orderView;
@property (atomic, retain) IBOutlet UITextField *errorMessageView;


- (IBAction) meow;
- (IBAction)Cancel:(id)sender;

@end
