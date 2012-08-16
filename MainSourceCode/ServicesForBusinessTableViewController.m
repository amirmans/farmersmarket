 //
//  ServicesForBusinessTableViewController.m
//  ScratchTabNav
//  
//  Created by Amir on 7/24/11.
//  Copyright 2011 MyDoosts.com. All rights reserved.
//

#import "ServicesForBusinessTableViewController.h"
#import "MenuViewController.h"
#import "MeowToOrderController.h"
#import "BillViewController.h"
#import "ShowItemsTableViewController.h"
#import "StoreMapViewController.h"
#import "TapTalkLooks.h"


@implementation ServicesForBusinessTableViewController

@synthesize biz;

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

- (id) initWithData:(NSDictionary *)subAndMainChoices :(NSArray *)onlyMainChoices :(NSString *)chosenItem forBusiness:(Business *)argBiz
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        allChoices = subAndMainChoices;
        mainChoices = onlyMainChoices;
        chosenMainMenu = chosenItem;  
        biz = argBiz;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // for some reason - setting the background color in the nib file didn't work
    [TapTalkLooks setBackgroundImage:self.tableView];
//    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_image.jpg"]];
//    [tempImageView setFrame:self.tableView.frame];
//    
//    self.tableView.backgroundView = tempImageView;
//    tempImageView = nil;
    // Do any additional setup after loading the view from its nib.
    self.hidesBottomBarWhenPushed = FALSE;

    self.title = chosenMainMenu;

    NSArray *tempRows =  [allChoices objectForKey:chosenMainMenu];
    if (tempRows == nil)
    {
        NSLog(@"Someting went wrong there are no rows");
        NSLog(@"Here are allchoices in the detail view....%@", allChoices);
        NSLog(@"Here is the chosen main menu...%@", chosenMainMenu);
    }
    
    NSUInteger numberOfRows = tempRows.count;
    if (numberOfRows == 0)
        numberOfRows++;
    CGFloat rowHeight = (420 - 44) / (numberOfRows);
    self.tableView.rowHeight = rowHeight;
}


-(void)viewWillAppear:(BOOL)animated
{

}
 

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (@"TapTalk it");
}
*/ 

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectimenuon
{
    NSArray *tempArr = [allChoices objectForKey:chosenMainMenu];
    return ([tempArr count]);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TapTalk"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TapTalk"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tmpStr = [[allChoices objectForKey:chosenMainMenu] objectAtIndex:indexPath.row];
    tmpStr = [tmpStr lowercaseString];
    NSUInteger whileIndex = 0;
    while (whileIndex < 5)
    {
        if (whileIndex == 0)
        {
            if ([tmpStr rangeOfString:@"menu"].location != NSNotFound)
            {    
                MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:menuViewController animated:YES];    
            }
        }
        if (whileIndex == 1)
        {
            if (([tmpStr rangeOfString:@"food or drink"].location != NSNotFound) || ([tmpStr rangeOfString:@"ask for service"].location != NSNotFound) )
            {
                MeowToOrderController *orderViewController = [[MeowToOrderController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:orderViewController animated:YES];
            }
        }
        
        if (whileIndex == 2)
        {
            if ([tmpStr rangeOfString:@"bill"].location != NSNotFound)
            {
                BillViewController *billViewController = [[BillViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:billViewController animated:YES];
            }
        }
        
        if (whileIndex == 3)
        {
            if ([tmpStr rangeOfString:@"map"].location != NSNotFound)
            {
                StoreMapViewController *storeMapViewController = [[StoreMapViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:storeMapViewController animated:YES];
            }
        }
        
        if (whileIndex == 4)
        {
            if ([tmpStr rangeOfString:@"items"].location != NSNotFound)
            {
                ShowItemsTableViewController *showItemsTableViewController = [[ShowItemsTableViewController alloc] initWithNibName:nil bundle:nil data:biz.businessProducts];
                [self.navigationController pushViewController:showItemsTableViewController animated:YES];
            }
        }

        whileIndex++;
    }  // while
    
}

@end
