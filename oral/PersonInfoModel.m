//
//  PersonInfoModel.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonInfoModel.h"

@implementation PersonInfoModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"找不到key：%@",key);
}

@end
