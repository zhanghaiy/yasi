//
//  ZipManager.m
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ZipManager.h"
#import "ZipArchive.h"
#import "JSONKit.h"
@implementation ZipManager

+ (void)unzipFileFromPath:(NSString *)fromPath ToPath:(NSString *)toPath
{
    NSLog(@"解压文件----ZipManager");
    ZipArchive* zip = [[ZipArchive alloc] init];
    
    if( [zip UnzipOpenFile:fromPath] )
    {
        BOOL ret = [zip UnzipFileTo:toPath overWrite:YES];
        if( NO==ret )
        {
            NSLog(@"UnzipOpenFailed");
        }
        else
        {
            NSLog(@"成功解压");
        }
        [zip UnzipCloseFile];
    }
    // 解压之后将zip文件删除
    [[NSFileManager defaultManager] removeItemAtPath:fromPath error:nil];
}

@end
