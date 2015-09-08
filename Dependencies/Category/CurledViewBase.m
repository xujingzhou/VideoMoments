//
//  CurledViewBase.m
//  curledViews
//
//  Created by Ryan Kelly on 2/9/12.
//  Copyright (c) 2012 Remote Vision, Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "CurledViewBase.h"
#import <QuartzCore/QuartzCore.h>

@implementation CurledViewBase

#pragma mark - Singleton
+ (CurledViewBase *) sharedInstance
{
    static CurledViewBase *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[CurledViewBase alloc] init];
    });
    
    return singleton;
}

+(UIImage*)rescaleImage:(UIImage*)image forLayer:(CALayer*)layer
{
    UIImage* scaledImage = image;
    CGFloat borderWidth = layer.borderWidth;
    
    //if border is defined 
    if (borderWidth > 0)
    {
        //rectangle in which we want to draw the image.
        CGRect imageRect = CGRectMake(0.0, 0.0, layer.bounds.size.width - 2 * borderWidth, layer.bounds.size.height - 2 * borderWidth);
        
        //Only draw image if its size is bigger than the image rect size.
        if (image.size.width > imageRect.size.width || image.size.height > imageRect.size.height)
        {
            UIGraphicsBeginImageContext(imageRect.size);
            [image drawInRect:imageRect];
            scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }        
    }
    
    return scaledImage;
}


+(UIBezierPath*)curlShadowPathWithShadowDepth:(CGFloat)shadowDepth controlPointXOffset:(CGFloat)controlPointXOffset controlPointYOffset:(CGFloat)controlPointYOffset forLayer:(CALayer*)layer
{
    
    CGSize viewSize = [layer bounds].size;
    CGPoint polyTopLeft = CGPointMake(0.0, controlPointYOffset);
    CGPoint polyTopRight = CGPointMake(viewSize.width, controlPointYOffset);
    CGPoint polyBottomLeft = CGPointMake(0.0, viewSize.height + shadowDepth);
    CGPoint polyBottomRight = CGPointMake(viewSize.width, viewSize.height +  shadowDepth);
    
    CGPoint controlPointLeft = CGPointMake(controlPointXOffset , controlPointYOffset);
    CGPoint controlPointRight = CGPointMake(viewSize.width - controlPointXOffset,  controlPointYOffset);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    [path moveToPoint:polyTopLeft];
    [path addLineToPoint:polyTopRight];
    [path addLineToPoint:polyBottomRight];
    [path addCurveToPoint:polyBottomLeft 
            controlPoint1:controlPointRight
            controlPoint2:controlPointLeft];
    
    [path closePath];  
    return path;
}

-(void)configureBorder:(CGFloat)borderWidth shadowDepth:(CGFloat)shadowDepth controlPointXOffset:(CGFloat)controlPointXOffset controlPointYOffset:(CGFloat)controlPointYOffset forLayer:(CALayer*)layer

{
    [layer setBorderWidth:borderWidth];
    [layer setBorderColor:[UIColor whiteColor].CGColor];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:CGSizeMake(0.0, 4.0)];
    [layer setShadowRadius:3.0];
    [layer setShadowOpacity:0.4];
    
    UIBezierPath* path = [CurledViewBase curlShadowPathWithShadowDepth:shadowDepth
                                                   controlPointXOffset:controlPointXOffset
                                                   controlPointYOffset:controlPointYOffset
                                                               forLayer:layer];
    [layer setShadowPath:path.CGPath];
}

-(UIImage*)setImage:(UIImage*)image forLayer:(CALayer*)layer
{
    return [self setImage:image borderWidth:5.0 shadowDepth:10.0 controlPointXOffset:30.0 controlPointYOffset:70.0 forLayer:layer];
}

-(UIImage*)setImage:(UIImage*)image borderWidth:(CGFloat)borderWidth shadowDepth:(CGFloat)shadowDepth controlPointXOffset:(CGFloat)controlPointXOffset controlPointYOffset:(CGFloat)controlPointYOffset forLayer:(CALayer*)layer
{
    layer.backgroundColor = (__bridge CGColorRef)([UIColor lightGrayColor]);
    
    // delegate to CurledViewBase
    [self configureBorder:borderWidth shadowDepth:shadowDepth controlPointXOffset:controlPointXOffset controlPointYOffset:controlPointYOffset forLayer:layer];
    
    UIImage* scaledImage = [CurledViewBase rescaleImage:image forLayer:layer];
    layer.contents = (id)[scaledImage CGImage];
    
    return scaledImage;
}

@end
