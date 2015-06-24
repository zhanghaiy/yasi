//
//  AudioPlayer.h
//  oral
//
//  Created by cocim01 on 15/5/19.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h> 


@interface AudioPlayer : NSObject<AVAudioPlayerDelegate>


@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;

@property (nonatomic,strong) AVAudioPlayer *player;


+ (AudioPlayer*)getAudioManager;
- (void)playerPlayWithFilePath:(NSString *)filePath;
- (void)beginePlay;
- (void)stopPlay;
- (void)pausePlay;
@property (nonatomic,assign) float audioDuration;

@end
