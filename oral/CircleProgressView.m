//
//  CircleProgressView.m
//  oral
//
//  Created by cocim01 on 15/5/22.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CircleProgressView.h"

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self drawShapeLayer];
    }
    return self;
}

- (void)drawShapeLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    
    shapeLayer.cornerRadius = 45;
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
