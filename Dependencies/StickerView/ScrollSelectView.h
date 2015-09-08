//
//  ScrollSelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollSelectViewDelegate;

@interface ScrollSelectView : UIView

@property (nonatomic, strong) UIScrollView  *ContentView;
@property (nonatomic, assign) id<ScrollSelectViewDelegate> delegateSelect;
@property (nonatomic, assign) NSInteger selectStyleIndex;

- (id)initWithFrameFromGif:(CGRect)frame;
- (id)initWithFrameFromBorder:(CGRect)frame;

+ (void)getDefaultFilelist;

@end

@protocol ScrollSelectViewDelegate <NSObject>

@optional
- (void)didSelectedGifIndex:(NSInteger)styleIndex;
- (void)didSelectedBorderIndex:(NSInteger)styleIndex;

@end
