//
//  NSURLConnectionRequest.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "NSURLConnectionRequest.h"

@implementation NSURLConnectionRequest

{
    //用苹果自带的网络交互类
    NSURLConnection *_urlConnection;
}
- (id)init
{
    self = [super init];
    if (self) {
        _downloadData  =[[NSMutableData alloc] init];
    }
    return self;
}

#pragma mark - 上传图片
+ (void)upLoadImageWithUrlString:(NSString *)urlStr ParamStr:(NSString *)params Target:(id)target Action:(SEL)selector
{
    NSURLConnectionRequest *requestManager = [[NSURLConnectionRequest alloc] init];
    requestManager.requestUrlString = urlStr;
    requestManager.target = target;
    requestManager.aciton = selector;
    [requestManager startUpLoadImageWithParams:params];
}


- (void)startUpLoadImageWithParams:(NSString *)params
{
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrlString]];
    //http method
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - get Request
/*
    有2个方法  上面的--->初始的  下面的---->后续拓展的方法
    原来的不能满足需求 增加方法满足新需求  同时保证原先仍可用
 */
#pragma mark -- 初始写的 网络请求
+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh
{
    [self requestWithUrlString:urlStr target:target aciton:aciton andRefresh:isRefresh ShowPercent:NO PercentAction:nil];
}

#pragma mark -- 后来完善的
+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh ShowPercent:(BOOL)shoePercent PercentAction:(SEL)perAction
{
    NSURLConnectionRequest *request = [[NSURLConnectionRequest alloc] init];
    request.requestUrlString = urlStr;
    request.target = target;
    request.aciton = aciton;
    request.percentAction = perAction;
    request.showPercent = shoePercent;
    
    // 增加缓存
    NSString *requestPath = [NSString stringWithFormat:@"%@/%@",[request getLoadPath],urlStr];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:requestPath]&&(isRefresh==NO))
    {
        NSData *data = [NSData dataWithContentsOfFile:requestPath];
        [request.downloadData setLength:0];
        [request.downloadData appendData:data];
        //让target执行action,同时传出request
        if ([request.target respondsToSelector:request.aciton])
        {
            [request.target performSelector:request.aciton withObject:request afterDelay:NO];
        }
    }
    else
    {
        //发起请求
        [request startRequest];
    }
    
}

#pragma mark -- get 开始请求
//向服务器发起请求的方法
- (void)startRequest
{
    if (_requestUrlString.length ==0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:_requestUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //http协议 get请求  请求方式 异步
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


#pragma mark - Post Request
+ (void)requestPOSTUrlString:(NSString *)urlStr andParamStr:(NSString *)paramStr target:(id)target action:(SEL)action andRefresh:(BOOL)refresh
{
    NSURLConnectionRequest *request = [[NSURLConnectionRequest alloc] init];
    request.requestUrlString = urlStr;
    request.target = target;
    request.aciton = action;
    
    // 增加缓存
    NSString *requestPath = [NSString stringWithFormat:@"%@/%@",[request getLoadPath],urlStr];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:requestPath]&&(refresh==NO))
    {
        NSData *data = [NSData dataWithContentsOfFile:requestPath];
        [request.downloadData setLength:0];
        [request.downloadData appendData:data];
        //让target执行action,同时传出request
        if ([request.target respondsToSelector:request.aciton])
        {
            [request.target performSelector:request.aciton withObject:request afterDelay:NO];
        }
    }
    else
    {
        //发起请求
        [request postRequest:paramStr];
    }
}

#pragma mark -- post 开始请求
- (void)postRequest:(NSString *)paramStr
{
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
    [postRequest setURL:[NSURL URLWithString:_requestUrlString]];
    [postRequest setHTTPMethod:@"POST"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
    [postRequest setHTTPBody:postBody];
    _urlConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
}


#pragma mark - 获取存储的data路径
- (NSString *)getLoadPath
{
    NSString *path = [NSString stringWithFormat:@"%@/Documents/NetData",NSHomeDirectory()];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}




#pragma mark - url Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //清空旧数据 ,200 ok  404/400/500
    [_downloadData setLength:0];
    // 标记总长度
    _sumLength = response.expectedContentLength;// 预计总长度
}


//接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_downloadData appendData:data];
    // 判断是否显示下载进度
    if (_showPercent)
    {
        NSInteger currentLength = _downloadData.length;
        NSInteger percent = currentLength*100/_sumLength;
        NSString *percentString = [NSString stringWithFormat:@"%ld%%",percent];
        if ([self.target respondsToSelector:_percentAction])
        {
            [self.target performSelector:_percentAction withObject:percentString afterDelay:0];
        }
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //接收完成
    // 存储数据
    NSString *dataPath = [NSString stringWithFormat:@"%@/%@",[self getLoadPath],self.requestUrlString];
    [_downloadData writeToFile:dataPath atomically:NO];
    
    if ([_target respondsToSelector:_aciton]) {
        //告知编译器 performSelector 没有问题
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_aciton withObject:self];
#pragma clang diagnostic pop
    }
}


//网络不好，或者请求失败时
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

}


@end
