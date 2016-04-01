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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

-(void) viewWillAppear:(BOOL)animated{
 [self setFavoriteAPICallWithBusinessId];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    
//    NSString *date = [dic objectForKey:@"time_redeemed"];
//    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
//    dateformater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSDate *converteddate = [dateformater dateFromString:date];
//    dateformater.dateFormat = @"MMM-dd HH:mm a";
//    NSString *localdate = [dateformater stringFromDate:converteddate];
    
//    cell.lbldate.text =localdate;
    cell.btnpoints.titleLabel.text = [NSString stringWithFormat:@"%ld",[[dic objectForKey:@"points"] integerValue]];
  
//    cell.backgroundColor = [UIColor colorWithHue:245/255.0f saturation:245/255.0f brightness:245/255.0f alpha:1];
    return cell;
}


- (void)setFavoriteAPICallWithBusinessId{
    
    //    NSDictionary *data = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"businessID", nil];
    Business *b =   [CurrentBusiness sharedCurrentBusinessManager].business;
    int businessid = b.businessID;
    NSDictionary *param = @{@"cmd":@"get_all_points",@"consumerID":[NSNumber numberWithInteger:[DataModel sharedDataModelManager].userID],@"businessID":[NSNumber numberWithInteger:businessid]};
    NSLog(@"param=%@",param);
    
    [[APIUtility sharedInstance]getRevardpointsForBusiness:param completiedBlock:^(NSDictionary *response) {
        int status = [[response objectForKey:@"status"] integerValue];
        if (status == 1){
            NSMutableDictionary *data = [response valueForKeyPath:@"data"];
            self.pointsarray = [data valueForKeyPath:@"points_redeemed"];
            [self.tableView reloadData];
        }
    }];
}

@end
