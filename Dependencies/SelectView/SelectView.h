//
//  SelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 10/19/14.
//  Copyright (c) 2014 Future Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectViewDelegate;

@interface SelectView : UIView

@property (nonatomic, strong) UIScrollView  *selectView;
@property (nonatomic, assign) id<SelectViewDelegate> delegateSelect;
@property (nonatomic, assign) NSInteger      picCount;
@property (nonatomic, assign) NSInteger      selectStyleIndex;

- (id)initWithFrameFromPuzzle:(CGRect)frame picCount:(NSInteger)picCount;

@end

@protocol SelectViewDelegate <NSObject>

@optional
- (void)didSelectedPicCount:(NSInteger)picCount styleIndex:(NSInteger)styleIndex;

@end
