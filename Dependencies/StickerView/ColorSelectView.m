//
//  ColorSelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "ColorSelectView.h"
#import "ColorData.h"

#define ContentHeight 50

@interface ColorSelectView()

@property (nonatomic, strong) UIButton *selectedViewBtn;

@end

@implementation ColorSelectView

#pragma mark - Init
- (id)initWithFrameFromColor:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization
        [self initResourceFormColor];
    }
    return self;
}

- (void)initResourceFormColor
{
    _ContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), ContentHeight)];
    [_ContentView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    _ContentView.showsHorizontalScrollIndicator = NO;
    _ContentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_ContentView];
    
    // Get files count from resource
    NSArray *fileList = [NSArray arrayWithArray:[[ColorData sharedInstance] backgroundButtonArray]];
    NSLog(@"fileList: %@, Count: %lu", fileList, (unsigned long)[fileList count]);
    
    unsigned long count = [fileList count] + 1;
    CGFloat width = 116/2.0f;
    CGFloat height = 100/2.0f;
    for (int i = 0; i < count; ++i)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*width+(width-37)/2.0f, 2.5f, 45, 45)];
        
        if (i == 0)
        {
            UIImage *image = [UIImage imageNamed:@"btn_close"];
            [button setImage:image forState:UIControlStateNormal];
        }
        else
        {
            NSString *name = [fileList objectAtIndex:i-1];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            [button setImage:image forState:UIControlStateNormal];
        }
        
        UIEdgeInsets insets = {3, 3, 3, 3};
        [button setImageEdgeInsets:insets];
        
        [button setBackgroundImage:[UIImage imageNamed:@"sm_select_ptn_selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(gifAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [_ContentView addSubview:button];
        
        if (i == 1)
        {
            [button setSelected:YES];
            _selectedViewBtn = button;
        }
    }
    
    [_ContentView setContentSize:CGSizeMake(count*width, height)];
}

- (void)gifAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == _selectedViewBtn)
    {
        return;
    }
    
    self.selectStyleIndex = button.tag;
    if (self.selectStyleIndex != 0)
    {
        [_selectedViewBtn setSelected:NO];
        _selectedViewBtn = button;
        [_selectedViewBtn setSelected:YES];
    }
    
    if (_delegateSelect && [_delegateSelect respondsToSelector:@selector(didSelectedColorIndex:)])
    {
        [_delegateSelect didSelectedColorIndex:self.selectStyleIndex];
    }
}

@end
