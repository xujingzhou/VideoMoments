//
//  ScrollSelectView
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "ScrollSelectView.h"

static NSMutableDictionary *filenameDic;

#define ContentHeight 50

@interface ScrollSelectView()

@property (nonatomic, strong) UIButton *selectedViewBtn;

@end

@implementation ScrollSelectView

#pragma mark - GIF
- (id)initWithFrameFromGif:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization
        [self initResourceFormGif];
    }
    return self;
}

- (void)initResourceFormGif
{
    _ContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), ContentHeight)];
    [_ContentView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    _ContentView.showsHorizontalScrollIndicator = NO;
    _ContentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_ContentView];
    
    // Get files count from resource
    NSString *filename = @"gif";
    NSArray *fileList = [filenameDic objectForKey:filename];
    NSLog(@"fileList: %@, Count: %lu", fileList, (unsigned long)[fileList count]);
    
    unsigned long gifCount = [fileList count] + 1;
    CGFloat width = 116/2.0f;
    CGFloat height = 100/2.0f;
    for (int i = 0; i < gifCount; ++i)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*width+(width-37)/2.0f, 2.5f, 45, 45)];
        
        if (i == 0)
        {
            UIImage *image = [UIImage imageNamed:@"btn_close"];
            [button setImage:image forState:UIControlStateNormal];
        }
        else
        {
            NSString *name = [NSString stringWithFormat:@"gif_%i.gif", i];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            [button setImage:image forState:UIControlStateNormal];
        }
        
        UIEdgeInsets insets = {3, 3, 3, 3};
        [button setImageEdgeInsets:insets];
        
        [button setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(gifAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [_ContentView addSubview:button];
        
        if (i == 1)
        {
            [button setSelected:YES];
            _selectedViewBtn = button;
        }
    }
    
    [_ContentView setContentSize:CGSizeMake(gifCount*width, height)];
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
    
    if (_delegateSelect && [_delegateSelect respondsToSelector:@selector(didSelectedGifIndex:)])
    {
        [_delegateSelect didSelectedGifIndex:self.selectStyleIndex];
    }
}

#pragma mark - Border
- (id)initWithFrameFromBorder:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization
        [self initResourceFormBorder];
    }
    return self;
}

- (void)initResourceFormBorder
{
    _ContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), ContentHeight)];
    [_ContentView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    _ContentView.showsHorizontalScrollIndicator = NO;
    _ContentView.showsVerticalScrollIndicator = NO;
    [self addSubview:_ContentView];
    
    // Get files count from resource
    NSString *filename = @"border";
    NSArray *fileList = [filenameDic objectForKey:filename];
    NSLog(@"fileList: %@, Count: %lu", fileList, (unsigned long)[fileList count]);
    
    unsigned long borderCount = [fileList count] + 1;
    CGFloat width = 116/2.0f;
    CGFloat height = 100/2.0f;
    for (int i = 0; i < borderCount; i++)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*width+(width-37)/2.0f, 2.5f, 37, 45)];
        if (i == 0)
        {
            UIImage *image = [UIImage imageNamed:@"btn_close"];
            [button setImage:image forState:UIControlStateNormal];
        }
        else
        {
            NSString *name = [NSString stringWithFormat:@"border_%i.png", i];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
            [button setImage:img forState:UIControlStateNormal];
        }
        
        UIEdgeInsets insets = {3, 3, 3, 3};
        [button setImageEdgeInsets:insets];
        
        [button setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(borderAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [_ContentView addSubview:button];
        
        if (i == 1)
        {
            [button setSelected:YES];
            _selectedViewBtn = button;
        }
    }
    
    [_ContentView setContentSize:CGSizeMake(borderCount*width, height)];
}

- (void)borderAction:(id)sender
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
    
    if (_delegateSelect && [_delegateSelect respondsToSelector:@selector(didSelectedBorderIndex:)])
    {
        [_delegateSelect didSelectedBorderIndex:self.selectStyleIndex];
    }
}

#pragma mark - GetDefaultFilelist
+ (void)getDefaultFilelist
{
    NSString *name = @"gif_1", *type = @"gif";
    NSString *fileFullPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSString *filePathWithoutName = [fileFullPath stringByDeletingLastPathComponent];
    NSString *fileName = [fileFullPath lastPathComponent];
    NSString *fileExt = [fileFullPath pathExtension];
    NSLog(@"filePathWithoutName: %@, fileName: %@, fileExt: %@", filePathWithoutName, fileName, fileExt);
    
    NSString *filenameByGif = @"gif";
    filenameDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [filenameDic setObject:getFilelistBySymbol(filenameByGif, filePathWithoutName, type) forKey:filenameByGif];
    
    NSString *filenameByBorder = @"border";
    type = @"png";
    [filenameDic setObject:getFilelistBySymbol(filenameByBorder, filePathWithoutName, type) forKey:filenameByBorder];
}

@end
