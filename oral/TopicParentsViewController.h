//
//  TopicParentsViewController.h
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
     所有视图父类 --> 用于自定义导航栏
 */
@interface TopicParentsViewController : UIViewController
{
    UIColor *_backColor;// 老师外圈颜色 顶部按钮背景色 导航条颜色
    UIColor *_timeProgressColor;// 时间进度条颜色
    UIColor *_textColor;// 文字颜色
    UIColor *_pointColor;// 闯关页part按钮颜色
}
@property (nonatomic,strong) UIView *navTopView;// 模拟导航栏背景
@property (nonatomic,strong) UILabel *lineLab;
@property (nonatomic,strong) UILabel *titleLab; //  标题控件

// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName;
// titleLabel
- (void)addTitleLabelWithTitleWithTitle:(NSString *)title;
// 返回上一页
- (void)backToPrePage;

@end
