//
//  ChooseProfile.h
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LetsMeowAppDelegate.h"

@interface PublicProfile : UIViewController <UITextViewDelegate, UITabBarDelegate> {
//    LetsMeowAppDelegate *appDelegate;
    UINavigationController *appNavController;
    UIButton *nameButton;
    UIButton *ageButton;
    UIButton *pictureButton;
    UIButton *interestButton;
    UIButton *quoteButton;
    UITextView *profileTextView;
    UIToolbar *toolbar;
}

//@property (atomic, retain) LetsMeowAppDelegate *appDelegate;
@property(atomic, retain) UINavigationController *appNavController;

@property(atomic, retain) IBOutlet UIButton *nameButton;
@property(atomic, retain) IBOutlet UIButton *ageButton;
@property(atomic, retain) IBOutlet UIButton *pictureButton;
@property(atomic, retain) IBOutlet UIButton *interestButton;
@property(atomic, retain) IBOutlet UIButton *quoteButton;
@property(atomic, retain) IBOutlet UITextView *profileTextView;

@property(atomic, retain) IBOutlet UIToolbar *toolbar;

- (IBAction)toggleName:(id)sender;

- (IBAction)toggleAgeGroup:(id)sender;

- (IBAction)togglePublicPicture:(id)sender;

- (IBAction)toggleBriefInterest:(id)sender;

- (IBAction)toggleMyQuoteofTheDay:(id)sender;

- (IBAction)cancel:(id)sender;

- (IBAction)meowcialize:(id)sender;

@end
