//
//  ColorSelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorScrollSelectViewDelegate;

@interface ColorSelectView : UIView

@property (nonatomic, strong) UIScrollView  *ContentView;
@property (nonatomic, assign) id<ColorScrollSelectViewDelegate> delegateSelect;
@property (nonatomic, assign) NSInteger selectStyleIndex;

- (id)initWithFrameFromColor:(CGRect)frame;

@end

@protocol ColorScrollSelectViewDelegate <NSObject>

@optional
- (void)didSelectedColorIndex:(NSInteger)styleIndex;

@end
