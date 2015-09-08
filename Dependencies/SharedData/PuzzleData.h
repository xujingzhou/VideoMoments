//
//  PuzzleData.h
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/4/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PuzzleData : NSObject

@property (nonatomic, strong) NSMutableArray *puzzlePaths;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) CGSize superFrame;

+ (PuzzleData *)sharedInstance;

@end
