//
//  NSString+CalculateStringSize.h
//  oral
//
//  Created by cocim01 on 15/5/29.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (CalculateStringSize)

+ (CGRect)CalculateSizeOfString:(NSString *)text Width:(NSInteger)width Height:(NSInteger)height FontSize:(NSInteger)fontSize;

@end
