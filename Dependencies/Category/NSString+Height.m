//
//  NSString (Height)
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/22/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "NSString+Height.h"

@implementation NSString (Height)

//- (CGSize)sizeWithFontSize:(CGFloat)fontSize constrainedWidth:(CGFloat)width
//{
//    CGSize constraint = CGSizeMake(width, 20000.0f);
//    
//    if (iOS6) {
//        return [self sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint];
//    }
//    else {
//        CGRect rect = [self boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
//        return rect.size;
//    }
//}
//
//- (float)widthInSingleLine:(CGFloat)fontSize
//{
////    UILabel *tmpLabel = [[UILabel alloc] init];
////    [tmpLabel setFont:[UIFont systemFontOfSize:fontSize]];
////    [tmpLabel setText:self];
////    [tmpLabel sizeToFit];
////    
////    return tmpLabel.width;
//    
//    CGSize size = [self sizeWithFont:[UIFont systemFontOfSize:fontSize]];
//    return size.width;
//}

- (CGFloat)maxWidthForText:(NSString *)text height:(CGFloat)textHeight font:(UIFont*)font
{
    CGSize constrainedSize = CGSizeMake(CGFLOAT_MAX, textHeight);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    CGRect requiredSize = [string boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    if (requiredSize.size.height > textHeight)
    {
        requiredSize = CGRectMake(0, 0, requiredSize.size.width, textHeight);
    }
    
//    NSLog(@"maxWidthForText: %f", requiredSize.size.width);
    
    return requiredSize.size.width;
}

- (CGSize)maxHeightForText:(NSString *)text width:(CGFloat)textWidth font:(UIFont*)font
{
    CGSize constrainedSize = CGSizeMake(textWidth, CGFLOAT_MAX);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    CGRect requiredSize = [string boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    if (requiredSize.size.width > textWidth)
    {
        requiredSize = CGRectMake(0, 0, textWidth, requiredSize.size.height);
    }
    
//    NSLog(@"maxHeightForText: %f", requiredSize.size.height);
    
    return requiredSize.size;
}

- (CGSize)sizeForText:(NSString *)text font:(UIFont*)font
{
    CGSize constrainedSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    CGRect requiredSize = [string boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
//    NSLog(@"sizeForText width: %f, height: %f", requiredSize.size.width, requiredSize.size.height);
    
    return requiredSize.size;
}

@end
