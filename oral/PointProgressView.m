//
//  PointProgressView.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PointProgressView.h"

@implementation PointProgressView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = kPart_Button_Color;
    _timeLAbel.textColor = kPart_Button_Color;
    _progressLabel.textColor = kPart_Button_Color;
    _progressV.progress = 0.0;
    _progressV.color = kPart_Button_Color;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
