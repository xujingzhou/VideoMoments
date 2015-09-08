//
//  PuzzleData.m
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/4/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "PuzzleData.h"

@implementation PuzzleData

#pragma mark - Singleton
+ (PuzzleData *) sharedInstance
{
    static PuzzleData *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[PuzzleData alloc] init];
    });
    
    return singleton;
}

#pragma mark - LifeCycle
- (id)init
{
    if (self = [super init])
    {
        _puzzlePaths = [[NSMutableArray alloc] initWithCapacity:1];
        _frames = [[NSMutableArray alloc] initWithCapacity:1];
        _superFrame = CGSizeZero;
    }
    
    return self;
}

- (void)dealloc
{
    if (_puzzlePaths)
    {
        [_puzzlePaths removeAllObjects];
        _puzzlePaths = nil;
    }
    
    if (_frames)
    {
        [_frames removeAllObjects];
        _frames = nil;
    }
}

@end
