//
//  AppDelegate.h
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
    待完成：  1、成绩单界面的逻辑 06.19
             2、闯关、模考流程以完善 一些细节：网络提交失败时给用户提示 问题与问题之间的链接 还需美工确定 完善细节
    问题：
         练习簿的音频 和 闯关音频 区分开 
    
 */

#define kScreentWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

