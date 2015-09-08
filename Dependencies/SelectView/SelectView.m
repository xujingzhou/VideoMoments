//
//  SelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 10/19/14.
//  Copyright (c) 2014 Future Studio. All rights reserved.
//

#import "SelectView.h"

static NSMutableDictionary *filenameDic;

#define ContentHeight 50

@interface SelectView()

@property (nonatomic, strong) UIButton *selectedBtn;

@end

@implementation SelectView

#pragma mark - Puzzle
- (id)initWithFrameFromPuzzle:(CGRect)frame picCount:(NSInteger)picCount
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.picCount = picCount;
        [self initResourceFormPuzzle];
    }
    return self;
}

- (void)initResourceFormPuzzle
{
    _selectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, ContentHeight)];
    [_selectView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    _selectView.showsHorizontalScrollIndicator = NO;
    _selectView.showsVerticalScrollIndicator = NO;
    [self addSubview:_selectView];
    
    CGFloat width = 116/2.0f;
    CGFloat height = 100/2.0f;
    
    NSArray *imageNameArray = nil;
    
    switch (self.picCount)
    {
        case 2:
            imageNameArray = [NSArray arrayWithObjects:
                                @"btn_close",
                                @"makecards_puzzle_storyboard1_icon",
                                @"makecards_puzzle_storyboard2_icon",
                                @"makecards_puzzle_storyboard3_icon",
                                nil];
            break;
        case 3:
            imageNameArray = [NSArray arrayWithObjects:
                              @"btn_close",
                              @"makecards_puzzle3_storyboard1_icon",
                              @"makecards_puzzle3_storyboard2_icon",
                              @"makecards_puzzle3_storyboard3_icon",
                              nil];
            break;
        case 4:
            imageNameArray = [NSArray arrayWithObjects:
                              @"btn_close",
                              @"makecards_puzzle4_storyboard1_icon",
                              @"makecards_puzzle4_storyboard2_icon",
                              @"makecards_puzzle4_storyboard3_icon",
                              @"makecards_puzzle4_storyboard4_icon",
                              nil];
            break;
        case 5:
            imageNameArray = [NSArray arrayWithObjects:
                              @"btn_close",
                              @"makecards_puzzle5_storyboard1_icon",
                              @"makecards_puzzle5_storyboard2_icon",
                              @"makecards_puzzle5_storyboard3_icon",
                              @"makecards_puzzle5_storyboard4_icon",
                              nil];
            break;
        default:
            break;
    }
    
    for (int i = 0; i < [imageNameArray count]; i++)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*width+(width-37)/2.0f, 2.5f, 37, 45)];
        [button setImage:[UIImage imageNamed:[imageNameArray objectAtIndex:i]] forState:UIControlStateNormal];
        
        UIEdgeInsets insets = {3, 3, 3, 3};
        [button setImageEdgeInsets:insets];
        
        [button setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [_selectView addSubview:button];
        
        if (i == 1)
        {
            [button setSelected:YES];
            _selectedBtn = button;
        }
    }
    
    [_selectView setContentSize:CGSizeMake([imageNameArray count]*width, height)];
}

- (void)selectAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == _selectedBtn)
    {
        return;
    }
    
    self.selectStyleIndex = button.tag;
    if (self.selectStyleIndex != 0)
    {
        [_selectedBtn setSelected:NO];
        _selectedBtn = button;
        [_selectedBtn setSelected:YES];
    }
    
    if (_delegateSelect && [_delegateSelect respondsToSelector:@selector(didSelectedPicCount:styleIndex:)])
    {
        [_delegateSelect didSelectedPicCount:self.picCount styleIndex:self.selectStyleIndex];
    }
}

@end
