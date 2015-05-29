//
//  NSString+CalculateStringSize.m
//  oral
//
//  Created by cocim01 on 15/5/29.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "NSString+CalculateStringSize.h"


@implementation NSString (CalculateStringSize)

+ (CGRect)CalculateSizeOfString:(NSString *)text Width:(NSInteger)width Height:(NSInteger)height FontSize:(NSInteger)fontSize
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return rect;
}

@end
