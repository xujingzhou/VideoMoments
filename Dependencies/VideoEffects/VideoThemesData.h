//
//  VideoThemesData.h
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/11/14.
//  Copyright (c) 2014 Future Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoThemes.h"

// Effects
typedef enum
{
    kAnimationNone = 0,
    kAnimationFireworks,
    kAnimationSnow,
    kAnimationSnow2,
    kAnimationHeart,
    kAnimationRing,
    kAnimationStar,
    kAnimationMoveDot,
    kAnimationSky,
    kAnimationMeteor,
    kAnimationRain,
    kAnimationFlower,
    kAnimationFire,
    kAnimationSmoke,
    kAnimationSpark,
    kAnimationSteam,
    kAnimationBirthday,
    kAnimationBlackWhiteDot,
    kAnimationScrollScreen,
    kAnimationSpotlight,
    kAnimationScrollLine,
    kAnimationRipple,
    kAnimationImage,
    kAnimationImageArray,
    kAnimationVideoFrame,
    kAnimationTextStar,
    kAnimationTextSparkle,
    kAnimationTextScroll,
    kAnimationTextGradient,
    kAnimationFlashScreen,
    kAnimationPhotoLinearScroll,
    KAnimationPhotoCentringShow,
    kAnimationPhotoDrop,
    kAnimationPhotoParabola,
    kAnimationPhotoFlare,
    kAnimationPhotoEmitter,
    kAnimationPhotoExplode,
    kAnimationPhotoExplodeDrop,
    kAnimationPhotoCloud,
    kAnimationPhotoSpin360,
    kAnimationPhotoCarousel,
    kAnimationVideoBorder,
    kAnimationPhotoParallax,
    
} AnimationActionType;

// Themes
typedef enum
{
    // none
    kThemeNone = 0,
    
    // Custom
    kThemeCustom,
    
    // fruit
    kThemeFruit,
    
    // cartoon
    kThemeCartoon,
    
    // flare
    kThemeFlare,
    
    // starshine
    kThemeStarshine,
    
    // cubical
    kThemeScience,
    
    // leaf
    kThemeLeaf,
    
    // butterfly
    kThemeButterfly,
    
    // cloud
    kThemeCloud,
    
} ThemesType;

@interface VideoThemesData : NSObject
{
    
}

+ (VideoThemesData *) sharedInstance;

- (NSMutableDictionary*) getThemesData;
- (VideoThemes*) getThemeByType:(ThemesType)themeType;

- (NSArray*) getRandomAnimation;
- (NSArray*) getAnimationByIndex:(int)index;

- (NSString*) getVideoBorderByIndex:(int)index;

@end
