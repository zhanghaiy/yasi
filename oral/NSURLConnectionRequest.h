//
//  NSURLConnectionRequest.h
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnectionRequest : NSObject

//请求地址
@property (nonatomic,copy) NSString *requestUrlString;
//请求下来的数据
@property (nonatomic,strong) NSMutableData *downloadData;
//通知id 来进行后续的操作
@property (nonatomic,weak) id target;
//后续操作
@property (nonatomic,assign) SEL aciton;

@property (nonatomic,assign) NSInteger sumLength;// 标记下载文件总长度
@property (nonatomic,assign) SEL percentAction;  // 下载文件时显示百分比回调方法
@property (nonatomic,assign) BOOL showPercent; // 是否显示百分比

// get
+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh ShowPercent:(BOOL)shoePercent PercentAction:(SEL)perAction;

+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh;
// post方式
+ (void)requestPOSTUrlString:(NSString *)urlStr andParamStr:(NSString *)paramStr target:(id)target action:(SEL)action andRefresh:(BOOL)refresh;

@end
