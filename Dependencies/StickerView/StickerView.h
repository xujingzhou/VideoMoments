//
//  StickerView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#import "CircleView.h"

@interface StickerView : UIView

@property (copy, nonatomic) GenericCallback deleteFinishBlock;

+ (void)setActiveStickerView:(StickerView*)view;

- (id)initWithFilePath:(NSString *)path;

- (UIImageView*)imageView;
- (id)initWithImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;
- (void)setScale:(CGFloat)scaleX andScaleY:(CGFloat)scaleY;

- (void)setVideoContentRect:(CGRect)videoContent;
- (CGRect)getVideoContentRect;

- (CGRect)getInnerFrame;
- (CGFloat)getRotateAngle;
- (NSString *)getFilePath;

- (void)replayGif;

@end
