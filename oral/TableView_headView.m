//
//  TableView_headView.m
//  oral
//
//  Created by cocim01 on 15/5/27.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TableView_headView.h"

@implementation TableView_headView

- (void)awakeFromNib
{
    _commitButton.layer.cornerRadius = _commitButton.bounds.size.height/2;
    _commitButton.backgroundColor = [UIColor colorWithRed:78/255.0 green:235/255.0 blue:137/255.0 alpha:1];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _titleLabel.textColor = [UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1];
    
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
