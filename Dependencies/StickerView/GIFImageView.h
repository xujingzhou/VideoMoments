
@interface GIFImageView : UIImageView

@property (nonatomic, strong) NSString *gifPath;
@property (nonatomic, strong) NSData *gifData;

- (void)startGIF;
- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode;
- (void)stopGIF;
- (BOOL)isGIFPlaying;

@end
