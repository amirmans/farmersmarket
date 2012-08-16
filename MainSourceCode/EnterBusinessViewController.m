//
//  FirstTabViewController.m
//  ScratchTabNav
//
//  Created by Amir on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnterBusinessViewController.h"
#import "PublicProfile.h"


@implementation EnterBusinessViewController


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


- (id) initWithData:(NSDictionary *)subAndMainChoices :(NSArray *)onlyMainChoices
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        allChoices = subAndMainChoices;
        mainChoices = onlyMainChoices;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Let's TapTalk";
    // Do any additional setup after loading the view from its nib.
    CGFloat rowHeight = (420 - 44) / mainChoices.count;
    self.tableView.rowHeight = rowHeight;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
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

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return mainChoices.count;
}
 

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Congrats - you can TapTalk now!!!";
}
 
*/

- (NSString *)choiceAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *choicesInSection = [allChoices objectForKey:[mainChoices objectAtIndex:indexPath.section]];
	return [choicesInSection objectAtIndex:indexPath.row];
}


- (UIImage *)imageForCell:(NSUInteger)row
{
    NSString *mainChoice = [mainChoices objectAtIndex:row];
    NSRange range; range.location = NSNotFound;
    
    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *methodImage = nil;
    for (NSUInteger loopIndex = 0; loopIndex < 3; loopIndex++)
    {
        if (loopIndex == 0)
        {
            range = [[mainChoice lowercaseString] rangeOfString:@"house"];
            if (range.location != NSNotFound)
            {
                NSString *path = [bundle pathForResource: @"House_woody_cat_table" ofType: @"jpg"];
                methodImage = [UIImage imageWithContentsOfFile:path];
                
                break;
            }
        }
        else if (loopIndex == 1)
        {   
            range = [[mainChoice lowercaseString] rangeOfString:@"ask"];
            if (range.location != NSNotFound)
            {
                NSString *path = [bundle pathForResource: @"Asking_cat" ofType: @"jpeg"];
                methodImage = [UIImage imageWithContentsOfFile:path];
                
                break;
            }
   
        }
        else if (loopIndex == 2)
        {   
            range = [[mainChoice lowercaseString] rangeOfString:@"socialize"];
            if (range.location != NSNotFound)
            {
                NSString *path = [bundle pathForResource: @"Socialize_cats" ofType: @"png"];
                methodImage = [UIImage imageWithContentsOfFile:path];
                
                break;
            }
            
        }
    }
        
    return methodImage;
}

- (UIViewController *)nextViewController: (NSUInteger)row
{
    NSString *tempChosenMainMenu = [[mainChoices objectAtIndex:row] lowercaseString];
    NSUInteger whileIndex = 0;
    while (whileIndex < 3)
    {
        if (whileIndex == 0)
        {
            if ([tempChosenMainMenu rangeOfString:@"socialize"].location != NSNotFound)
            {
                PublicProfile *publicProfile = [[PublicProfile alloc] initWithNibName:nil bundle:nil];
                return publicProfile;
            }
        }
        else if (whileIndex == 1)
        {
            if ([tempChosenMainMenu rangeOfString:@"house"].location != NSNotFound)
            {       //TODO
//                ServicesForBusinessTableViewController *detailInfo =[[ServicesForBusinessTableViewController alloc] initWithData:allChoices :mainChoices :[mainChoices objectAtIndex:row]];
//                detailInfo.hidesBottomBarWhenPushed = FALSE;
            
//                return detailInfo;
            }
        }
        else 
        {
            
          
        
        }// else
                
        whileIndex++;
    }  // while
    
    return nil;
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TapTalkI"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TapTalkI"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    UIImage *cellImage = [self imageForCell:indexPath.row]; 
    if (cellImage != nil)
        cell.imageView.image = cellImage;
    
    cell.textLabel.text = [mainChoices objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
        
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* detailInfo = [self nextViewController:indexPath.row];
    
    [self.navigationController pushViewController:detailInfo animated:YES];
    
    detailInfo = nil;
}

@end
