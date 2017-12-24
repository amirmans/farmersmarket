//
//  ProductMoreInformation.h
//  TapForAll
//
//  Created by Amir on 8/6/14.
//
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface ProductMoreInformationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSDictionary *product;
    BOOL displayInquiryAction;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)productArg displayInquiryAction:(BOOL)displayAction;

@property (strong, nonatomic) IBOutlet JBKenBurnsView *productView;
@property (strong, nonatomic) IBOutlet JBKenBurnsView *productView1;

@property (weak, nonatomic) IBOutlet UITableView *moreInformationTableView;
@property (nonatomic, strong) NSDictionary *product;
@property (atomic, assign) BOOL displayInquiryAction;
@property (strong, nonatomic) IBOutlet UIButton *contactForInquiryButton;
- (IBAction)contactForInquiryAction:(id)sender;

@end
