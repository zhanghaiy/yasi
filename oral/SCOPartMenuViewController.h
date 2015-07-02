//
//  SCOPartMenuViewController.h
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface SCOPartMenuViewController : TopicParentsViewController

@property (nonatomic,assign) BOOL review_point_3;// 判断是否有反馈
@property (nonatomic,strong) NSDictionary *review_dict_point_3;//老师反馈总信息 包含老师头像 和 反馈id

@end
