//
//  TopicInfoManager.m
//  oral
//
//  Created by cocim01 on 15/7/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicInfoManager.h"

@implementation TopicInfoManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        _allTopicsDict = [[NSMutableDictionary alloc]init];
    }
    return self;
}

static TopicInfoManager *manager = nil;
+ (TopicInfoManager *)getTopicInfoManager
{
    if (manager == nil)
    {
        manager = [[TopicInfoManager alloc]init];
    }
    return manager;
}

- (void)setTopicDetailInfo:(NSDictionary *)topicInfoDic TopicID:(NSString *)topicID
{
    [_allTopicsDict setObject:topicInfoDic forKey:topicID];
}

- (NSDictionary *)getTopicDetailInfoWithTopicID:(NSString *)topicID
{
    return [_allTopicsDict objectForKey:topicID];
}

//- (void)addPartPracticeInfoWithPracticeID:(NSString *)practiceID Commit:(BOOL)commit 


@end
