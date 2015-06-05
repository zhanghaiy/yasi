//
//  CheckTestViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckTestViewController.h"
#import "AudioPlayer.h"
#import "TPCCheckpointViewController.h"
#import "MyTeacherViewController.h"

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
    
    UIColor *_tip_text_Color;// 文字颜色
    
    BOOL _testFinished;
}
@end

@implementation CheckTestViewController

#define kPartButtonTag 1000
#define KLeftCommitButtonTag 8002
#define KRightCommitButtonTag 8001


#pragma mark - 构成数据
#pragma mark -- 解析本地json文件
- (void)LocalData
{
//    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"mockinfo" ofType:@"json"];
    NSString *jsonPath = [NSString stringWithFormat:@"%@/mockinfo.json",[self getFileBasePath]];
    NSLog(@"%@",jsonPath);
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *testDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    _partListArray = [[testDic objectForKey:@"mockquestion"] objectForKey:@"questionlist"];
    _sum_part_Counts = _partListArray.count;
}

#pragma mark -- 本地资源文件路径
- (NSString *)getFileBasePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicTest/temp",self.topicName];
    NSLog(@"%@",self.topicName);
    return path;
}

#pragma mark -- 本地录音文件路径
- (NSString *)getRecordSavePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicTest/AnswerFile",self.topicName];
    if (![[NSFileManager defaultManager]fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

#pragma mark -- 切换单个问题数据
- (void)makeUpCurrentQuestionData
{
    _currentQuestionDict = [[[_partListArray objectAtIndex:_current_part_Counts] objectForKey:@"question"] objectAtIndex:_current_question_Counts];
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag + (_current_question_Counts+1)];
}

#pragma mark -- 切换part 问题数据
- (void)makeUpCurrentPartData
{
    _partQuestionDict = [_partListArray objectAtIndex:_current_part_Counts];
    _sum_question_Counts = [[_partQuestionDict objectForKey:@"question"] count];
    _current_question_Counts = 0;
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag];
    [self changePartButtonSelectedWithButttonTag:_current_part_Counts*100+kPartButtonTag + (_current_question_Counts+1)];
}


#pragma mark - ui配置
#pragma mark -- 创建标记问题进行情况的View
- (void)createTopCountProgressButtonWithArray:(NSArray *)array
{
    NSInteger org_y = _topBackView.frame.size.height;
    NSInteger btn_big_Height = 25;
    NSInteger btn_small_height = 8;
    
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
        btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize2];
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
            btn_spot.titleLabel.font = [UIFont systemFontOfSize:kFontSize1+1];
            [_topBackView addSubview:btn_spot];
        }
        org_x += questionArray.count*(btn_small_height+10);
    }
}

#pragma mark -- 标记完成的问题
- (void)changePartButtonSelectedWithButttonTag:(NSInteger)tag
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:tag];
    btn.selected = YES;
}

#pragma mark -- 修改参数
- (void)uiConfig
{
    // 调整背景颜色
    _teaBackView.backgroundColor = [UIColor clearColor];
    _stuBackView.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.textColor = [UIColor colorWithRed:139/255.0 green:185/255.0 blue:200/255.0 alpha:1];
    _tipLabel.textColor = _tip_text_Color;
    _tipLabel.backgroundColor = [UIColor clearColor];
    
    _sumTimeLabel.textColor = _tip_text_Color;
    _teaDesLabel.textColor = _tip_text_Color;
//    _tea_show_btn.titleLabel.textColor = _tip_text_Color;
    [_tea_show_btn setTitleColor:_tip_text_Color forState:UIControlStateNormal];
    
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
    [_teaHeadImageV setFrame:_tea_head_small_frame];
    
    // 学生界面
    CGRect stu_middle_rect = _stuHeadImageV.frame;
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
    _teaHeadImageV.layer.masksToBounds = YES;
    _teaHeadImageV.layer.cornerRadius = _teaHeadImageV.frame.size.height/2;
    
    _followBtn.layer.masksToBounds = YES;
    _followBtn.layer.cornerRadius = _followBtn.frame.size.height/2;
    
    _stuHeadImageV.layer.masksToBounds = YES;
    _stuHeadImageV.layer.cornerRadius = _stuHeadImageV.frame.size.height/2;
    
    // 设置初始界面元素 隐藏特定的控件
    _teaCircleImageView.hidden = YES;// 仿声波动画控件
    _teaDesLabel.hidden = YES;// 关键词提示控件
    _followBtn.hidden = YES;// 跟读按钮
    
    // 设置文字
    _tipLabel.text = @"";
    _sumTimeLabel.text = @"10:00";
    
    _teaHeadImageV.alpha = 0.5;
    _stuHeadImageV.alpha = 0.5;
    
    // 光圈动画
    _teaCircleImageView.animationImages = @[[UIImage imageNamed:@"circle_1"],[UIImage imageNamed:@"circle_2"],[UIImage imageNamed:@"circle_3"]];
    _teaCircleImageView.animationDuration = 1.5;
    _teaCircleImageView.animationRepeatCount = 0;
    
    // 时间进度
    _circleProgressView.hidden = YES;
    _circleProgressView.backgroundColor = [UIColor clearColor];
    [_circleProgressView settingProgress:0.0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    
    _tea_show_btn.hidden = YES;
    
    [_stuHeadImageV setFrame:CGRectMake(30, 30, 40, 40)];
    
    
    // 提交按钮
    [_commitButtonLeft setBackgroundColor:_backgroundViewColor];
    [_commitButtonLeft setTitleColor:kPart_Back_Color forState:UIControlStateNormal];
    _commitButtonLeft.hidden = YES;
    _commitButtonLeft.tag = KLeftCommitButtonTag;
    
    [_commitButtonRight setBackgroundColor:_backgroundViewColor];
    [_commitButtonRight setTitleColor:kPart_Back_Color forState:UIControlStateNormal];
    _commitButtonRight.hidden = YES;
    _commitButtonRight.tag = KRightCommitButtonTag;
    
    _commitButtonLeft.layer.masksToBounds = YES;
    _commitButtonLeft.layer.cornerRadius = _commitButtonLeft.frame.size.height/2;
    
    _commitButtonRight.layer.masksToBounds = YES;
    _commitButtonRight.layer.cornerRadius = _commitButtonRight.frame.size.height/2;
}

#pragma mark - 视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _testFinished = NO;
    _aloneCounts = 0;
    _prepareTime_point2 = 6;
    _tip_text_Color = [UIColor colorWithRed:0 green:196/255.0 blue:255/255.0 alpha:1];
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


#pragma mark - 视图出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_testFinished == NO)
    {
        _tipLabel.text = [NSString stringWithFormat:@"第%ld轮考试马上开始~请集中注意力~~~~",_current_part_Counts+1];// @"考试马上开始~请集中注意力~~~~";
        [self TextAnimationWithView:_tipLabel];
        // 预留准备时间
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareTest) userInfo:nil repeats:NO];
    }
}


#pragma mark - 开始模考
- (void)prepareTest
{
    // 1、开启总时间的定时器
    _mainTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sumTimeCountDownMethod) userInfo:nil repeats:YES];
    
    [self prepareTestQuestion];
}
#pragma mark - 提问
- (void)prepareTestQuestion
{
    // 2、中心 放大后的frame
    [self enlargeTeacherHeadImage];
    // 3、告知用户即将提问
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showQuestionBeginTip) userInfo:nil repeats:NO];
    // 4、开始提问
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(beginPlayQuestion) userInfo:nil repeats:NO];
}



#pragma mark - 开始提问 播放问题
- (void)beginPlayQuestion
{
    _tipLabel.text = @"老师正在提问...";
    [self startAnimotion];
    
    NSString *audioName = [_currentQuestionDict objectForKey:@"url"];
    NSString *audioPath = [NSString stringWithFormat:@"%@/%@",[self getFileBasePath],audioName];
    [_audioManager playerPlayWithFilePath:audioPath];
}

#pragma mark - 播放问题结束 回调
- (void)playTestQuestioCallBack
{
    [self stopAnimotion];// 光圈停止
    
    // 1--> 问题结束 ----> 老师部分做一系列动画
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(endQuestion) userInfo:nil repeats:NO];
    
    // 2、学员准备回答 ----> 动画
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(prepareAnswerTest) userInfo:nil repeats:NO];
    //    // 开始回答
    //    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
}



#pragma mark - 准备回答 --> 动画
- (void)prepareAnswerTest
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
        // 提示标签
        _tipLabel.text = @"准备.....";
        [self TextAnimationWithView:_tipLabel];
        
        // 放大学生头像
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(enlargeStudentHeadImage) userInfo:nil repeats:NO];
        
        // 开始回答
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}

#pragma mark - 准备时间
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
        [self enlargeStudentHeadImage];
        _tipLabel.text = @"准备~~~~";
        [self TextAnimationWithView:_tipLabel];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}

#pragma mark - 开始回答
- (void)startAnswer
{
    _tipLabel.text = @"请作答~";
    _followBtn.hidden = NO;
    [self followButtonClicked:_followBtn];
}


#pragma mark - 回答按钮点击事件 开始录音
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

#pragma mark - 录音结束 回答完毕
- (void)recordFinished
{
    _followBtn.hidden = YES;
    // 录音完成
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(answerEnd) userInfo:nil repeats:NO];
    // 目前测界面逻辑 手动连接
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(nextQuestion_test) userInfo:nil repeats:NO];
}

#pragma mark - 下一题
- (void)nextQuestion_test
{
    _current_question_Counts ++;
    if (_current_question_Counts<_sum_question_Counts)
    {
        // 下一问题
        
        // 重组数据源
        [self makeUpCurrentQuestionData];
        _tipLabel.text = @"即将进入下一题...";
        [self TextAnimationWithView:_tipLabel];
        
        // 恢复最初
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeSelfViewFomal) userInfo:nil repeats:NO];
        
        // 准备下一题
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(prepareTestQuestion) userInfo:nil repeats:NO];
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
        else
        {
            _tipLabel.text = @"模考结束";
            [_mainTimer invalidate];
            _mainTimer = nil;
            _testFinished = YES;
            _commitButtonLeft.hidden = NO;
            _commitButtonRight.hidden = NO;
        }
    }
}

#pragma mark - 老师提问时 构建动画所用的方法
#pragma mark -- 放大
- (void)enlargeTeacherHeadImage
{
    _teaHeadImageV.alpha = 1;
    [UIView animateWithDuration:1 animations:^{
        _teaHeadImageV.frame = _tea_head_big_frame;
    }];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTeacherLayer) userInfo:nil repeats:NO];
}
#pragma mark -- 改变圆角半径
- (void)changeTeacherLayer
{
    _teaHeadImageV.layer.cornerRadius = _teaHeadImageV.frame.size.height/2;
}

//- (void)changeStudentLayer
//{
//    _stuHeadImageV.layer.cornerRadius = _stuHeadImageV.frame.size.height/2;
//}

#pragma mark -- 缩小
- (void)narrowTeacherHeadImage
{
    _teaHeadImageV.alpha = 0.5;
    [UIView animateWithDuration:1 animations:^{
        _teaHeadImageV.frame = _tea_head_small_frame;
        _teaHeadImageV.layer.cornerRadius = _teaHeadImageV.frame.size.height/2;
    }];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTeacherLayer) userInfo:nil repeats:NO];
}
#pragma mark -- 左移
- (void)moveTeacherHeadImageToLeft
{
    _teaHeadImageV.alpha = 0.5;
    [UIView animateWithDuration:1 animations:^{
        _teaHeadImageV.frame = _tea_head_small_frame_left;
    }];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTeacherLayer) userInfo:nil repeats:NO];
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


#pragma mark -- 开始光圈动画
- (void)startAnimotion
{
    _teaCircleImageView.hidden = NO;
    [_teaCircleImageView startAnimating];
}
#pragma mark -- 结束光圈动画
- (void)stopAnimotion
{
    _teaCircleImageView.hidden = YES;
    [_teaCircleImageView stopAnimating];
}

#pragma mark -- 展示关键词
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

#pragma mark -- 提问结束动画
- (void)endQuestion
{
    // 1:文字动画
    _tipLabel.text = @"提问结束，准备回答....";
    [self TextAnimationWithView:_tipLabel];
    // 2: 缩小头像
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(narrowTeacherHeadImage) userInfo:nil repeats:NO];
    if (_current_part_Counts!=0)
    {
        // 左移
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(moveTeacherHeadImageToLeft) userInfo:nil repeats:NO];
        // 展示关键词
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showKeyWordView) userInfo:nil repeats:NO];
    }
}

#pragma mark -- 告知用户 即将提问
- (void)showQuestionBeginTip
{
    _tipLabel.text = @"老师开始提问，请注意听....";
    [self TextAnimationWithView:_tipLabel];
}

#pragma mark - 学生准备回答一系列动画
#pragma mark -- 放大学生头像
- (void)enlargeStudentHeadImage
{
    [UIView animateWithDuration:1 animations:^{
        [_stuHeadImageV setFrame:_stu_head_big_frame];
        _stuHeadImageV.layer.cornerRadius = _stuHeadImageV.frame.size.height/2;
        _stuHeadImageV.alpha = 1;
    }];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeStudentLayer) userInfo:nil repeats:NO];
}

#pragma mark -- 缩小学生头像
- (void)narrowStudentHeadImage
{
    [UIView animateWithDuration:1 animations:^{
        [_stuHeadImageV setFrame:_stu_head_small_frame];
        _stuHeadImageV.alpha = 0.5;
        _stuHeadImageV.layer.cornerRadius = _stuHeadImageV.frame.size.height/2;
    }];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeStudentLayer) userInfo:nil repeats:NO];
}

#pragma mark -- 回答完毕之后的动画流程
- (void)answerEnd
{
    _tipLabel.text = @"当前问题回答完毕";
    _followBtn.hidden = YES;
    _circleProgressView.hidden = YES;
    [_circleProgressView settingProgress:0.0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    _aloneCounts = 0;
    [self narrowStudentHeadImage];
    _teaDesLabel.text = @"";
    _teaDesLabel.hidden = YES;    
}

#pragma mark -- 每个问题结束后 回到最开始的样子
- (void)makeSelfViewFomal
{
    [self narrowTeacherHeadImage];
    _teaDesLabel.hidden = YES;
    _tea_show_btn.hidden = YES;
    _tea_show_btn.selected = NO;
    _teaHeadImageV.frame = _tea_head_small_frame;
}

#pragma mark -- 显示问题文本
- (IBAction)showQuestionText:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected)
    {
        btn.hidden = YES;
        _teaDesLabel.hidden = NO;
        _teaDesLabel.text = [_currentQuestionDict objectForKey:@"question"];
        [self TextAnimationWithView:_teaDesLabel];
    }
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
    
    NSString *minuteString;
    if ([timeCha minute]<10)
    {
        minuteString = [NSString stringWithFormat:@"0%ld",[timeCha minute]];
    }
    else
    {
        minuteString = [NSString stringWithFormat:@"%ld",[timeCha minute]];
    }
    
    NSString *seconString;
    if ([timeCha second]<10)
    {
        seconString = [NSString stringWithFormat:@"0%ld",[timeCha second]];
    }
    else
    {
        seconString = [NSString stringWithFormat:@"%ld",[timeCha second]];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@:%@",minuteString,seconString];
    
    _sumTimeLabel.text = title;
    if ([title isEqualToString:@"00:00"])
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

- (void)didReceiveMemoryWarning
{
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

- (IBAction)commitButtonClicked:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == KLeftCommitButtonTag)
    {
        // 稍后提交
        [self backToTopicPage];
    }
    else if (btn.tag == KRightCommitButtonTag)
    {
        // 现在提交
        
        MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]initWithNibName:@"MyTeacherViewController" bundle:nil];
        [self.navigationController pushViewController:myTeacherVC animated:YES];
    }
}

#pragma mark - 返回topic详情页
- (void)backToTopicPage
{
//    for (UIViewController *viewControllers in self.navigationController.viewControllers)
//    {
//        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
//        {
//            [self.navigationController popToViewController:viewControllers animated:YES];
//            break;
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
