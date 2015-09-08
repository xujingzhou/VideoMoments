//
//  AVAsset (help)
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/30/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "AVAsset+help.h"

@implementation AVAsset (help)

+ (instancetype)assetWithResourceName:(NSString *)name
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    return [self assetWithURL:url];
}

+ (instancetype)assetWithFileURL:(NSURL *)url
{
    return [self assetWithURL:url];
}

- (AVAssetTrack *)firstVideoTrack
{
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    return [tracks firstObject];
}

- (void)whenProperties:(NSArray *)names areReadyDo:(void (^)(void))block
{
    [self loadValuesAsynchronouslyForKeys:names completionHandler:^{
        NSMutableArray *pendingNames;
        for (NSString *name in names)
        {
            switch ([self statusOfValueForKey:name error:nil])
            {
                case AVKeyValueStatusLoaded:
                case AVKeyValueStatusFailed:
                    break;
                default:
                    if (pendingNames ==  nil)
                    {
                        pendingNames = [NSMutableArray array];
                    }
                    [pendingNames addObject:name];
            }
        }

        if (pendingNames == nil)
        {
            block();
        }
        else
        {
            [self whenProperties:pendingNames areReadyDo:block];
        }
    }];
}

@end
