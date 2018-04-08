//
//  StoreMapViewController.m
//  TapTalk
//
//  Created by Amir on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreMapViewController.h"
#import "TapTalkLooks.h"
#import "CurrentBusiness.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "DetailBusinessVCTableViewCell.h"
#import "APIUtility.h"
#import "AppData.h"

@implementation StoreMapViewController
@synthesize storeMapImageView;
@synthesize mapScrollView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton =  true;
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];

    
    mapScrollView.delegate = self;
    NSString *mapSubDir = [CurrentBusiness sharedCurrentBusinessManager].business.map_image_url;
    if (mapSubDir == nil) {
//        [UIAlertView showErrorAlert:@"Map is not given to us."];
        [UIAlertController showOKAlertForViewController:self withText:@"Map is not given to us."];
        return;
    }
    
    
    
    self.bussinessListByBranch = [[NSMutableArray alloc] init];
    
    self.tblStore.delegate = self;
    self.tblStore.dataSource = self;
    
    [self setBusinessData];
    
    NSString *imageURLString = [BusinessCustomersMapDirectory stringByAppendingString:mapSubDir];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                            if (image && finished) {
                                self.storeMapImageView.image = image;
                                self.mapScrollView.contentSize = self.storeMapImageView.image.size;
                                self.mapScrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
                                self.mapScrollView.minimumZoomScale = 1;
                                self.mapScrollView.maximumZoomScale = 5;
                                [self.mapScrollView setScrollEnabled:YES];
                                self.mapScrollView.contentInset = UIEdgeInsetsZero;
                            }
                        }];
    
//    [TapTalkLooks setBackgroundImage:mapScrollView];

}


- (void)viewDidUnload {
    storeMapImageView = nil;
    [self setStoreMapImageView:nil];
    mapScrollView = nil;
    [self setMapScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    storeMapImageView = nil;
    [self setStoreMapImageView:nil];
    mapScrollView = nil;
    [self setMapScrollView:nil];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.storeMapImageView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [mapScrollView setZoomScale:1.0 animated:YES];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)inscrollView
{
    UIView *subView = [inscrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (inscrollView.bounds.size.width > inscrollView.contentSize.width)?
    (inscrollView.bounds.size.width - inscrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (inscrollView.bounds.size.height > inscrollView.contentSize.height)?
    (inscrollView.bounds.size.height - inscrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(inscrollView.contentSize.width * 0.5 + offsetX,
                                 inscrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bussinessListByBranch.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"DetailBusinessVCTableViewCell";
    
    DetailBusinessVCTableViewCell *cell = (DetailBusinessVCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailBusinessVCTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *cellDict;
    cellDict = [self.bussinessListByBranch objectAtIndex:indexPath.row];
    Business *biz1 = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:indexPath.row]];
    
    cell.lblOpenCloseDate.text =[[APIUtility sharedInstance]getOpenCloseTime:biz1.opening_time CloseTime:biz1.closing_time];
    
    NSString *tmpIconName = biz1.iconRelativeURL;
    if (tmpIconName != (id)[NSNull null] && tmpIconName.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:tmpIconName];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        [[cell imgBusinessIcon] Compatible_setImageWithURL:imageURL placeholderImage:nil];
    }
    
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"Star.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_Half_Empty.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_Filled.png"];
    cell.rateView.rating = 0;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
    
    cell.titleLabel.text = biz1.title;
    cell.subtitleLabel.text = biz1.address;
    cell.bussinessType.text = biz1.businessTypes;
    cell.bussinessAddress.text = biz1.neighborhood;
    
    cell.distance.text = [NSString stringWithFormat:@"%.1f m",[[AppData sharedInstance]getDistance:biz1.lat longitude:biz1.lng]];
    cell.rateView.rating = [biz1.rating floatValue];
    
    if([[APIUtility sharedInstance]isBusinessOpen:biz1.opening_time CloseTime:biz1.closing_time]){
        cell.lblOpenClose.text = @"OPEN NOW";
        cell.lblOpenClose.textColor = [UIColor greenColor];
    }else{
        cell.lblOpenClose.text = @"CLOSE";
        cell.lblOpenClose.textColor = [UIColor redColor];
    }
    
    cell.btnFevorite.tag = indexPath.row;
    [cell.btnFevorite  addTarget:self action:@selector(FevoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (IBAction)FevoriteButtonClicked:(UIButton *) sender
{
    NSInteger index = sender.tag;
    Business *business = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:index]];
    
    if(sender.selected) {
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"0"];
        sender.selected = false;
    }
    else {
        [self setFavoriteAPICallWithBusinessId:[NSString stringWithFormat:@"%d",business.businessID] rating:@"5"];
        sender.selected = true;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld",(long)indexPath.row);
    
    
    //        BusinessServicesViewController *BusinessDetailsVC = [[BusinessServicesViewController alloc] initWithNibName:@"BusinessServicesViewController" bundle:nil];
//    Business *biz1 = [[Business alloc] initWithDataFromDatabase:[self.bussinessListByBranch objectAtIndex:indexPath.row]];
//    [self enterAndGetServiceAction:self];
}

#pragma mark - Custom Methods

- (IBAction) backButtonClicked: (id) sender;
{
        [self.navigationController popViewControllerAnimated:true];
//    [self.navigationController popToRootViewControllerAnimated:true];
}


- (void) setBusinessData {
    [self.bussinessListByBranch removeAllObjects];
    
    NSDictionary *business1 = @{
                                @"active" : @"1",
                                @"address" : @"4720 NW Bethany Blvd E6, Portland, OR 97229 ",
                                @"bg_image" : @"koi_bg_image.png",
                                @"branch" : @"0",
                                @"businessID" : @"1",
                                @"businessTypes" : @"Mobile Food",
                                @"chat_masters" : @"[{\n    \"id\": \"1234567853\",\n    \"business_name\": \"KOI Fusion\"\n}]",
                                @"chatroom_table" : @"chatitems_koi",
                                @"city" : @"Portland",
                                @"closing_time" : @"13:00:00",
                                @"customerProfileName" : @"mobile food",
                                @"date_added" : @"2015-12-26",
                                @"date_dropped" : @"<null>",
                                @"description" : @"Beta customer",
                                @"email" : @"<null>",
                                @"exclusive" : @"0",
                                @"external_reference_no" : @"<null>",
                                @"hours" : @"",
                                @"icon" : @"KoiFusion_logo.png",
                                @"inquiry_for_product" : @"0",
                                @"lat" : @"45.55409990",
                                @"lng" : @"-122.83644930",
                                @"map_image_url" : @"<null>",
                                @"marketing_statement" : @"Authentic Korean Flavors with a Twist",
                                @"name" : @"KOI Fusion",
                                @"neighborhood" : @"Portland",
                                @"opening_time" : @"11:00:00",
                                @"operating_hours" : @"<null>",
                                @"payment_processing_email" : @"<null>",
                                @"payment_processing_id" : @"<null>",
                                @"phone" : @"415-867-6326",
                                @"pictures" : @"koi_food1.jpg, koi_food2.jpg, koi_food3.jpg, koi_food4.jpg, koi_food5.jpg, koi_food6.jpg",
                                @"rating" : @"4",
                                @"short_name" : @"KOI",
                                @"should_tip" : @"1",
                                @"sms_no" : @"415-867-6326",
                                @"state" : @"OR",
                                @"ti_rating" : @"0",
                                @"validate_chat" : @"0",
                                @"website" : @"http://koifusionpdx.com",
                                @"zipcode" : @"97229",
                                };
        
    [self.bussinessListByBranch addObject:business1];
    [self.tblStore reloadData];
}

- (void) setFavoriteAPICallWithBusinessId : (NSString *) businessId rating : (NSString *) favRating {
    
    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    NSDictionary *param = @{@"cmd":@"setRatings",@"consumer_id":@"1",@"rating":favRating,@"id":businessId,@"type":@"1"};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]setFavoriteAPICall:param completiedBlock:^(NSDictionary *response) {
        
    }];
}


@end
