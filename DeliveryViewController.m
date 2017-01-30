//
//  AddressVC.m
//  TapForAll
//
//  Created by Lalit on 10/11/16.
//
//
#import <UIKit/UIKit.h>
#import "DeliveryViewController.h"
#import "APIUtility.h"
#import "MBProgressHUD.h"
#import "ActionSheetPicker.h"
#import "DataModel.h"
#import "UIAlertView+TapTalkAlerts.h"
#import "AppData.h"
#import "UIImageView+AFNetworking.h"


@interface DeliveryViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSString *stringUid;
    BOOL keyboardIsShown;
    NSMutableArray *latestInfoArray;
    NSString *delivery_start_time;
    NSString *delivery_end_time;
    NSNumber *delivery_time_interval;
    NSDate *setMinPickerTime;
    ActionSheetDatePicker *datePicker;
    NSString *uploadTime;
    NSDateFormatter *formatter2;
}
@end



@implementation DeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.isPickerOpen = NO;
//    [self.datePicker setAlpha:0.0];
    self.locationArr = [[NSMutableArray alloc] init];
    self.locationNameArr = [[NSMutableArray alloc] init];
    
    formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"hh:mm a"];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:MM:SS"];
//    self.lblDeliveryTIme.text =[dateFormatter stringFromDate:[NSDate date]];
    
    long uid = [[DataModel sharedDataModelManager] userID];
    if (uid <= 0) {
        [UIAlertController showErrorAlert:@"Please register on profile page to set your favorites. \nYou can order them next time around."];
        return;
    }
    
    stringUid = [NSString stringWithFormat:@"%ld", uid];

    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:self.view.window];
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:self.view.window];
//    keyboardIsShown = NO;
    
   
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.label.text = @"Loading...";
//    HUD.detailsLabel.text = @"It is worth the wait!";
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    // it seems this should be after setting the mode
    [HUD.bezelView setBackgroundColor:[UIColor blackColor]];
    HUD.bezelView.color = [UIColor orangeColor];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    [self.view addSubview:HUD];
    [HUD showAnimated:YES];
    
    [self GetLatestDelivaryInfo];
    
    self.delivery_Location_Textfield.delegate = self;
    self.selceted_Location_TextField.delegate = self;

    //Set Latest Info
    NSLog(@"%@",_latestDeliveryInfo);
    if(self.latestDeliveryInfo.count > 0){
        
        self.delivery_Location_Textfield.text = [NSString stringWithFormat: @"%@", [[self.latestDeliveryInfo objectAtIndex:0] valueForKey:@"delivery_address"]];
        self.selceted_Location_TextField.text = [NSString stringWithFormat: @"%@", [[self.latestDeliveryInfo objectAtIndex:0] valueForKey:@"delivery_address_name"]];
        self.txtNote.text = [NSString stringWithFormat: @"%@", [[self.latestDeliveryInfo objectAtIndex:0] valueForKey:@"delivery_instruction"]];
        
    }

    
    long business_id_long = [CurrentBusiness sharedCurrentBusinessManager].business.businessID;
    NSNumber *business_id = [NSNumber numberWithLongLong:business_id_long];
    NSDictionary *inDataDict = @{@"business_id":business_id};
    NSLog(@"%@",inDataDict);

    
    [[APIUtility sharedInstance] BusinessDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
        
        if([[response valueForKey:@"status"] integerValue] >= 0)
        {
            if(((NSArray *)[response valueForKey:@"data"]).count > 0) {
                
                NSArray *dataDict = [response valueForKey:@"data"];
                
                NSLog(@"%@",dataDict);
                self.delivery_Location_Textfield.text = [NSString stringWithFormat:@"%@",[[dataDict objectAtIndex:0] valueForKey:@"section_location_name"]];
                //            NSArray *locationArry = [[[dataDict objectAtIndex:0] valueForKey:@"locations_in_section"] mutableCopy];
                //            self.txtNote.text = [NSString stringWithFormat:@"%@",[[dataDict objectAtIndex:0] valueForKey:@"note"]];
                
                delivery_start_time = [[dataDict objectAtIndex:0] valueForKey:@"delivery_start_time"];
                delivery_end_time = [[dataDict objectAtIndex:0] valueForKey:@"delivery_end_time"];
                
                delivery_time_interval = [[dataDict objectAtIndex:0] valueForKey:@"delivery_time_interval_in_minutes"];
                
                self.locationArr = [[[dataDict objectAtIndex:0] valueForKey:@"locations_in_section"] mutableCopy];
                
                for (int i = 0 ; i < self.locationArr.count ; i++) {
                    [self.locationNameArr addObject:[self.locationArr[i] objectForKey:@"location_name"]];
                }
                
                self.titleLable.text = [[dataDict objectAtIndex:0] valueForKey:@"message_to_consumers"];
                
                NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
                dateFormatter1.dateFormat = @"HH:mm:ss";
                NSDate *startDate = [dateFormatter1 dateFromString:delivery_start_time];
                NSDate *endDate = [dateFormatter1 dateFromString:delivery_end_time];
                
                dateFormatter1.dateFormat = @"hh:mm a";
                
                self.lblDeliveryStartEndTime.hidden = NO;
                
                self.lblDeliveryStartEndTime.text = [NSString stringWithFormat:@"Delivery between %@ - %@",[dateFormatter1 stringFromDate:startDate],[dateFormatter1 stringFromDate:endDate]];
                
                NSString *mapString = [NSString stringWithFormat:@"%@/%@",business_id,[[dataDict objectAtIndex:0] valueForKey:@"section_map"]];
                NSString *imageURLString = [BusinessCustomerIndividualDirectory stringByAppendingString:mapString];
                NSURL *imageURL = [NSURL URLWithString:imageURLString];
                //            [self.mapImageView setImageURL:imageURL];
                
                NSLog(@"%@",imageURL);
                //            self.mapImageView.hidden = YES;
                NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:imageURL];
                UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(125, 50, 30, 30)];
                progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                progress.center = self.mapImageView.center;
                [self.view addSubview:progress];
                [progress startAnimating];
                [self.mapImageView setImageWithURLRequest:urlReq
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      [self.mapImageView setImageWithURL:imageURL];
                                                      [progress stopAnimating];
                                                      
                                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                      [progress stopAnimating];
                                                      NSLog(@"failure: %@", response);
                                                  }];
                
                [HUD hideAnimated:YES];
                
            }else{
                self.mapImageView.hidden = NO;
                self.lblDeliveryStartEndTime.hidden = YES;
                [HUD hideAnimated:YES];
            }
        }
        else{
            [HUD hideAnimated:YES];
            [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
        }
    }];
    
    //Picker Setup
    UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

//    [pickerView addSubview:pickerToolbar];
//    [pickerView addSubview:self.datePicker];
    
    self.dateTime_TextField.inputView = pickerView;
    // Do any additional setup after loading the view.
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.origin.y += (keyboardSize.height - 50);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"%f",keyboardSize.height);
    // resize the noteView
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.origin.y -= (keyboardSize.height - 50);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    keyboardIsShown = YES;
}

#pragma mark - User Functions

-(void)GetLatestDelivaryInfo{
    
    NSLog(@"%@",[DataModel sharedDataModelManager].uuid);
    if ([DataModel sharedDataModelManager].uuid.length < 1) {
        
        [UIAlertController showErrorAlert:@"Please register on profile page.\nThen you can get delivary."];
    }
    else {
        NSDictionary *inDataDict = @{@"consumer_id":stringUid,
                                     @"cmd":@"get_consumer_latest_delivery_info"};
        
        [[APIUtility sharedInstance] ConsumerDelivaryInfoAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
            if([[response valueForKey:@"status"] integerValue] >= 0)
            {
                if( ((NSArray *)[response valueForKey:@"data"]).count > 0) {
                    NSLog(@"%@",response);
                    self.selceted_Location_TextField.text = [[[response valueForKey:@"data"] objectAtIndex:0] valueForKey:@"delivery_address_name"];
                    self.txtNote.text = [[[response valueForKey:@"data"] objectAtIndex:0] valueForKey:@"delivery_instruction"];
                    
                    NSString *dTime = [[[response valueForKey:@"data"] objectAtIndex:0] valueForKey:@"delivery_time"];
                    NSLog(@"%@",dTime);
                    NSDateFormatter *dforamat = [[NSDateFormatter alloc] init];
                    [dforamat setDateFormat:@"HH:mm:ss"];
                    NSDate *date = [dforamat dateFromString:dTime];
                    NSLog(@"%@",date);
                    self.lblDeliveryTIme.text = [formatter2 stringFromDate:date];
                    
                    //                latestInfoArray = (NSArray *)[response valueForKey:@"data"];
                    //                delivaryLocationName = [NSString stringWithFormat: @"%@", [[[response valueForKey:@"data"] objectAtIndex:0]valueForKey:@"delivery_address_name"]];
                    //                self.btnDeliveryTo.titleLabel.text = delivaryLocationName;
                    
                }
            }
            else
            {
                [HUD hideAnimated:YES];
                [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
            }
        }];
    }
}



//Date Picker

#pragma mark- Picker Methods


-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm:ss"];
//    NSDate *date2 = [formatter dateFromString:delivery_end_time];
//    
//    NSComparisonResult result = [selectedTime compare:setMinPickerTime];
//    
//    if(result == NSOrderedAscending)
//    {
//        NSLog(@"date2 is later than date1");
//        self.lblDeliveryTIme.text = [NSString stringWithFormat:@"%@",[selectedTime dateByAddingTimeInterval:60*30]];
//        
//    }
//    else
//    {
//        NSLog(@"date1 is equal to date2");
//        
//    }
//
    
    
    
    NSLog(@"%@",selectedTime);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss"];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is %@",[df stringFromDate:now]);
//    NSString *currentTime = [df stringFromDate:now];
    
//    NSDate *CurrentTime = [df dateFromString:currentTime];
    
    NSString *selectTime = [df stringFromDate:selectedTime];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];

    NSDate *time = [formatter dateFromString:selectTime];
    NSDate *date1= [formatter dateFromString:delivery_start_time];
    NSDate *date2 = [formatter dateFromString:delivery_end_time];
    
//    NSComparisonResult result = [CurrentTime compare:setMinPickerTime];
//    if(result == NSOrderedDescending)
//    {
//        NSLog(@"date1 is later than date2");
//        self.lblDeliveryTIme.text = [NSString stringWithFormat:@"%@",setMinPickerTime];
//    }
//    else if(result == NSOrderedAscending)
//    {
//        NSLog(@"date2 is later than date1");
//        self.lblDeliveryTIme.text = [NSString stringWithFormat:@"%@",[selectedTime dateByAddingTimeInterval:60*30]];
//    }
//    else
//    {
//        NSLog(@"date1 is equal to date2");
//        self.lblDeliveryTIme.text = [NSString stringWithFormat:@"%@",setMinPickerTime];
//    }
    
    
    NSComparisonResult result = [time compare:date1];
    NSLog(@"%ld",(long)result);
    if ([setMinPickerTime compare:time] == NSOrderedDescending ||
        [date2 compare:time] == NSOrderedAscending)
    {
        if([setMinPickerTime compare:time] == NSOrderedDescending)
        {
//            NSDate *time1 = [formatter2 dateFromString:[formatter2 stringFromDate:setMinPickerTime]];
            self.lblDeliveryTIme.text = [formatter2 stringFromDate:setMinPickerTime];
            uploadTime = [formatter stringFromDate:setMinPickerTime];
        }
        else
        {
//            NSDate *withOutSelectTime = [setMinPickerTime dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
//            NSDate *time1 = [formatter2 dateFromString:[formatter2 stringFromDate:withOutSelectTime]];
            self.lblDeliveryTIme.text = [formatter2 stringFromDate:setMinPickerTime];
            
            uploadTime = [formatter stringFromDate:setMinPickerTime];
        }
    }
    else
    {
//        if([CurrentTime compare:selectedTime] == NSOrderedSame)
//        {
//            selectedTime = [selectedTime dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
//        }
//        NSDate *time1 = [formatter2 dateFromString:[formatter2 stringFromDate:selectedTime]];
        self.lblDeliveryTIme.text = [formatter2 stringFromDate:selectedTime];
        
        uploadTime = [formatter stringFromDate:selectedTime];
    }
    NSLog(@"%@",selectedTime);
    NSLog(@"%@",self.lblDeliveryTIme.text);
    
}



//Filte location

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"location_name beginswith[c] %@",searchText];
    self.filterArray = [self.locationArr filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"%@",self.locationArr);
    NSLog(@"Result = %@", searchText);
    NSLog(@"Result = %@", self.filterArray);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.btnCancelSearch.hidden = true;
    
}
//Textfield

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.selceted_Location_TextField.text.length > 0)
    {
        self.btnCancelSearch.hidden = false;
    }
    else
    {
        self.btnCancelSearch.hidden = true;
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.selceted_Location_TextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        NSLog(@"%lu",(unsigned long)newLength);
        if(newLength > 0)
        {
            self.btnCancelSearch.hidden = false;
        }
        else
        {
            self.btnCancelSearch.hidden = true;
        }
        [self filterContentForSearchText:[NSString stringWithFormat:@"%@%@",self.selceted_Location_TextField.text,string]];
        NSLog(@"%@",self.selceted_Location_TextField.text);
        if(self.filterArray.count > 0){
            if(newLength > (characterSearchLimit-1))
            {
                self.locationTableView.hidden = NO;
                [self.locationTableView reloadData];
            }
            else
            {
                self.locationTableView.hidden = YES;
                [self.locationTableView reloadData];
            }
        }
        else{
            
            self.locationTableView.hidden = YES;
            [self.locationTableView reloadData];
        }
    }
//    else
//    {
//        
//        // resize the noteView
//        CGRect viewFrame = self.view.frame;
//        // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
//        viewFrame.origin.y -= (258.00 - 50);
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [self.view setFrame:viewFrame];
//        [UIView commitAnimations];
//    }
    return YES;
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.btnCancelSearch.hidden = true;
    
    [textField resignFirstResponder];
    if(textField == self.selceted_Location_TextField){
        
        self.locationTableView.hidden = YES;
        [self.locationTableView reloadData];
    }
    return YES;
}

//Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   return self.filterArray.count;    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    cell.backgroundColor = [UIColor grayColor];
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    NSDictionary *dic = [self.filterArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"location_name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = [self.filterArray objectAtIndex:indexPath.row];
    self.selceted_Location_TextField.text = [dic objectForKey:@"location_name"];
    self.locationTableView.hidden = YES;
    self.btnCancelSearch.hidden = YES;
    [self.selceted_Location_TextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)btnOk_Clicked:(id)sender {
    
//    if(self.delivery_Location_Textfield.text.length == 0){
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"Please select location."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
    NSLog(@"%@",self.locationNameArr);
    if(self.selceted_Location_TextField.text.length == 0){
        [self showAlert:@"Error" :@"Please select location."];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"Please select location."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
    else if(self.lblDeliveryTIme.text.length == 0){
         [self showAlert:@"Error" :@"Please select date and time."];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"Please select date and time."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
    else if(![self.locationNameArr containsObject:self.selceted_Location_TextField.text])
    {
        [self showAlert:@"Error" :@"Please select correct location."];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"Please select correct location."
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
    else {
        
        [HUD showAnimated:YES];
        NSDictionary *inDataDict;
        
        if(uploadTime != nil)
        {
            
            inDataDict = @{              @"delivery_address_name":self.selceted_Location_TextField.text,
                                         @"delivery_instruction":self.txtNote.text,
                                         @"delivery_time":uploadTime,
                                         @"cmd":@"save_consumer_delivery",
                                         @"consumer_id":stringUid
                                         };
        }else
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"hh:mm a";
            NSDate *date = [dateFormatter dateFromString:self.lblDeliveryTIme.text];
            
            dateFormatter.dateFormat = @"HH:mm";
            NSString *pmamDateString = [dateFormatter stringFromDate:date];
            
            inDataDict = @{              @"delivery_address_name":self.selceted_Location_TextField.text,
                                         @"delivery_instruction":self.txtNote.text,
                                         @"delivery_time":pmamDateString,
                                         @"cmd":@"save_consumer_delivery",
                                         @"consumer_id":stringUid
                                         };
        }
            NSLog(@"%@",inDataDict);
            [[APIUtility sharedInstance] ConsumerDelivaryInfoSaveAPICall:inDataDict completiedBlock:^(NSDictionary *response) {
                if([[response valueForKey:@"status"] integerValue] >= 0)
                {
                    if( ((NSArray *)response).count > 0) {
                        
                        [AppData sharedInstance].consumer_Delivery_Id =[NSString stringWithFormat:@"%@", [response valueForKey:@"consumer_delivery_id"]];
                        [AppData sharedInstance].consumer_Delivery_Location = self.selceted_Location_TextField.text;
                        [self dismissViewControllerAnimated:YES completion:nil];
                        //                [self.navigationController popViewControllerAnimated:true];
                    }
                    else
                    {
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                       message:@"Something went wrong."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    [HUD hideAnimated:YES];
                }
                else
                {
                    [HUD hideAnimated:YES];
                    [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
                }
            }];
    }
}

- (IBAction)btnCancel_Clicked:(id)sender {
//    [self.navigationController popViewControllerAnimated:true];
    self.titleLable.text = @"";
    self.delivery_Location_Textfield.text = @"";
    self.mapImageView.image = nil;
    self.txtNote.text = @"";
    [AppData sharedInstance].consumer_Delivery_Id = nil;
    [AppData sharedInstance].consumer_Delivery_Location = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)BtnDateTimeClicked:(id)sender {
    
    [self.view endEditing:true];
    
//    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:[NSDate new] target:self action:@selector(timeWasSelected:element:) origin:sender];
//    if(delivery_time_interval != nil || delivery_time_interval != NULL)
//    {
//        datePicker.minuteInterval = [delivery_time_interval integerValue];
//    }
//    else
//    {
//        datePicker.minuteInterval = 30;
//    }
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
//    [datePicker setLocale:locale];

    NSString *time1 = delivery_start_time;
    
    NSDate *now = [NSDate date];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"HH:mm:ss";
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    
//    NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
//    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
//    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
//    NSLog(@"sourceDate=%@ timeZoneOffset=%f", sourceDate, timeZoneOffset);
    
//    NSTimeZone *currentTimeZone = [NSTimeZone systemTimeZone];
//    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//    
//    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:now];
//    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:now];
//    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
//
//    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:now];
    
//    [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    
//    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is %@",[formatter stringFromDate:now]);
    NSString *time2 = [formatter stringFromDate:now];
    
    NSDate *date1= [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    NSString *time3 = delivery_end_time;
    NSDate *date3= [formatter dateFromString:time3];
    
    NSComparisonResult result = [date1 compare:date2];

    if(result == NSOrderedDescending)
    {
        NSLog(@"date1 is later than date2");
        setMinPickerTime = date1;

    }
    else if(result == NSOrderedAscending)
    {
        NSLog(@"date2 is later than date1");
        setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
        
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:setMinPickerTime];
        NSInteger minute = [components minute];
        NSLog(@"%ld",(long)minute);
        NSLog(@"%ld",(long)minute % [delivery_time_interval integerValue]);
        if(minute % [delivery_time_interval integerValue] == 0)
        {
            setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delivery_time_interval integerValue]];
            
            datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
            datePicker.minuteInterval = [delivery_time_interval integerValue];
            [datePicker showActionSheetPicker];
        }
        else
        {
            if([setMinPickerTime compare:date3] == NSOrderedDescending)
            {
                
                NSString *message = [NSString stringWithFormat:@"Sorry! \n We are not able to deliever today."];
                [UIAlertController showErrorAlert:message];
                
            }
            else
            {
                NSNumber *delieverTime = delivery_time_interval;
                delieverTime = @([delieverTime integerValue] * 2);
                setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                if([setMinPickerTime compare:date3] == NSOrderedDescending)
                {
                    NSNumber *delieverTime = delivery_time_interval;
                    delieverTime = @([delieverTime integerValue]);
                    setMinPickerTime =[date2 dateByAddingTimeInterval:60*[delieverTime integerValue]];
                }
                NSLog(@"%@",setMinPickerTime);
                
                datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
                datePicker.minuteInterval = [delivery_time_interval integerValue];
                [datePicker showActionSheetPicker];
            }
        }
    }
    else
    {
        NSLog(@"date1 is equal to date2");
        setMinPickerTime = date1;
        
        datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:date2 minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
        datePicker.minuteInterval = [delivery_time_interval integerValue];
        [datePicker showActionSheetPicker];
    }
    
    
//    NSString *time4 = self.lblDeliveryTIme.text;
//    
//   
    
//    NSDate *date4 = [formatter dateFromString:time4];
//    
//    NSComparisonResult result2 = [date3 compare:date4];
//    if(result2 == NSOrderedDescending)
//    {
//        NSLog(@"date3 is later than date4");
//        [datePicker setMaximumDate:date3];
//    }
//    else if(result2 == NSOrderedAscending)
//    {
//        NSLog(@"date4 is later than date3");
//        [datePicker setMaximumDate:date4];
//    }
//    else
//    {
//        NSLog(@"date3 is equal to date4");
//        [datePicker setMaximumDate:date2];
//    }
//
    
//     datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:setMinPickerTime minimumDate:setMinPickerTime maximumDate:date3 target:self action:@selector(timeWasSelected:element:) origin:sender];
    
    
    
    
    
   
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm a";
//    
//    [datePicker setLocale:locale];
    

}

- (IBAction)btnCancelSearch:(id)sender {
    self.selceted_Location_TextField.text = @"";
}
- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:true];
}

- (void)showAlert:(NSString *)Title :(NSString *)Message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:Title
                                 message:Message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* OKButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self dismissViewControllerAnimated:true completion:nil];
                               }];
    
    [alert addAction:OKButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
