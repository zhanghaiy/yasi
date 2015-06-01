//
//  Score_Point3_TableHeaderView_commited.m
//  oral
//
//  Created by cocim01 on 15/6/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Score_Point3_TableHeaderView_commited.h"

@implementation Score_Point3_TableHeaderView_commited

- (void)awakeFromNib
{
    _titleLabel.text = @"老师给你综合评价楼~快快点开看看吧！";
    _titleLabel.textColor = kPart_Button_Color;
    _reviewImgV.backgroundColor = kPart_Button_Color;
    
    _scoreButton.layer.masksToBounds = YES;
    _scoreButton.layer.cornerRadius = _scoreButton.bounds.size.height/2;
    _scoreButton.backgroundColor = kPart_Button_Color;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
