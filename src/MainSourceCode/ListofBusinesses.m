//
//  ListofBusinesses.m
//  TapForAll
//
//  Created by Amir on 2/14/14.
//
//

#import "AppDelegate.h"
#import "ListofBusinesses.h"
#import "AppData.h"


@interface ListofBusinesses () {
    
@private

    
}

@end



@implementation ListofBusinesses

@synthesize businessListArray;


+ (id)sharedListofBusinesses {
    static ListofBusinesses *sharedListofBusinesses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedListofBusinesses = [[self alloc] init];
    });
    return sharedListofBusinesses;
}


- (id)init
{
   self = [super init];
    if (self)
    {
        myServer = [[ServerInteractionManager alloc] init];
        myServer.postProcessesDelegate = self;
    }
    return self;
}

- (void)startGettingListofAllBusinesses
{
    [myServer serverCallToGetListofAllBusinesses];
}

- (void)startGettingListofAllBusinessesForCorp:(NSString *)businesses
{
    [myServer serverCallToGetListofAllBusinessesForCorp:businesses];
}

- (void)postProcessForListOfBusinessesSuccess:(NSDictionary *)responseData
{
    //    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
//    int status = [[responseData objectForKey:@"status"] intValue];
//        NSAssert(status == 0, @"We could not get list of our businesses");
    if ([[responseData objectForKey:@"status"] integerValue] >= 0) {
        businessListArray = [responseData objectForKey:@"data"];
        AppDelegate * myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([responseData objectForKey:@"information_date"]) {
            myAppDelegate.informationDate = [responseData objectForKey:@"information_date"];
        }
    
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error"
                                     message:@"Something went wrong."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OKButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
        [alert addAction:OKButton];
        UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
        UIViewController *mainController = [keyWindow rootViewController];
        [mainController presentViewController:alert animated:YES completion:nil];
//        [self presentViewController:alert animated:YES completion:nil];

//        [AppData showAlert:@"Error" message:@"Something went wrong." buttonTitle:@"ok" viewClass:self];
    }
    
//    NSLog(@"The status is: %i and our list of businesses is: %@", status, businessListArray);
}


@end
