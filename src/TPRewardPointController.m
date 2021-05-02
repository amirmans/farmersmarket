//
//  TPRewardPointController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "RewardDetailsModel.h"
#import "TPRewardPointController.h"
#import "TPRewardPointCell.h"
#import "APIUtility.h"
#import "Corp.h"

@interface TPRewardPointController ()

@end

@implementation  TPRewardPointController

@synthesize currency_symbol;
@synthesize currency_code;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInsetAdjustmentBehavior = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController setSelectedIndex:4];
      [AppData sharedInstance].Current_Selected_Tab = @"4";
    Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.businessBackgrounImage.image = biz.bg_image;
    self.lbl_businessName.text = [DataModel sharedDataModelManager].shortBusinessName;
    
    if (([Corp sharedCorp].chosenCorp) && [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"]> 0 ) {
//                 corp_id = [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"];
    }

    currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;


    [self getRewardAPICallWithBusinessId];

    if ([AppData sharedInstance].isFromTotalCart == true) {
        [self redirectFromTotalCart:true];
        [AppData sharedInstance].isFromTotalCart = false;
    }
    else {
        [self redirectFromTotalCart:false];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"%ld",(unsigned long)self.pointsarray.count);
    return self.pointsarray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *simpleTableIdentifier = @"TPRewardPointCell";

    TPRewardPointCell *cell = (TPRewardPointCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TPRewardPointCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSDictionary * dic = [self.pointsarray objectAtIndex:indexPath.row];
    NSString *date = @"";

    NSInteger points = labs([[dic objectForKey:@"points"] integerValue]) ;

    [cell.btnpoints setTitle:[NSString stringWithFormat:@"%ld",(long)points] forState:UIControlStateNormal];

    if([[dic objectForKey:@"points"] integerValue] > 0){
        cell.lblreddemed.text  = @"Earned";
        date = [dic objectForKey:@"time_earned"];
    }else{
        cell.lblreddemed.text  = @"Redeemed";
        date = [dic objectForKey:@"time_redeemed"];
    }

    if (date != (id)[NSNull null]) {
        NSDateFormatter *dateformater = [[AppData sharedInstance] setDateFormatter:@"yyyy-MM-dd HH:mm:ss"];
//        NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
//        dateformater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *converteddate = [dateformater dateFromString:date];
        dateformater.dateFormat = @"MMM-dd HH:mm a";
        NSString *localdate = [dateformater stringFromDate:converteddate];
        cell.lbldate.text =localdate;
    }
    cell.lbl_order_no.text = [dic objectForKey:@"order_id"];
    //  cell.backgroundColor = [UIColor colorWithHue:245/255.0f saturation:245/255.0f brightness:245/255.0f alpha:1];

    return cell;
}

- (void)getRewardAPICallWithBusinessId{
    self.tv_points_msg3.text = @"";
    self.lblRedeemPoints.text = @"";
//  NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];

//    Business *b = [CurrentBusiness sharedCurrentBusinessManager].business;
//
//    int businessid = b.businessID;
//
//    NSString *corp_id=@"";
//    if (([Corp sharedCorp].chosenCorp) && [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"]> 0 ) {
//        corp_id = [[Corp sharedCorp].chosenCorp valueForKey:@"corp_id"];
//    }
//
//    NSDictionary *param = @{@"cmd":@"get_all_points",@"consumerID":[NSNumber numberWithInteger:[DataModel sharedDataModelManager].userID],@"businessID":[NSNumber numberWithInteger:businessid], @"corp_id":corp_id};
//    NSLog(@"param in getRewardApiCallWithBusinessID called from clicking on tabbar is =%@",param);
//
//    [[APIUtility sharedInstance]getRewardpointsForBusiness:param completiedBlock:^(NSDictionary *response) {
//
        NSDictionary *points_data = [RewardDetailsModel sharedInstance].rewardDict;
        int status = [[points_data objectForKey:@"status"] intValue];

        if (status == 1) {
//            NSString *total_available_points= @"0";
            NSMutableDictionary *data = [points_data valueForKeyPath:@"data"];
            NSDictionary *current_points_level = [data valueForKeyPath:@"current_points_level"];
            NSArray *summary_points_array = [data valueForKeyPath:@"summary_points_array"];
            int markets_points = [[summary_points_array valueForKey:@"this_market_all_points"] intValue] + [[summary_points_array valueForKey:@"all_markets_all_points"] intValue];
            self.lblCongrats.text = [NSString stringWithFormat:@"You have %i points for all vendors in this market.", markets_points];
//            self.lblCongrats.text = @"For this market you have 0 points -  yay";
            NSString *totalPoints = [summary_points_array valueForKey:@"total_points"];
            self.lblPoints.text = [NSString stringWithFormat:@"%@",totalPoints];
            int point_value =  ceil([[summary_points_array valueForKey:@"point_value"] floatValue] * 100);
            self.lbl_point_value.text = [NSString stringWithFormat:@"Each point = %i cents.", point_value];

            
            if ([CurrentBusiness sharedCurrentBusinessManager].business) {
                NSString *this_business_all_points = [summary_points_array valueForKey:@"this_business_all_points"];
                NSString *currentPointsMessage = [NSString stringWithFormat:@"For this business, You have %@ points.", this_business_all_points];

                NSString *msg3_text;
                int total_redeemable = [[summary_points_array valueForKey:@"total_redeemable"] intValue];
                if (total_redeemable > 0) {
                    msg3_text = [NSString stringWithFormat:@"Altogether: congrats, you passed the threshold and can redeem %i points", total_redeemable];
                } else {
                    msg3_text = [NSString stringWithFormat:@"You need to earm more points."];
                }
                self.tv_points_msg3.text = msg3_text;
                
                int current_point = 200;
                if ([current_points_level valueForKeyPath:@"points"] != [NSNull null]) {
                    current_point = [[current_points_level valueForKeyPath:@"points"] intValue];
                if ([this_business_all_points intValue] <= current_point)
                    currentPointsMessage = [NSString stringWithFormat:@"For this business earn at least %ld points to redeem them", (long)current_point];
                    self.lblRedeemPoints.text = currentPointsMessage;
                }

            } else {
                // we have not chosen a business yet
//                self.lblCongrats.text = @"For this market you have 0 points";
//                self.lblRedeemPoints.text = [NSString stringWithFormat:@"Your total points for all businesses in this market: %@",total_available_points];
            }
            self.pointsarray = [data valueForKeyPath:@"points"];
            [self.tableView reloadData];
        }
}

- (void) redirectFromTotalCart : (BOOL) flag {
    if(flag) {
        self.btnWait.hidden = false;
        self.btnRedeem.hidden = false;
    }
    else {
        self.btnWait.hidden = true;
        self.btnRedeem.hidden = true;
    }
}

//- (void) checkCurrentPoints {
//    if((dollarValueDouble*Points_to_dollar) > 0) {
//        if((dollarValueDouble*Points_to_dollar) > current_points_level_int) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:RedeemPoints object:nil];
//        }
//        else {
//            NSString *message = [NSString stringWithFormat:@"You have %ld points, You need more %.f points to redeem",(long)current_points_level_int,((dollarValueDouble*Points_to_dollar) - current_points_level_int)];
//
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            }];
//
//            [alert addAction:okAction];
//            [self presentViewController:alert animated:true completion:^{
//
//            }];
//        }
//    }
//    else {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"You have no points to redeem" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//
//        [alert addAction:okAction];
//        [self presentViewController:alert animated:true completion:^{
//
//        }];
//    }
//}

#pragma mark - Button Actions

//- (IBAction)btnRedeemClicked:(id)sender {
//    [self checkCurrentPoints];
//}
//
//- (IBAction)btnWaitClicked:(id)sender {
//}


@end
