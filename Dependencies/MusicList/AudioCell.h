//
//  AudioCell
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/22/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGlossyButton.h"
#import "UIView+LayerEffects.h"

#define TableViewRowHeight 50

@interface AudioCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIGlossyButton *audioButton;
@property (strong, nonatomic) UIImageView *avatarView;

@end
