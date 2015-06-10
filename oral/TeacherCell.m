//
//  TeacherCell.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TeacherCell.h"

@implementation TeacherCell

- (void)awakeFromNib {
    // Initialization code
    _lineLabel_down.backgroundColor = [UIColor colorWithRed:240/255.0 green:249/255.0 blue:250/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
