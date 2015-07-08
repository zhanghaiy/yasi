//
//  DeviceManager.m
//  oral
//
//  Created by cocim01 on 15/6/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "DeviceManager.h"

@implementation DeviceManager

//获取屏幕的高度
+ (NSInteger)currentScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (NSString *)currentVersion
{
    return [UIDevice currentDevice].systemVersion;
}

//判断操作系统是否为iOS7
+ (BOOL)upIOS7Version
{
    //获取到操作系统的版本号
    NSString *currentVersion = [UIDevice currentDevice].systemVersion;
    //hasPrefix 字符串的方法，判断版本号是否有7的前缀
    float version = [currentVersion floatValue];
    if (version>=7)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

//获取设备的型号 返回的是一个字符串
+ (NSString *)currentDeviceModel
{
    // UIDevice跟设备参数相关的类，设备的版本号、设备名称、设备型号、等参数通过此类获取
    //currentDevice 通过此方法获取到UIdevice单例
    return [UIDevice currentDevice].model;
}


@end
