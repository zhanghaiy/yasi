//
//  DetectionNetWorkState.h
//  oral
//
//  Created by cocim01 on 15/7/3.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface DetectionNetWorkState : NSObject
+ (BOOL)IsEnableWIFI;
+ (BOOL)IsEnable3G;
+ (NetworkStatus)netStatus;
@end
