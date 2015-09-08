//
//  ExportEffects
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoThemesData.h"

#define TrackIDCustom 1

typedef NSString *(^JZOutputFilenameBlock)();
typedef void (^JZFinishVideoBlock)(BOOL success, id result);
typedef void (^JZExportProgressBlock)(NSNumber *percentage, NSString *title);

@interface ExportEffects : NSObject

@property (nonatomic, copy) JZFinishVideoBlock finishVideoBlock;
@property (nonatomic, copy) JZExportProgressBlock exportProgressBlock;
@property (nonatomic, copy) JZOutputFilenameBlock filenameBlock;

@property (nonatomic, strong) NSMutableArray *gifArray;
@property (nonatomic, assign) ThemesType themeCurrentType;

+ (ExportEffects *)sharedInstance;

- (void)addEffectToVideo:(NSMutableArray *)assets;
- (void)writeExportedVideoToAssetsLibrary:(NSString *)outputPath;

@end
