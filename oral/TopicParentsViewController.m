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
    _textColor = [UIColor colorWithWhite:135/255.0 alpha:1];
    _pointColor = [UIColor colorWithRed:35/255.0 green:222/255.0 blue:191/255.0 alpha:1];
    _backgroundViewColor = [UIColor colorWithRed:244/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    _badColor = [UIColor colorWithRed:255/255.0 green:63/255.0 blue:37/255.0 alpha:1];
    _perfColor = [UIColor colorWithRed:0 green:231/255.0 blue:136/255.0 alpha:1];
    _goodColor = [UIColor colorWithRed:250/255.0 green:220/255.0 blue:18/255.0 alpha:1];
    [self createLoadingView];
}

// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 24, 47, 44)];
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
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 26, kScreentWidth-60*2, 40)];
    _titleLab.textColor = _titleTextColor;
    _titleLab.font = [UIFont systemFontOfSize:kTitleFontSize];
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
    return NO; // 返回NO表示要显示，返回YES将hiden
}


- (NSString *)getPathWithTopic:(NSString *)topicName IsPart:(BOOL)isPart
{
    NSArray *sectionArr = @[@"topicTest",@"topicResource"];
    return [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@",topicName,[sectionArr objectAtIndex:isPart]];
}


- (void)changeLoadingViewTitle:(NSString *)title
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
    
    UIView *actionView = [[UIView alloc]initWithFrame:CGRectMake((kScreentWidth-200)/2, kScreenHeight/2-100, action_View_W, action_View_H)];
    actionView.layer.masksToBounds = YES;
    actionView.layer.cornerRadius = 5;
    actionView.layer.borderWidth = 1;
    actionView.layer.borderColor = kPart_Button_Color.CGColor;
    
    actionView.backgroundColor = [UIColor whiteColor];
    
    NSInteger action_W = 80;
    NSInteger tipLabel_H = 40;
    
    
//    UIActivityIndicatorView *action = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((action_View_W-action_W)/2, (action_View_H-action_W-tipLabel_H)/2, action_W, action_W)];
//    action.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [actionView addSubview:action];
//    [action startAnimating];
    
    UIImageView *loadingImgV = [[UIImageView alloc]initWithFrame:CGRectMake((action_View_W-action_W)/2, (action_View_H-action_W-tipLabel_H)/2, action_W, action_W)];
    loadingImgV.animationDuration = 2;
    loadingImgV.animationImages = @[[UIImage imageNamed:@"Loading_1"],[UIImage imageNamed:@"Loading_2"],[UIImage imageNamed:@"Loading_3"],[UIImage imageNamed:@"Loading_4"],[UIImage imageNamed:@"Loading_5"],[UIImage imageNamed:@"Loading_6"],[UIImage imageNamed:@"Loading_7"],[UIImage imageNamed:@"Loading_8"]];
    loadingImgV.animationRepeatCount = -1;
    [actionView addSubview:loadingImgV];
    [loadingImgV startAnimating];
    
    _tipLabel= [[UILabel alloc]initWithFrame:CGRectMake(0,action_W+loadingImgV.frame.origin.y, actionView.frame.size.width, tipLabel_H)];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = kPart_Button_Color;
    _tipLabel.font = [UIFont systemFontOfSize:kFontSize1];
    _tipLabel.numberOfLines = 0;
    [actionView addSubview:_tipLabel];
    
    actionView.center = _loading_View.center;
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
