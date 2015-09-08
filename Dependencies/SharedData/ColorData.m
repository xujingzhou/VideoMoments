//
//  ColorData
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/4/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "ColorData.h"

@interface ColorData()

@property (nonatomic, strong) NSArray *backgroundArray;
@property (nonatomic, strong) NSArray *backgroundButtonArray;

@end


@implementation ColorData

#pragma mark - Singleton
+ (ColorData *) sharedInstance
{
    static ColorData *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[ColorData alloc] init];
    });
    
    return singleton;
}

#pragma mark - LifeCycle
- (id)init
{
    if (self = [super init])
    {
        _backgroundArray = [NSArray arrayWithObjects:
                             @"sm_pattern_01.png", @"sm_pattern_02.png",  @"sm_pattern_03.png", @"sm_pattern_04.png", @"sm_pattern_05.png", @"sm_pattern_06.png", @"sm_pattern_07.png",  @"sm_pattern_08.png", @"sm_pattern_09.png", @"sm_pattern_10.png", @"sm_pattern_11.png", @"sm_pattern_12.png", @"sm_pattern_13.png",  @"sm_pattern_14.png", @"sm_pattern_15.png", @"sm_pattern_16.png", @"sm_pattern_17.png", @"sm_pattern_18.png", @"sm_pattern_19.png", @"sm_pattern_20.png", nil];
        
        _backgroundButtonArray = [NSArray arrayWithObjects:
                                  @"sm_select_ptn_01@2x.png", @"sm_select_ptn_02@2x.png", @"sm_select_ptn_03@2x.png",  @"sm_select_ptn_04@2x.png", @"sm_select_ptn_05@2x.png", @"sm_select_ptn_06@2x.png", @"sm_select_ptn_07@2x.png", @"sm_select_ptn_08@2x.png", @"sm_select_ptn_09@2x.png", @"sm_select_ptn_10@2x.png", @"sm_select_ptn_11@2x.png", @"sm_select_ptn_12@2x.png", @"sm_select_ptn_13@2x.png", @"sm_select_ptn_14@2x.png", @"sm_select_ptn_15@2x.png", @"sm_select_ptn_16@2x.png", @"sm_select_ptn_17@2x.png", @"sm_select_ptn_18@2x.png", @"sm_select_ptn_19@2x.png", @"sm_select_ptn_20@2x.png", nil];
        
        _curSelectBgIndex = -1;
    }
    
    return self;
}

- (void)dealloc
{
    if (_backgroundArray)
    {
        _backgroundArray = nil;
    }
    
    if (_backgroundButtonArray)
    {
        _backgroundButtonArray = nil;
    }
}

@end
