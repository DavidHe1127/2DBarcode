/**
 * 2DBarcode
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"

@interface ComAuQrModule : TiModule
{
}
- (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)size;
- (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor;
@end
