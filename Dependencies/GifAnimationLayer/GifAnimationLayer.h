
#import <QuartzCore/QuartzCore.h>

@interface GifAnimationLayer : CALayer

+ (id)layerWithGifFilePath:(NSString *)filePath withFrame:(CGRect)frame withAniBeginTime:(CFTimeInterval)beginTime;

- (void)startAnimating;
- (void)stopAnimating;
- (void)pauseAnimating;
- (void)resumeAnimating;

- (NSDictionary*)getValuesAndKeyTimes;
- (CFTimeInterval)getTotalDuration;
- (CGImageRef)copyImageAtFrameIndex:(NSUInteger)index;

@property (nonatomic, copy) NSString *gifFilePath;
@property (nonatomic) CFTimeInterval aniBeginTime;

@end
