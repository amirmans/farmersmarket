//
//  MessagesFromOpenConnections.m
//  meowcialize
//
//  Created by Amir Amirmansoury on 8/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatMessagesViewController.h"
#import "MBProgressHUD.h"
#import "ChatTableView.h"
#import "DataModel.h"
//#import "TapTalkChatMessage.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"
#import "ASIFormDataRequest.h"

#import "UIAlertView+TapTalkAlerts.h"
#import "LoginViewController.h"

#import <QuartzCore/CALayer.h>


@interface ChatMessagesViewController ()
{
    TapTalkChatMessage *ttChatMessage;
}

@end

@implementation ChatMessagesViewController
@synthesize chatTableView;
@synthesize sendButton;
@synthesize composeMessageTextField;
//@synthesize dataModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        ttChatMessage = [[TapTalkChatMessage alloc] initWithDelegate:self];
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
    // Do any additional setup after loading the view from its nib.    
    self.title = [[DataModel sharedDataModelManager] businessName];
    //TODO
    [chatTableView setBackgroundColor:[UIColor colorWithRed:219/255.0 green:226/255.0 blue:237/255.0 alpha:1.0]];
    
    [[composeMessageTextField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[composeMessageTextField layer] setBorderWidth:2.3];
    [[composeMessageTextField layer] setCornerRadius:15];
    [composeMessageTextField setClipsToBounds: YES]; 
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"messagesFromOpenConnection is about to appear");
    if (![[DataModel sharedDataModelManager] joinedChat]) {
        // show the user that are about to connect to a new business chatroom
        LoginViewController* loginController = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
        loginController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//      loginController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:loginController animated:YES];
        loginController = nil;

        [[DataModel sharedDataModelManager] setJoinedChat:TRUE];
        [ttChatMessage loadMessagesFromServer];

        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Loading messages", @"");
    }
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    ttChatMessage = nil;
    [self setChatTableView:nil];
    [self setComposeMessageTextField:nil];
    [self setSendButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UITableViewDataSource

- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [DataModel sharedDataModelManager].messages.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"MessageCellIdentifier";
    
	MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	//TapTalkChatMessage* message = [[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row];
    [ttChatMessage setValuesFrom:[[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row]];

	[cell insertMessage:ttChatMessage];
	return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	// This function is called before cellForRowAtIndexPath, once for each cell.
	// We calculate the size of the speech bubble here and then cache it in the
	// Message object, so we don't have to repeat those calculations every time
	// we draw the cell. We add 16px for the label that sits under the bubble.
//	TapTalkChatMessage* message = [[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row];
    NSDictionary *tempMessage = [[DataModel sharedDataModelManager].messages objectAtIndex:indexPath.row];
    [ttChatMessage setValuesFrom:tempMessage];
    //TODO: cleanup
//    NSLog(@"information in message in the heightForRowAtIndexPath");
//    NSLog(@"textChar is:%@ sender is:%@dateAdded is%@", tempMessage.textChat, tempMessage.sender, tempMessage.dateAdded);
	ttChatMessage.bubbleSize = [SpeechBubbleView sizeForText:ttChatMessage.textChat];
	
    return ttChatMessage.bubbleSize.height + 16;
}


#pragma mark - 
#pragma Actions
//TODO check to see if we need TapTalkChatMessage
- (void)didSaveMessage:(TapTalkChatMessage*)message atIndex:(int)index
{
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
//		self.chatTableView = nil;
//        [self.chatTableView beginUpdates];
		[self.chatTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.chatTableView endUpdates];
        [self.chatTableView viewWillAppearWithNewMessage];
//        self.composeMessageTextField.text = @"";
//		[self.chatTableView scrollToNewestMessage];
	}
}


- (void)userDidCompose:(NSString*)text
{
	// Create a new Message object
	TapTalkChatMessage* message = [[TapTalkChatMessage alloc] init];

	message.sender = [DataModel sharedDataModelManager].nickname;
	message.dateAdded = [NSDate date];
	message.textChat = text;
    
	// Add the Message to the data model's list of messages
	int index = [[DataModel sharedDataModelManager] addMessage:message];
    
	// Add a row for the Message to ChatViewController's table view.
	// Of course, ComposeViewController doesn't really know that the
	// delegate is the ChatViewController.
	[self didSaveMessage:message atIndex:index];
}


- (void)sendChatMessageToServer
{
	// Show an activity spinner that blocks the whole screen
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Sending the message", @"");
    
	NSString* text = composeMessageTextField.text;
    
	// Create the HTTP request object for our URL
    NSString *urlString = [DataModel sharedDataModelManager].chatSystemURL;
    urlString =[urlString stringByAppendingString:AddChatServerURL_APPENDIX];
    NSLog(@"url string to call and add the chat message is: %@", urlString);
    NSURL* url = [NSURL URLWithString:urlString];
	__block ASIFormDataRequest* __weak request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    [request setPostValue:text forKey:@"message"];
    NSString *userName = [DataModel sharedDataModelManager].nickname;
    [request setPostValue:userName forKey:@"user"];
    
	// This code will be executed when the HTTP request is successful
	[request setCompletionBlock:^
     {
         // now composeMessageTextField.text which has given its value to text is being processes 
         // good time to erase it.
         composeMessageTextField.text = nil;
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             // If the HTTP response code is not "200 OK", then our server API
             // complained about a problem. This shouldn't happen, but you never
             // know. We must be prepared to handle such unexpected situations.
             if ([request responseStatusCode] != 200)
             {
                 [UIAlertView showErrorAlert:NSLocalizedString(@"No connection to Business", nil)];
             }
             else
             {

             }
         }
     }];
    
	// This code is executed when the HTTP request fails
	[request setFailedBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [UIAlertView showErrorAlert:@"You are not in the business's chat room"];
         }
     }];
    
	[request startAsynchronous];
}


- (IBAction)sendMessage:(id)sender {
    if ([composeMessageTextField.text length] > 1)
    {
        [composeMessageTextField resignFirstResponder];
        [self sendChatMessageToServer];
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)updateBytesRemaining:(NSString*)text
{
	// Calculate how many bytes long the text is. We will send the text as
	// UTF-8 characters to the server. Most common UTF-8 characters can be
	// encoded as a single byte, but multiple bytes as possible as well.
//	const char* s = [text UTF8String];
//	size_t numberOfBytes = strlen(s);
    
	// Show the number of remaining bytes in the navigation bar's title
    //TODO
//    int remaining = MaxMessageLength - numberOfBytes;
//	if (remaining >= 0)
//		self.navigationBar.topItem.title = [NSString stringWithFormat:NSLocalizedString(@"%d Remaining", nil), remaining];
//	else
//		self.navigationBar.topItem.title = NSLocalizedString(@"Text Too Long", nil);
//    
//	// Disable the Save button if no text is entered, or if it is too long
//	self.saveItem.enabled = (remaining >= 0) && (text.length != 0);
}

- (BOOL)textView:(UITextView*)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	NSString* newText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
	[self updateBytesRemaining:newText];
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark TapTalkChatMessageDelegate Protocol definitions
- (void)tapTalkChatMessageDidFinishLoadingData:(NSMutableArray *)objects
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [DataModel sharedDataModelManager].messages  =  objects;
    [self.chatTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.chatTableView scrollToNewestMessage];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallBack)]];
	[invocation setTarget:self];
	[invocation setSelector:@selector(timerCallback)];
    //	[NSTimer scheduledTimerWithTimeInterval:10.0 invocation:invocation repeats:YES];
    
    NSTimer *chatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerCallBack) userInfo:nil repeats: NO];
    
    if (![[DataModel sharedDataModelManager] joinedChat]) {
        [chatTimer invalidate];
        chatTimer = nil;
    }
}

- (void) tapTalkChatMessageDidFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error: %@", error); 
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *alertMessage = [[NSString alloc] initWithFormat:@"No connection to %@", [[DataModel sharedDataModelManager] businessName]];
    [UIAlertView showErrorAlert:NSLocalizedString(alertMessage, nil)];
    alertMessage= nil;
}

- (void)timerCallBack
{
    [ttChatMessage loadMessagesFromServer];
}




@end
