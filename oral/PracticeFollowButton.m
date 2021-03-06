//
//  PracticeFollowButton.m
//  oral
//
//  Created by cocim01 on 15/6/18.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PracticeFollowButton.h"

@implementation PracticeFollowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"Practise_follow_s"] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"Practise_follow"] forState:UIControlStateNormal];
        [self drawShapeLayer];
    }
    return self;
}

- (void)awakeFromNib
{
    [self drawShapeLayer];
}

- (void)drawShapeLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    
    shapeLayer.cornerRadius = self.frame.size.height/2;
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

- (void)settingProgress:(CGFloat)progress andColor:(UIColor *)progressColor andWidth:(int)width andCircleLocationWidth:(NSInteger)locationWidth
{
    self.shapeLayer.lineWidth = width;
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                          radius:self.bounds.size.width/2-locationWidth
                                                      startAngle:3*M_PI_2
                                                        endAngle:3*M_PI_2 + 2*M_PI
                                                       clockwise:YES].CGPath;
    
    self.shapeLayer.strokeEnd = progress;
    self.shapeLayer.strokeColor = progressColor.CGColor;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
