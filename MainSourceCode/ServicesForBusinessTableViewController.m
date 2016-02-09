//
//  ServicesForBusinessTableViewController.m
//  ScratchTabNav
//  
//  Created by Amir on 7/24/11.
//  Copyright 2011 MyDoosts.com. All rights reserved.
//

#import "ServicesForBusinessTableViewController.h"
#import "ServicesTableViewCell.h"
#import "MenuViewController.h"
#import "AskForSeviceViewController.h"
#import "BillViewController.h"
#import "ProductItemsTableViewController.h"
#import "StoreMapViewController.h"
#import "ChatMessagesViewController.h"
#import "TapTalkLooks.h"
#import "MBProgressHUD.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "LoginViewController.h"
#import "UtilityConsumerProfile.h"
#import "EventsTableViewController.h"

// github library to load the images asynchronously
#import "Consts.h"
#import <SDWebImage/UIImageView+WebCache.h>



@interface ServicesForBusinessTableViewController ()


@property (strong, nonatomic) NSTimer *timerToLoadProducts;


- (void)displayProduct;

@end


@implementation ServicesForBusinessTableViewController

@synthesize biz;
@synthesize timerToLoadProducts;
//@synthesize cellBackGroundImageForCustomer;

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
    self.title = [NSString stringWithFormat:@"TapforAll - %@", biz.shortBusinessName];

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [TapTalkLooks setBackgroundImage:self.tableView withBackgroundImage:biz.bg_image];
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

- (ServicesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TapTalk"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ServicesTableViewCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (ServicesTableViewCell *) currentObject;
                break;
            }
        }
        //  bug in XCode - you have to make a uitextview editable to be able to change or set it's font
        cell.iconImage.contentMode = UIViewContentModeScaleAspectFit;
        cell.serviceTextView.editable = YES;
        [cell.serviceTextView setFont:[UIFont boldSystemFontOfSize:16]];
        cell.serviceTextView.editable = NO;
    
        [TapTalkLooks setToTapTalkLooks:cell.contentView isActionButton:NO makeItRound:YES];
        [TapTalkLooks setFontColorForView:cell.contentView toColor:[UIColor whiteColor]];
    }


    cell.serviceTextView.text = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    if (biz.iconRelativeURL != (id)[NSNull null] && biz.iconRelativeURL.length != 0 )
    {
        NSString *imageURLString = [BusinessCustomerIconDirectory stringByAppendingString:biz.iconRelativeURL];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        #ifdef __IPHONE_8_0
            [cell.iconImage sd_setImageWithURL:imageURL placeholderImage:nil];
        #else
            [cell.iconImage setImageWithURL:imageURL placeholderImage:nil];

        #endif
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tmpStr = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    [self loadNextViewController:tmpStr forBusiness:self.biz inNavigationController:self.navigationController];
}



- (void)loadNextViewController:(NSString *)service forBusiness:(Business *)function_biz inNavigationController:(UINavigationController *)navigationController {
    NSString* tmpStr = [service lowercaseString];
    NSUInteger whileIndex = 0;
    while (whileIndex < 8) {
        if (whileIndex == 0) {
            if ([tmpStr rangeOfString:@"menu"].location != NSNotFound) {
                MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
                [navigationController pushViewController:menuViewController animated:YES];
            }
        }
        if (whileIndex == 1) {
            if ([tmpStr rangeOfString:@"service"].location != NSNotFound) {
                AskForSeviceViewController *orderViewController = [[AskForSeviceViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:orderViewController animated:YES];
            }
        }
        
        if (whileIndex == 2) {
            if ( ([tmpStr rangeOfString:@"bill"].location != NSNotFound) ||
                    ([tmpStr rangeOfString:@"pay"].location != NSNotFound) ) {
                BillViewController *billViewController = [[BillViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:billViewController animated:YES];
            }
        }
        
        if (whileIndex == 3) {
            if ([tmpStr rangeOfString:@"map"].location != NSNotFound) {
                StoreMapViewController *storeMapViewController = [[StoreMapViewController alloc] initWithNibName:nil bundle:nil];
                storeMapViewController.title = [NSString stringWithFormat:@"Map of %@",function_biz.shortBusinessName];
                [navigationController pushViewController:storeMapViewController animated:YES];
            }
        }
        
        if (whileIndex == 4) {
            
            if (([tmpStr rangeOfString:@"items"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"have"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"show"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"food"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"item"].location != NSNotFound)
                || ([tmpStr rangeOfString:@"product"].location != NSNotFound)
                )
            {
                    if (function_biz.isProductListLoaded) {
                        [self displayProduct];
                    }
                    else {
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        timerToLoadProducts = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayProduct) userInfo:nil repeats:YES];
                    }
            }
        }
        
        if (whileIndex == 5) {
            if ([tmpStr rangeOfString:@"chat"].location != NSNotFound) {
                
                if ([DataModel sharedDataModelManager].nickname.length < 1) {
                    [UIAlertController showErrorAlert:@"You don't have a nick name yet.  Please go to the profile page and get one."];
                }
                else if (![UtilityConsumerProfile canUserChat]) {
                    [UIAlertController showErrorAlert:@"You are NOT registered to particate in this chat.  Please ask the manager to add you."];
                }
                else {
                    if (![[DataModel sharedDataModelManager] joinedChat]) {
                        // show the user that are about to connect to a new business chatroom
                        [DataModel sharedDataModelManager].shouldDownloadChatMessages = TRUE;
                        LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
                        loginController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
                        
                        [self presentViewController:loginController animated:YES completion:nil];
                        loginController = nil;
                    }
                    
                    ChatMessagesViewController *chatViewContoller = [[ChatMessagesViewController alloc] initWithNibName:nil bundle:nil];
                    [navigationController pushViewController:chatViewContoller animated:YES];
                }
            }
            
        }
        
        if (whileIndex == 6) {
            if ([tmpStr rangeOfString:@"event"].location != NSNotFound) {
                EventsTableViewController *eventTableViewController = [[EventsTableViewController alloc] initWithNibName:nil bundle:nil forBusiness:function_biz];
                [navigationController pushViewController:eventTableViewController animated:YES];

            }
            
        }
        if (whileIndex == 7) {
            if (([tmpStr rangeOfString:@"history"].location != NSNotFound) || ([tmpStr rangeOfString:@"shopping"].location != NSNotFound)) {
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
                                                                         initWithNibName:nil bundle:nil data:biz];
        showItemsTableViewController.title = [NSString stringWithFormat:@"%@ products", biz.shortBusinessName];
        [self.navigationController pushViewController:showItemsTableViewController animated:YES];
        
        if (timerToLoadProducts != nil)
        {
            [timerToLoadProducts invalidate];
            timerToLoadProducts = nil;
        }
    }

}

@end
