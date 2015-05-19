//
//  CustomProgressView.h
//  IELTS
//
//  Created by cocim01 on 15/5/13.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgressView : UIView

@property (nonatomic,strong) UIView * progressView;

@property (nonatomic,assign) float progress;
@property (nonatomic,assign) UIColor *color;

@end
