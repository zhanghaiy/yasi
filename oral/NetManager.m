//
//  NetManager.m
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "NetManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation NetManager


//static NetManager *manager;
//+ (NetManager *)getNetManager
//{
//    if (manager == nil)
//    {
//        manager = [[NetManager alloc]init];
//    }
//    return manager;
//}

- (void)netPostUrl:(NSString *)urlString andParameters:(NSDictionary *)parameDict
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //发送请求
    [manager POST:urlString parameters:parameDict success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"JSON: %@", responseObject);
        self.success = YES;
        _downLoadData = operation.responseData;
        [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSLog(@"Error: %@", error);
        self.success = NO;
        [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
    }];
}

- (void)netGetUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.success = YES;
         self.downLoadData = operation.responseData;
         [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];

         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         self.success = NO;
         NSLog(@"AFHttpRequestOperation错误");
         [self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
     }];
    
    NSOperationQueue*queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

@end
