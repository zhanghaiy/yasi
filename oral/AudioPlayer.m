//
//  AudioPlayer.m
//  oral
//
//  Created by cocim01 on 15/5/19.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer


static AudioPlayer *audioPlayer;

+ (AudioPlayer*)getAudioManager
{
    if (audioPlayer == nil)
    {
        audioPlayer = [[AudioPlayer alloc]init];
    }
    return audioPlayer;
}

#pragma mark - 通过路径播放
- (void)playerPlayWithFilePath:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        if (_player)
        {
            _player = nil;
        }
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        _player.delegate = self;
        _audioDuration = _player.duration ;
        _player.volume = 1;
        [_player prepareToPlay];
        [_player play];
    }
}

#pragma mark - 播放
- (void)beginePlay
{
    [_player play];
}

#pragma mark- 暂停
- (void)pausePlay
{
    [_player pause];
}

#pragma mark - 停止
- (void)stopPlay
{
    [_player stop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"播放完成回调:error");
}

#pragma mark - 播放完成回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完成");
    if (_target&&[_target respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:nil];
#pragma clang diagnostic pop
    }
}

- (void)dealloc
{
    _player = nil;
}



@end
