/**
 * 2DBarcode
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "ComAuQrModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "qrencode.h"

@implementation ComAuQrModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"3f521422-1d70-4404-834f-3e580497e02b";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.au.qr";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark - private

- (void)mdDrawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size fillColor:(UIColor *)fillColor {
    int margin = 0;
    unsigned char *data = code->data;
    int width = code->width;
    int totalWidth = width + margin * 2;
    int imageSize = (int)floorf(size);
    
    // @todo - review float->int stuff
    int pixelSize = imageSize / totalWidth;
    if (imageSize % totalWidth) {
        pixelSize = imageSize / width;
        margin = (imageSize - width * pixelSize) / 2;
    }
    
    CGRect rectDraw = CGRectMake(0.0f, 0.0f, pixelSize, pixelSize);
    // draw
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake(margin + j * pixelSize, margin + i * pixelSize);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

- (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)size {
    return [self mdQRCodeForString:qrString size:size fillColor:[UIColor blackColor]];
}

-(UIColor *)colorFromHex:(NSString *)hex {
    unsigned int c;
    if ([hex characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hex substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hex] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0
                           green:((c & 0xff00) >> 8)/255.0
                            blue:(c & 0xff)/255.0 alpha:1.0];
}

- (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor {
    if (0 == [qrString length]) {
        return nil;
    }
    
    // generate QR
    QRcode *code = QRcode_encodeString([qrString UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    CGFloat size = imageSize * [[UIScreen mainScreen] scale];
    if (code->width > size) {
        printf("Image size is less than qr code size (%d)\n", code->width);
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter safely.
    
    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [self mdDrawQRCode:code context:ctx size:size fillColor:fillColor];
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    // free memory
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    return qrImage;
}

#pragma Public APIs
-(TiBlob*)buildQrcode:(id)args{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    //width
    CGFloat targetWidth = [TiUtils floatValue:args[@"width"]] / 2;
    NSString *targetString = [TiUtils stringValue:args[@"text"]];
    NSString *colorCode = [TiUtils stringValue:args[@"color"]];
    
    //TiColor *colorCode = [TiUtils colorValue:@"color"];
    //UIColor *targetColor = [colorCode _color];

    UIColor *targetColor = [self colorFromHex:colorCode];
    
    UIImage* proceedImage = [self mdQRCodeForString:targetString size:targetWidth fillColor:targetColor];

    // generate blob
    NSString* mimeType = @"image/png";
    NSData* convertedData = UIImagePNGRepresentation(proceedImage);
    TiBlob* convertedBlob = [[TiBlob alloc] initWithData:convertedData
                                                mimetype:mimeType];
    return convertedBlob;
}

@end
