//
//  BillViewController.m
//  TapTalk
//
//  Created by Amir Amirmansoury on 9/14/11.
//  Copyright (c) 2011 __MyDoosts__. All rights reserved.
//
#include <stdlib.h>

#import "BillViewController.h"
#import "TapTalkLooks.h"
#import "AskForSeviceViewController.h"
#import "Business.h"
#import "BillPayViewController.h"


@interface BillPayViewController() {
 
    NSDictionary *orderDict;
}

@property (nonatomic, retain) NSDictionary *orderDict;

@end

@implementation BillViewController

@synthesize rateView = _rateView;
@synthesize ratingString;
//@synthesize billImageView, billScrollView;
@synthesize cancelUIButton;
@synthesize payUIButton;
@synthesize questionsUIButton;
@synthesize billBusiness;
@synthesize billInDollar;
@synthesize orderTableView;

//TODO
- (void)pullBillInformationFromBusiness
{
    int r = arc4random() % 10000;
    billInDollar = [[NSDecimalNumber alloc] initWithInt:r];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forBusiness:(Business *)biz
 {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        billBusiness = biz;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [TapTalkLooks setBackgroundImage:self.view withBackgroundImage:billBusiness.bg_image];
//    [TapTalkLooks setBackgroundImage:self.orderTableView withBackgroundImage:billBusiness.bg_image];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    NSString *titleString = [NSString stringWithFormat:@"Bill from %@", billBusiness.businessName];
//    self.title = titleString;
    [self pullBillInformationFromBusiness];
    [TapTalkLooks setToTapTalkLooks:payUIButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:cancelUIButton isActionButton:YES makeItRound:YES];
    [TapTalkLooks setToTapTalkLooks:questionsUIButton isActionButton:YES makeItRound:YES];

    _rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    _rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    _rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    _rateView.rating = 0;
    _rateView.editable = YES;
    _rateView.maxRating = 5;
    _rateView.delegate = self;

//    [billScrollView setBackgroundColor:[UIColor blackColor]];
//    [billScrollView setCanCancelContentTouches:NO];
//    billScrollView.clipsToBounds = YES;

//    billScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
//    CGSize billSize = CGSizeMake(billImageView.frame.size.width, billImageView.frame.size.height);
//    [billScrollView setContentSize:billSize];
//    [billScrollView addSubview:billImageView];
    
    // now add the history button to the navigation controller bar
    UIBarButtonItem *billsHistoryButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Bill history"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(loadBillHistory)];
    self.navigationItem.rightBarButtonItem = billsHistoryButton;
}


- (void)loadBillHistory {
    
}

- (void)viewDidUnload {
//    billScrollView = nil;
//    billImageView = nil;
    [self setPayUIButton:nil];
    [self setQuestionsUIButton:nil];
    [self setCancelUIButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)readyToPayAction:(id)sender {
    
    BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:billInDollar forBusiness:billBusiness];
    [self.navigationController pushViewController:payBillViewController animated:YES];
}

- (IBAction)questionsAction:(id)sender {
    
    AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:billBusiness];
    [self.navigationController pushViewController:orderViewController animated:YES];
}


- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    const int intRating = roundf(rating);
    NSString *strRating = @"No opinion";
    switch (intRating) {
        case 1:
            strRating = @"No opinion";
            break;
        case 2:
            strRating = @"No good";
            break;
        case 3:
            strRating = @"Average good";
            break;
        case 4:
            strRating = @"Good";
            break;
        case 5:
            strRating = @"Wow";
            break;
        default:
            strRating = @"No opinion";
    }
    ratingString.text = strRating;
}

- (NSDictionary *)orderDict {
    if (!self.orderDict) {
     
        
    }
    return @{@"":@""};
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BillTableViewCellIdentifier";
    
    UITableViewCell *cell = [orderTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    return cell;
}


#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This function is called before cellForRowAtIndexPath, once for each cell.
    // We calculate the size of the speech bubble here and then cache it in the
    // Message object, so we don't have to repeat those calculations every time
    // we draw the cell. We add 16px for the label that sits under the bubble.
//    NSDictionary *tempMessage = [[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row];
//    [ttChatMessage setValuesFrom:tempMessage];
//    //TODO: cleanup
//    //    ttChatMessage.bubbleSize = [SpeechBubbleView sizeForText:ttChatMessage.textChat];
//    
//    //return ttChatMessage.bubbleSize.height + 16;
//    //    return 96;
//    
//    
//    
//    NSString *comment = ttChatMessage.textChat;
//    CGFloat whidt =  300;
//    UIFont *FONT = [UIFont systemFontOfSize:12];
//    NSAttributedString *attributedText =[[NSAttributedString alloc]  initWithString:comment  attributes:@  {      NSFontAttributeName: FONT }];
//    CGRect rect = [attributedText boundingRectWithSize:(CGSize){whidt, MAXFLOAT}
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                               context:nil];
//    CGSize size = rect.size;
//    return size.height +55;
    return 0.0;
}


@end
