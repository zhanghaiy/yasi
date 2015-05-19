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
//    CGRect rect = _topicProgressV.frame;
//    NSLog(@"%f",rect.size.height);
//    _topicProgressV = [[CustomProgressView alloc]initWithFrame:rect];
    _topicProgressV.progress = 0.5;
    _topicProgressV.color = [UIColor colorWithRed:86/255.0 green:223/255.0 blue:189/255.0 alpha:1];
    [self.contentView addSubview:_topicProgressV];
    
    _topicTitle.textColor = [UIColor colorWithWhite:149/255.0 alpha:1];
}

-(void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    _topicProgressV.progress = 0.5;
    _topicProgressV.color = _progressColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
