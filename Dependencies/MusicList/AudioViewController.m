//
//  AudioViewController
//  VideoMoments
//
//  Created by Johnny Xu(徐景周) on 5/22/15.
//  Copyright (c) 2015 Future Studio. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioCell.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioViewController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSIndexPath *lastSelectRow;

@end

@implementation AudioViewController

#pragma mark - View Lifecycle
- (void)dealloc
{
}

- (void)createNavigationBar
{
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 20;
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:1 green:1 blue:1 alpha:1], NSForegroundColorAttributeName,
                                                                     shadow,
                                                                     NSShadowAttributeName,
                                                                     [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                                                     nil]];
    
    self.title = GBLocalizedString(@"MusicList");
}

- (void)createNavigationItem
{
    NSString *fontName = GBLocalizedString(@"FontName");
    CGFloat fontSize = 18;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:GBLocalizedString(@"Skip") style:UIBarButtonItemStylePlain target:self action:@selector(handleSkip)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _lastSelectRow = nil;

    [self createNavigationBar];
    [self createNavigationItem];
    
    _allAudios = [[NSArray arrayWithObjects:
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
                          
                          nil] mutableCopy];
    
    // Load data
    [self loadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.tableView = nil;
}

#pragma mark - handleSkip
- (void)handleSkip
{
    if (_seletedRowBlock)
    {
        NSInteger tag = NSNotFound;
        NSLog(@"handleSkip: %ld", (long)tag);
        
        self.seletedRowBlock(YES, [NSNumber numberWithInteger:tag]);
        [self backAction];
    }
}

#pragma mark - Selected Row
- (void)selectedRowResult:(UIButton *)button
{
    if (_seletedRowBlock)
    {
        NSLog(@"selectedRowResult: %ld", (long)button.tag);
        
        self.seletedRowBlock(YES, [NSNumber numberWithInteger:button.tag]);
        [self backAction];
    }
}

- (void)playAudio:(NSInteger)index
{
    NSDictionary *item = [_allAudios objectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    AudioCell *cell = (AudioCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if (_lastSelectRow.hash == indexPath.hash)
    {
        BOOL startsPlaying = !self.audioPlayer.playing;
        if (startsPlaying)
        {
            [self.audioPlayer play];
            cell.avatarView.image = [UIImage imageNamed:@"pause"];
        }
        else
        {
            [self.audioPlayer pause];
            cell.avatarView.image = [UIImage imageNamed:@"start"];
        }
    }
    else
    {
        AudioCell *cellLast = (AudioCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectRow];
        cellLast.avatarView.image = [UIImage imageNamed:@"start"];
        [self.audioPlayer stop];
        
        NSString *file = [item objectForKey:@"url"];
        NSString *fileName = [file stringByDeletingPathExtension];
        NSLog(@"File name: %@",fileName);
        NSString *fileExt = [file pathExtension];
        NSLog(@"File ExtName: %@",fileExt);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
        NSURL *url = [NSURL fileURLWithPath:path];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
        
        cell.avatarView.image = [UIImage imageNamed:@"pause"];
        
        self.lastSelectRow = indexPath;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"lastSelectRow.row: %ld, [self.allAudios count]: %ld", (long)self.lastSelectRow.row, (unsigned long)[self.allAudios count]);
    
    if (self.lastSelectRow && self.lastSelectRow.row < [self.allAudios count])
    {
        AudioCell *cellLast = (AudioCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectRow];
        cellLast.avatarView.image = [UIImage imageNamed:@"start"];
    }
}

#pragma mark
#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_allAudios count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AudioCell";
    AudioCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[AudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    NSDictionary *item = [_allAudios objectAtIndex:indexPath.row];
    cell.titleLabel.text = [item objectForKey:@"song"];
    cell.audioButton.tag = indexPath.row;
    [cell.audioButton addTarget:self action:@selector(selectedRowResult:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.lastSelectRow && self.lastSelectRow.hash == indexPath.hash)
    {
        AudioCell *cellLast = (AudioCell*)[self.tableView cellForRowAtIndexPath:self.lastSelectRow];
        if (cellLast)
        {
            if (self.audioPlayer.playing)
            {
                cellLast.avatarView.image = [UIImage imageNamed:@"pause"];
            }
            else
            {
                cellLast.avatarView.image = [UIImage imageNamed:@"start"];
            }
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath.Row: %ld", (long)indexPath.row);
    
    if(indexPath && indexPath.row >= 0)
    {
        [self playAudio:indexPath.row];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Load Data
- (void)reloadData
{
    if (_allAudios && [_allAudios count] > 0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [self.tableView reloadData];
}

- (void)loadData
{
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Background Play Audio
- (void)backgroundPlayAudioSetting
{
    // Setting play in background
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
