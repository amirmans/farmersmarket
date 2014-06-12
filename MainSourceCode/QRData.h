//
//  QRData.h
//  TapForAll
//
//  Created by Amir on 3/28/14.
//
//

#import <Foundation/Foundation.h>

@interface QRData : NSObject {

}

- (UIImage*)loadQRImage;
- (void)saveQRImage: (UIImage*)image;

@end
