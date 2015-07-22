//
//  Point_3_Section_Head_View.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Point_3_Section_Head_View.h"

@implementation Point_3_Section_Head_View


- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    
    _question_label.textAlignment = NSTextAlignmentLeft;
    _question_label.textColor = kText_Color;
    _question_label.numberOfLines = 0;
    _question_label.font = [UIFont systemFontOfSize:kFontSize_14];

    _markLabel.text = @"点击查看自己对此问题的回答如何吧";
    _markLabel.textAlignment = NSTextAlignmentLeft;
    _markLabel.textColor = [UIColor colorWithWhite:135/255.0 alpha:1];
    _markLabel.font = [UIFont systemFontOfSize:kFontSize_12];
    _lineLab.backgroundColor = [UIColor colorWithRed:240/255.0 green:245/255.0 blue:250/255.0 alpha:1];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
