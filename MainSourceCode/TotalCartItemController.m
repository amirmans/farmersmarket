//  TotalCartItemController.m
//  TapForAll
//  Created by Harry on 2/15/16.

#import "TotalCartItemController.h"
#import "TotalCartItemCell.h"
#import "AppDelegate.h"
#import "AskForSeviceViewController.h"
#import "BillPayViewController.h"

@interface TotalCartItemController ()

@end

@implementation TotalCartItemController

@synthesize itemCartTableView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Orders";
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBUttonClicked:)];
    self.navigationItem.leftBarButtonItem = BackButton;
    BackButton.tintColor = [UIColor whiteColor];
    
    self.itemCartTableView.delegate = self;
    self.itemCartTableView.dataSource = self;
    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray= [[NSMutableArray alloc]initWithArray:[AppDelegate sharedInstance].getRecord];
    NSLog(@"%lu",(unsigned long)_FetchedRecordArray.count);
    
    zero = [NSDecimalNumber zero];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.itemCartTableView.contentInset = UIEdgeInsetsMake(self.itemCartTableView.frame.origin.x, self.itemCartTableView.frame.origin.y, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.itemCartTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self paymentSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// Table View Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _FetchedRecordArray.count;
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

    _currentObject = _FetchedRecordArray[indexPath.row];
    cell.lbl_totalItems.text = [self.currentObject valueForKey:@"quantity"];
    
    CGFloat val = [[self.currentObject valueForKey:@"price"] floatValue];
    val =  val * [[self.currentObject valueForKey:@"quantity"] integerValue];
    CGFloat rounded_down = floorf(val * 100) / 100;
    cell.lbl_Price.text = [NSString stringWithFormat:@"$%.2f",rounded_down];
    
    cell.lbl_Description.text = [self.currentObject valueForKey:@"product_descrption"];
    cell.lbl_Title.text = [self.currentObject valueForKey:@"productname"];

    cell.btn_minus.tag = indexPath.row;
    cell.btn_minus.section = indexPath.section;
    cell.btn_minus.row = indexPath.row;
    
    [cell.btn_minus addTarget:self action:@selector(MinusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btn_plus.tag = indexPath.row;
    cell.btn_plus.section = indexPath.section;
    cell.btn_plus.row = indexPath.row;
    [cell.btn_plus addTarget:self action:@selector(PlusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)PlusButtonClicked:(UIButton*)sender
{
}

-(void)MinusButtonClicked:(UIButton*)sender
{
}

// set total oder and Price
- (void)paymentSummary{

    _managedObjectContext= [[AppDelegate sharedInstance]managedObjectContext];
    self.FetchedRecordArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate sharedInstance]getRecord]];
    int QTY = 0;
    CGFloat TotalPrice = 0.0f;
    for (NSManagedObject *obj in self.FetchedRecordArray) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        QTY += [[dictionary valueForKey:@"quantity"] integerValue];
        CGFloat val = [[dictionary valueForKey:@"price"] floatValue];
        val =  val * [[dictionary valueForKey:@"quantity"] integerValue];
        CGFloat rounded_down = floorf(val * 100) / 100;
        TotalPrice += rounded_down;
    }
    
    self.lblSubTotalPrice.text = [NSString stringWithFormat:@"$ %.2f",TotalPrice];
    self.lblQty.text = [NSString stringWithFormat:@"%d",QTY];
    self.lblTotalPrice.text = [NSString stringWithFormat:@"$ %.2f",TotalPrice];
    billInDollar = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",TotalPrice]];
}

// Button Clicked

- (IBAction) backBUttonClicked: (id) sender;
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnPayButtonClicked:(id)sender {
    
    if ([billInDollar compare:zero] ==  NSOrderedDescending) {
        BillPayViewController *payBillViewController = [[BillPayViewController alloc] initWithNibName:nil bundle:nil withAmount:billInDollar forBusiness:billBusiness];
        [self.navigationController pushViewController:payBillViewController animated:YES];
    }
}

- (IBAction)btnCancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnQuestionClicked:(id)sender {
    AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:billBusiness];
    [self.navigationController pushViewController:orderViewController animated:YES];
}
@end
