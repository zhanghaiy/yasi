//
//  CustomProgressView.m
//  IELTS
//
//  Created by cocim01 on 15/5/13.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self uiconfig];

    }
    return self;
}

- (void)awakeFromNib
{
    [self uiconfig];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self uiconfig];
    }
    return self;
}

- (void)uiconfig
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0;
    self.layer.cornerRadius = self.bounds.size.height/2;
    self.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _progressView = [[UIView alloc]initWithFrame:self.bounds];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _progressView.layer.cornerRadius = self.frame.size.height/2;
    _progressView.layer.cornerRadius = self.frame.size.height/2;
    [self addSubview:_progressView];
}

- (void)setProVProgress:(NSNumber*)progress
{
    _progress = progress.floatValue;
    
    NSInteger wid = _progress*self.frame.size.width;
    _progressView.frame = CGRectMake(0, 0, wid, self.frame.size.height);
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    NSInteger wid = _progress*self.frame.size.width;
    _progressView.frame = CGRectMake(0, 0, wid, self.frame.size.height);
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    _progressView.backgroundColor = _color;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    self.layer.cornerRadius = 10;
}

@end
