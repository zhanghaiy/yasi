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
#import "OralDBFuncs.h"
#import "RecordManager.h"
#import "NSString+CalculateStringSize.h"
#import "ZipArchive.h"
#import "AFHTTPRequestOperationManager.h"


@interface CheckTestViewController ()<SelectTeacherDelegate,UIAlertViewDelegate>
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
    NSMutableArray *_testAudioPathArray;// 录音文件路径
    NSMutableArray *_jsonArray;
    NSInteger _sum_part_Counts;
    NSInteger _sum_question_Counts;

    int _current_part_Counts;
    NSInteger _current_question_Counts;
    
    NSDictionary *_currentQuestionDict;
    NSDictionary *_partQuestionDict;
    
    AudioPlayer *_audioManager;
    RecordManager *_recordManager;
    NSInteger _prepareTime_point2;// 第二关准备总时间
    BOOL _isFirst;// 用于总倒计时
    NSDate *_beginDate;// 设置开始时间
    UIColor *_tip_text_Color;// 文字颜色
    
    NSString *_teacherid;
    BOOL _testFinished;
    
    float _markTime_PartAlone;
    
    BOOL _commitSuccess;
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
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/mockinfo.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO]];
    NSLog(@"%@",jsonPath);
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *testDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    _partListArray = [[testDic objectForKey:@"mockquestion"] objectForKey:@"questionlist"];
    _sum_part_Counts = _partListArray.count;
}

//#pragma mark -- 本地资源文件路径
//- (NSString *)getFileBasePath
//{
//    NSString *path = [NSString stringWithFormat:@"%@/temp"];[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicTest/temp",[OralDBFuncs getCurrentTopic]];
//    return path;
//}

#pragma mark -- 本地录音文件路径
- (NSString *)getRecordSavePath
{
    NSString *path = [self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO];
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
        btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_12];
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
            btn_spot.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
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
    float tea_back_View_height = kScreentWidth*34/75;
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
    
    [_teaCircleImageView setFrame:CGRectMake((kScreentWidth-100)/2, (_teaBackView.frame.size.height-100)/2, 100, 100)];
    
    // 学生界面
    [_stuBackView setFrame:CGRectMake(0, 185+tea_back_View_height, kScreentWidth, kScreenHeight-185-tea_back_View_height)];
    
    // 缩小时的frame
    _stu_head_small_frame = CGRectMake((kScreentWidth-45)/2, 66, 45, 45);
    // 放大时的frame
    _stu_head_big_frame = CGRectMake((kScreentWidth-65)/2, 56, 65, 65);//_stu_head_small_frame;
    
    
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
    [_commitButtonLeft setTitleColor:_tip_text_Color forState:UIControlStateNormal];
    _commitButtonLeft.hidden = YES;
    _commitButtonLeft.tag = KLeftCommitButtonTag;
    
    [_commitButtonRight setBackgroundColor:_backgroundViewColor];
    [_commitButtonRight setTitleColor:_tip_text_Color forState:UIControlStateNormal];
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
    
    _commitSuccess = NO;
    _testFinished = NO;
    _aloneCounts = 0;
    _prepareTime_point2 = 30; //总时间为30秒 此处为了便于调试暂时用10秒
    _tip_text_Color = [UIColor colorWithRed:0 green:196/255.0 blue:255/255.0 alpha:1];
    
    _testAudioPathArray = [[NSMutableArray alloc]init];
    _jsonArray = [[NSMutableArray alloc]init];
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
    
    _recordManager = [[RecordManager alloc]init];
    _recordManager.target = self;
    _recordManager.action = @selector(recordFinished:);
    
    _markTime_PartAlone = 0;
}

#pragma mark -- 视图将要出现
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_stuHeadImageV setFrame:_stu_head_small_frame];
    _circleProgressView.frame = CGRectMake((kScreentWidth-100)/2, _stu_head_big_frame.origin.y-17.5, 100, 100);
    _circleProgressView.frame = CGRectMake(_stu_head_big_frame.origin.x-17.5, _stu_head_big_frame.origin.y-17.5, 100, 100);
}


#pragma mark -- 视图出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_testFinished == NO)
    {
        _tipLabel.text = [NSString stringWithFormat:@"第%d轮考试马上开始~请集中注意力~~~~",_current_part_Counts+1];// @"考试马上开始~请集中注意力~~~~";
        [self TextAnimationWithView:_tipLabel];
        // 预留准备时间
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareTest) userInfo:nil repeats:NO];
    }
}


#pragma mark -- 开始模考
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
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(beginPlayQuestion) userInfo:nil repeats:NO];
}


#pragma mark  - 播放
#pragma mark -- 开始提问 播放问题
- (void)beginPlayQuestion
{
    [self startAnimotion]; // 光圈动画开启
    NSString *audioName = [_currentQuestionDict objectForKey:@"url"];
    NSString *audioPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO],audioName];
    // 播放
    [_audioManager playerPlayWithFilePath:audioPath];
    _markTime_PartAlone += _audioManager.audioDuration;
    NSLog(@"_markTime_PartAlone: %f",_markTime_PartAlone);
}

#pragma mark -- 播放问题结束 回调
- (void)playTestQuestioCallBack
{
    [self stopAnimotion];// 光圈停止
    
    // 1--> 问题结束 ----> 老师部分做一系列动画
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(endQuestion) userInfo:nil repeats:NO];
    
    // 2、学员准备回答 ----> 动画
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(prepareAnswerTest) userInfo:nil repeats:NO];
    //    // 开始回答
    //    [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
}


#pragma mark - 回答
#pragma mark -- 准备回答 --> 动画
- (void)prepareAnswerTest
{
    if (_current_part_Counts == 1)
    {
        // 有30“时间准备
        _tipLabel.text = [NSString stringWithFormat:@"此题根据关键词作答~~你有%ld\"的准备时间~~~",_prepareTime_point2];
        [self TextAnimationWithView:_tipLabel];
        [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(prepareTransition) userInfo:nil repeats:NO];
    }
    else
    {
        // 提示标签
//        _tipLabel.text = @"准备.....";
//        [self TextAnimationWithView:_tipLabel];
        
        // 放大学生头像
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(enlargeStudentHeadImage) userInfo:nil repeats:NO];
        
        // 开始回答
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}

#pragma mark -- 准备时间过渡
- (void)prepareTransition
{
    _aloneTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(prepareTime) userInfo:nil repeats:YES];
}

#pragma mark -- 准备时间
- (void)prepareTime
{
    _prepareTime_point2 --;
    _tipLabel.text = [NSString stringWithFormat:@"剩余准备时间：%ld\"",_prepareTime_point2];
    
    if (_prepareTime_point2 <= 0)
    {
        [_aloneTimer invalidate];
        _aloneTimer = nil;
        [self enlargeStudentHeadImage];
        _tipLabel.text = @"准备回答.....";
        [self TextAnimationWithView:_tipLabel];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnswer) userInfo:nil repeats:NO];
    }
}



#pragma mark -- 开始回答
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
        [self stopRecord];
    }
    else
    {
        btn.selected = YES;
        // 开始录音
        _circleProgressView.hidden = NO;
        [self startRecord];
        _aloneTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(answerTimeDecrease) userInfo:nil repeats:YES];
    }
}

#pragma mark - 录音
#pragma mark -- 开始录音
- (void)startRecord
{
    NSString *testPath =[NSString stringWithFormat:@"%@/test-%d-%ld.wav",[self  getRecordSavePath],_current_part_Counts+1,_current_question_Counts+1];
    [_recordManager prepareRecorderWithFilePath:testPath];
    [_testAudioPathArray addObject:testPath];
}

#pragma mark -- 结束录音
- (void)stopRecord
{
    [_recordManager stopRecord];
}

#pragma mark -- 录音反馈
- (void)recordFinished:(RecordManager *)record
{
    _followBtn.hidden = YES;
    // 标记part 时间
    _markTime_PartAlone += record.recorderTime;
    
    long audioTime = record.recorderTime*1000;
    // 增加模考时间
    [OralDBFuncs addExamTime:audioTime ForUser:[OralDBFuncs getCurrentUserName]];
    // 问题文本
    NSString *modellongtime = [NSString stringWithFormat:@"%ld",audioTime];
    NSString *question = [_currentQuestionDict objectForKey:@"question"];
    NSString *id = [_currentQuestionDict objectForKey:@"id"];
    NSString *recorderUrl = [NSString stringWithFormat:@"test-%d-%ld.wav",_current_part_Counts+1,_current_question_Counts+1];
    NSString *urltime = [NSString transformNSStringWithDate:record.endDate andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    NSDictionary *dic = @{@"answer":question,@"modellongtime":modellongtime,@"partid":id,@"recorderUrl":recorderUrl,@"urltime":urltime};
    [_jsonArray addObject:dic];
    
    
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
        // 存储 清零
        [OralDBFuncs setTestPartDuration:_markTime_PartAlone andPart:_current_part_Counts Topic:[OralDBFuncs getCurrentTopic] Username:[OralDBFuncs getCurrentUserName]];
        
        _markTime_PartAlone = 0;
        _current_part_Counts ++;
        _current_question_Counts = 0;
        if (_current_part_Counts<_sum_part_Counts)
        {
            // 判断进行下一题 或下一关卡
            [self TextAnimationWithView:self.view];
            _tipLabel.text =[NSString stringWithFormat:@"第%d轮考试马上开始~请集中注意力~~~~",_current_part_Counts+1];
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
//        _teaHeadImageV.center = _teaBackView.center;
//        _teaCircleImageView.center = _teaBackView.center;
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
//        _teaHeadImageV.center = _teaBackView.center;
//        _teaCircleImageView.center = _teaBackView.center;
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
    [UIView setAnimationDuration:0.7f];
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
            _teaDesLabel.text = @"此处展示关键词，关键词的内容还未给出，暂时无法展示";
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
    _tipLabel.text = @"考官提问结束，考生请做好准备...";
    [self TextAnimationWithView:_tipLabel];
    // 2: 缩小考官头像
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
    _tipLabel.text = @"考官正在提问提问，请注意听....";
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
        [self followButtonClicked:_followBtn];
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

#pragma mark - 提交
- (IBAction)commitButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == KLeftCommitButtonTag)
    {
        // 稍后提交
        //1、 标记 关卡3是否提交
        // 合成json文件 打包zip  在后续成绩单界面 直接用zip
        if ([self makeUpLocalJsonFile_test])
        {
            [self zipCurrentTestFile];
            [OralDBFuncs setTestCommit:NO withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName]];
            [self backToTopicPage];
        }
        else
        {
            NSLog(@"打包文件失败");
            [self showAlertViewWithMessage:@"打包文件失败"];
        }
    }
    else if (btn.tag == KRightCommitButtonTag)
    {
        // 现在提交
        //1、 标记 关卡3是否提交 成功提交后再做标记
        // 2、判断是否有默认老师 无---跳转到选择老师界面  有----直接提交
        if ([OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]])
        {
            _teacherid = [OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]];
            // 有默认老师
            [self startRequst_test];
        }
        else
        {
            MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]initWithNibName:@"MyTeacherViewController" bundle:nil];
            myTeacherVC.delegate = self;
            [self.navigationController pushViewController:myTeacherVC animated:YES];
        }
    }
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_commitSuccess)
    {
        // 提交成功
        [self backToTopicPage];
    }
}

#pragma mark - 网络请求
- (void)startRequst_test
{
    _loading_View.hidden = NO;
    [self changeLoadingViewTitle:@"正在提交，请稍后...."];
    // 合成json文件
    BOOL makeUpSuccess = [self makeUpLocalJsonFile_test];
    if (makeUpSuccess)
    {
        // 压缩zip包
        NSData *zipData = [NSData dataWithContentsOfFile:[self zipCurrentTestFile]];
        // 网络提交 uploadfile
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"modelpart" forKey:@"uploadfile"];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kTestCommitUrl];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             if (zipData)
             {
                 [formData appendPartWithFileData:zipData name:@"uploadfile" fileName:@"modelpart.zip" mimeType:@"application/zip"];
                 
             }
         } success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             _loading_View.hidden = YES;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
             NSLog(@"%@",dic);

             if ([[dic objectForKey:@"respCode"] intValue] == 1000)
             {
                 // 提交成功后回到topic详情页面
                 NSLog(@"upload success!");
                 // 提交成功后回到topic详情页面
                 [OralDBFuncs setTestCommit:YES withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName]];
                 NSLog(@"模考提交老师成功");
                 _commitSuccess = YES;
                 [self showAlertViewWithMessage:@"提交成功"];
             }
             else
             {
                 NSLog(@"提交失败：%@",[dic objectForKey:@"remark"]);
                 [self commitFailed_test];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             _loading_View.hidden = YES;
             NSLog(@"失败乃");
             [self commitFailed_test];
         }];

    }
}

- (void)commitFailed_test
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

#pragma mark - 合成json文件
- (BOOL)makeUpLocalJsonFile_test
{
    NSDictionary *modelpartInfo = @{@"modelpartInfo":_jsonArray,@"teacherid":_teacherid,@"topic":[OralDBFuncs getCurrentTopicID],@"useid":[OralDBFuncs getCurrentUserID]};
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelpartInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/modelpart.json",[self getRecordSavePath]];
    NSLog(@"~~~~~~~json文件保存路径：%@~~~~~~~",jsonFilePath);
    BOOL saveSuc = [jsonData writeToFile:jsonFilePath atomically:YES];
    return saveSuc;
}

#pragma mark - 压缩zip包
- (NSString *)zipCurrentTestFile
{
    NSString *zipPath = [NSString stringWithFormat:@"%@/modelpart.zip",[self getRecordSavePath]];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = [zip CreateZipFile2:zipPath];
    if (ret)
    {
        for (NSString *testAudioPath  in _testAudioPathArray)
        {
            NSString *audioName = [[testAudioPath componentsSeparatedByString:@"/"] lastObject];
            [zip addFileToZip:testAudioPath newname:audioName];
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@/modelpart.json",[self getRecordSavePath]];
        [zip addFileToZip:jsonPath newname:@"modelpart.json"];
    }
//    NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
    return zipPath;
}

#pragma mark - 选择老师回调
- (void)selectTeacherId:(NSString *)teacherID
{
    _teacherid = teacherID;
    [self startRequst_test];
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
