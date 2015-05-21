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

@property (nonatomic,strong) UIView *navTopView;// 模拟导航栏背景
@property (nonatomic,strong) UILabel *lineLab;
@property (nonatomic,strong) UILabel *titleLab; //  标题控件 
// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName;
// titleLabel
- (void)addTitleLabelWithTitleWithTitle:(NSString *)title;


@end
