//
//  SaveRecordTime.m
//  oral
//
//  Created by cocim01 on 15/6/17.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "SaveRecordTime.h"

@implementation SaveRecordTime

static SaveRecordTime *recordTime;
+ (SaveRecordTime *)getSaveRecordTime
{
    if (recordTime == nil)
    {
        recordTime = [[SaveRecordTime alloc]init];
    }
    return recordTime;
}

//- (void)setTopicName:(NSString *)topicName PartCounts:(int)part Point:(int)point LastTime:(long)time UserName:(NSString *)userName
//{
//    NSString *key = [NSString stringWithFormat:@"%@-%@",topicName,userName];
//    NSDictionary *subDic = @{@"time":[NSNumber numberWithLong:time],@"part":[NSNumber numberWithInt:part],@"point":[NSNumber numberWithInt:point]};
//    if ([_topicTimeDic objectForKey:key])
//    {
//        [_topicTimeDic removeObjectForKey:key];
//    }
//    [_topicTimeDic setObject:subDic forKey:key];
//}
//
//- (void)getTopicTimeWithTopic:(NSString *)topicName UserName:(NSString *)userName
//{
//    NSString *key = [NSString stringWithFormat:@"%@-%@",topicName,userName];
//    NSDictionary *dic = [_topicTimeDic objectForKey:key];
//    long time =
//}


@end
