//
//  ViewController.m
//  EOTMPlayer
//
//  Created by Shawn Roske on 10/10/16.
//  Copyright © 2016 space150. All rights reserved.
//

#import "ViewController.h"
#import "EOTMVideoSet.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#define INFO_INTERVAL_SECONDS 30.0f
#define INFO_SHOW_SECONDS 10.0f


@interface ViewController () <EOTMVideoSetDelegate>

@property (weak, nonatomic) IBOutlet UIVisualEffectView *infoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *employeeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) EOTMVideoSet *videoSet;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@property (nonatomic, strong) NSTimer *infoTriggerTimer;
@property (nonatomic, assign) BOOL showEOTMInfo;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // render "loading" view
    // TODO

    self.infoContainerView.clipsToBounds = YES;
    self.infoContainerView.layer.cornerRadius = 10.0f;
    [self.infoContainerView setAlpha:0.0f];
    
    self.videoSet = [[EOTMVideoSet alloc] init];
    [self.videoSet setDelegate:self];
    [self.videoSet load];
    
    self.showEOTMInfo = YES;
    
    self.infoTriggerTimer = [NSTimer scheduledTimerWithTimeInterval:INFO_INTERVAL_SECONDS target:self selector:@selector(showInfoView) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Movie management/playback

- (void)loadMovie:(NSURL *)movieUrl
{
    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.player = [AVPlayer playerWithURL:movieUrl];
    _playerViewController.view.frame = self.view.bounds;
    
    _playerViewController.player.volume = 0.0f;
    _playerViewController.showsPlaybackControls = NO;
    
    [self.view insertSubview:_playerViewController.view atIndex:0];
    self.view.autoresizesSubviews = YES;
    
    [_playerViewController.player play];
    
    [self setupMovieLooping];
}

- (void)setupMovieLooping
{
    // loop forever!
    __weak typeof(self) weakSelf = self; // prevent memory cycle
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                            object:nil // any object can send
                             queue:nil // the queue of the sending
                        usingBlock:^(NSNotification *note) {
                            // holding a pointer to avPlayer to reuse it
                            [weakSelf.playerViewController.player seekToTime:kCMTimeZero];
                            [weakSelf.playerViewController.player play];
                        }];
}

- (void)showInfoView
{
    if ( self.showEOTMInfo ) {
        [self.employeeNameLabel setText:self.videoSet.currentEmployeeName];
        [self.dateLabel setText:[NSString stringWithFormat:@"EOTM: %@", self.videoSet.currentDateString]];
    } else {
        [self.employeeNameLabel setText:[[UIDevice currentDevice] name]];
        [self.dateLabel setText:@"WIFI: space150-guest"];
    }
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        [self.infoContainerView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f delay:INFO_SHOW_SECONDS options:UIViewAnimationOptionCurveLinear animations:^{
            [self.infoContainerView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            // nothing
        }];
    }];
    
    self.showEOTMInfo = !self.showEOTMInfo;
}

#pragma mark - EOTMVideoSetDelegate Methods

- (void)videoSetLoaded:(NSURL *)videoURL
{
    NSLog(@"video set loaded: %@", videoURL);
    
    [self loadMovie:videoURL];
}

- (void)errorLoadingVideoSet:(NSError *)error
{
    NSLog(@"error loading video set: %@", [error localizedDescription]);
}


@end
