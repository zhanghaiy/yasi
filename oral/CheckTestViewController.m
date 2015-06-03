//
//  CheckTestViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckTestViewController.h"
#import "AudioPlayer.h"


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
    
    NSArray *_partListArray;// 总的数据
    
    NSInteger _sum_part_Counts;
    NSInteger _sum_question_Counts;

    NSInteger _current_part_Counts;
    NSInteger _current_question_Counts;
    
    NSDictionary *_currentQuestionDict;
    NSDictionary *_partQuestionDict;
    
    AudioPlayer *_audioManager;
    NSInteger _prepareTime_point2;// 第二关准备时间
    
    BOOL _isFirst;// 用于总倒计时
    NSDate *_beginDate;// 设置开始时间
}
@end

@implementation CheckTestViewController

#define kPartButtonTag 1000

- (void)LocalData
{
    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"mockinfo" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *testDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    _partListArray = [[testDic objectForKey:@"mockquestion"] objectForKey:@"questionlist"];
    _sum_part_Counts = _partListArray.count;
}

#pragma mark - 切换单个问题数据
- (void)makeUpCurrentQuestionData
{
    _currentQuestionDict = [[[_partListArray objectAtIndex:_current_part_Counts] objectForKey:@"question"] objectAtIndex:_current_question_Counts];
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag + (_current_question_Counts+1)];
}

#pragma mark - 切换part 问题数据
- (void)makeUpCurrentPartData
{
    _partQuestionDict = [_partListArray objectAtIndex:_current_part_Counts];
    _sum_question_Counts = [[_partQuestionDict objectForKey:@"question"] count];
    _current_question_Counts = 0;
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag];
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag + (_current_question_Counts+1)];
}

#pragma mark - 创建标记问题进行情况的View
- (void)createTopCountProgressButtonWithArray:(NSArray *)array
{
    NSInteger org_y = _topBackView.frame.size.height;
    NSInteger btn_big_Height = 30;
    NSInteger btn_small_height = 10;
    
    NSInteger org_x = 15;// 从15开始
    for (int i = 0; i < _partListArray.count; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(org_x, (org_y-btn_big_Height)/2, btn_big_Height, btn_big_Height)];
        [btn setBackgroundImage:[UIImage imageNamed:@"Test_Top_blue"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"Test_Top_white"] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:1/255.0 green:196/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.tag = kPartButtonTag + i * 100;
        [_topBackView addSubview:btn];
        
        org_x += btn_big_Height+10;
        
        NSArray *questionArray = [[_partListArray objectAtIndex:i] objectForKey:@"question"];
        for (int j = 0; j < questionArray.count; j++)
        {
            UIButton *btn_spot = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn_spot setFrame:CGRectMake(org_x+j*(btn_small_height+10), (org_y-btn_small_height)/2, btn_small_height, btn_small_height)];
            [btn_spot setBackgroundImage:[UIImage imageNamed:@"Test_Top_blue"] forState:UIControlStateSelected];
            [btn_spot setBackgroundImage:[UIImage imageNamed:@"Test_Top_white"] forState:UIControlStateNormal];
            btn_spot.tag = (j+1)+i*100+kPartButtonTag;
            [_topBackView addSubview:btn_spot];
        }
        org_x += questionArray.count*(btn_small_height+10);
    }
}

#pragma mark - 标记完成的问题
- (void)changePartButtonSelectedWithButttonTag:(NSInteger)tag
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:tag];
    btn.selected = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _aloneCounts = 0;
    _prepareTime_point2 = 6;
    // 返回按钮
    [self addTitleLabelWithTitleWithTitle:@"直接模考"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self uiConfig];
    
    [self LocalData];
    _topBackView.backgroundColor = [UIColor clearColor];
    [self createTopCountProgressButtonWithArray:nil];
    _current_part_Counts = 0;
    _current_question_Counts = 0;
    [self makeUpCurrentPartData];
    [self makeUpCurrentQuestionData];
    
    _audioManager = [AudioPlayer getAudioManager];
    _audioManager.target = self;
    _audioManager.action = @selector(playTestQuestioCallBack);
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
    _teaHeadBtn.layer.masksToBounds = YES;
    _teaHeadBtn.layer.cornerRadius = _teaHeadBtn.frame.size.height/2;
    
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
    _sumTimeLabel.text = @"10:00";
    
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
    
    _tea_show_btn.hidden = YES;
}

#pragma mark - 视图已经出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _tipLabel.text = [NSString stringWithFormat:@"第%ld轮考试马上开始~请集中注意力~~~~",_current_part_Counts+1];// @"考试马上开始~请集中注意力~~~~";
    [self TextAnimationWithView:_tipLabel];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sumTimeCountDownMethod) userInfo:nil repeats:YES];
}


#pragma mark - 准备提问动画
- (void)prepareTestQuestion
{
    // 1、中心 放大后的frame
    [UIView animateWithDuration:2 animations:^{
        
        [_teaHeadBtn setFrame:_tea_head_big_frame];
        _teaHeadBtn.alpha = 1;
    }];
    // 2、文字提示 即将开始提问
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showQuestionBeginTip) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(beginPlayQuestion) userInfo:nil repeats:NO];
}

#pragma mark - 显示提示文本
- (void)showQuestionBeginTip
{
    _tipLabel.text = @"老师开始提问，请注意听....";
    [self TextAnimationWithView:_tipLabel];
}

#pragma mark - 播放问题音频 开始提问
- (void)beginPlayQuestion
{
    _tipLabel.text = @"老师正在提问...";
    // 展示动画
    [self startAnimotion];
    NSString *audioName = [_currentQuestionDict objectForKey:@"url"];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:[[audioName componentsSeparatedByString:@"."] objectAtIndex:0] ofType:[[audioName componentsSeparatedByString:@"."] objectAtIndex:1]];
    [_audioManager playerPlayWithFilePath:audioPath];
}

#pragma mark - 结束提问动画
- (void)endQuestion
{
    // 1:文字动画
    _tipLabel.text = @"提问结束，准备回答....";
    [self TextAnimationWithView:_tipLabel];
    // 2: 缩小头像
    [UIView animateWithDuration:1 animations:^{
        [_teaHeadBtn setFrame:_tea_head_small_frame];
        _teaHeadBtn.alpha = 0.5;
    }];
    if (_current_part_Counts!=0)
    {
        
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(moveToLeft) userInfo:nil repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showKeyWordView) userInfo:nil repeats:NO];
    }
}


#pragma mark - 问题结束 回调
- (void)playTestQuestioCallBack
{
    [self stopAnimotion];
    // 1-->问题结束是动画
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(endQuestion) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(prepareAnswerTestAnimotion) userInfo:nil repeats:NO];
//    // 开始回答
//    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
}

#pragma mark - 准备回答动画
- (void)prepareAnswerTestAnimotion
{
    if (_current_part_Counts == 1)
    {
        // 有30“时间准备
        _tipLabel.text = @"此题根据关键词作答~~你有30\"的准备时间~~~";
        [self TextAnimationWithView:_tipLabel];
        _aloneTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(prepareTime) userInfo:nil repeats:YES];
    }
    else
    {
        // 1、放大 变亮
        _tipLabel.text = @"准备.....";
        [self TextAnimationWithView:_tipLabel];
        [UIView animateWithDuration:1 animations:^{
            [_stuHeadBtn setFrame:_stu_head_big_frame];
            _stuHeadBtn.alpha = 1;
        }];
        // 开始回答
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}

- (void)prepareTime
{
    _prepareTime_point2 --;
    if (_prepareTime_point2 == 5)
    {
        _tipLabel.text = @"准备时间即将结束~~";
        [self TextAnimationWithView:_tipLabel];
    }
    if (_prepareTime_point2 <= 0)
    {
        [_aloneTimer invalidate];
        _aloneTimer = nil;
        [UIView animateWithDuration:1 animations:^{
            [_stuHeadBtn setFrame:_stu_head_big_frame];
            _stuHeadBtn.alpha = 1;
        }];
        _tipLabel.text = @"请作答~~~~";
        [self TextAnimationWithView:_tipLabel];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}

#pragma mark - 开始回答
- (void)startAnswer
{
    _tipLabel.text = @"请作答~";

//    if (_current_part_Counts == 0)
//    {
//        _tipLabel.text = @"请作答~";
//    }
//    else if (_current_part_Counts == 1)
//    {
//        _tipLabel.text = @"根据关键词作答~";
//    }
//    else
//    {
//       _tipLabel.text = @"请作答~";
//    }
    //    [self TextAnimationWithView:_tipLabel];
    _followBtn.hidden = NO;
    [self followButtonClicked:_followBtn];
}

#pragma mark - 回答倒计时
- (void)answerTimeDecrease
{
    _aloneCounts++;
    float tip = 1.0/20/10.0*_aloneCounts;
    [_circleProgressView settingProgress:tip andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    if (tip>=1)
    {
        [_aloneTimer invalidate];
        _aloneTimer = nil;
        _followBtn.selected = NO;
        [self recordFinished];
    }
}


#pragma mark - 展示关键词
- (void)showKeyWordView
{
    switch (_current_part_Counts)
    {
        case 1:
        {
            // part2 左移 显示关键字
            _teaDesLabel.hidden = NO;
            _tea_show_btn.hidden = YES;
            // 显示关键词
            _teaDesLabel.text = @"Translation Translation Trans lationTran slation Transl ation Transl ationTranslatio nTrans latio nTransl ation Trans lation Translation Translation Trans lationTran slation Transl ation Transl ationTranslatio nTrans latio nTransl ation Trans lation";
        }
            break;
        case 2:
        {
            // part3 左移 点击显示问题
            _teaDesLabel.hidden = YES;
            _tea_show_btn.hidden = NO;
        }
            break;
        default:
            break;
    }

}

#pragma mark - 老师头像左移
- (void)moveToLeft
{
    [UIView animateWithDuration:1 animations:^{
        [_teaHeadBtn setFrame:_tea_head_small_frame_left];
        _teaHeadBtn.alpha = 0.5;
    }];
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

#pragma mark - 下一题
- (void)nextQuestion_test
{
    _current_question_Counts ++;
    if (_current_question_Counts<_sum_question_Counts)
    {
        // 下一问题
        [self makeUpCurrentQuestionData];
        _tipLabel.text = @"即将进入下一题...";
        [self TextAnimationWithView:_tipLabel];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeSelfViewFomal) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
    }
    else if (_current_question_Counts >= _sum_question_Counts)
    {
        // 下一关卡
        _current_part_Counts ++;
        _current_question_Counts = 0;
        if (_current_part_Counts<_sum_part_Counts)
        {
            // 判断进行下一题 或下一关卡
            [self TextAnimationWithView:self.view];
            _tipLabel.text =[NSString stringWithFormat:@"第%ld轮考试马上开始~请集中注意力~~~~",_current_part_Counts+1];// @"考试马上开始~请集中注意力~~~~";
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeSelfViewFomal) userInfo:nil repeats:NO];
            [self makeUpCurrentPartData];
            [self makeUpCurrentQuestionData];
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
        }
    }
}

#pragma mark - 录音反馈
- (void)recordFinished
{
    // 录音完成
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(answerEnd) userInfo:nil repeats:NO];
    // 目前测界面逻辑 手动连接
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(nextQuestion_test) userInfo:nil repeats:NO];
}

- (void)makeSelfViewFomal
{
    _teaDesLabel.hidden = YES;
    _tea_show_btn.hidden = YES;
    _tea_show_btn.selected = NO;
    _teaHeadBtn.frame = _tea_head_small_frame;
}

#pragma mark - 回答完毕之后的动画流程
- (void)answerEnd
{
    _tipLabel.text = @"当前问题回答完毕";
    _followBtn.hidden = YES;
    _circleProgressView.hidden = YES;
    [_circleProgressView settingProgress:0.0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    _aloneCounts = 0;
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

#pragma mark - 文字动画
- (void)TextAnimationWithView:(UIView *)view
{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    if ([view isKindOfClass:[UILabel class]])
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:YES];
    }
    else
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:view cache:YES];
    }
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
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

- (IBAction)showQuestionText:(id)sender
{
    
}

#pragma mark - 考试总时间倒计时
- (void)sumTimeCountDownMethod
{
    //    _sumTimerCount--;
    NSDate *today = [NSDate date];
    if (_isFirst==NO)
    {
        _beginDate = today;
        _isFirst = YES;
    }
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [[NSDateComponents alloc]init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    component = [currentCalendar components:unitFlags fromDate:_beginDate];
    
    NSInteger year = [component year];
    NSInteger month = [component month];
    NSInteger day = [component day];
    NSInteger hour = [component hour];
    NSInteger minute = [component minute]+10;
    NSInteger  second = [component second];
    
    NSDateComponents *todateComps = [[NSDateComponents alloc]init];
    [todateComps setYear:year];
    [todateComps setMonth:month];
    [todateComps setDay:day];
    [todateComps setHour:hour];
    [todateComps setMinute:minute];
    [todateComps setSecond:second];
    
    NSDate *todate = [currentCalendar dateFromComponents:todateComps];
    
    NSDateComponents *timeCha = [currentCalendar components:unitFlags fromDate:today toDate:todate options:0];
    
    NSString *title = [NSString stringWithFormat:@"%ld:%ld",[timeCha minute],[timeCha second]];
    
    _sumTimeLabel.text = title;
    if ([title isEqualToString:@"0:0"])
    {
        // 模考结束
        [_mainTimer invalidate];
        _mainTimer = nil;
        if (_aloneTimer)
        {
            [_aloneTimer invalidate];
            _aloneTimer = nil;
        }
    }
}

@end
