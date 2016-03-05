//
//  TPRewardPointController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "TPRewardPointController.h"
#import "TPRewardPointCell.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
//    cell.backgroundColor = [UIColor colorWithHue:245/255.0f saturation:245/255.0f brightness:245/255.0f alpha:1];
    return cell;
}

@end
