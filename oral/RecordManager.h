//
//  RecordManager.h
//  IELTSSpeaking
//
//  Created by cocim01 on 14-11-18.
//  Copyright (c) 2014年 cocim01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordManager : NSObject<AVAudioRecorderDelegate>
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,strong) NSDate *beginDate;
@property (nonatomic,strong) NSDate *endDate;
@property (nonatomic,assign) NSTimeInterval recorderTime;
- (void)prepareRecorderWithFileName:(NSString *)fileName;
- (void)stopRecord;
- (void)pausestopRecord;

@end
