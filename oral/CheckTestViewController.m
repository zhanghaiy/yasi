//
//  CheckTestViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckTestViewController.h"

@interface CheckTestViewController ()
{
    CGRect _tea_head_big_frame;// 中心 放大后的
    CGRect _tea_head_small_frame;// 中心 缩小的
    CGRect _tea_head_small_frame_left;// 左侧位置
    
    CGRect _stu_head_big_frame;
    CGRect _stu_head_small_frame;
    
    NSTimer *_mainTimer;// 总时间定时器
    NSTimer *_aloneTimer;// 每个问题回答时间定时器
    NSInteger _aloneCounts;
}
@end

@implementation CheckTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _aloneCounts = 0;
    // 返回按钮
    [self addTitleLabelWithTitleWithTitle:@"直接模考"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self uiConfig];

}

- (void)createTopCountProgressButtonWithArray:(NSArray *)array
{
    for (int i = 0; i < 3; i ++)
    {
        for (int j = 0; j < 5; j ++)
        {
            UIButton *spotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置初始位置 中心 缩小的 （然后放大）
    [_teaHeadBtn setFrame:_tea_head_small_frame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _tipLabel.text = @"考试即将开始~请集中注意力~~";
    [self TextAnimation];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
}

#pragma mark - 文字动画
- (void)TextAnimation
{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_tipLabel cache:YES];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
}


#pragma mark - 准备提问
- (void)prepareTestQuestion
{
    // 中心 放大后的frame
    _teaHeadBtn.alpha = 1;

    [UIView animateWithDuration:2 animations:^{
        
        [_teaHeadBtn setFrame:_tea_head_big_frame];
    }];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(playTestQuestion) userInfo:nil repeats:NO];
}

#pragma mark - 播放问题音频
- (void)playTestQuestion
{
    _tipLabel.text = @"正在提问...";
    // 展示动画
    [self startAnimotion];
    // 播放音频
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(playQuestionCallBack) userInfo:nil repeats:NO];
}


#pragma mark - 结束提问
- (void)endQuestion
{
    [UIView animateWithDuration:1 animations:^{
        [_teaHeadBtn setFrame:_tea_head_small_frame];
        _teaHeadBtn.alpha = 0.5;
        _tipLabel.text = @"准备回答问题~~";
        [self TextAnimation];
    }];
}

#pragma mark - 问题结束 回答开始
- (void)playQuestionCallBack
{
    //
    [self stopAnimotion];
//    [self endQuestion];
    // 开始回答
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareAnswerTest) userInfo:nil repeats:NO];
}

- (void)prepareAnswerTest
{
    [UIView animateWithDuration:1 animations:^{
        [_stuHeadBtn setFrame:_stu_head_big_frame];
        _stuHeadBtn.alpha = 1;
    }];
    _tipLabel.text = @"请作答~";
    [self TextAnimation];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
}

#pragma mark - 开始回答
- (void)startAnswer
{
    _followBtn.hidden = NO;
    [self followButtonClicked:_followBtn];

}

- (void)answerTimeDecrease
{
    _aloneCounts++;
    float tip = 1.0/20/10.0*_aloneCounts;
    [_circleProgressView settingProgress:tip andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
}

#pragma mark - ui配置
- (void)uiConfig
{
    // 调整背景颜色
    _teaBackView.backgroundColor = [UIColor clearColor];
    _stuBackView.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.textColor = [UIColor colorWithRed:139/255.0 green:185/255.0 blue:200/255.0 alpha:1];
    _tipLabel.textColor = [UIColor colorWithRed:1/255.0 green:196/255.0 blue:255.0/255.0 alpha:1];
    _tipLabel.backgroundColor = [UIColor clearColor];
    
    // 调整位置 记录大小
    
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    
    // 提问界面
    float tea_back_View_height = _teaBackView.frame.size.height;
    _teaBackView.frame = CGRectMake(0, 131, kScreentWidth, tea_back_View_height);
    
    // 中心 缩小后的frame
    _tea_head_small_frame = CGRectMake((kScreentWidth-45)/2, (tea_back_View_height-45)/2, 45, 45);
    // 中心 放大后的frame
    _tea_head_big_frame = CGRectMake((kScreentWidth-65)/2, (tea_back_View_height-65)/2, 65, 65);//_tea_head_big_frame;
    
    // 左边 缩小后的frame
    _tea_head_small_frame_left =_tea_head_small_frame;
    _tea_head_small_frame_left.origin.x = 15;
    
    // 设置初始位置 中心 缩小的 （然后放大）
    [_teaHeadBtn setFrame:_tea_head_small_frame];
    
    // 学生界面
    CGRect stu_middle_rect = _stuHeadBtn.frame;
    // 缩小时的frame
    _stu_head_small_frame = stu_middle_rect;
    _stu_head_small_frame.origin.x = (kScreentWidth-_stu_head_small_frame.size.width)/2;
    // 放大时的frame
    _stu_head_big_frame = _stu_head_small_frame;
    _stu_head_big_frame.origin.x -= 10;
    _stu_head_big_frame.origin.y -= 10;
    _stu_head_big_frame.size.width += 20;
    _stu_head_big_frame.size.height += 20;
    
    
    // 设置圆角半径
//    _teaHeadBtn.layer.masksToBounds = YES;
//    _teaHeadBtn.layer.cornerRadius = _teaHeadBtn.frame.size.height/2;
    
    _followBtn.layer.masksToBounds = YES;
    _followBtn.layer.cornerRadius = _followBtn.frame.size.height/2;
    
    _stuHeadBtn.layer.masksToBounds = YES;
    _stuHeadBtn.layer.cornerRadius = _stuHeadBtn.frame.size.height/2;
    
    // 设置初始界面元素 隐藏特定的控件
    _teaCircleImageView.hidden = YES;// 仿声波动画控件
    _teaDesLabel.hidden = YES;// 关键词提示控件
    _followBtn.hidden = YES;// 跟读按钮
    
    // 设置文字
    _tipLabel.text = @"";
    
    _teaHeadBtn.alpha = 0.5;
    _stuHeadBtn.alpha = 0.5;
    
    // 光圈动画
    _teaCircleImageView.animationImages = @[[UIImage imageNamed:@"circle_1"],[UIImage imageNamed:@"circle_2"],[UIImage imageNamed:@"circle_3"]];
    _teaCircleImageView.animationDuration = 1.5;
    _teaCircleImageView.animationRepeatCount = 0;
    
    // 时间进度
    _circleProgressView.hidden = YES;
    _circleProgressView.backgroundColor = [UIColor clearColor];
    [_circleProgressView settingProgress:0.0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
}

#pragma mark - 开始光圈动画
- (void)startAnimotion
{
    _teaCircleImageView.hidden = NO;
    [_teaCircleImageView startAnimating];
}
#pragma mark - 结束光圈动画
- (void)stopAnimotion
{
    _teaCircleImageView.hidden = YES;
    [_teaCircleImageView stopAnimating];
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

- (void)recordFinished
{
    // 录音完成 判断进行下一题 或下一关卡
    // 目前测界面逻辑 手动连接
    
    [self answerEnd];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
}

- (void)answerEnd
{
    _followBtn.hidden = YES;
    _circleProgressView.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        _stuHeadBtn.frame = _stu_head_small_frame;
    }];
    _stuHeadBtn.alpha = 0.5;
}

- (IBAction)followButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected = NO;
        //结束录音
        [_aloneTimer invalidate];
        _aloneTimer = nil;
        [self recordFinished];
    }
    else
    {
        btn.selected = YES;
        // 开始录音
        _circleProgressView.hidden = NO;
        _aloneTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(answerTimeDecrease) userInfo:nil repeats:YES];
    }
}
@end
