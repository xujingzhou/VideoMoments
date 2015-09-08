//
//  ExportEffects
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ExportEffects.h"
#import "VideoBuilder.h"
#import "PuzzleData.h"
#import "CustomVideoCompositor.h"
#import "GifAnimationLayer.h"
#import "StickerView.h"

#define DefaultOutputVideoName @"outputMovie.mp4"
#define DefaultOutputAudioName @"outputAudio.caf"

@interface ExportEffects ()
{
}

@property (strong, nonatomic) NSTimer *timerEffect;
@property (strong, nonatomic) AVAssetExportSession *exportSession;

@property (retain, nonatomic) VideoBuilder *videoBuilder;
@property (retain, nonatomic) NSMutableDictionary *themesDic;

@end

@implementation ExportEffects
{

}

+ (ExportEffects *)sharedInstance
{
    static ExportEffects *sharedInstance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[ExportEffects alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _timerEffect = nil;
        _exportSession = nil;
        _filenameBlock = nil;
        
        self.themeCurrentType = kThemeNone;
        self.videoBuilder = [[VideoBuilder alloc] init];
        self.themesDic = [[VideoThemesData sharedInstance] getThemesData];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_exportSession)
    {
        _exportSession = nil;
    }
    
    if (_timerEffect)
    {
        [_timerEffect invalidate];
        _timerEffect = nil;
    }
    
    if (_exportSession)
    {
        _exportSession = nil;
    }
}

#pragma mark Utility methods
- (NSString*)getOutputFilePath
{
    NSString* mp4OutputFile = [NSTemporaryDirectory() stringByAppendingPathComponent:DefaultOutputVideoName];
    return mp4OutputFile;
}

- (NSString*)getTempOutputFilePath
{
    NSString *path = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mov"];
    return fileName;
}

#pragma mark - writeExportedVideoToAssetsLibrary
- (void)writeExportedVideoToAssetsLibrary:(NSString *)outputPath
{
    __unsafe_unretained typeof(self) weakSelf = self;
    NSURL *exportURL = [NSURL fileURLWithPath:outputPath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             NSString *message;
             if (!error)
             {
                 message = GBLocalizedString(@"MsgSuccess");
             }
             else
             {
                 message = [error description];
             }
             
             NSLog(@"%@", message);
             
             // Output path
             self.filenameBlock = ^(void) {
                 return outputPath;
             };
             
             if (weakSelf.finishVideoBlock)
             {
                 weakSelf.finishVideoBlock(YES, message);
             }
         }];
    }
    else
    {
        NSString *message = GBLocalizedString(@"MsgFailed");;
        NSLog(@"%@", message);
        
        // Output path
        self.filenameBlock = ^(void) {
            return @"";
        };
        
        if (_finishVideoBlock)
        {
            _finishVideoBlock(NO, message);
        }
    }
    
    library = nil;
}

#pragma mark - Export Video
- (void)addEffectToVideo:(NSMutableArray *)assets
{
    if ((!assets || [assets count] < 1) || self.themeCurrentType == kThemeNone)
    {
        NSLog(@"assets is empty! or Theme is empty!");
        
        // Output path
        self.filenameBlock = ^(void) {
            return @"";
        };
        
        if (self.finishVideoBlock)
        {
            self.finishVideoBlock(NO, GBLocalizedString(@"MsgConvertFailed"));
        }
        
        return;
    }
    
    VideoThemes *themeCurrent = nil;
    if (self.themeCurrentType != kThemeNone && [self.themesDic count] >= self.themeCurrentType)
    {
        themeCurrent = [self.themesDic objectForKey:[NSNumber numberWithInt:self.themeCurrentType]];
    }
    
    NSMutableArray *videoFileArray = [NSMutableArray arrayWithCapacity:[assets count]];
    for (int i = 0; i < [assets count]; ++i)
    {
        ALAsset *asset = [assets objectAtIndex:i];
        [videoFileArray addObject:asset.defaultRepresentation.url];
    }
    [self exportVideo:videoFileArray withPhotos:nil withAudioFilePath:themeCurrent.bgMusicFile];
}

#pragma mark - addAudioMixToComposition
- (void)addAudioMixToComposition:(AVMutableComposition *)composition withAudioMix:(AVMutableAudioMix *)audioMix withAsset:(AVURLAsset*)audioAsset
{
    NSInteger i;
    NSArray *tracksToDuck = [composition tracksWithMediaType:AVMediaTypeAudio];
    
    // 1. Clip commentary duration to composition duration.
    CMTimeRange commentaryTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    if (CMTIME_COMPARE_INLINE(CMTimeRangeGetEnd(commentaryTimeRange), >, [composition duration]))
        commentaryTimeRange.duration = CMTimeSubtract([composition duration], commentaryTimeRange.start);
    
    // 2. Add the commentary track.
    AVMutableCompositionTrack *compositionCommentaryTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:TrackIDCustom];
    AVAssetTrack * commentaryTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, commentaryTimeRange.duration) ofTrack:commentaryTrack atTime:commentaryTimeRange.start error:nil];
    
    // 3. Fade in for bgMusic
    CMTime fadeTime = CMTimeMake(1, 1);
    CMTimeRange startRange = CMTimeRangeMake(kCMTimeZero, fadeTime);
    NSMutableArray *trackMixArray = [NSMutableArray array];
    AVMutableAudioMixInputParameters *trackMixComentray = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:commentaryTrack];
    [trackMixComentray setVolumeRampFromStartVolume:0.0f toEndVolume:0.5f timeRange:startRange];
    [trackMixArray addObject:trackMixComentray];
    
    // 4. Fade in & Fade out for original voices
    for (i = 0; i < [tracksToDuck count]; i++)
    {
        CMTimeRange timeRange = [[tracksToDuck objectAtIndex:i] timeRange];
        if (CMTIME_COMPARE_INLINE(CMTimeRangeGetEnd(timeRange), ==, kCMTimeInvalid))
        {
            break;
        }
        
        CMTime halfSecond = CMTimeMake(1, 2);
        CMTime startTime = CMTimeSubtract(timeRange.start, halfSecond);
        CMTime endRangeStartTime = CMTimeAdd(timeRange.start, timeRange.duration);
        CMTimeRange endRange = CMTimeRangeMake(endRangeStartTime, halfSecond);
        if (startTime.value < 0)
        {
            startTime.value = 0;
        }
        
        [trackMixComentray setVolumeRampFromStartVolume:0.5f toEndVolume:0.2f timeRange:CMTimeRangeMake(startTime, halfSecond)];
        [trackMixComentray setVolumeRampFromStartVolume:0.2f toEndVolume:0.5f timeRange:endRange];
        [trackMixArray addObject:trackMixComentray];
    }
    
    audioMix.inputParameters = trackMixArray;
}

- (void)addAsset:(AVAsset *)asset toComposition:(AVMutableComposition *)composition withTrackID:(CMPersistentTrackID)trackID withRecordAudio:(BOOL)recordAudio withTimeRange:(CMTimeRange)timeRange
{
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CMTimeRange timeRangeSelf = CMTimeRangeFromTimeToTime(kCMTimeZero, assetVideoTrack.timeRange.duration);
    [videoTrack insertTimeRange:timeRangeSelf ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    
    if (recordAudio)
    {
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:trackID];
        if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        {
            AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            [audioTrack insertTimeRange:timeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
        }
        else
        {
            NSLog(@"Reminder: video hasn't audio!");
        }
    }
}

- (void)exportVideo:(NSArray *)videoFilePathArray withPhotos:(NSMutableArray *)photos withAudioFilePath:(NSString *)audioFilePath
{
    if (!videoFilePathArray || [videoFilePathArray count] < 1)
    {
        NSLog(@"videoFilePath is empty!");
        
        // Output path
        self.filenameBlock = ^(void) {
            return @"";
        };
        
        if (self.finishVideoBlock)
        {
            self.finishVideoBlock(NO, GBLocalizedString(@"MsgConvertFailed"));
        }
        
        return;
    }
    
    CMTime duration = kCMTimeZero;
    CMTime totalDuration = kCMTimeZero;
    CMTimeRange bgVideoTimeRange = kCMTimeRangeZero;
    NSMutableArray *assetArray = [[NSMutableArray alloc] initWithCapacity:1];
    AVMutableComposition *composition = [AVMutableComposition composition];
    for (int i = 0; i < [videoFilePathArray count]; ++i)
    {
        NSURL *videoURL = [videoFilePathArray objectAtIndex:i];
        AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
        
        NSLog(@"bgVideoFile: %@", videoURL);
        
        if (videoAsset)
        {
            UIInterfaceOrientation videoOrientation = orientationForTrack(videoAsset);
            NSLog(@"videoOrientation: %ld", (long)videoOrientation);
            if (videoOrientation == UIInterfaceOrientationPortrait)
            {
                // Right rotation 90 degree
                [self setShouldRightRotate90:YES withTrackID:i+1];
            }
            else
            {
                [self setShouldRightRotate90:NO withTrackID:i+1];
            }
            
            [self addAsset:videoAsset toComposition:composition withTrackID:i+1 withRecordAudio:NO withTimeRange:bgVideoTimeRange];
            [assetArray addObject:videoAsset];
            
            // Max duration
//            duration = MAX(duration, CMTimeGetSeconds(videoAsset.duration));
            if (CMTIME_COMPARE_INLINE(duration, <, videoAsset.duration))
            {
                duration = videoAsset.duration;
                bgVideoTimeRange = [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] timeRange];
            }
            
            totalDuration = CMTimeAdd(totalDuration, videoAsset.duration);
        }
    }
    
    if ([assetArray count] < 1)
    {
        NSLog(@"assetArray is empty!");
        
        // Output path
        self.filenameBlock = ^(void) {
            return @"";
        };
        
        if (self.finishVideoBlock)
        {
            self.finishVideoBlock(NO, GBLocalizedString(@"MsgConvertFailed"));
        }
        
        return;
    }
    
    // Embedded Music
    if (!isStringEmpty(audioFilePath))
    {
        NSLog(@"audioFilePath: %@", audioFilePath);
        
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:getFileURLFromAbsolutePath(getFilePath(audioFilePath)) options:nil];
        AVAssetTrack *assetAudioTrack = nil;
        if ([[audioAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        {
            assetAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            if (assetAudioTrack)
            {
                AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [compositionAudioTrack insertTimeRange:bgVideoTimeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
            }
        }
        else
        {
            NSLog(@"Reminder: embedded audio file is empty!");
        }
    }
    else
    {
        // BG video music
        AVAssetTrack *assetAudioTrack = nil;
        AVAsset *audioAsset = [assetArray objectAtIndex:0];
        if ([[audioAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        {
            assetAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            if (assetAudioTrack)
            {
                AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [compositionAudioTrack insertTimeRange:bgVideoTimeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
            }
        }
        else
        {
            NSLog(@"Reminder: embeded BG video hasn't audio!");
        }
    }
    
    // Background video
    AVAssetTrack *firstVideoTrack = [[assetArray[0] tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize videoSize = [[PuzzleData sharedInstance] superFrame]; //firstVideoTrack.naturalSize;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoComposition.renderSize = CGSizeMake(videoSize.width, videoSize.height);
//    BOOL shouldRotate = [self shouldRightRotate90ByTrackID:TrackIDCustom];
//    if (shouldRotate)
//    {
//        videoComposition.renderSize = CGSizeMake(videoSize.height, videoSize.width);
//    }
//    else
//    {
//        videoComposition.renderSize = CGSizeMake(videoSize.width, videoSize.height);
//    }
    
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / firstVideoTrack.nominalFrameRate, firstVideoTrack.naturalTimeScale);
    instruction.timeRange = bgVideoTimeRange; //[composition.tracks.firstObject timeRange];
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i < [assetArray count]; ++i)
    {
        AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
        videoLayerInstruction.trackID = i + 1;
        
        // Rotate 90 if need
//        if (shouldRotate)
//        {
//            CGAffineTransform t1 = CGAffineTransformMakeTranslation(videoSize.height, 0);
//            CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
//            [videoLayerInstruction setTransform:t2 atTime:kCMTimeZero];
//        }
        
        [layerInstructionArray addObject:videoLayerInstruction];
    }
    
    instruction.layerInstructions = layerInstructionArray;
    videoComposition.instructions = @[ instruction ];
    videoComposition.customVideoCompositorClass = [CustomVideoCompositor class];
    
    
    // Animation
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    int limitMinLen = 100;
    CGSize videoSizeResult = CGSizeZero;
    if (videoSize.width >= limitMinLen || videoSize.height >= limitMinLen)
    {
        // Assign a output size
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoSizeResult = videoSize;
    }
    else
    {
        NSLog(@"videoSize is empty!");
        
        // Output path
        self.filenameBlock = ^(void) {
            return @"";
        };
        
        if (self.finishVideoBlock)
        {
            self.finishVideoBlock(NO, GBLocalizedString(@"MsgConvertFailed"));
        }
        
        return;
    }
    
    videoLayer.frame = parentLayer.frame;
    [parentLayer addSublayer:videoLayer];
    
    VideoThemes *themeCurrent = nil;
    if (self.themeCurrentType != kThemeNone && [self.themesDic count] >= self.themeCurrentType)
    {
        themeCurrent = [self.themesDic objectForKey:[NSNumber numberWithInt:self.themeCurrentType]];
    }
        
    // Animation effects
    NSMutableArray *animatedLayers = [[NSMutableArray alloc] initWithCapacity:[[themeCurrent animationActions] count]];
    if (_gifArray && [_gifArray count] > 0)
    {
        CALayer *animatedLayer = nil;
        for (StickerView *view in _gifArray)
        {
            NSString *gifPath = view.getFilePath;
            CGFloat widthFactor  = CGRectGetWidth(view.getVideoContentRect) / CGRectGetWidth(view.getInnerFrame);
            CGFloat heightFactor = CGRectGetHeight(view.getVideoContentRect) / CGRectGetHeight(view.getInnerFrame);
            
            CGPoint origin = CGPointMake((view.getInnerFrame.origin.x / CGRectGetWidth(view.getVideoContentRect)) * videoSizeResult.width,  videoSizeResult.height - ((view.getInnerFrame.origin.y / CGRectGetHeight(view.getVideoContentRect)) * videoSizeResult.height) - videoSizeResult.height/heightFactor);
            CGRect gifFrame = CGRectMake(origin.x, origin.y, videoSizeResult.width/widthFactor, videoSizeResult.height/heightFactor);
            NSLog(@"view.getWidthRatio: %f, view.getHeightRatio: %f", widthFactor, heightFactor);
            
            CFTimeInterval beginTime = 0.1;
            animatedLayer = [GifAnimationLayer layerWithGifFilePath:gifPath withFrame:gifFrame withAniBeginTime:beginTime];
            if (animatedLayer && [animatedLayer isKindOfClass:[GifAnimationLayer class]])
            {
                animatedLayer.opacity = 0.0f;
                
                CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
                [animation setKeyPath:@"contents"];
                animation.calculationMode = kCAAnimationDiscrete;
                animation.autoreverses = NO;
                animation.repeatCount = INT16_MAX;
                animation.beginTime = beginTime;
                
                NSDictionary *gifDic = [(GifAnimationLayer*)animatedLayer getValuesAndKeyTimes];
                NSMutableArray *keyTimes = [gifDic objectForKey:@"keyTimes"];
                NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:[keyTimes count]];
                for (int i = 0; i < [keyTimes count]; ++i)
                {
                    CGImageRef image = [(GifAnimationLayer*)animatedLayer copyImageAtFrameIndex:i];
                    if (image)
                    {
                        [imageArray addObject:(__bridge id)image];
                    }
                }
                
                animation.values   = imageArray;
                animation.keyTimes = keyTimes;
                animation.duration = [(GifAnimationLayer*)animatedLayer getTotalDuration];
                animation.removedOnCompletion = YES;
                animation.delegate = self;
                [animation setValue:@"stop" forKey:@"TAG"];
                
                [animatedLayer addAnimation:animation forKey:@"contents"];
                
                CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                fadeOutAnimation.fromValue = @1.0f;
                fadeOutAnimation.toValue = @0.9f;
                fadeOutAnimation.additive = YES;
                fadeOutAnimation.removedOnCompletion = YES;
                fadeOutAnimation.beginTime = beginTime;
                fadeOutAnimation.duration = animation.beginTime + animation.duration + 2;
                fadeOutAnimation.fillMode = kCAFillModeBoth;
                fadeOutAnimation.repeatCount = INT16_MAX;
                [animatedLayer addAnimation:fadeOutAnimation forKey:@"opacityOut"];
                
                [animatedLayers addObject:(id)animatedLayer];
            }
        }
    }

    if (themeCurrent && [[themeCurrent animationActions] count] > 0)
    {
        for (NSNumber *animationAction in [themeCurrent animationActions])
        {
            CALayer *animatedLayer = nil;
            switch ([animationAction intValue])
            {
                case kAnimationTextSparkle:
                {
                    if (!isStringEmpty(themeCurrent.textSparkle))
                    {
                        NSTimeInterval startTime = 10;
                        animatedLayer = [_videoBuilder buildEmitterSparkle:videoSizeResult text:themeCurrent.textSparkle startTime:startTime];
                        if (animatedLayer)
                        {
                            [animatedLayers addObject:(id)animatedLayer];
                        }
                    }
                    
                    break;
                }
                case kAnimationTextStar:
                {
                    if (!isStringEmpty(themeCurrent.textStar))
                    {
                        NSTimeInterval startTime = 0.1;
                        animatedLayer = [_videoBuilder buildAnimationStarText:videoSizeResult text:themeCurrent.textStar startTime:startTime];
                        if (animatedLayer)
                        {
                            [animatedLayers addObject:(id)animatedLayer];
                        }
                    }
                    
                    break;
                }
                case kAnimationTextScroll:
                {
                    if (themeCurrent.scrollText && [[themeCurrent scrollText] count] > 0)
                    {
                        NSArray *startYPoints = [NSArray arrayWithObjects:[NSNumber numberWithFloat:videoSizeResult.height/3], [NSNumber numberWithFloat:videoSizeResult.height/2], [NSNumber numberWithFloat:videoSizeResult.height*2/3], nil];
                        
                        NSTimeInterval timeInterval = 10.0;
                        for (NSString *text in themeCurrent.scrollText)
                        {
                            if (!isStringEmpty(text))
                            {
                                animatedLayer = [_videoBuilder buildAnimatedScrollText:videoSizeResult text:text startPoint:CGPointMake(videoSizeResult.width, [startYPoints[arc4random()%(int)3] floatValue]) startTime:timeInterval];
                                
                                if (animatedLayer)
                                {
                                    [animatedLayers addObject:(id)animatedLayer];
                                    
                                    timeInterval += 3.0;
                                }
                            }
                        }
                    }
                    
                    break;
                }
                case kAnimationTextGradient:
                {
                    if (!isStringEmpty(themeCurrent.textGradient))
                    {
                        NSTimeInterval timeInterval = 3.0;
                        animatedLayer = [_videoBuilder buildGradientText:videoSizeResult positon:CGPointMake(videoSizeResult.width/2, videoSizeResult.height - videoSizeResult.height/4) text:themeCurrent.textGradient startTime:timeInterval];
                        if (animatedLayer)
                        {
                            [animatedLayers addObject:(id)animatedLayer];
                        }
                    }
                    
                    break;
                }
                case kAnimationVideoBorder:
                {
                    if (!isStringEmpty(themeCurrent.imageVideoBorder))
                    {
                        animatedLayer = [_videoBuilder BuildVideoBorderImage:videoSizeResult borderImage:themeCurrent.imageVideoBorder position:CGPointMake(videoSizeResult.width/2, videoSizeResult.height/2)];
                        
                        if (animatedLayer)
                        {
                            [animatedLayers addObject:(id)animatedLayer];
                        }
                    }
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if (animatedLayers && [animatedLayers count] > 0)
    {
        for (CALayer *animatedLayer in animatedLayers)
        {
            [parentLayer addSublayer:animatedLayer];
        }
    }
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    NSLog(@"videoSizeResult width: %f, Height: %f", videoSizeResult.width, videoSizeResult.height);
    
    if (animatedLayers)
    {
        [animatedLayers removeAllObjects];
        animatedLayers = nil;
    }

    // Export
    NSString *exportPath = [self getOutputFilePath];
    NSURL *exportURL = [NSURL fileURLWithPath:[self returnFormatString:exportPath]];
    // Delete old file
    unlink([exportPath UTF8String]);
    
    _exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    _exportSession.outputURL = exportURL;
    _exportSession.outputFileType = AVFileTypeMPEG4;
    _exportSession.shouldOptimizeForNetworkUse = YES;
    
    if (videoComposition)
    {
        _exportSession.videoComposition = videoComposition;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Progress monitor
        _timerEffect = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                        target:self
                                                      selector:@selector(retrievingExportProgress)
                                                      userInfo:nil
                                                       repeats:YES];
    });
    
    __block typeof(self) blockSelf = self;
    [_exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        switch ([_exportSession status])
        {
            case AVAssetExportSessionStatusCompleted:
            {
                // Close timer
                [blockSelf.timerEffect invalidate];
                blockSelf.timerEffect = nil;
                
                // Save video to Album
                [self writeExportedVideoToAssetsLibrary:exportPath];
                
                NSLog(@"Export Successful: %@", exportPath);
                break;
            }
                
            case AVAssetExportSessionStatusFailed:
            {
                // Close timer
                [blockSelf.timerEffect invalidate];
                blockSelf.timerEffect = nil;
                
                // Output path
                self.filenameBlock = ^(void) {
                    return @"";
                };
                
                if (self.finishVideoBlock)
                {
                    self.finishVideoBlock(NO, GBLocalizedString(@"MsgConvertFailed"));
                }
                
                NSLog(@"Export failed: %@, %@", [[blockSelf.exportSession error] localizedDescription], [blockSelf.exportSession error]);
                break;
            }
                
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Canceled: %@", blockSelf.exportSession.error);
                break;
            }
            default:
                break;
        }
    }];
}

// Convert 'space' char
- (NSString *)returnFormatString:(NSString *)str
{
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - Export Progress Callback
- (void)retrievingExportProgress
{
    if (_exportSession && _exportProgressBlock)
    {
        self.exportProgressBlock([NSNumber numberWithFloat:_exportSession.progress], nil);
    }
}

#pragma mark - NSUserDefaults
#pragma mark - setShouldRightRotate90
- (void)setShouldRightRotate90:(BOOL)shouldRotate withTrackID:(NSInteger)trackID
{
    NSString *identifier = [NSString stringWithFormat:@"TrackID_%ld", (long)trackID];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if (shouldRotate)
    {
        [userDefaultes setBool:YES forKey:identifier];
    }
    else
    {
        [userDefaultes setBool:NO forKey:identifier];
    }
    
    [userDefaultes synchronize];
}

- (BOOL)shouldRightRotate90ByTrackID:(NSInteger)trackID
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [NSString stringWithFormat:@"TrackID_%ld", (long)trackID];
    BOOL result = [[userDefaultes objectForKey:identifier] boolValue];
    NSLog(@"shouldRightRotate90ByTrackID %@ : %@", identifier, result?@"Yes":@"No");
    
    if (result)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
