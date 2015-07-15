//
//  TopicParentsViewController.h
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KNavTopViewHeight 64

/*
     所有视图父类 --> 用于自定义导航栏
 */
@interface TopicParentsViewController : UIViewController
{
    UIColor *_titleTextColor;
    UIColor *_backColor;// 老师外圈颜色 顶部按钮背景色 导航条颜色
    UIColor *_timeProgressColor;// 时间进度条颜色
    UIColor *_textColor;// 文字颜色
    UIColor *_pointColor;// 闯关页part按钮颜色
    UIColor *_backgroundViewColor;
    
    UIColor *_perfColor;// 80~100
    UIColor *_goodColor;// 60~80
    UIColor *_badColor;// 0~60
    
    UIView *_loading_View;
}
@property (nonatomic,strong) UIView *navTopView;// 模拟导航栏背景
@property (nonatomic,strong) UILabel *lineLab;
@property (nonatomic,strong) UILabel *titleLab; //  标题控件

@property (nonatomic,copy) NSString *pageTitleString;
// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName;
// titleLabel
- (void)addTitleLabelWithTitle:(NSString *)title;
// 返回上一页
- (void)backToPrePage;

- (NSString *)getPathWithTopic:(NSString *)topicName IsPart:(BOOL)isPart;
- (void)changeLoadingViewPercentTitle:(NSString *)title;

@end
