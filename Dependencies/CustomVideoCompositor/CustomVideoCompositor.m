//
//  CustomVideoCompositor
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

@import  UIKit;
#import "CustomVideoCompositor.h"
#import "PuzzleData.h"
#import "ColorData.h"

@interface CustomVideoCompositor()


@end

@implementation CustomVideoCompositor

- (instancetype)init
{
    return self;
}

#pragma mark - startVideoCompositionRequest
- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request
{
    NSMutableArray *videoArray = [[NSMutableArray alloc] init];
    CVPixelBufferRef destination = [request.renderContext newPixelBuffer];
    if (request.sourceTrackIDs.count > 0)
    {
        for (NSUInteger i = 0; i < [request.sourceTrackIDs count]; ++i)
        {
            CVPixelBufferRef videoBufferRef = [request sourceFrameByTrackID:[[request.sourceTrackIDs objectAtIndex:i] intValue]];
            if (videoBufferRef)
            {
                [videoArray addObject:(__bridge id)(videoBufferRef)];
            }
        }
        
        for (NSUInteger i = 0; i < [videoArray count]; ++i)
        {
            CVPixelBufferRef video = (__bridge CVPixelBufferRef)([videoArray objectAtIndex:i]);
            CVPixelBufferLockBaseAddress(video, kCVPixelBufferLock_ReadOnly);
        }
        CVPixelBufferLockBaseAddress(destination, 0);
        
        [self renderBuffer:videoArray toBuffer:destination];
        
        CVPixelBufferUnlockBaseAddress(destination, 0);
        for (NSUInteger i = 0; i < [videoArray count]; ++i)
        {
            CVPixelBufferRef video = (__bridge CVPixelBufferRef)([videoArray objectAtIndex:i]);
            CVPixelBufferUnlockBaseAddress(video, kCVPixelBufferLock_ReadOnly);
        }
    }
    
    [request finishWithComposedVideoFrame:destination];
    CVBufferRelease(destination);
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext
{
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext
{
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

- (NSDictionary *)sourcePixelBufferAttributes
{
    return @{ (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @[ @(kCVPixelFormatType_32BGRA) ] };
}

#pragma mark - renderBuffer
- (void)renderBuffer:(NSMutableArray *)videoBufferRefArray toBuffer:(CVPixelBufferRef)destination
{
    size_t width = CVPixelBufferGetWidth(destination);
    size_t height = CVPixelBufferGetHeight(destination);
    NSMutableArray *imageRefArray = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [videoBufferRefArray count]; ++i)
    {
        CVPixelBufferRef videoFrame = (__bridge CVPixelBufferRef)([videoBufferRefArray objectAtIndex:i]);
        CGImageRef imageRef = [self createSourceImageFromBuffer:videoFrame];
        if (imageRef)
        {
            if ([self shouldRightRotate90ByTrackID:i+1])
            {
                // Right rotation 90
                imageRef = CGImageRotated(imageRef, M_PI_2);
            }
            
            [imageRefArray addObject:(__bridge id)(imageRef)];
        }
        CGImageRelease(imageRef);
    }
    
    CGRect rectVideo = CGRectZero;
    rectVideo.size = CGSizeMake(width, height);
    CGContextRef gc = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(destination), width, height, CGImageGetBitsPerComponent((CGImageRef)imageRefArray[0]), CVPixelBufferGetBytesPerRow(destination), CGImageGetColorSpace((CGImageRef)imageRefArray[0]), CGImageGetBitmapInfo((CGImageRef)imageRefArray[0]));
    
    // Fill whole background
    NSInteger curIndex = [[ColorData sharedInstance] curSelectBgIndex];
    if (curIndex < 0)
    {
        CGContextSetFillColorWithColor(gc, UIColorFromRGB(0xEEEEEE).CGColor);
        CGContextFillRect(gc, rectVideo);
    }
    else
    {
        NSString *imageName = [[[ColorData sharedInstance] backgroundArray] objectAtIndex:curIndex];
        UIImage *backgroundImage = [UIImage imageNamed:imageName];
        CGContextClipToRect(gc, rectVideo);
        CGContextDrawTiledImage(gc, CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height), [backgroundImage CGImage]);
    }
    
    NSMutableArray *frames = [[PuzzleData sharedInstance] frames];
    for (int i = 0; i < [imageRefArray count]; ++i)
    {
        CGRect frame = [frames[i] CGRectValue];
        CGContextSetFillColorWithColor(gc, [UIColor blackColor].CGColor);
        CGContextFillRect(gc, frame);
        
        float imageWidth = CGImageGetWidth((CGImageRef)imageRefArray[i]);
        float imageHeight = CGImageGetHeight((CGImageRef)imageRefArray[i]);
        float width = 0.0, height = 0.0;
        if (imageWidth < CGRectGetWidth(frame))
        {
            width = imageWidth;
        }
        else
        {
            width = CGRectGetWidth(frame);
        }
        
        if (imageHeight < CGRectGetHeight(frame))
        {
            height = imageHeight;
        }
        else
        {
            height = CGRectGetHeight(frame);
        }
                             
        CGRect cropRect = CGRectMake(fabs((imageWidth - width)/2), fabs((imageHeight - height)/2), width, height);
        CGImageRef imageRef = CGImageCreateWithImageInRect((CGImageRef)imageRefArray[i], cropRect);
        CGRect resultRect = CGRectMake(CGRectGetMinX(frame) + fabs((CGRectGetWidth(frame) - width)/2), CGRectGetMinY(frame) + fabs((CGRectGetHeight(frame) - height)/2), width, height);
        CGContextDrawImage(gc, resultRect, imageRef);
        CGImageRelease(imageRef);
    }
        
    CGContextRelease(gc);
}

#pragma mark - createSourceImageFromBuffer
- (CGImageRef)createSourceImageFromBuffer:(CVPixelBufferRef)buffer
{
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t stride = CVPixelBufferGetBytesPerRow(buffer);
    void *data = CVPixelBufferGetBaseAddress(buffer);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, height * stride, NULL);
    CGImageRef image = CGImageCreate(width, height, 8, 32, stride, rgb, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, provider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgb);
    
    return image;
}

#pragma mark - CGImageRotated
CGImageRef CGImageRotated(CGImageRef originalCGImage, double radians)
{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(originalCGImage), CGImageGetHeight(originalCGImage));
    CGSize rotatedSize;
    if (radians == M_PI_2 || radians == -M_PI_2)
    {
        rotatedSize = CGSizeMake(imageSize.height, imageSize.width);
    }
    else
    {
        rotatedSize = imageSize;
    }
    
    double rotatedCenterX = rotatedSize.width / 2.f;
    double rotatedCenterY = rotatedSize.height / 2.f;
    CGContextRef rotatedContext = CGBitmapContextCreate(NULL, rotatedSize.width, rotatedSize.height,
                                             CGImageGetBitsPerComponent(originalCGImage), 0,
                                             CGImageGetColorSpace(originalCGImage),
                                             CGImageGetBitmapInfo(originalCGImage));
    if (radians == 0.f || radians == M_PI)
    {
        // 0 or 180 degrees
        CGContextTranslateCTM(rotatedContext, rotatedCenterX, rotatedCenterY);
        if (radians == 0.0f)
        {
            CGContextScaleCTM(rotatedContext, 1.f, -1.f);
        }
        else
        {
            CGContextScaleCTM(rotatedContext, -1.f, 1.f);
        }
        CGContextTranslateCTM(rotatedContext, -rotatedCenterX, -rotatedCenterY);
    }
    else if (radians == M_PI_2 || radians == -M_PI_2)
    {
        // +/- 90 degrees
//        CGContextTranslateCTM(rotatedContext, rotatedCenterX, rotatedCenterY);
//        CGContextRotateCTM(rotatedContext, radians);
//        CGContextScaleCTM(rotatedContext, 1.f, -1.f);
//        CGContextTranslateCTM(rotatedContext, -rotatedCenterY, -rotatedCenterX);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, 0, rotatedSize.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        CGContextConcatCTM(rotatedContext, transform);
    }
    
    CGRect drawingRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
    CGContextDrawImage(rotatedContext, drawingRect, originalCGImage);
    CGImageRef rotatedCGImage = CGBitmapContextCreateImage(rotatedContext);
    CGContextRelease(rotatedContext);
    
    return rotatedCGImage;
}

void drawImage(CGContextRef context, CGImageRef image , CGRect rect)
{
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image);
    
    CGContextRestoreGState(context);
}

#pragma mark - addPath
- (void)addPath:(CGContextRef)gc withPath:(UIBezierPath *)path
{
    // Path points
    CGContextBeginPath(gc);
    CGContextSetRGBStrokeColor(gc, 1, 1, 1, 1);
    CGContextSetLineWidth(gc, 3);
    CGContextSetShouldAntialias(gc, YES);
    CGContextAddPath(gc, path.CGPath);
}

#pragma mark - drawBorderInFrame
- (void)drawBorderInFrames:(NSArray *)frames withContextRef:(CGContextRef)contextRef
{
    if (!frames || [frames count] < 1)
    {
        NSLog(@"drawBorderInFrames is empty.");
        return;
    }
    
    if ([self shouldDisplayInnerBorder])
    {
        // Fill background
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextFillRect(contextRef, [frames[0] CGRectValue]);
        
        // Draw
        CGContextBeginPath(contextRef);
        CGFloat lineWidth = 5;
        for (int i = 1; i < [frames count]; ++i)
        {
            CGRect innerVideoRect = [frames[i] CGRectValue];
            if (!CGRectIsEmpty(innerVideoRect))
            {
                CGContextAddRect(contextRef, CGRectInset(innerVideoRect, lineWidth, lineWidth));
            }
        }
        CGContextClip(contextRef);
    }
}

#pragma mark - getCroppedRect
- (CGRect)getCroppedRect
{
    NSArray *pointsPath = [self getPathPoints];
    return getCroppedBounds(pointsPath);
}

#pragma mark - NSUserDefaults
#pragma mark - PathPoints
- (NSArray *)getPathPoints
{
    NSArray *arrayResult = nil;
    NSString *flag = @"ArrayPathPoints";
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSData *dataPathPoints = [userDefaultes objectForKey:flag];
    if (dataPathPoints)
    {
        arrayResult = [NSKeyedUnarchiver unarchiveObjectWithData:dataPathPoints];
//        if (arrayResult && [arrayResult count] > 0)
//        {
//             NSLog(@"points has content.");
//        }
    }
    else
    {
//        NSLog(@"getPathPoints is empty.");
    }
    
    return arrayResult;
}

#pragma mark - OutputBGColor
- (UIColor *)getOutputBGColor
{
    NSString *flag = @"OutputBGColor";
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSData *objColor = [userDefaultes objectForKey:flag];
    UIColor *bgColor = nil;
    if (objColor)
    {
        bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:objColor];
    }
    return bgColor;
}

#pragma mark - shouldDisplayInnerBorder
- (BOOL)shouldDisplayInnerBorder
{
    NSString *shouldDisplayInnerBorder = @"ShouldDisplayInnerBorder";
//    NSLog(@"shouldDisplayInnerBorder: %@", [[[NSUserDefaults standardUserDefaults] objectForKey:shouldDisplayInnerBorder] boolValue]?@"Yes":@"No");
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:shouldDisplayInnerBorder] boolValue])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - shouldRightRotate90ByTrackID
- (BOOL)shouldRightRotate90ByTrackID:(NSInteger)trackID
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [NSString stringWithFormat:@"TrackID_%ld", (long)trackID];
    BOOL result = [[userDefaultes objectForKey:identifier] boolValue];
//    NSLog(@"shouldRightRotate90ByTrackID %@ : %@", identifier, result?@"Yes":@"No");
    
    if (result)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
