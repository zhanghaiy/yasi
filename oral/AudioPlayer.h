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

+ (AudioPlayer*)getAudioManager;
- (void)playerPlayWithFilePath:(NSString *)filePath;
- (void)beginePlay;
- (void)stopPlay;
- (void)pausePlay;

@end
