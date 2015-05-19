//
//  TopicParentsViewController.m
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface TopicParentsViewController ()

@end

@implementation TopicParentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 44)];
    _navTopView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navTopView];
    
    UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, kScreentWidth, 1)];
    lineLab.backgroundColor = [UIColor colorWithRed:231/255.0 green:238/255.0 blue:239/255.0 alpha:1];
    [self.view addSubview:lineLab];
}

// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 47, 44)];
    [backButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPrePage) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:backButton];
}

- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

// titleLabel
- (void)addTitleLabelWithTitleWithTitle:(NSString *)title
{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 2, kScreentWidth-60*2, 40)];
    _titleLab.textColor = [UIColor colorWithWhite:119/255.0 alpha:1];
    _titleLab.font = [UIFont systemFontOfSize:KOneFontSize];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.text = title;
    [self.navTopView addSubview:_titleLab];
}

// 右侧按钮
- (void)addRightButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(kScreentWidth-45, 7, 35, 35)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"touxiang.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(personCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:backButton];
}

- (void)personCenter
{
    // 个人中心
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
