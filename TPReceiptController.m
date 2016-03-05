//
//  TPRewardsController.m
//  TapForAll
//
//  Created by Harry on 2/18/16.
//
//

#import "TPReceiptController.h"
#import "TotalCartItemCell.h"
#import "AppDelegate.h"

@interface TPReceiptController ()

@end

@implementation TPReceiptController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Receipt";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"< Done" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self paymentSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backBUttonClicked: (id) sender;
{
//    [self.navigationController popViewControllerAnimated:true];
    [self.navigationController popToRootViewControllerAnimated:true];
}

// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return FetchedRecordArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"TotalCartItemCell";
    TotalCartItemCell *cell = (TotalCartItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TotalCartItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    currentObject = FetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [currentObject valueForKey:@"quantity"];
    
    CGFloat val = [[currentObject valueForKey:@"price"] floatValue];
    val =  val * [[currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = floorf(val * 100) / 100;
    cell.lbl_Price.text = [NSString stringWithFormat:@"$%.2f",rounded_down];
    
    cell.lbl_Description.text = [currentObject valueForKey:@"product_descrption"];
    cell.lbl_Title.text = [currentObject valueForKey:@"productname"];
    
    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

// set total oder and Price
- (void)paymentSummary{
    
    managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    CGFloat TotalPrice = 0.0f;
    for (NSManagedObject *obj in FetchedRecordArray) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];

        CGFloat val = [[dictionary valueForKey:@"price"] floatValue];
        val =  val * [[dictionary valueForKey:@"quantity"] integerValue];
        CGFloat rounded_down = floorf(val * 100) / 100;
        TotalPrice += rounded_down;
    }
    
    self.lbl_Total.text = [NSString stringWithFormat:@"$%.2f",TotalPrice];
}


@end
