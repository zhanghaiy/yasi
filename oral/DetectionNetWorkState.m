//
//  DetectionNetWorkState.m
//  oral
//
//  Created by cocim01 on 15/7/3.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "DetectionNetWorkState.h"


@implementation DetectionNetWorkState

// 是否wifi
+ (BOOL)IsEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G
+ (BOOL)IsEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

+ (NetworkStatus)netStatus
{
     Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    return [reach currentReachabilityStatus];
}

@end
