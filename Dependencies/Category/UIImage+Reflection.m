//
//  UIImage+Reflection.m
//  ImageReflection
//
//  Created by Alex Nichol on 11/7/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import "UIImage+Reflection.h"

#ifndef UIImageReflectionMethods
#define UIImageReflectionMethods

CGImageRef CreateGradientImage (int pixelsWide, int pixelsHigh, CGFloat endPoint)
{
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, endPoint);
	
	if (endPoint < 0)
    {
		gradientEndPoint = CGPointMake(0, -endPoint);
	}
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	
	if (endPoint < 0)
    {
		// rotate
		CGContextClearRect(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh));
		CGContextTranslateCTM(gradientBitmapContext, 0.0, pixelsHigh);
		CGContextScaleCTM(gradientBitmapContext, 1.0, -1.0);
		CGContextDrawImage(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh), theCGImage);
		CGImageRelease(theCGImage);
		theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	}
	
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

static CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

#endif

@implementation UIImage (Reflection)

- (UIImage *)reflectionRotatedWithAlpha:(float)pcnt
{
	int height = self.size.height;
	UIImage * fromImage = self;
	pcnt = 1.0 / pcnt;
	
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, height);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height, -(height * pcnt));
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	// CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	// CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage 
	UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}

- (UIImage *)reflectionWithHeight:(int)height
{
	if (height == -1)
    {
		height = [self size].height;
	}
    
	if (height == 0)
		return nil;
	
    UIImage * fromImage = self;
	
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, fromImage.size.height);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	CGContextTranslateCTM(mainViewContentContext, 0.0, fromImage.size.height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage 
	UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}

- (UIImage *)reflectionWithAlpha:(float)pcnt
{
	int height = self.size.height;
	UIImage * fromImage = self;
	pcnt = 1.0 / pcnt;
	
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.size.width, height);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height, height * pcnt);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.size.width, fromImage.size.height), [fromImage CGImage]);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage 
	UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}

@end
