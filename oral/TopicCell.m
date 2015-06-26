//
//  TopicCell.m
//  IELTS
//
//  Created by cocim01 on 15/5/13.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicCell.h"

@implementation TopicCell

- (void)awakeFromNib
{
    // Initialization code    
    _topicTitle.textColor = [UIColor colorWithWhite:149/255.0 alpha:1];
}

-(void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
//    _topicProgressV.progress = 0.5;
    _topicProgressV.color = _progressColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
