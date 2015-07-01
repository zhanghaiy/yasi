//
//  Score_Point3_Section_View.m
//  oral
//
//  Created by cocim01 on 15/6/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Score_Point3_Section_View.h"

@implementation Score_Point3_Section_View

- (void)awakeFromNib
{
    _titleLAbel.numberOfLines = 0;
    _titleLAbel.textAlignment = NSTextAlignmentLeft;
    _titleLAbel.font = [UIFont systemFontOfSize:kFontSize_12];
    _titleLAbel.textColor = [UIColor colorWithWhite:135/255.0 alpha:1];
    
    _desLabel.text = @"点击查看自己对此问题的回答如何吧";
    _desLabel.textAlignment = NSTextAlignmentLeft;
    _desLabel.textColor = [UIColor colorWithWhite:135/255.0 alpha:1];
    _desLabel.font = [UIFont systemFontOfSize:kFontSize_12];
    
    _lineLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
