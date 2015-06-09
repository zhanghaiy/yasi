//
//  ConstellationManager.h
//  IELTSSpeaking
//
//  Created by cocim01 on 15-2-12.
//  Copyright (c) 2015年 cocim01. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConstellationManager : NSObject

+(NSString *)getAstroWithMonth:(int)month day:(int)day;
+(NSString *)transformNSStringWithDate:(NSDate *)date;
+(NSDate *)transformDateWithString:(NSString *)str;

@end
