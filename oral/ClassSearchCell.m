//
//  ClassSearchCell.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassSearchCell.h"

@implementation ClassSearchCell

- (void)awakeFromNib
{
    // Initialization code
    _classNameLabel.textColor = [UIColor colorWithWhite:115/255.0 alpha:1];
    _classCountsLabel.textColor = kText_Color;
    _classTeacherLabel.textColor = kText_Color;
    _classDesLabel.textColor = [UIColor colorWithWhite:150/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
