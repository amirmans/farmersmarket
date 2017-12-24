//
//  ProductMoreInformation.m
//  TapForAll
//
//  Created by Amir on 8/6/14.
//
//

#import "ProductMoreInformationViewController.h"
#import "AskForSeviceViewController.h"
#import "CurrentBusiness.h"
#import "TapTalkLooks.h"
#import "Tap4AllDisplayUtil.h"

@interface ProductMoreInformationViewController () {

}
@property (nonatomic, strong) NSArray *productMoreInformation;

- (UITableViewCell *)setCellValuesForCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;

@end


@implementation ProductMoreInformationViewController

@synthesize product;
@synthesize productMoreInformation;
@synthesize displayInquiryAction;
@synthesize moreInformationTableView;
@synthesize contactForInquiryButton;
@synthesize productView;
@synthesize productView1;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)productArg displayInquiryAction:(BOOL)displayAction
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        product = productArg;
        productMoreInformation = [product objectForKey:@"MoreInformation"];
        displayInquiryAction = displayAction;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"More info";
    [TapTalkLooks setBackgroundImage:self.view];
    if (displayInquiryAction) {
        contactForInquiryButton.hidden = FALSE;
    } else {
        contactForInquiryButton.hidden = TRUE;
    }
    [TapTalkLooks setToTapTalkLooks:contactForInquiryButton isActionButton:YES makeItRound:NO];
    [TapTalkLooks setToTapTalkLooks:self.moreInformationTableView isActionButton:NO makeItRound:NO];
    NSString *stringOfPictures = [product objectForKey:@"PictureArray"];
    NSArray *pictureArray = [stringOfPictures componentsSeparatedByString:@","];
    [Tap4AllDisplayUtil displayPicturesInJBKenBurnsViewFromArrayOfURLs:pictureArray forPictureview:productView inParentView:self.view];
    [Tap4AllDisplayUtil displayPicturesInJBKenBurnsViewFromArrayOfURLs:pictureArray forPictureview:productView1 inParentView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return productMoreInformation.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductMoreInformationViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
         
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:NO];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue Light" size:15];
    
    cell = [self setCellValuesForCell:cell withIndexPath:indexPath];
    
    return cell;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (UITableViewCell *)setCellValuesForCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *nameValuePair = [productMoreInformation objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[nameValuePair objectForKey:@"name"]];
    [cell.detailTextLabel setText:[nameValuePair objectForKey:@"value"]];
    return cell;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    // 1. The view for the header
//    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
//    
//    // 2. Set a custom background color and a border
//    headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
//    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
//    headerView.layer.borderWidth = 1.0;
//    
//    // 3. Add a label
//    UILabel* headerLabel = [[UILabel alloc] init];
//    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textColor = [UIColor whiteColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
//    headerLabel.text = @"This item has this aditional information";
//    headerLabel.textAlignment = NSTextAlignmentCenter;
//    
//    // 4. Add the label to the header view
//    [headerView addSubview:headerLabel];
//    
//    // 5. Finally return
//    return headerView;
//}

- (IBAction)contactForInquiryAction:(id)sender {
    NSString *message = [NSString stringWithFormat:@"I want to know more about %@ with SKU of %@ ", [product objectForKey:@"Name"], [product objectForKey:@"SKU"]];
    AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:[CurrentBusiness sharedCurrentBusinessManager].business];
    orderViewController.initialMessage = message;
    
    [self.navigationController pushViewController:orderViewController animated:YES];
    
}
@end
