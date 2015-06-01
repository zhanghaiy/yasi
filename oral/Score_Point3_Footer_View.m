//
//  Score_Point3_Footer_View.m
//  oral
//
//  Created by cocim01 on 15/6/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Score_Point3_Footer_View.h"

@implementation Score_Point3_Footer_View

- (void)awakeFromNib
{
    _spotImgV.layer.masksToBounds = YES;
    _spotImgV.layer.cornerRadius = _spotImgV.frame.size.height/2;
    
    _reviewBackV.layer.masksToBounds = YES;
    _reviewBackV.layer.cornerRadius = _reviewBackV.frame.size.height/2;
    
    _reviewBackV.backgroundColor = kPart_Button_Color;
    _spotImgV.backgroundColor = kPart_Button_Color;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
