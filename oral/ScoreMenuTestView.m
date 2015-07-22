//
//  ScoreMenuTestView.m
//  oral
//
//  Created by cocim01 on 15/5/27.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreMenuTestView.h"

@implementation ScoreMenuTestView

- (void)awakeFromNib
{
    _contentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.cornerRadius = _contentView.bounds.size.height/2;
    _playButton.layer.masksToBounds = YES;
    _playButton.layer.cornerRadius = _playButton.bounds.size.height/2;
    [_playButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    _timeBackLabel.backgroundColor = [UIColor whiteColor];
}

- (void)setProgress:(float)progress
{
    NSInteger sumTimeWid = kScreentWidth-155;// 时间控件长度
    _progress = progress;
    CGRect rect = _timeLabel.frame;
    rect.size.width = sumTimeWid*progress;
    [_timeLabel setFrame:CGRectMake(50, 18, 100, 4)];// frame = rect;
    [self bringSubviewToFront:_timeLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
