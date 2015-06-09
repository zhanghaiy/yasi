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

+ (void)requestWithUrlString:(NSString *)urlStr target:(id)target aciton:(SEL)aciton andRefresh:(BOOL)isRefresh
{
    NSURLConnectionRequest *request = [[NSURLConnectionRequest alloc] init];
    request.requestUrlString = urlStr;
    request.target = target;
    request.aciton = aciton;
    //发起请求
    [request startRequest];
}

+ (void)requestPOSTUrlString:(NSString *)urlStr andParamStr:(NSString *)paramStr target:(id)target action:(SEL)action andRefresh:(BOOL)refresh
{
    NSURLConnectionRequest *request = [[NSURLConnectionRequest alloc] init];
    request.requestUrlString = urlStr;
    request.target = target;
    request.aciton = action;
    //发起请求
    [request postRequest:paramStr];
    
}

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



#pragma mark - url Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //清空旧数据 ,200 ok  404/400/500
    [_downloadData setLength:0];
}


//收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_downloadData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //接收完成
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
    NSLog(@"~~~~~~~%@",error.localizedDescription);
    NSLog(@"!!!!!!!!!!%@~~~~~~~~~~~~~~~",error.localizedFailureReason);

    NSLog(@"error!!");
}


@end
