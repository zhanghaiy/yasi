//
//  RecordManager.m
//  IELTSSpeaking
//
//  Created by cocim01 on 14-11-18.
//  Copyright (c) 2014年 cocim01. All rights reserved.
//

#import "RecordManager.h"

@implementation RecordManager
{
    AVAudioRecorder *recorder;
    NSURL *fileNameUrl;
}


//static RecordManager *recordManager;
//- (RecordManager *)getRecordManager
//{
//    if (recordManager == nil)
//    {
//        recordManager = [[RecordManager alloc]init];
//    }
//    
//    return recordManager;
//}



- (void)prepareRecorderWithFilePath:(NSString *)filePath
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: 44100.0],AVSampleRateKey, [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey, [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey, [NSNumber numberWithInt: 2], AVNumberOfChannelsKey, [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey, [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
    
    fileNameUrl = [NSURL fileURLWithPath:
               filePath];
    recorder = [[AVAudioRecorder alloc]initWithURL:fileNameUrl settings:setting error:nil];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    [recorder record];
    _beginDate = [NSDate date];
}

- (void)stopRecord
{
    
    [recorder stop];
    _endDate = [NSDate date];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];

}

- (void)pausestopRecord
{
    [recorder pause];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    _recorderTime = [_endDate timeIntervalSinceDate:_beginDate];
    NSLog(@"时间差： %f ",_recorderTime);
    NSLog(@"录音完成");
    if ([_target respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
    }

}

- (void)createPathWithPath:(NSString *)path
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音过程被中断");
}


@end
