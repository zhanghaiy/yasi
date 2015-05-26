//
//  ZipManager.h
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipManager : NSObject

// 解压
+ (void)unzipFileFromPath:(NSString *)fromPath ToPath:(NSString *)toPath;


@end
