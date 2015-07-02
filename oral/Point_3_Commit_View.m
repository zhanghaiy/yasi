//
//  Point_3_Commit_View.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Point_3_Commit_View.h"

@implementation Point_3_Commit_View


- (void)awakeFromNib
{
    _commit_des_Label.textAlignment = NSTextAlignmentLeft;
    _commit_des_Label.textColor = kText_Color;
    _commit_des_Label.font = [UIFont systemFontOfSize:kFontSize_14];
    _commit_des_Label.numberOfLines = 0;
    
    _commit_Button.layer.masksToBounds = YES;
    _commit_Button.layer.cornerRadius = _commit_Button.frame.size.height/2.0;
    _commit_Button.backgroundColor = kPart_Button_Color;
    _commit_Button.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
