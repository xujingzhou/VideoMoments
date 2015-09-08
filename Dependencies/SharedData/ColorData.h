//
//  ColorData
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 8/4/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorData : NSObject

@property (nonatomic, strong, readonly) NSArray *backgroundArray;
@property (nonatomic, strong, readonly) NSArray *backgroundButtonArray;
@property (nonatomic, assign) long curSelectBgIndex;

+ (ColorData *)sharedInstance;

@end
