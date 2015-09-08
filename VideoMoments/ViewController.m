//
//  ViewController.m
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 7/19/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ViewController.h"
#import "CTAssetsPickerController.h"
#import "PBJVideoPlayerController.h"
#import "DBPrivateHelperController.h"
#import "KGModal.h"
#import "CMPopTipView.h"
#import "UIAlertView+Blocks.h"
#import "ExportEffects.h"
#import "NSString+Height.h"
#import "AudioViewController.h"
#import "SelectView.h"
#import "PuzzleData.h"
#import "StickerView.h"
#import "ScrollSelectView.h"
#import "ColorData.h"
#import "ColorSelectView.h"

#define VideoMinLen 3.0
#define VideoMaxLen 30.0
#define MaxVideoAssets 5
#define MinVideoAssets 2
#define BottomViewHeight 50.0
#define SelectViewHeight 50.0

@interface ViewController ()<CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate, SelectViewDelegate, ScrollSelectViewDelegate, ColorScrollSelectViewDelegate, PBJVideoPlayerControllerDelegate>
{
    CMPopTipView *_popTipView;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) ColorSelectView *colorView;
@property (nonatomic, strong) ScrollSelectView *gifView;
@property (nonatomic, strong) ScrollSelectView *borderView;
@property (nonatomic, strong) SelectView *puzzleView;
@property (nonatomic, strong) UIScrollView *bottomControlView;
@property (nonatomic, strong) UIImageView *borderImageView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *puzzleButton;
@property (nonatomic, strong) UIButton *gifButton;
@property (nonatomic, strong) UIButton *borderButton;
@property (nonatomic, strong) UIButton *colorButton;
@property (nonatomic, strong) UIButton *selectControlButton;

@property (nonatomic, assign) NSInteger selectStyleIndex;

@property (nonatomic, strong) PBJVideoPlayerController *demoVideoPlayerController;
@property (nonatomic, strong) UIView *demoVideoContentView;
@property (nonatomic, strong) UIImageView *demoPlayButton;

@property (nonatomic, strong) NSMutableArray *videoPlayerViews;
@property (nonatomic, strong) NSMutableArray *videoPlayerControllers;

@property (nonatomic, copy) NSString *audioPickFile;
@property (nonatomic, strong) NSMutableArray *gifArray;

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [ScrollSelectView getDefaultFilelist];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

#pragma mark - Authorization Helper
- (void)popupAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:GBLocalizedString(@"Private_Setting_Audio_Tips") delegate:nil cancelButtonTitle:GBLocalizedString(@"IKnow") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)popupAuthorizationHelper:(id)type
{
    DBPrivateHelperController *privateHelper = [DBPrivateHelperController helperForType:[type longValue]];
    privateHelper.snapshot = [self snapshot];
    privateHelper.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:privateHelper animated:YES completion:nil];
}

- (UIImage *)snapshot
{
    id <UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIGraphicsBeginImageContextWithOptions(appDelegate.window.bounds.size, NO, appDelegate.window.screen.scale);
    [appDelegate.window drawViewHierarchyInRect:appDelegate.window.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

#pragma mark - Delete Temp Files
- (void)deleteTempDirectory
{
    NSString *dir = NSTemporaryDirectory();
    deleteFilesAt(dir, @"mov");
    deleteFilesAt(dir, @"mp4");
}

#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer == _demoVideoPlayerController)
    {
        _demoPlayButton.alpha = 1.0f;
        _demoPlayButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            
            _demoPlayButton.alpha = 0.0f;
        } completion:^(BOOL finished)
         {
             _demoPlayButton.hidden = YES;
         }];
    }
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer == _demoVideoPlayerController)
    {
        _demoPlayButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            
            _demoPlayButton.alpha = 1.0f;
        } completion:^(BOOL finished)
         {
             
         }];
    }
}

#pragma mark - pickAssets
- (void)clearAssets:(id)sender
{
    if (self.assets)
    {
        self.assets = nil;
    }
}

- (void)pickupVideos:(id)sender
{
    // Check permisstion for photo album
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
    {
        [self performSelectorOnMainThread:@selector(popupAuthorizationHelper:) withObject:[NSNumber numberWithLong:DBPrivacyTypePhoto] waitUntilDone:YES];
        return;
    }
    else
    {
        // Has permisstion to execute
        [self performSelector:@selector(pickAssets:) withObject:sender afterDelay:0.1];
    }
    
}

- (void)pickAssets:(id)sender
{
    if (!self.assets)
    {
        self.assets = [[NSMutableArray alloc] init];
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allVideos];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:self.assets];
    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popover.delegate = self;
        
        [self.popover presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - Popover Controller Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Assets Picker Delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (picker.selectedAssets.count < MinVideoAssets)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:GBLocalizedString(@"Reminder")
                                   message:GBLocalizedString(@"LessThanAssetsCount")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:GBLocalizedString(@"OK"), nil];
        
        [alertView show];
        
        return;
    }
    
    if (self.popover != nil)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (_assets && [_assets count] > 0)
    {
        [self.assets removeAllObjects];
    }
    self.assets = [NSMutableArray arrayWithArray:assets];
    NSLog(@"Seleted assets: %@", _assets);
    
    [self showBottomControlView];
    [self createPuzzleSelectView];
    [_puzzleButton setSelected:YES];
    _selectStyleIndex = 1;
    [self reloadPuzzleData];
    [self bottomViewControlAction:_puzzleButton];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least Ns
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= VideoMinLen;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count > MaxVideoAssets)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:GBLocalizedString(@"Reminder")
                                   message:GBLocalizedString(@"MoreThanAssetsCount")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:GBLocalizedString(@"OK"), nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:GBLocalizedString(@"Reminder")
                                   message:GBLocalizedString(@"AssetError")
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:GBLocalizedString(@"OK"), nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < MaxVideoAssets && asset.defaultRepresentation != nil);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectAsset:(ALAsset *)asset
{
}

#pragma mark - pickMusicFromCustom
- (void)pickMusicFromCustom
{
    if (![self getNextStepRunCondition])
    {
        NSString *message = nil;
        message = GBLocalizedString(@"VideoIsEmptyHint");
        showAlertMessage(message, nil);
        return;
    }
    
    AudioViewController *audioController = [[AudioViewController alloc] init];
    [audioController setSeletedRowBlock: ^(BOOL success, id result) {
        
        if (success && [result isKindOfClass:[NSNumber class]])
        {
            NSInteger index = [result integerValue];
            NSLog(@"pickAudio result: %ld", (long)index);
            
            if (index != NSNotFound)
            {
                NSArray *allAudios = [NSArray arrayWithObjects:
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"Apple"), @"song", @"Apple.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"TheMoodOfLove"), @"song", @"Love Paradise.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"LeadMeOn"), @"song", @"Lead Me On.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"Butterfly"), @"song", @"Butterfly.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"PenguinsGame"), @"song", @"Penguin's Game.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"BecauseILoveYou"), @"song", @"Because I Love You.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"MyLove"), @"song", @"My Love.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"PrettyBoy"), @"song", @"Pretty Boy.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"TheDayYouWentAway"), @"song", @"The Day You Went Away.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"RhythmOfRain"), @"song", @"Rhythm Of Rain.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"YesterdayOnceMore"), @"song", @"Yesterday Once More.mp3", @"url", nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:GBLocalizedString(@"ILoveYouMoreThanICanSay"), @"song", @"I Love You More Than I Can Say.mp3", @"url", nil],
                                      
                                      nil];
                NSDictionary *item = [allAudios objectAtIndex:index];
                NSString *file = [item objectForKey:@"url"];
                _audioPickFile = file;
            }
            else
            {
                _audioPickFile = nil;
            }
            
            [[[VideoThemesData sharedInstance] getThemeByType:kThemeCustom] setBgMusicFile:_audioPickFile];
            
            // Convert
            ThemesType curThemeType = kThemeCustom;
            [self handleConvert:curThemeType];
        }
    }];
    
    [self.navigationController pushViewController:audioController animated:NO];
}

#pragma mark - getNextStepCondition
- (BOOL)getNextStepRunCondition
{
    BOOL result = FALSE;
    if (_assets && [_assets count] > 0)
    {
        result = TRUE;
    }
    
    return result;
}

#pragma mark - playDemoVideo
- (void)playDemoVideo:(NSString*)inputVideoPath withinVideoPlayerController:(PBJVideoPlayerController*)videoPlayerController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        videoPlayerController.videoPath = inputVideoPath;
        [videoPlayerController playFromBeginning];
    });
}

#pragma mark - Progress callback
- (void)retrievingProgress:(id)progress title:(NSString *)text
{
    if (progress && [progress isKindOfClass:[NSNumber class]])
    {
        NSString *title = text ?text :GBLocalizedString(@"SavingVideo");
        NSString *currentPrecentage = [NSString stringWithFormat:@"%d%%", (int)([progress floatValue] * 100)];
        ProgressBarUpdateLoading(title, currentPrecentage);
    }
}

#pragma mark - View Lifecycle
- (void)createPopTipView
{
    NSArray *colorSchemes = [NSArray arrayWithObjects:
                             [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                             nil];
    NSArray *colorScheme = [colorSchemes objectAtIndex:foo4random()*[colorSchemes count]];
    UIColor *backgroundColor = [colorScheme objectAtIndex:0];
    UIColor *textColor = [colorScheme objectAtIndex:1];
    
    NSString *hint = GBLocalizedString(@"UsageHint");
    _popTipView = [[CMPopTipView alloc] initWithMessage:hint];
    if (backgroundColor && ![backgroundColor isEqual:[NSNull null]])
    {
        _popTipView.backgroundColor = backgroundColor;
    }
    if (textColor && ![textColor isEqual:[NSNull null]])
    {
        _popTipView.textColor = textColor;
    }
    
    _popTipView.animation = arc4random() % 2;
    _popTipView.has3DStyle = NO;
    _popTipView.dismissTapAnywhere = YES;
    [_popTipView autoDismissAnimated:YES atTimeInterval:5.0];
    
    [_popTipView presentPointingAtBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

- (void)createNavigationBar
{
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 20;
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     shadow,
                                                                     NSShadowAttributeName,
                                                                     [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                                                     nil]];
    
    self.title = GBLocalizedString(@"VideoMoments");
}

- (void)createNavigationItem
{
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 18;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(pickMusicFromCustom)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"PickupVideo") style:UIBarButtonItemStylePlain target:self action:@selector(pickupVideos:)];
    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)createContentView
{
//    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGSize sizeContent = [self calcContentSize];
    self.contentView =  [[UIScrollView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - sizeContent.width)/2.0f, (CGRectGetHeight(self.view.bounds) - SelectViewHeight - sizeContent.height)/2.0f, sizeContent.width, sizeContent.height)];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_contentView];
    
    // Border
    _borderImageView = [[UIImageView alloc] initWithFrame:_contentView.frame];
    [_borderImageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_borderImageView];
}

- (void)createPuzzleSelectView
{
    if (_puzzleView)
    {
        [_puzzleView removeFromSuperview];
        _puzzleView = nil;
    }
    
    _puzzleView = [[SelectView alloc] initWithFrameFromPuzzle:_bottomControlView.bounds picCount:[self.assets count]];
    [_puzzleView setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.6]];
    _puzzleView.delegateSelect = self;
    [_bottomControlView addSubview:_puzzleView];
    _puzzleView.hidden = YES;
}

- (void)createGifSelectView
{
    if (_gifView)
    {
        [_gifView removeFromSuperview];
        _gifView = nil;
    }
    
    _gifView = [[ScrollSelectView alloc] initWithFrameFromGif:_bottomControlView.bounds];
    [_gifView setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.6]];
    _gifView.delegateSelect = self;
    [_bottomControlView addSubview:_gifView];
    _gifView.hidden = YES;
}

- (void)createBorderSelectView
{
    if (_borderView)
    {
        [_borderView removeFromSuperview];
        _borderView = nil;
    }
    
    _borderView = [[ScrollSelectView alloc] initWithFrameFromBorder:_bottomControlView.bounds];
    [_borderView setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.6]];
    _borderView.delegateSelect = self;
    [_bottomControlView addSubview:_borderView];
    _borderView.hidden = YES;
}

- (void)createColorSelectView
{
    if (_colorView)
    {
        [_colorView removeFromSuperview];
        _colorView = nil;
    }
    
    _colorView = [[ColorSelectView alloc] initWithFrameFromColor:_bottomControlView.bounds];
    [_colorView setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.6]];
    _colorView.delegateSelect = self;
    [_bottomControlView addSubview:_colorView];
    _colorView.hidden = YES;
}

- (void)createBottomView
{
//    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    self.bottomControlView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - BottomViewHeight - SelectViewHeight, CGRectGetWidth(self.view.bounds), SelectViewHeight)];
    [self.bottomControlView setContentSize:CGSizeMake(CGRectGetWidth(self.bottomControlView.bounds) * 2, CGRectGetHeight(self.bottomControlView.bounds))];
    [self.bottomControlView setPagingEnabled:YES];
    [self.bottomControlView setScrollEnabled:NO];
    [_bottomControlView setHidden:YES];
    [self.view addSubview:_bottomControlView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - BottomViewHeight, CGRectGetWidth(self.view.bounds), BottomViewHeight)];
    [_bottomView setBackgroundColor:UIColorFromRGB(0x005831)];
    [self.view addSubview:_bottomView];
    
    _puzzleButton = [[UIButton alloc] init];
    [_puzzleButton setImage:[UIImage imageNamed:@"icon_puzzle"] forState:UIControlStateNormal];
    [_puzzleButton setImage:[UIImage imageNamed:@"icon_puzzle_selected"] forState:UIControlStateSelected];
//    [_puzzleButton setTitle:GBLocalizedString(@"Puzzle") forState:UIControlStateNormal];
    [_puzzleButton setTag:1];
    [self controlButtonStyleSettingWithButton:_puzzleButton];
    [_bottomView addSubview:_puzzleButton];
    
    _gifButton = [[UIButton alloc] init];
    [_gifButton setImage:[UIImage imageNamed:@"Gif"] forState:UIControlStateNormal];
    [_gifButton setImage:[UIImage imageNamed:@"Gif_Selected"] forState:UIControlStateSelected];
    [_gifButton setTag:2];
    [self controlButtonStyleSettingWithButton:_gifButton];
    [_bottomView addSubview:_gifButton];
    
    _colorButton = [[UIButton alloc] init];
    [_colorButton setImage:[UIImage imageNamed:@"Color"] forState:UIControlStateNormal];
    [_colorButton setImage:[UIImage imageNamed:@"Color_Selected"] forState:UIControlStateSelected];
    [_colorButton setTag:3];
    [self controlButtonStyleSettingWithButton:_colorButton];
    [_bottomView addSubview:_colorButton];
    
    _borderButton = [[UIButton alloc] init];
    [_borderButton setImage:[UIImage imageNamed:@"Frame"] forState:UIControlStateNormal];
    [_borderButton setImage:[UIImage imageNamed:@"Frame_Selected"] forState:UIControlStateSelected];
    [_borderButton setTag:4];
    [self controlButtonStyleSettingWithButton:_borderButton];
    [_bottomView addSubview:_borderButton];
}

- (void)controlButtonStyleSettingWithButton:(UIButton *)sender
{
    float toolbarCount = 4;
    sender.frame =  CGRectMake(_bottomView.frame.size.width/toolbarCount*(sender.tag-1), 0, _bottomView.frame.size.width/toolbarCount, _bottomView.frame.size.height);
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 18;
    [sender.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setTitleColor:kBrightBlue forState:UIControlStateHighlighted];
    [sender setTitleColor:kBrightBlue forState:UIControlStateSelected];
    [sender addTarget:self action:@selector(bottomViewControlAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createVideoPlayView:(CGRect)frame withPath:(UIBezierPath*)path withURL:(NSURL*)url
{
    UIView *videoContentView =  [[UIView alloc] initWithFrame:frame];
    [_contentView addSubview:videoContentView];
    
    PBJVideoPlayerController *videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.view.frame = videoContentView.bounds;
    videoPlayerController.view.clipsToBounds = YES;
    videoPlayerController.videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    videoPlayerController.delegate = self;
//    videoPlayerController.playbackLoops = YES;
    [videoContentView addSubview:videoPlayerController.view];
    
    UIImage *imageFrame = getImageFromVideoFrame(url, CMTimeMake(1, 30));
    if (imageFrame.size.width > CGRectGetWidth(frame))
    {
        videoPlayerController.videoView.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    }
    
    [_videoPlayerViews addObject:videoContentView];
    [_videoPlayerControllers addObject:videoPlayerController];
    
    [self playDemoVideo:[url absoluteString] withinVideoPlayerController:videoPlayerController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xEEEEEE); //[UIColor colorWithPatternImage:[UIImage imageNamed:@"sharebg3"]];
    _selectStyleIndex = 1;
    
    [self createNavigationBar];
    [self createNavigationItem];

    [self createContentView];
    [self createBottomView];
    
    [self createGifSelectView];
    [self createColorSelectView];
    [self createBorderSelectView];
    
    // Hint
    [self createPopTipView];
    
    // Delete temp files
    [self deleteTempDirectory];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // Hide scroll view
//    [self hiddenBottomControlView];
}

#pragma mark - Show/Hide
- (void)showScrollView:(ScrollViewStatus)status
{
    switch (status)
    {
        case kPuzzleScrollView:
        {
            _puzzleView.hidden = NO;
            _gifView.hidden = YES;
            _colorView.hidden = YES;
            _borderView.hidden = YES;
            
            break;
        }
        case kGifScrollView:
        {
            _gifView.hidden = NO;
            _puzzleView.hidden = YES;
            _colorView.hidden = YES;
            _borderView.hidden = YES;
            
            break;
        }
        case kColorScrollView:
        {
            _colorView.hidden = NO;
            _gifView.hidden = YES;
            _puzzleView.hidden = YES;
            _borderView.hidden = YES;
            
            break;
        }
        case kBorderScrollView:
        {
            _borderView.hidden = NO;
            _colorView.hidden = YES;
            _gifView.hidden = YES;
            _puzzleView.hidden = YES;
            
            break;
        }
        default:
            break;
    }
}

- (void)showBottomControlView
{
    self.bottomControlView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomControlView.frame =  CGRectMake(0, self.view.frame.size.height  - BottomViewHeight - SelectViewHeight, self.view.frame.size.width, SelectViewHeight);
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hiddenBottomControlView
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomControlView.frame =  CGRectMake(0, self.view.frame.size.height  - BottomViewHeight, self.view.frame.size.width, 1);
                         
                     } completion:^(BOOL finished) {
                         [self.bottomControlView setHidden:YES];
                     }];
}

#pragma mark - contentRemoveView
- (void)contentRemoveView
{
    for (UIView *subView in _contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}

#pragma mark - reloadPuzzleData
- (void)reloadPuzzleData
{
    [self contentResetSizeWithCalc:YES];
    
    // Clear gif
    [self clearEmbeddedGifArray];
    [StickerView setActiveStickerView:nil];
    
    // Puzzle
    [self contentRemoveView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetViewByStyleIndex:_selectStyleIndex imageCount:self.assets.count];
    });
}

#pragma mark - bottomViewControlAction
- (void)bottomViewControlAction:(id)sender
{
    if (![self getNextStepRunCondition])
    {
        NSString *message = nil;
        message = GBLocalizedString(@"VideoIsEmptyHint");
        showAlertMessage(message, nil);
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    [_selectControlButton setSelected:NO];
    
    switch (button.tag)
    {
        case 1:
        {
            if ([self.assets count] < MinVideoAssets)
            {
                NSLog(@"self.assets count < 2");
                return;
            }
            
            [self showScrollView:kPuzzleScrollView];
            self.bottomControlView.contentOffset = CGPointMake(0, 0);
            [self showBottomControlView];
            
            break;
        }
        case 2:
        {
            [self showScrollView:kGifScrollView];
            self.bottomControlView.contentOffset = CGPointMake(0, 0);
            [self showBottomControlView];
            
            break;
        }
        case 3:
        {
            [self showScrollView:kColorScrollView];
            self.bottomControlView.contentOffset = CGPointMake(0, 0);
            [self showBottomControlView];
            
            break;
        }
        case 4:
        {
            [self showScrollView:kBorderScrollView];
            self.bottomControlView.contentOffset = CGPointMake(0, 0);
            [self showBottomControlView];
            
            break;
        }
        default:
            break;
    }
    
    _selectControlButton = button;
    [button setSelected:YES];
}

#pragma mark - SelectViewDelegate
- (void)didSelectedPicCount:(NSInteger)picCount styleIndex:(NSInteger)styleIndex
{
    NSLog(@"didSelectedPuzzleIndex: %ld", (long)styleIndex);
    
    if (styleIndex == 0)
    {
        if (!_bottomControlView.hidden)
        {
            [self hiddenBottomControlView];
            return;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        _selectStyleIndex = styleIndex;
        [self reloadPuzzleData];
    });
}

#pragma mark - ColorScrollSelectViewDelegate
- (void)didSelectedColorIndex:(NSInteger)styleIndex
{
    NSLog(@"didSelectedColorIndex: %ld", (long)styleIndex);
    
    if (styleIndex == 0)
    {
        if (!_bottomControlView.hidden)
        {
            [StickerView setActiveStickerView:nil];
            
            [self hiddenBottomControlView];
            return;
        }
    }

    NSString *image = [[[ColorData sharedInstance] backgroundArray] objectAtIndex:styleIndex-1];
    _contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:image]];
    [[ColorData sharedInstance] setCurSelectBgIndex:styleIndex-1];
}

#pragma mark - ScrollSelectViewDelegate
- (void)didSelectedBorderIndex:(NSInteger)styleIndex
{
    NSLog(@"didSelectedBorderIndex: %ld", (long)styleIndex);
    
    if (styleIndex == 0)
    {
        if (!_bottomControlView.hidden)
        {
            [StickerView setActiveStickerView:nil];
            [self hiddenBottomControlView];
            return;
        }
    }
    else if (styleIndex == 1)
    {
        // Original picture(No border)
        [_borderImageView setImage:nil];
        
        NSString *videoBorder = @"";
        [[[VideoThemesData sharedInstance] getThemeByType:kThemeCustom] setImageVideoBorder:videoBorder];
        return;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"border_%lu.png", (long)styleIndex];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    image = scaleImage(image, _borderImageView.bounds.size);
    [_borderImageView setImage:image];
    
    NSString *videoBorder = [[VideoThemesData sharedInstance] getVideoBorderByIndex:(int)styleIndex];
    [[[VideoThemesData sharedInstance] getThemeByType:kThemeCustom] setImageVideoBorder:videoBorder];
}

#pragma mark - ScrollSelectViewDelegate
- (void)didSelectedGifIndex:(NSInteger)styleIndex
{
    NSLog(@"didSelectedGifIndex: %ld", (long)styleIndex);
    
    if (styleIndex == 0)
    {
        if (!_bottomControlView.hidden)
        {
            [StickerView setActiveStickerView:nil];
            
            [self hiddenBottomControlView];
            return;
        }
    }
    
    [self createEmbededGifStickerView:styleIndex];
}

#pragma mark - createEmbededGifView
- (void)createEmbededGifStickerView:(NSInteger)styleIndex
{
    NSString *imageName = [NSString stringWithFormat:@"gif_%lu.gif", (long)styleIndex];
    StickerView *view = [[StickerView alloc] initWithFilePath:getFilePath(imageName)];
    CGFloat ratio = MIN( (0.3 * _contentView.width) / view.width, (0.3 * _contentView.height) / view.height);
    [view setScale:ratio];
    CGFloat gap = 50;
    view.center = CGPointMake(_contentView.width/2 - gap, _contentView.height/2 - gap);
    [_contentView addSubview:view];
    
    [StickerView setActiveStickerView:view];
    
    if (!_gifArray)
    {
        _gifArray = [NSMutableArray arrayWithCapacity:1];
    }
    [_gifArray addObject:view];
    
    [view setDeleteFinishBlock:^(BOOL success, id result) {
        if (success)
        {
            if (_gifArray && [_gifArray count] > 0)
            {
                if ([_gifArray containsObject:result])
                {
                    [_gifArray removeObject:result];
                }
            }
        }
    }];
    
    [[ExportEffects sharedInstance] setGifArray:_gifArray];
}

#pragma mark - clearEmbeddedGifArray
- (void)clearEmbeddedGifArray
{
    [StickerView setActiveStickerView:nil];
    
    if (_gifArray && [_gifArray count] > 0)
    {
        for (StickerView *view in _gifArray)
        {
            [view removeFromSuperview];
        }
        
        [_gifArray removeAllObjects];
        _gifArray = nil;
    }
}

#pragma mark - handleConvert
- (void)handleConvert:(ThemesType)curThemeType
{
    if (![self getNextStepRunCondition])
    {
        NSString *message = nil;
        message = GBLocalizedString(@"VideoIsEmptyHint");
        showAlertMessage(message, nil);
        return;
    }
    
    ProgressBarShowLoading(GBLocalizedString(@"Processing"));
    
    [StickerView setActiveStickerView:nil];
    if (_gifArray && [_gifArray count] > 0)
    {
        for (StickerView *view in _gifArray)
        {
            [view setVideoContentRect:_contentView.frame];
        }
    }

    [[ExportEffects sharedInstance] setThemeCurrentType:curThemeType];
    [[ExportEffects sharedInstance] setExportProgressBlock: ^(NSNumber *percentage, NSString *title) {
        
        // Export progress
        NSString *content = GBLocalizedString(@"SavingVideo");
        if (!isStringEmpty(title))
        {
            content = title;
        }
        
        [self retrievingProgress:percentage title:content];
    }];
    
    [[ExportEffects sharedInstance] setFinishVideoBlock: ^(BOOL success, id result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                ProgressBarDismissLoading(GBLocalizedString(@"Success"));
            }
            else
            {
                ProgressBarDismissLoading(GBLocalizedString(@"Failed"));
            }
            
            // Alert
            NSString *ok = GBLocalizedString(@"OK");
            [UIAlertView showWithTitle:nil
                               message:result
                     cancelButtonTitle:ok
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  
                                  if (buttonIndex == [alertView cancelButtonIndex])
                                  {
                                      NSLog(@"Alert Cancelled");
                                      
                                      [NSThread sleepForTimeInterval:0.5];
                                      
                                      // Demo result video
                                      if (!isStringEmpty([ExportEffects sharedInstance].filenameBlock()))
                                      {
                                          NSString *outputPath = [ExportEffects sharedInstance].filenameBlock();
                                          [self showDemoVideo:outputPath];
                                      }
                                  }
                              }];
        });
    }];
    
    [[ExportEffects sharedInstance] addEffectToVideo:_assets];
}

#pragma mark Puzzle Style
- (void)resetViewByStyleIndex:(NSInteger)index imageCount:(NSInteger)count
{
    @synchronized(self)
    {
        self.selectStyleIndex = index;
        NSString *picCountFlag = @"";
        NSString *styleIndex = @"";
        
        switch (count)
        {
            case 2:
                picCountFlag = @"two";
                break;
            case 3:
                picCountFlag = @"three";
                break;
            case 4:
                picCountFlag = @"four";
                break;
            case 5:
                picCountFlag = @"five";
                break;
            default:
                break;
        }
        
        switch (index)
        {
            case 1:
                styleIndex = @"1";
                break;
            case 2:
                styleIndex = @"2";
                break;
            case 3:
                styleIndex = @"3";
                break;
            case 4:
                styleIndex = @"4";
                break;
            case 5:
                styleIndex = @"5";
                break;
            case 6:
                styleIndex = @"6";
                break;
            default:
                break;
        }
        
        NSString *styleName = [NSString stringWithFormat:@"number_%@_style_%@.plist",picCountFlag,styleIndex];
        NSDictionary *styleDict = [NSDictionary dictionaryWithContentsOfFile:
                                   [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:styleName]];
        if (styleDict)
        {
            CGSize superSize = CGSizeFromString([[styleDict objectForKey:@"SuperViewInfo"] objectForKey:@"size"]);
            CGSize superSizeOriginal = CGSizeFromString([[styleDict objectForKey:@"SuperViewInfo"] objectForKey:@"size"]);
            superSize = [self sizeScaleWithSize:superSize scale:2.0f];
            
            if (_videoPlayerViews && [_videoPlayerViews count] > 0)
            {
                for (UIView *view in _videoPlayerViews)
                {
                    [view removeFromSuperview];
                }
                
                [_videoPlayerViews removeAllObjects];
            }
            else
            {
                _videoPlayerViews = [[NSMutableArray alloc]initWithCapacity:1];
            }
            
            if (_videoPlayerControllers && [_videoPlayerControllers count] > 0)
            {
                for (PBJVideoPlayerController *controller in _videoPlayerControllers)
                {
                    [controller removeFromParentViewController];
                }
                
                [_videoPlayerControllers removeAllObjects];
            }
            else
            {
                _videoPlayerControllers = [[NSMutableArray alloc]initWithCapacity:1];
            }
            
            NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:1];
            NSMutableArray *puzzleDatas = [[NSMutableArray alloc] initWithCapacity:1];
            NSArray *subViewArray = [styleDict objectForKey:@"SubViewArray"];
            for(int j = 0; j < [subViewArray count]; ++j)
            {
                CGRect rect = CGRectZero;
                UIBezierPath *path = nil;
                UIBezierPath *pathOriginal = nil;
                NSDictionary *subDict = [subViewArray objectAtIndex:j];
                if([subDict objectForKey:@"frame"])
                {
                    rect = CGRectFromString([subDict objectForKey:@"frame"]);
                    rect = [self rectScaleWithRect:rect scale:2.0f];
                    rect.origin.x = rect.origin.x * _contentView.frame.size.width/superSize.width;
                    rect.origin.y = rect.origin.y * _contentView.frame.size.height/superSize.height;
                    rect.size.width = rect.size.width * _contentView.frame.size.width/superSize.width;
                    rect.size.height = rect.size.height * _contentView.frame.size.height/superSize.height;
                }
                
                rect = [self rectWithArray:[subDict objectForKey:@"pointArray"] andSuperSize:superSize andOriginal:NO];
                if ([subDict objectForKey:@"pointArray"])
                {
                    NSArray *pointArray = [subDict objectForKey:@"pointArray"];
                    path = [UIBezierPath bezierPath];
                    pathOriginal = [UIBezierPath bezierPath];
                    if (pointArray.count > 2)
                    {
                        // >2
                        for(int i = 0; i < [pointArray count]; ++i)
                        {
                            NSString *pointString = [pointArray objectAtIndex:i];
                            if (pointString)
                            {
                                CGPoint point = CGPointFromString(pointString);
                                CGPoint pointOriginal = [self convertCGPoint:point fromSize1:superSize toSize2:_contentView.bounds.size];
                                if (i == 0)
                                {
                                    [pathOriginal moveToPoint:pointOriginal];
                                }
                                else
                                {
                                    [pathOriginal addLineToPoint:pointOriginal];
                                }
                                
                                point = [self pointScaleWithPoint:point scale:2.0f];
                                point.x = (point.x)*_contentView.frame.size.width/superSize.width - rect.origin.x;
                                point.y = (point.y)*_contentView.frame.size.height/superSize.height - rect.origin.y;
                                if (i == 0)
                                {
                                    [path moveToPoint:point];
                                }
                                else
                                {
                                    [path addLineToPoint:point];
                                }
                            }
                        }
                    }
                    else
                    {
                        [path moveToPoint:CGPointMake(0, 0)];
                        [path addLineToPoint:CGPointMake(rect.size.width, 0)];
                        [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
                        [path addLineToPoint:CGPointMake(0, rect.size.height)];
                        
                        pathOriginal = path;
                    }
                    
                    [path closePath];
                }
                
                ALAsset *asset = [self.assets objectAtIndex:j];
                [self createVideoPlayView:rect withPath:path withURL:asset.defaultRepresentation.url];
                
                CGRect rectOriginal = [self rectWithArray:[subDict objectForKey:@"pointArray"] andSuperSize:superSize andOriginal:YES];
                rectOriginal.origin.y = fabs(superSizeOriginal.height - rectOriginal.origin.y - CGRectGetHeight(rectOriginal));
                [frames addObject:[NSValue valueWithCGRect:rectOriginal]];
                [puzzleDatas addObject:pathOriginal];
            }
            
            // Save for puzzle data
            [[PuzzleData sharedInstance] setSuperFrame:superSizeOriginal];
            [[PuzzleData sharedInstance] setFrames:frames];
            [[PuzzleData sharedInstance] setPuzzlePaths:puzzleDatas];
        }
    
        _contentView.contentSize = _contentView.frame.size;
    }
}

#pragma mark - CalcPointArray
- (CGPoint)convertCGPoint:(CGPoint)point1 fromSize1:(CGSize)size1 toSize2:(CGSize)size2
{
    point1.y = size1.height - point1.y;
    CGPoint result = CGPointMake((point1.x *size2.width)/size1.width, (point1.y*size2.height)/size1.height);
    return result;
}

- (CGRect)rectWithArray:(NSArray *)array andSuperSize:(CGSize)superSize andOriginal:(BOOL)original
{
    CGRect rect = CGRectZero;
    CGFloat minX = INT_MAX;
    CGFloat maxX = 0;
    CGFloat minY = INT_MAX;
    CGFloat maxY = 0;
    for (int i = 0; i < [array count]; i++)
    {
        NSString *pointString = [array objectAtIndex:i];
        CGPoint point = CGPointFromString(pointString);
        if (point.x <= minX)
        {
            minX = point.x;
        }
        
        if (point.x >= maxX)
        {
            maxX = point.x;
        }
        
        if (point.y <= minY)
        {
            minY = point.y;
        }
        
        if (point.y >= maxY)
        {
            maxY = point.y;
        }
        rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    
    if (!original)
    {
        rect = [self rectScaleWithRect:rect scale:2.0f];
        rect.origin.x = rect.origin.x * _contentView.frame.size.width/superSize.width;
        rect.origin.y = rect.origin.y * _contentView.frame.size.height/superSize.height;
        rect.size.width = rect.size.width * _contentView.frame.size.width/superSize.width;
        rect.size.height = rect.size.height * _contentView.frame.size.height/superSize.height;
    }
    
    return rect;
}

- (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale
{
    if (scale <= 0)
    {
        scale = 1.0f;
    }
    
    CGRect retRect = CGRectZero;
    retRect.origin.x = rect.origin.x/scale;
    retRect.origin.y = rect.origin.y/scale;
    retRect.size.width = rect.size.width/scale;
    retRect.size.height = rect.size.height/scale;
    return  retRect;
}

- (CGPoint)pointScaleWithPoint:(CGPoint)point scale:(CGFloat)scale
{
    if (scale <= 0)
    {
        scale = 1.0f;
    }
    
    CGPoint retPointt = CGPointZero;
    retPointt.x = point.x/scale;
    retPointt.y = point.y/scale;
    return  retPointt;
}

- (CGSize)sizeScaleWithSize:(CGSize)size scale:(CGFloat)scale
{
    if (scale <= 0)
    {
        scale = 1.0f;
    }
    
    CGSize retSize = CGSizeZero;
    retSize.width = size.width/scale;
    retSize.height = size.height/scale;
    return  retSize;
}

#pragma mark - calcContentSize
- (void)contentResetSizeWithCalc:(BOOL)calc
{
    if (calc)
    {
        CGSize sizeContent = [self calcContentSize];
        _contentView.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - sizeContent.width)/2.0f, (CGRectGetHeight(self.view.bounds) - SelectViewHeight - sizeContent.height)/2.0f, sizeContent.width, sizeContent.height);
        _contentView.contentSize = self.contentView.frame.size;
    }
    else
    {
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - BottomViewHeight);
    }
    
    _borderImageView.frame = _contentView.frame;
}

- (CGSize)calcContentSize
{
    CGSize retSize = CGSizeZero;
    CGFloat size_width = CGRectGetWidth(self.view.bounds);
    CGFloat size_height = size_width * 4 /3.0f;
    if (size_height >= (CGRectGetHeight(self.view.bounds) - BottomViewHeight))
    {
        size_height = CGRectGetHeight(self.view.bounds) - BottomViewHeight;
        size_width = size_height * 3/4.0f;
    }
    
    retSize.width = size_width;
    retSize.height = size_height;
    return  retSize;
}

#pragma mark - reCalcVideoViewSize
- (CGSize)reCalcVideoViewSize:(NSString *)videoPath
{
    CGSize resultSize = CGSizeZero;
    if (isStringEmpty(videoPath))
    {
        return resultSize;
    }
    
    UIImage *videoFrame = getImageFromVideoFrame(getFileURLFromAbsolutePath(videoPath), kCMTimeZero);
    if (!videoFrame || videoFrame.size.height < 1 || videoFrame.size.width < 1)
    {
        return resultSize;
    }
    
    NSLog(@"reCalcVideoViewSize: %@, width: %f, height: %f", videoPath, videoFrame.size.width, videoFrame.size.height);
    
    CGFloat statusBarHeight = 0; //iOS7AddStatusHeight;
    CGFloat navHeight = 0; //CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat gap = 15;
    CGFloat height = CGRectGetHeight(self.view.frame) - navHeight - statusBarHeight - 2*gap;
    CGFloat width = CGRectGetWidth(self.view.frame) - 2*gap;
    if (height < width)
    {
        width = height;
    }
    else if (height > width)
    {
        height = width;
    }
    CGFloat videoHeight = videoFrame.size.height, videoWidth = videoFrame.size.width;
    CGFloat scaleRatio = videoHeight/videoWidth;
    CGFloat resultHeight = 0, resultWidth = 0;
    if (videoHeight <= height && videoWidth <= width)
    {
        resultHeight = videoHeight;
        resultWidth = videoWidth;
    }
    else if (videoHeight <= height && videoWidth > width)
    {
        resultWidth = width;
        resultHeight = height*scaleRatio;
    }
    else if (videoHeight > height && videoWidth <= width)
    {
        resultHeight = height;
        resultWidth = width/scaleRatio;
    }
    else
    {
        if (videoHeight < videoWidth)
        {
            resultWidth = width;
            resultHeight = height*scaleRatio;
        }
        else if (videoHeight == videoWidth)
        {
            resultWidth = width;
            resultHeight = height;
        }
        else
        {
            resultHeight = height;
            resultWidth = width/scaleRatio;
        }
    }
    
    resultSize = CGSizeMake(resultWidth, resultHeight);
    return resultSize;
}

#pragma mark - showDemoVideo
- (void)showDemoVideo:(NSString *)videoPath
{
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGSize size = [self reCalcVideoViewSize:videoPath];
    _demoVideoContentView =  [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - size.width/2, CGRectGetMidY(self.view.frame) - size.height/2 - navHeight - statusBarHeight, size.width, size.height)];
    [self.view addSubview:_demoVideoContentView];
    
    // Video player of destination
    _demoVideoPlayerController = [[PBJVideoPlayerController alloc] init];
    _demoVideoPlayerController.view.frame = _demoVideoContentView.bounds;
    _demoVideoPlayerController.view.clipsToBounds = YES;
    _demoVideoPlayerController.videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _demoVideoPlayerController.delegate = self;
    //    _demoVideoPlayerController.playbackLoops = YES;
    [_demoVideoContentView addSubview:_demoVideoPlayerController.view];
    
    _demoPlayButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    _demoPlayButton.center = _demoVideoPlayerController.view.center;
    [_demoVideoPlayerController.view addSubview:_demoPlayButton];
    
    // Popup modal view
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeLeft];
    [[KGModal sharedInstance] showWithContentView:_demoVideoContentView andAnimated:YES];
    
    [self playDemoVideo:videoPath withinVideoPlayerController:_demoVideoPlayerController];
}

#pragma mark - NSUserDefaults
#pragma mark - AppRunCount
- (void)addAppRunCount
{
    NSUInteger appRunCount = [self getAppRunCount];
    NSInteger limitCount = 6;
    if (appRunCount < limitCount)
    {
        ++appRunCount;
        NSString *appRunCountKey = @"AppRunCount";
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        [userDefaultes setInteger:appRunCount forKey:appRunCountKey];
        [userDefaultes synchronize];
    }
}

- (NSUInteger)getAppRunCount
{
    NSUInteger appRunCount = 0;
    NSString *appRunCountKey = @"AppRunCount";
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([userDefaultes integerForKey:appRunCountKey])
    {
        appRunCount = [userDefaultes integerForKey:appRunCountKey];
    }
    
    NSLog(@"getAppRunCount: %lu", (unsigned long)appRunCount);
    return appRunCount;
}

@end
