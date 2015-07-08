//
//  DeviceManager.h
//  oral
//
//  Created by cocim01 on 15/6/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//跟设备有关的参数，从此类获取
@interface DeviceManager : NSObject

//获取屏幕的高度
+ (NSInteger)currentScreenHeight;

//判断操作系统是否高于iOS7
+ (BOOL)upIOS7Version;

+ (NSString *)currentVersion;

//获取设备的型号 返回的是一个字符串
+ (NSString *)currentDeviceModel;


@end
