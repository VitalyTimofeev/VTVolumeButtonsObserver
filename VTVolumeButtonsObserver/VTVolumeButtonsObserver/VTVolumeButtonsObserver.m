//
//  VTVolumeButtonsObserver.m
//  VTVolumeButtonsObserver
//
//  Created by Vitaly Timofeev on 05/06/15.
//  Copyright (c) 2015 Vitaly Timofeev. All rights reserved.
//

#import "VTVolumeButtonsObserver.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static CGRect const kVTVolumeButtonsObserverVolumeViewFrame = {0.0f, -200.0f, 320.0f, 100.0f};
static CGFloat const kVTVolumeButtonsObserverThresholdValue = 0.5f;

@interface VTVolumeButtonsObserver()

@property (copy, nonatomic) VTVolumeButtonsObserverBlock upButtonBlock;
@property (copy, nonatomic) VTVolumeButtonsObserverBlock downButtonBlock;

@property (strong, nonatomic) MPVolumeView *volumeView;

@end

@implementation VTVolumeButtonsObserver

+ (instancetype)observerWithUpButtonBlock:(VTVolumeButtonsObserverBlock)upButtonBlock downButtonBlock:(VTVolumeButtonsObserverBlock)dowbButtonBlock
{
    NSParameterAssert(upButtonBlock && dowbButtonBlock);
    
    if (TARGET_IPHONE_SIMULATOR){
        NSLog(@"VTVolumeButtonsObserver: MPVolumeView is not available on simulator");
        return nil;
    }
    
    VTVolumeButtonsObserver *observer = [VTVolumeButtonsObserver new];
    observer.upButtonBlock = upButtonBlock;
    observer.downButtonBlock = dowbButtonBlock;
    return observer;
}

- (instancetype)init
{
    if (self){
        if ([self activateAudioSession]){
            [self setupVolumeView];
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeVolumeView];
    [self deactivateAudioSession];
}

#pragma mark - MPVolumeView Setup

- (void)setupVolumeView
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:kVTVolumeButtonsObserverVolumeViewFrame];
    volumeView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    volumeView.showsRouteButton = NO;
    volumeView.showsVolumeSlider = YES;
    self.volumeView = volumeView;
    
    [[UIApplication sharedApplication].keyWindow insertSubview:volumeView atIndex:0];
    
    //need small delay to get rid of system's volume dialog
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupVolumeViewSliderHandler];
    });
}

- (void)removeVolumeView
{
    [self.volumeView removeFromSuperview];
    self.volumeView = nil;
}

#pragma mark - MPVolumeView's slider setup

- (void)setupVolumeViewSliderHandler
{
    __block UISlider *slider = nil;
    
    [self.volumeView.subviews enumerateObjectsUsingBlock:^(UISlider *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UISlider class]]){
            slider = obj;
            *stop = YES;
        }
    }];
    
    if (slider == nil){
        NSLog(@"VTVolumeButtonsObserver: Unable to find UISlider in MPVolumeView !!!");
    }
    
    [self setDefaultVolumeValueForSlider:slider];
    [slider addTarget:self action:@selector(volumeViewSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setDefaultVolumeValueForSlider:(UISlider *)slider
{
    slider.value = kVTVolumeButtonsObserverThresholdValue;
}

- (void)volumeViewSliderValueChanged:(UISlider *)slider
{
    if (slider.value > kVTVolumeButtonsObserverThresholdValue){
        self.upButtonBlock();
    }
    else if (slider.value < kVTVolumeButtonsObserverThresholdValue){
        self.downButtonBlock();
    }
    [self setDefaultVolumeValueForSlider:slider];
}

#pragma mark - AVAudioSession Helpers

- (BOOL)activateAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryAmbient error:&error];
    if (error){
        NSLog(@"VTVolumeButtonsObserver: Unable to set AVAudioSessionCategoryAmbient with error: %@", error);
        return NO;
    }
    [session setActive:YES error:&error];
    if (error){
        NSLog(@"VTVolumeButtonsObserver: Activate audio session error: %@", error);
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    
    return YES;
}

- (void)deactivateAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setActive:NO error:&error];
    if (error){
        NSLog(@"VTVolumeButtonsObserver: Deactivate audio session error: %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification
{
    AVAudioSessionInterruptionType interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (interruptionType == AVAudioSessionInterruptionTypeEnded){
        NSLog(@"VTVolumeButtonsObserver: Audio session interruption ended - try to activate session again");
        [self activateAudioSession];
    }
}

@end
