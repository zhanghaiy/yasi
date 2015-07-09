//
//  CustomProgressView.h
//  IELTS
//
//  Created by cocim01 on 15/5/13.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
   自定义进度条 ： 两个View构成  一个为底 一个根据进度变换
 */
@interface CustomProgressView : UIView

@property (nonatomic,strong) UIView * progressView;// 上面的 显示进度View

@property (nonatomic,assign) float progress;
@property (nonatomic,assign) UIColor *color;

- (void)setProVProgress:(NSNumber*)progress;

@end
