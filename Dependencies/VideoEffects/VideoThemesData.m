//
//  VideoThemesData.m
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/11/14.
//  Copyright (c) 2014 Future Studio. All rights reserved.
//

#import "VideoThemesData.h"
#import "CommonDefine.h"
#import "DeviceHardware.h"

@interface VideoThemesData()
{
    NSMutableDictionary *_themesDic;
}

@property (retain, nonatomic) NSMutableDictionary *themesDic;

@end


@implementation VideoThemesData

@synthesize themesDic = _themesDic;

#pragma mark - Singleton
+ (VideoThemesData *) sharedInstance
{
    static VideoThemesData *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[VideoThemesData alloc] init];
    });
    
    return singleton;
}

#pragma mark - Life cycle
- (id) init
{
    if (self = [super init])
    {
        // Only run once
        [self initThemesData];
    }
    
    return self;
}

- (void) dealloc
{
    [self clearAll];
}

- (void) clearAll
{
    
    if (self.themesDic && [self.themesDic count]>0)
    {
        [self.themesDic removeAllObjects];
        self.themesDic = nil;
    }
}

#pragma mark - Private Methods
- (NSURL*) getFileURL:(NSString*)inputFileName
{
    NSString *fileName = [inputFileName stringByDeletingPathExtension];
    NSLog(@"%@",fileName);
    NSString *fileExt = [inputFileName pathExtension];
    NSLog(@"%@",fileExt);
    
    NSURL *inputVideoURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExt];
    return inputVideoURL;
}

- (NSString*) getWeekdayFromDate:(NSDate*)date
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = nil; //[[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    components = [calendar components:unitFlags fromDate:date];
    NSUInteger weekday = [components weekday];
    
    NSString *result = nil;
    switch (weekday)
    {
        case 1:
        {
            result = GBLocalizedString(@"Sunday");
            break;
        }
        case 2:
        {
            result = GBLocalizedString(@"Monday");
            break;
        }
        case 3:
        {
            result = GBLocalizedString(@"Tuesday");
            break;
        }
        case 4:
        {
            result = GBLocalizedString(@"Wednesday");
            break;
        }
        case 5:
        {
            result = GBLocalizedString(@"Thursday");
            break;
        }
        case 6:
        {
            result = GBLocalizedString(@"Friday");
            break;
        }
        case 7:
        {
            result = GBLocalizedString(@"Saturday");
            break;
        }
        default:
            break;
    }
    
    return result;
}

-(NSString*) getStringFromDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}

#pragma mark - Init themes
- (VideoThemes*) createThemeButterfly
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeButterfly;
    theme.thumbImageName = @"themeButterfly";
    theme.name = @"Butterfly";
    theme.textStar = @"butterfly";
    theme.textSparkle = @"beautifully";
    theme.textGradient = nil;
    theme.bgMusicFile = @"1.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo01.m4v"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationPhotoLinearScroll], [NSNumber numberWithInt:KAnimationPhotoCentringShow], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeLeaf
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeLeaf;
    theme.thumbImageName = @"themeLeaf";
    theme.name = @"Leaf";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"2.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo02.m4v"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects: [NSNumber numberWithInt:kAnimationMeteor], [NSNumber numberWithInt:kAnimationPhotoDrop], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeStarshine
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeStarshine;
    theme.thumbImageName = @"themeStarshine";
    theme.name = @"Star";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"3.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo03.m4v"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoParabola], [NSNumber numberWithInt:kAnimationMoveDot], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeFlare
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeFlare;
    theme.thumbImageName = @"themeFlare";
    theme.name = @"Flare";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"4.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo04.mov"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoFlare], [NSNumber numberWithInt:kAnimationSky], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeFruit
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeFruit;
    theme.thumbImageName = @"themeFruit";
    theme.name = @"Fruit";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"5.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo05.mov"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoEmitter], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeCartoon
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeCartoon;
    theme.thumbImageName = @"themeCartoon";
    theme.name = @"Cartoon";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"6.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo06.mov"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoExplode], [NSNumber numberWithInt:kAnimationPhotoSpin360], nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeScience
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeScience;
    theme.thumbImageName = @"themeScience";
    theme.name = @"Science";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"7.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo07.mov"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoExplodeDrop], [NSNumber numberWithInt:KAnimationPhotoCentringShow],nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeCloud
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeCloud;
    theme.thumbImageName = @"themeCloud";
    theme.name = @"Cloud";
    theme.textStar = nil;
    theme.textSparkle = nil;
    theme.textGradient = nil;
    theme.bgMusicFile = @"8.mp3";
    theme.imageFile = nil;
    theme.scrollText = nil;
    theme.bgVideoFile = [self getFileURL:@"bgVideo08.mov"];
    
    // Animation effects
    NSArray *aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationPhotoCloud], [NSNumber numberWithInt:KAnimationPhotoCentringShow],nil];
    theme.animationActions = [NSArray arrayWithArray:aniActions];
    
    return theme;
}

- (VideoThemes*) createThemeCustom
{
    VideoThemes *theme = [[VideoThemes alloc] init];
    theme.ID = kThemeCustom;
    theme.thumbImageName = @"themeCustom";
    theme.name = @"Custom";
    theme.textStar = GBLocalizedString(@"MyLove");
    theme.textSparkle = GBLocalizedString(@"MissYou");
    theme.textGradient = GBLocalizedString(@"ToMyLover");
    theme.bgMusicFile = @"Butterfly.mp3";
    theme.imageFile = nil;
    theme.animationImages = nil;
    
    // Scroll text
    NSMutableArray *scrollText = [[NSMutableArray alloc] init];
    [scrollText addObject:[self getStringFromDate:[NSDate date]]];
    [scrollText addObject:[self getWeekdayFromDate:[NSDate date]]];
    [scrollText addObject:GBLocalizedString(@"AValuableDay")];
    theme.scrollText = scrollText;
    
    theme.imageVideoBorder = [NSString stringWithFormat:@"border_%i",(arc4random()%(int)10)];
    
    NSString *defaultVideo = @"BackgroundVideo.mov";
    theme.bgVideoFile = [self getFileURL:defaultVideo];
    
    theme.animationActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], nil];
    
    return theme;
}

- (NSString*) getVideoBorderByIndex:(int)index
{
    NSString *videoBorder = nil;
    if (index >= 0 && index <= 10)
    {
        videoBorder = [NSString stringWithFormat:@"border_%i", index];
    }
    
    return videoBorder;
}

- (NSArray*) getAnimationByIndex:(int)index
{
    // Animation effects
    NSArray *aniActions = nil;
    switch (index)
    {
        case 0:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoParallax], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 1:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoCloud], [NSNumber numberWithInt:KAnimationPhotoCentringShow], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 2:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoExplodeDrop], [NSNumber numberWithInt:KAnimationPhotoCentringShow], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 3:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoExplode], [NSNumber numberWithInt:kAnimationPhotoSpin360], [NSNumber numberWithInt:kAnimationTextStar],  [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 4:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoEmitter], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 5:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoFlare], [NSNumber numberWithInt:kAnimationSky], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 6:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoParabola], [NSNumber numberWithInt:kAnimationMoveDot], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 7:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationMeteor], [NSNumber numberWithInt:kAnimationPhotoDrop], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
        case 8:
        {
            if (([DeviceHardware specificPlatform] <= DeviceHardwareGeneralPlatform_iPhone_4S) || ([DeviceHardware specificPlatform] == DeviceHardwareGeneralPlatform_iPad_2) || ([DeviceHardware specificPlatform] == DeviceHardwareGeneralPlatform_iPad))
            {
               aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoFlare], [NSNumber numberWithInt:KAnimationPhotoCentringShow], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            }
            else
            {
                aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationPhotoLinearScroll], [NSNumber numberWithInt:KAnimationPhotoCentringShow], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            }
            break;
        }
        default:
        {
            aniActions = [NSArray arrayWithObjects:[NSNumber numberWithInt:kAnimationVideoBorder], [NSNumber numberWithInt:kAnimationSky], [NSNumber numberWithInt:kAnimationTextStar], [NSNumber numberWithInt:kAnimationTextScroll], [NSNumber numberWithInt:kAnimationTextGradient], [NSNumber numberWithInt:kAnimationTextSparkle], nil];
            
            break;
        }
    }
    
    return aniActions;
}

- (NSArray*) getRandomAnimation
{
    // Animation effects
    NSArray *aniActions = [self getAnimationByIndex:(arc4random() % 8)];
    return aniActions;
}

- (void) initThemesData
{
    self.themesDic = [NSMutableDictionary dictionaryWithCapacity:15];
    
    VideoThemes *theme = nil;
    for (int i = kThemeNone; i <= kThemeCustom; ++i)
    {
        switch (i)
        {
            case kThemeNone:
            {
                // 0. 无
                break;
            }
            case kThemeButterfly:
            {
                // Butterfly
                theme = [self createThemeButterfly];
                break;
            }
            case kThemeLeaf:
            {
                theme = [self createThemeLeaf];
                break;
            }
            case kThemeStarshine:
            {
                theme = [self createThemeStarshine];
                break;
            }
            case kThemeFlare:
            {
                theme = [self createThemeFlare];
                break;
            }
            case kThemeFruit:
            {
                theme = [self createThemeFruit];
                break;
            }
            case kThemeCartoon:
            {
                theme = [self createThemeCartoon];
                break;
            }
            case kThemeScience:
            {
                theme = [self createThemeScience];
                break;
            }
            case kThemeCloud:
            {
                theme = [self createThemeCloud];
                break;
            }
            case kThemeCustom:
            {
                theme = [self createThemeCustom];
                break;
            }
            default:
                break;
        }
        
        if (i == kThemeNone)
        {
            [self.themesDic setObject:[NSNull null] forKey:[NSNumber numberWithInt:kThemeNone]];
        }
        else
        {
            [self.themesDic setObject:theme forKey:[NSNumber numberWithInt:i]];
        }
    }
}

- (VideoThemes*) getThemeByType:(ThemesType)themeType
{
    if (self.themesDic && [self.themesDic count]>0)
    {
        VideoThemes* theme = [self.themesDic objectForKey:[NSNumber numberWithInt:themeType]];
        if (theme && ((NSNull*)theme != [NSNull null]))
        {
            return theme;
        }
    }
    
    return nil;
}

- (NSMutableDictionary*) getThemesData
{
    return self.themesDic;
}

@end
