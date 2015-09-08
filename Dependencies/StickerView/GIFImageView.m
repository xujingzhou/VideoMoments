
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "GIFImageView.h"

#define DEFAULT_FRAME_INTERVAL 3  // 60/DEFAULT_FRAME_INTERVAL frames/sec

/**********************************************************************/

@interface GIFManager : NSObject

@property (nonatomic, strong) CADisplayLink  *displayLink;
@property (nonatomic, strong) NSHashTable    *gifViewHashTable;
+ (GIFManager *)shared;
- (void)stopGIFView:(GIFImageView *)view;

@end

@implementation GIFManager

+ (GIFManager *)shared
{
    static GIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GIFManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
	self = [super init];
    
	if (self)
    {
		_gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
	}
	return self;
}

- (void)play
{
    for (GIFImageView *imageView in _gifViewHashTable)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([imageView respondsToSelector:@selector(playGIF)])
        {
            [imageView performSelector:@selector(playGIF) withObject:nil];
        }
#pragma clang diagnostic pop
    }
}

- (void)stopDisplayLink
{
    if (self.displayLink)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)stopGIFView:(GIFImageView *)view
{
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink)
    {
        [self stopDisplayLink];
    }
}

@end

/**********************************************************************/

@interface GIFImageView()
{
    size_t              _index;
    size_t              _frameCount;
    float               _timestamp;
    CGImageSourceRef    _gifSourceRef;
}

@end

@implementation GIFImageView

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self stopGIF];
}

- (void)startGIF
{
    [self startGIFWithRunLoopMode:NSDefaultRunLoopMode];
}

- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[GIFManager shared].gifViewHashTable containsObject:self])
        {
            if ((self.gifData || self.gifPath))
            {
                CGImageSourceRef gifSourceRef;
                if (self.gifData)
                {
                    gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
                }
                else
                {
                    gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
                }
                
                if (!gifSourceRef)
                {
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GIFManager shared].gifViewHashTable addObject:self];
                    _gifSourceRef = gifSourceRef;
                    _frameCount = CGImageSourceGetCount(gifSourceRef);
                });
            }
        }
    });
    
    if (![GIFManager shared].displayLink)
    {
        [GIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[GIFManager shared] selector:@selector(play)];
        [GIFManager shared].displayLink.frameInterval = DEFAULT_FRAME_INTERVAL;
        [[GIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:runLoopMode];
    }
}

- (void)stopGIF
{
    if (_gifSourceRef)
    {
        CFRelease(_gifSourceRef);
        _gifSourceRef = nil;
    }
    
    [[GIFManager shared] stopGIFView:self];
}

- (void)playGIF
{
    float nextFrameDuration = [self frameDurationAtIndex:MIN(_index+1, _frameCount-1)];
    if (_timestamp < nextFrameDuration)
    {
        _timestamp += [GIFManager shared].displayLink.duration;
        return;
    }
    
	_index ++;
	_index = _index%_frameCount;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index, NULL);
	self.layer.contents = (__bridge id)(ref);
    CGImageRelease(ref);
    _timestamp = 0;
}

- (BOOL)isGIFPlaying
{
    return _gifSourceRef?YES:NO;
}

- (float)frameDurationAtIndex:(size_t)index
{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    
    if (unclampedDelayTime.floatValue)
    {
        return unclampedDelayTime.floatValue;
    }
    else if (delayTime.floatValue)
    {
        return delayTime.floatValue;
    }
    else
    {
        return 1/24.0;
    }
}

@end
