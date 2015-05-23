//
//  ClassCell.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassCell.h"

@implementation ClassCell

- (void)awakeFromNib
{
    // Initialization code
    
    _lineLabel.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:250/255.0 alpha:1];
    _classCountLabel.textColor = [UIColor colorWithWhite:149/255.0 alpha:1];
    _classDesLabel.textColor = [UIColor colorWithWhite:149/255.0 alpha:1];
    _classTeacherLabel.textColor = [UIColor colorWithWhite:149/255.0 alpha:1];
    _classNameLabel.textColor = [UIColor colorWithRed:86/255.0 green:225/255.0 blue:189/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
