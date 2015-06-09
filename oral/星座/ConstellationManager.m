//
//  ConstellationManager.m
//  IELTSSpeaking
//
//  Created by cocim01 on 15-2-12.
//  Copyright (c) 2015年 cocim01. All rights reserved.
//

#import "ConstellationManager.h"

@implementation ConstellationManager

#pragma mark - 判断星座
+(NSString *)getAstroWithMonth:(int)month day:(int)day
{
    
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    
    if (month<1||month>12||day<1||day>31){
        return @"错误日期格式!";
    }
    
    if(month==2 && day>29)
    {
        return @"错误日期格式!!";
    }else if(month==4 ||month==6 || month==9 || month==11) {
        
        if (day>30) {
            return @"错误日期格式!!!";
        }
    }
    
    result=[NSString stringWithFormat:@"%@座",[astroString substringWithRange:NSMakeRange(month*2-(day < [[astroFormat substringWithRange:NSMakeRange((month-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

+(NSString *)transformNSStringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc]init];//格式化
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

+(NSDate *)transformDateWithString:(NSString *)str
{
    NSString* string = @"2011-08-26";
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [inputFormatter dateFromString:string];
    return date;
}

@end
