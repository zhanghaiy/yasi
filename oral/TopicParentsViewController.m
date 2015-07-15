//
//  TopicParentsViewController.m
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

#import "TPCCheckpointViewController.h"


@interface TopicParentsViewController ()
{
    UILabel *_tipLabel;
}
@end

@implementation TopicParentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    
    _navTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, KNavTopViewHeight)];
    _navTopView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navTopView];
    
    _lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight, kScreentWidth, 1)];
    _lineLab.backgroundColor = [UIColor colorWithRed:231/255.0 green:238/255.0 blue:239/255.0 alpha:1];
    [self.view addSubview:_lineLab];
    
    
    _titleTextColor = [UIColor colorWithWhite:91/255.0 alpha:1];
    _backColor = [UIColor colorWithRed:128/255.0 green:230/255.0 blue:209/255.0 alpha:1];
    _timeProgressColor = [UIColor colorWithRed:245/255.0 green:88/255.0 blue:62/255.0 alpha:1];
    _textColor = kText_Color;//[UIColor colorWithWhite:135/255.0 alpha:1];
    _pointColor = [UIColor colorWithRed:35/255.0 green:222/255.0 blue:191/255.0 alpha:1];
    _backgroundViewColor = [UIColor colorWithRed:244/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    _badColor = [UIColor colorWithRed:255/255.0 green:63/255.0 blue:37/255.0 alpha:1];
    _perfColor = [UIColor colorWithRed:0 green:231/255.0 blue:136/255.0 alpha:1];
    _goodColor = [UIColor colorWithRed:255/255.0 green:170/255.0 blue:6/255.0 alpha:1];
    [self createLoadingView];
}

#pragma mark - 设置返回按钮样式
- (void)addBackButtonWithImageName:(NSString *)imageName
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 24, 47, 44)];
    [backButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPrePage) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:backButton];
}

#pragma mark - 返回上一页
- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建titleLabel
- (void)addTitleLabelWithTitle:(NSString *)title
{
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 26, kScreentWidth-60*2, 40)];
    _titleLab.textColor = _titleTextColor;
    _titleLab.font = [UIFont systemFontOfSize:kTitleFontSize_17];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.text = title;
    [self.navTopView addSubview:_titleLab];
}

#pragma mark - 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return NO; // 返回NO表示要显示，返回YES将hiden
}

#pragma mark - 获取路径 闯关 or 模考
- (NSString *)getPathWithTopic:(NSString *)topicName IsPart:(BOOL)isPart
{
    NSArray *sectionArr = @[@"topicTest",@"topicResource"];
    return [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@",topicName,[sectionArr objectAtIndex:isPart]];
}

#pragma mark - loadingView
- (void)changeLoadingViewPercentTitle:(NSString *)title
{
    _tipLabel.text = title;
}

- (void)createLoadingView
{
    _loading_View = [[UIView alloc]initWithFrame:self.view.bounds];
    _loading_View.hidden = YES;
    _loading_View.backgroundColor = [UIColor colorWithWhite:100/255.0 alpha:0.2];
    
    NSInteger action_View_W = 300.0/375.0*kScreentWidth;
    NSInteger action_View_H = 200.0/667.0*kScreenHeight;
    
    UIView *actionView = [[UIView alloc]initWithFrame:CGRectMake((kScreentWidth-action_View_W)/2, kScreenHeight/2-100, action_View_W, action_View_H)];
    actionView.layer.masksToBounds = YES;
    actionView.layer.cornerRadius = 5;
    actionView.layer.borderWidth = 1;
    actionView.layer.borderColor = kPart_Button_Color.CGColor;
    actionView.backgroundColor = [UIColor whiteColor];
    
    // 动画等明天美工出图 再完善  宽高有待调整
    NSInteger loadingImgV_W = 219;
    NSInteger loadingImgV_H = 114;
    NSInteger loadingImgV_Y = (action_View_H-loadingImgV_H)/2;
    NSInteger loadingImgV_X = (action_View_W-loadingImgV_W)/2;
    
    NSInteger loadingLabel_H = 30;
    NSInteger loadingLabel_W = loadingImgV_W-30;
    NSInteger loadingLabel_X = (action_View_W-loadingLabel_W)/2;
    NSInteger loadingLabel_Y = (action_View_H - loadingLabel_H)/2;
    
    UIImageView *loadingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(loadingImgV_X, loadingImgV_Y, loadingImgV_W, loadingImgV_H)];
    loadingImgV.animationDuration = 1;
    loadingImgV.animationImages = @[[UIImage imageNamed:@"loading"]];
    loadingImgV.animationRepeatCount = -1;
    [actionView addSubview:loadingImgV];
    [loadingImgV startAnimating];
    
    _tipLabel= [[UILabel alloc]initWithFrame:CGRectMake(loadingLabel_X,loadingLabel_Y, loadingLabel_W, loadingLabel_H)];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = kPart_Button_Color;
    _tipLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    _tipLabel.numberOfLines = 0;
    _tipLabel.text = @"加载中...";
    [actionView addSubview:_tipLabel];
    
    [_loading_View addSubview:actionView];
    [self.view addSubview:_loading_View];
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
