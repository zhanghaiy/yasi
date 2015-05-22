//
//  CircleProgressView.h
//  oral
//
//  Created by cocim01 on 15/5/22.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressView : UIView

@property (nonatomic,strong) CAShapeLayer *shapeLayer;

- (void)settingProgress:(CGFloat)progress andColor:(UIColor *)progressColor andWidth:(int)width andCircleLocationWidth:(NSInteger)locationWidth;

@end
