//
//  AudioCell
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/22/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "AudioCell.h"

@implementation AudioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat gap = 10, widthAvatar = 30, heightAvatar = 30;
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(gap, (TableViewRowHeight - heightAvatar)/2, widthAvatar, heightAvatar)];
        _avatarView.image = [UIImage imageNamed:@"start"];
        [self.contentView addSubview:_avatarView];
        
        CGFloat widthButton = 50, heightButton = 35;
        NSString *textSave = GBLocalizedString(@"Save");
        _audioButton = [[UIGlossyButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - gap - widthButton, (TableViewRowHeight - heightButton)/2, widthButton, heightButton)];
        [_audioButton setBackgroundColor:[UIColor clearColor]];
        [_audioButton setNavigationButtonWithColor:[UIColor doneButtonColor]];
        [_audioButton setClipsToBounds:YES];
        _audioButton.titleLabel.font = [UIFont boldSystemFontOfSize: 14.0];
        _audioButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_audioButton setTitle:textSave forState: UIControlStateNormal];
        [self.contentView addSubview:_audioButton];
        
        CGFloat height = 40;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarView.frame) + gap, (TableViewRowHeight - height)/2, CGRectGetWidth(self.frame) - CGRectGetWidth(_avatarView.frame) - CGRectGetWidth(_audioButton.frame) - 4*gap, height)];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
