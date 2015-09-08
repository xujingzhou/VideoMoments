//
//  UIImage+Reflection.h
//  ImageReflection
//
//  Created by Alex Nichol on 11/7/10.
//  Copyright 2010 Jitsik. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Reflection)

- (UIImage *)reflectionWithHeight:(int)height;
- (UIImage *)reflectionWithAlpha:(float)pcnt;
- (UIImage *)reflectionRotatedWithAlpha:(float)pcnt;

@end
