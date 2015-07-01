//
//  TopicInfoManager.h
//  oral
//
//  Created by cocim01 on 15/7/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicInfoManager : NSObject

@property (strong,nonatomic) NSMutableDictionary *allTopicsDict;
+ (TopicInfoManager *)getTopicInfoManager;
- (void)setTopicDetailInfo:(NSDictionary *)topicInfoDic TopicID:(NSString *)topicID;
- (NSDictionary *)getTopicDetailInfoWithTopicID:(NSString *)topicID;

@end
