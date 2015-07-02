//
//  Point_3_Review_Head_View.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Point_3_Review_Head_View.h"

@implementation Point_3_Review_Head_View

- (void)awakeFromNib
{
    _review_score_button.layer.masksToBounds = YES;
    _review_score_button.layer.cornerRadius = _review_score_button.frame.size.height/2.0;
    _review_score_button.backgroundColor = kPart_Button_Color;
    _review_desLabel.text = @"老师给你综合评价喽~快点开看看吧~~";
    _review_desLabel.textAlignment = NSTextAlignmentLeft;
    _review_desLabel.textColor = kPart_Button_Color;
    _review_desLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    _review_desLabel.numberOfLines = 0;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
