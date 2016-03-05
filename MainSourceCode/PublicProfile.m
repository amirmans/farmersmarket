//
//  PublicProfile.m
//  LetsMeow
//
//  Created by Amir Amirmansoury on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublicProfile.h"

@interface PublicProfile () {

@private
    UIImage *checkedButton;
    UIImage *uncheckedButton;
}

- (void)setCurrentChoicesToWhatWasChosenPreviuosly;

- (BOOL)textView:(UITextView *)textView replaceTextWith:(NSString *)text;

@end

@implementation PublicProfile

// keys for NSUserDefaults
#define NAME @"name"
#define AGE  @"age"
#define PICTURE @"picture"
#define INTERESTS @"interests"
#define MY_QUOTE @"quote"

// tags
// these should conform to the tags in the nib file
#define TAG_PUBLIC_PROFILE  1
#define TAG_PRIVATE_PROFILE 2
#define TAG_HELP  3


@synthesize appNavController;
@synthesize nameButton, ageButton, pictureButton, interestButton, quoteButton, profileTextView;
@synthesize toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization 
        self.title = @"Info for public";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserChoices {
    
    NSUserDefaults *profileValues = [NSUserDefaults standardUserDefaults];
    bool boolValue = nameButton.isSelected;
    [profileValues setBool:boolValue forKey:NAME];
    boolValue = quoteButton.isSelected;
    [profileValues setBool:boolValue forKey:MY_QUOTE];
    boolValue = ageButton.isSelected;
    [profileValues setBool:boolValue forKey:AGE];
    boolValue = interestButton.isSelected;
    [profileValues setBool:boolValue forKey:INTERESTS];

    [profileValues synchronize];
}


- (IBAction)meowcialize:(id)sender {
    [self saveUserChoices];
}

- (IBAction)toggleName:(id)sender {
    if (nameButton.isSelected) {
        nameButton.selected = FALSE;
    }
    else {
        nameButton.selected = TRUE;
    }

    [self textView:profileTextView replaceTextWith:@""];
}


- (IBAction)toggleAgeGroup:(id)sender {
    if (ageButton.isSelected) {
        ageButton.selected = FALSE;
    }
    else {
        ageButton.selected = TRUE;
    }

    [self textView:profileTextView replaceTextWith:@""];
}


- (IBAction)togglePublicPicture:(id)sender {
    if (pictureButton.isSelected) {
        pictureButton.selected = FALSE;
    }
    else {
        pictureButton.selected = TRUE;
    }

    [self textView:profileTextView replaceTextWith:@""];
}


- (IBAction)toggleBriefInterest:(id)sender {
    if (interestButton.isSelected) {
        interestButton.selected = FALSE;
    }
    else {
        interestButton.selected = TRUE;
    }

    [self textView:profileTextView replaceTextWith:@""];

}

- (IBAction)toggleMyQuoteofTheDay:(id)sender {
    if (quoteButton.isSelected) {
        quoteButton.selected = FALSE;
    }
    else {
        quoteButton.selected = TRUE;
    }

    [self textView:profileTextView replaceTextWith:@""];
}

- (void)setCurrentChoicesToWhatWasChosenPreviuosly {
    NSUserDefaults *profileValues = [NSUserDefaults standardUserDefaults];

    BOOL boolKey = [profileValues boolForKey:NAME];
    [nameButton setSelected:boolKey];

    boolKey = [profileValues boolForKey:MY_QUOTE];
    [quoteButton setSelected:boolKey];

    boolKey = [profileValues boolForKey:AGE];
    [ageButton setSelected:boolKey];

    boolKey = [profileValues boolForKey:INTERESTS];
    [interestButton setSelected:boolKey];

    [self textView:profileTextView replaceTextWith:@""];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    [self.view addSubview:tabBar];
//    CGRect cgrect = CGRectMake(0,0,105,30);
//    UIToolbar *toolBar1 =[[UIToolbar alloc]initWithFrame:cgrect];

//    [self.navigationController.toolbar setItems:[NSArray arrayWithObjects:toolBar1, nil]];
//    [self.navigationController.toolbar setHidden:FALSE];
    [self setCurrentChoicesToWhatWasChosenPreviuosly];
}

- (void)viewDidLayoutSubviews {
}

//TODO
/*
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == TAG_PUBLIC_PROFILE)
    {
        // current view is chosen  - don't do anything
    }
    if (item.tag == TAG_PRIVATE_PROFILE)
    {
        // load private profile view
        PrivateProfile *privateProfile = [[PrivateProfile alloc] initWithNibName:nil bundle:nil];
//        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:privateProfile animated:YES]; 
    }
    if (item.tag == TAG_HELP)
    {
        // load help view

    }

}
*/

// the replacement text isn't used - this routing builds the whole confirmation/information string 
// from scratch eact time is called
- (BOOL)textView:(UITextView *)textView replaceTextWith:(NSString *)text {
    NSString *publicProfile = @"";

    if (nameButton.isSelected)
        textView.text = @"My name is: Amir. ";
    else
        textView.text = @"";

    publicProfile = [textView.text stringByAppendingString:publicProfile];

    if (ageButton.isSelected)
        textView.text = @" I am more than 33 years old.";
    else
        textView.text = @" I am more than 21 years old.";

    publicProfile = [publicProfile stringByAppendingString:textView.text];

    if (interestButton.isSelected)
        textView.text = @" I am interested in socializing and drinking.";
    else
        textView.text = @"";

    publicProfile = [publicProfile stringByAppendingString:textView.text];

    if (quoteButton.isSelected)
        textView.text = @" It is good to be the king";
    else
        textView.text = @"";

    publicProfile = [publicProfile stringByAppendingString:textView.text];

    textView.text = publicProfile;

    return TRUE;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
