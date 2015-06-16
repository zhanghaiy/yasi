//
//  FooterView.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "FooterView.h"

@implementation FooterView

- (void)awakeFromNib
{
    _selectedButton.layer.masksToBounds = YES;
    _selectedButton.layer.cornerRadius = _selectedButton.frame.size.height/2;
    _selectedButton.layer.borderColor = kPart_Button_Color.CGColor;
    _selectedButton.layer.borderWidth = 1;
    
    [_selectedButton setBackgroundColor:[UIColor whiteColor]];
    [_selectedButton setBackgroundImage:[UIImage imageNamed:@"selected_teacher"] forState:UIControlStateSelected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
