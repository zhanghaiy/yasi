//
//  NetManager.h
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetManager : NSObject
//+ (NetManager *)getNetManager;
- (void)netPostUrl:(NSString *)urlString andParameters:(NSDictionary *)parameDict;
- (void)netGetUrl:(NSString *)urlString;

@property (nonatomic,strong) NSData *downLoadData;
@property (nonatomic,assign) BOOL success;
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;

@end
