//
//  ServicesForBusinessTableViewController.m
//  ScratchTabNav
//  
//  Created by Amir on 7/24/11.
//  Copyright 2011 MyDoosts.com. All rights reserved.
//

#import "ServicesForBusinessTableViewController.h"
#import "MenuViewController.h"
#import "AskForSeviceViewController.h"
#import "BillViewController.h"
#import "ProductItemsTableViewController.h"
#import "StoreMapViewController.h"
#import "TapTalkLooks.h"
#import "MBProgressHUD.h"

@interface ServicesForBusinessTableViewController ()


@property (strong, nonatomic) NSTimer *timerToLoadProducts;

- (void)displayProduct;

@end


@implementation ServicesForBusinessTableViewController

@synthesize biz;
@synthesize timerToLoadProducts;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithData:(NSDictionary *)subAndMainChoices :(NSArray *)onlyMainChoices :(NSString *)chosenItem forBusiness:(Business *)argBiz {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        allChoices = subAndMainChoices;
        mainChoices = onlyMainChoices;
        chosenMainMenu = chosenItem;
        biz = argBiz;
        timerToLoadProducts = nil;
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

    // for some reason - setting the background color in the nib file didn't work
    [TapTalkLooks setBackgroundImage:self.tableView];
    self.title = [NSString stringWithFormat:@"TapforAll - %@", biz.businessName];

    NSArray *tempRows = [allChoices objectForKey:chosenMainMenu];
    if (tempRows == nil) {
        NSLog(@"Someting went wrong there are no rows");
        NSLog(@"Here are allchoices in the detail view....%@", allChoices);
        NSLog(@"Here is the chosen main menu...%@", chosenMainMenu);
    }

    CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
    NSInteger tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSUInteger numberOfRows = tempRows.count;
    if (numberOfRows == 0)
        numberOfRows++;
    CGFloat rowHeight = (screenHeight - navbarHeight- tabbarHeight-statusBarHeight) / (numberOfRows);
    self.tableView.rowHeight = rowHeight;
}


- (void)viewWillAppear:(BOOL)animated {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (@"TapTalk it");
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *tempArr = [allChoices objectForKey:chosenMainMenu];
    return ([tempArr count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TapTalk"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TapTalk"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor blueColor];
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"indicator.png"]];
//        [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 46)];
        [TapTalkLooks setToTapTalkLooks:cell isActionButton:NO makeItRound:NO];
    }

    cell.textLabel.text = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];


    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tmpStr = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    tmpStr = [tmpStr lowercaseString];
    NSUInteger whileIndex = 0;
    while (whileIndex < 5) {
        if (whileIndex == 0) {
            if ([tmpStr rangeOfString:@"menu"].location != NSNotFound) {
                MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:menuViewController animated:YES];
            }
        }
        if (whileIndex == 1) {
            if (([tmpStr rangeOfString:@"food or drink"].location != NSNotFound) || ([tmpStr rangeOfString:@"service"].location != NSNotFound)) {
                AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:biz];
                [self.navigationController pushViewController:orderViewController animated:YES];
            }
        }

        if (whileIndex == 2) {
            if ([tmpStr rangeOfString:@"bill"].location != NSNotFound) {
                BillViewController *billViewController = [[BillViewController alloc] initWithNibName:nil bundle:nil forBusiness:biz];
                [self.navigationController pushViewController:billViewController animated:YES];
            }
        }

        if (whileIndex == 3) {
            if ([tmpStr rangeOfString:@"map"].location != NSNotFound) {
                StoreMapViewController *storeMapViewController = [[StoreMapViewController alloc] initWithNibName:nil bundle:nil];
                storeMapViewController.title = [NSString stringWithFormat:@"Map of %@",biz.businessName];
                [self.navigationController pushViewController:storeMapViewController animated:YES];
            }
        }

        if (whileIndex == 4) {
            if (([tmpStr rangeOfString:@"items"].location != NSNotFound) || ([tmpStr rangeOfString:@"have"].location != NSNotFound)) {
                if (biz.isProductListLoaded) {
                    [self displayProduct];
                }
                else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    timerToLoadProducts = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayProduct) userInfo:nil repeats:YES];
                }
            }
        }

        whileIndex++;
    }  // while

}

- (void)displayProduct {
    if (biz.isProductListLoaded) {
        //at this point we should have already loaded the businessProducts
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        ProductItemsTableViewController *showItemsTableViewController = [[ProductItemsTableViewController alloc]
                                                                         initWithNibName:nil bundle:nil data:biz.businessProducts];
        showItemsTableViewController.title = [NSString stringWithFormat:@"What %@ has for you", biz.businessName];
        [self.navigationController pushViewController:showItemsTableViewController animated:YES];
        
        if (timerToLoadProducts != nil)
        {
            [timerToLoadProducts invalidate];
            timerToLoadProducts = nil;
        }
    }

}

@end
