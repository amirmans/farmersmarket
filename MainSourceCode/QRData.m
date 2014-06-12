//
//  QRData.m
//  TapForAll
//
//  Created by Amir on 3/28/14.
//
//

#import "QRData.h"
#import "DataModel.h"

@implementation QRData

- (void)saveQRImage: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          @"test.png" ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (UIImage*)loadQRImage
{
    NSString *imageName = [DataModel sharedDataModelManager].qrImageFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:imageName];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    dispatch_queue_t qrDataBackgroundQueue = dispatch_queue_create("qrDataBackgroundQueue", NULL);
    if (image == nil) {
        dispatch_async(qrDataBackgroundQueue, ^{
            
        });
    }
        
    return image;
}

@end
