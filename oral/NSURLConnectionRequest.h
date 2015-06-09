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

//生成httpRequest对象，并执行服务器的交互
//外部使用此类，只需要调用此方法，不用理会内部的实现
+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh;
// post方式
+ (void)requestPOSTUrlString:(NSString *)urlStr andParamStr:(NSString *)paramStr target:(id)target action:(SEL)action andRefresh:(BOOL)refresh;

@end
