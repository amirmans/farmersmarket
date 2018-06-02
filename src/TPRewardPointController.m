//
//  TPRewardPointController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "TPRewardPointController.h"
#import "TPRewardPointCell.h"
#import "APIUtility.h"

@interface TPRewardPointController ()

@end

@implementation TPRewardPointController

double dollarValueDouble = 0;
NSInteger current_points_level_int  = 0;
@synthesize currency_symbol;
@synthesize currency_code;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currency_code =  [CurrentBusiness sharedCurrentBusinessManager].business.curr_code;
    self.currency_symbol = [CurrentBusiness sharedCurrentBusinessManager].business.curr_symbol;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController setSelectedIndex:4];
      [AppData sharedInstance].Current_Selected_Tab = @"4";
    Business *biz = [CurrentBusiness sharedCurrentBusinessManager].business;
    self.businessBackgrounImage.image = biz.bg_image;

    
    [self getRewardAPICallWithBusinessId];
    
    if ([AppData sharedInstance].isFromTotalCart == true) {
        [self redirectFromTotalCart:true];
        [AppData sharedInstance].isFromTotalCart = false;
    }
    else {
        [self redirectFromTotalCart:false];
    }
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
        cell.lblreddemed.text  = @"Earned Points";
        date = [dic objectForKey:@"time_earned"];
    }else{
        cell.lblreddemed.text  = @"Redeemed Points";
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
    //  cell.backgroundColor = [UIColor colorWithHue:245/255.0f saturation:245/255.0f brightness:245/255.0f alpha:1];
    
    return cell;
}

- (void)getRewardAPICallWithBusinessId{
    
//  NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    
    Business *b = [CurrentBusiness sharedCurrentBusinessManager].business;
    
    int businessid = b.businessID;
    
    NSDictionary *param = @{@"cmd":@"get_all_points",@"consumerID":[NSNumber numberWithInteger:[DataModel sharedDataModelManager].userID],@"businessID":[NSNumber numberWithInteger:businessid]};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]getRewardpointsForBusiness:param completiedBlock:^(NSDictionary *response) {
        
        int status = [[response objectForKey:@"status"] intValue];
        
        if (status == 1){
            
            NSMutableDictionary *data = [response valueForKeyPath:@"data"];
//            NSDictionary *dic = [data valueForKeyPath:@"current_points_level"];
            NSString *total_available_points= @"0";
            if ([data valueForKeyPath:@"total_available_points"] != [NSNull null]) {
                total_available_points = [[data valueForKeyPath:@"total_available_points"] stringValue];
                self.lblPoints.text = [NSString stringWithFormat:@"Points: %@",total_available_points];
                
                dollarValueDouble = [total_available_points doubleValue]/Points_to_dollar; 
            }
            
            if ([CurrentBusiness sharedCurrentBusinessManager].business) {
                
                NSString *currentPointsMessage =@"";
                double dollarValueForEachPoint = 0.0;
                NSInteger nextLevelpoints = 0;
                NSInteger currentPoints = 0;
                if ([data valueForKeyPath:@"current_points_level"] != [NSNull null]) {
                    NSDictionary *current_points_level = [data valueForKeyPath:@"current_points_level"];
                    float dollarValue = 0.0;
                    currentPoints = [[current_points_level valueForKey:@"points"] integerValue];
     
                    current_points_level_int = currentPoints;
                    if (currentPoints > 0) {
                        if ([current_points_level valueForKey:@"dollar_value"] != [NSNull null]) {
                            dollarValue = [[current_points_level valueForKey:@"dollar_value"] floatValue];
                            if (dollarValue > 0) {
                                dollarValueForEachPoint = dollarValue / currentPoints;
//                                currentPointsMessage = [NSString stringWithFormat:@"Your points are worth %2.0f¢ each", dollarValueForEachPoint*100];
                                currentPointsMessage = [NSString stringWithFormat:@"You passed the thereshold.  Redeem points"];
                            }
                        }
                    }
                }
                
                if ([currentPointsMessage length] > 0) {
    //                self.lblRedeemPoints.hidden = false;
                    self.lblCongrats.hidden = false;
                    self.lblRedeemPoints.text = currentPointsMessage;
                } else {
    //                self.lblRedeemPoints.hidden = true;
                    self.lblCongrats.hidden = true;
                }
                
                if ([data valueForKeyPath:@"next_points_level"] != [NSNull null]) {
                    NSDictionary *next_points_level = [data valueForKeyPath:@"next_points_level"];
                    float dollarValue = 0.0;
                    nextLevelpoints = [[next_points_level valueForKey:@"points"] integerValue];
                    
                    if ([next_points_level valueForKey:@"dollar_value"] != [NSNull null]) {
                        dollarValue = [[next_points_level valueForKey:@"dollar_value"] floatValue];
                    }
                    
                    if (nextLevelpoints > 0) {
                        self.lblNextLevelPoints.hidden = false;
                        self.lblNextLevelPoints.text = [NSString stringWithFormat:@"Next level is %ld points for %@%.2f",(long)nextLevelpoints,self.currency_symbol,dollarValue];
                    }
                    else {
                        self.lblNextLevelPoints.hidden = true;
                    }
                }
                
                
                if (dollarValueForEachPoint <= 0.0) {
                    currentPointsMessage = [NSString stringWithFormat:@"Earn at least %ld points to redeem them", (long)nextLevelpoints];
                    self.lblRedeemPoints.text = currentPointsMessage;
                }

                // this was in the first release
    //            self.lblRedeemPoints.text = @"Keep earning points.";
    //            self.lblNextLevelPoints.text = @"Redeem them with the next app update.";
                
    //            if ([dic valueForKeyPath:@"points_earned"] != [NSNull null])
            } else {
                // we have not chosen an business yet
                self.lblCongrats.hidden = true;
                self.lblNextLevelPoints.hidden = true;
                self.lblRedeemPoints.text = [NSString stringWithFormat:@"Your total points for all businesses: %@",total_available_points];
            }
            self.pointsarray = [data valueForKeyPath:@"points"];
            [self.tableView reloadData];
        }
    }];
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

- (void) checkCurrentPoints {
    if((dollarValueDouble*Points_to_dollar) > 0) {
        if((dollarValueDouble*Points_to_dollar) > current_points_level_int) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedeemPoints object:nil];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"You have %ld points, You need more %.f points to redeem",(long)current_points_level_int,((dollarValueDouble*Points_to_dollar) - current_points_level_int)];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:true completion:^{
                
            }];
        }
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"You have no points to redeem" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:^{
            
        }];
    }
}

#pragma mark - Button Actions

- (IBAction)btnRedeemClicked:(id)sender {
    [self checkCurrentPoints];
}

- (IBAction)btnWaitClicked:(id)sender {
}


@end
