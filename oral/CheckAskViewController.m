//
//  CheckAskViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckAskViewController.h"
#import "AudioPlayer.h"
#import "RecordManager.h"
#import "CircleProgressView.h"
#import "MyTeacherViewController.h"
#import "TPCCheckpointViewController.h"
#import "OralDBFuncs.h"
#import "JSONKit.h"
#import "ZipArchive.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"

@interface CheckAskViewController ()<SelectTeacherDelegate,UIAlertViewDelegate>
{
    NSDictionary *_topicInfoDict;// 整个topic信息
    NSDictionary *_currentPartDict;// 当前part资源信息
    NSDictionary *_currentPointDict;// 当前关卡资源信息
    NSArray *_questioListArray; // 当前关卡的所有问题数组
    NSInteger _sumQuestionCounts;//总的问题个数
    NSInteger _currentQuestionCounts; // 当前正在进行的问题
   
    AudioPlayer *audioPlayer;// 播放
    RecordManager *_recordManager; // 录音
    
    NSInteger _markTimeChangeCounts;// 标记进度
    NSTimer *_reduceTimer;
    
    CGRect _stuHeadImgViewRect;// 放大后学生头像的frame
    CGRect _stuHeadImgViewRect_small;// 缩小的学生头像的frame
    
    CircleProgressView *_progressView;
    
    BOOL _pointFinished;// 标记闯关是否已经完成 避免从其他页面返回时 造成混乱
    NSString *_teacherId;// 标记老师id 用于将练习提交给老师 评价
    NSMutableArray *_recordPathArray;// 记录每次录音的路径 用于压缩zip包
    
    int _recordTime;// 累加的录音时间
    NSMutableArray *_partInfoArray;// 用于合成json文件 每个回答的进本信息 组成一个字典
    
    
    BOOL _commitSuccess;
}
@end

@implementation CheckAskViewController
#define kTopQueCountButtonTag 333
#define kCommitLeftButtonTag 444
#define kCommitRightButtonTag 555

- (void)backToPrePage
{
    for (UIViewController *viewControllers in self.navigationController.viewControllers)
    {
        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
        {
            [self.navigationController popToViewController:viewControllers animated:YES];
            break;
        }
    }
}


#pragma mark - 模拟数据
- (void)moNiDataFromLocal
{
    // json文件路径

    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];

    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    _topicInfoDict = [dict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    _currentPartDict = [[_topicInfoDict objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    // 当前关卡信息
    _currentPointDict = [[_currentPartDict objectForKey:@"levellist"] objectAtIndex:[OralDBFuncs getCurrentPoint]-1];
    // 当前关卡所有问题
    _questioListArray = [_currentPointDict objectForKey:@"questionlist"];
    // 总问题数
    _sumQuestionCounts = _questioListArray.count;
    // 当前进行的问题 起始：0
    _currentQuestionCounts = 0;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _commitSuccess = NO;
    [self changeLoadingViewTitle:@"正在提交给老师，请耐心等待..."];
    _partInfoArray = [[NSMutableArray alloc]init];
    _recordPathArray = [[NSMutableArray alloc]init];

    _recordTime = 0;
    _markTimeChangeCounts = 0;// 起始为零 用于倒计时 每次进行新问题前 置0
    _pointFinished = NO;
    
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerCallBack);
    
    [OralDBFuncs setCurrentPoint:3];
    NSString *title = [NSString stringWithFormat:@"Part%d-%d",[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint]];
    [self addTitleLabelWithTitle:title];

    self.navTopView.backgroundColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    self.titleLab.textColor = [UIColor whiteColor];
    [self moNiDataFromLocal];
    [self uiConfig];
    
    _recordManager = [[RecordManager alloc]init];
    _recordManager.target = self;
    _recordManager.action = @selector(recordFinished:);
}

- (void)uiConfig
{
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _topView.backgroundColor = [UIColor clearColor];
    _teacherView.backgroundColor = [UIColor clearColor];
    _stuView.backgroundColor = [UIColor clearColor];
    
    // 背景颜色 去掉
    // 计算出按钮高度  不同尺寸屏幕 高度不同
    NSInteger partCountHeight = _topView.frame.size.height;
    NSInteger btnWid = 30;
    // 根据总问题数创建按钮
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), (partCountHeight-btnWid)/2, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        // 选中
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:_backColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_12];
        
        [btn addTarget:self action:@selector(questionCountChanged_ask) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = kTopQueCountButtonTag+i;
        if (i == 0)
        {
            btn.selected = YES;// 默认：1
        }
        [_topView addSubview:btn];
    }
    

    
    // 获取到老师背景View的frame
//    CGRect rect = _teacherView.frame;
//    float ratio = rect.size.width/rect.size.height;
//    rect.size.width = kScreentWidth;
//    rect.size.height = kScreentWidth/ratio;
//    _teacherView.frame = rect;
    
    // 老师头像 圆形 有光圈
    _teaHeadImgView.image = [UIImage imageNamed:@"teacher_normal"];
    _teaHeadImgView.layer.masksToBounds = YES;
    _teaHeadImgView.layer.cornerRadius = _teaHeadImgView.frame.size.height/2;
    _teaHeadImgView.layer.borderColor = _backColor.CGColor;
    _teaHeadImgView.layer.borderWidth = 3;
    
    // 确定问题背景frame
    CGRect questionBackRect = _teaQuestioBackV.frame;
    questionBackRect.origin.x = 105;
    questionBackRect.size.width = kScreentWidth-120;
    _teaQuestioBackV.frame = questionBackRect;
    _teaQuestioBackV.layer.masksToBounds = YES;
    _teaQuestioBackV.backgroundColor = [UIColor whiteColor];
    _teaQuestioBackV.layer.cornerRadius = _teaQuestioBackV.frame.size.height/2;
    
    // 问题文本 其实为空
    _teaQuestionLabel.numberOfLines = 0;
    _teaQuestionLabel.textColor = _textColor;
    _teaQuestionLabel.textAlignment = NSTextAlignmentCenter;
    _teaQuestionLabel.text = @"";
    
    
    CGRect stuBackRect = _stuView.bounds;
    stuBackRect.size.height = kScreenHeight-331;
    stuBackRect.size.width = kScreentWidth;
    _stuView.frame = stuBackRect;
    
    // 确定学生头像frame  缩小frame 放大frame
    // 缩小的的头像
    _stuHeadImgV.center = _stuView.center;
    _stuHeadImgViewRect_small = _stuHeadImgV.frame;
    _stuHeadImgViewRect_small.origin.x = (kScreentWidth-_stuHeadImgV.frame.size.width)/2;
    _stuHeadImgViewRect_small.origin.y = (_stuView.frame.size.height-_stuHeadImgV.frame.size.width)/2;
    // 放大后的头像
    _stuHeadImgViewRect = _stuHeadImgViewRect_small;
    _stuHeadImgViewRect.origin.x -= 15;
    _stuHeadImgViewRect.origin.y -= 15;
    _stuHeadImgViewRect.size.width += 30;
    _stuHeadImgViewRect.size.height += 30;
    
    /*
         创建时间进度条： 圆形时间进度条 围绕在学生头像外圈
                       随着时间的增加而增加 当走完一圈 时间用尽 回答结束
     */
    
    [self createTimeProgress];
    
    // 提交按钮
    _CommitLeftButton.tag = kCommitLeftButtonTag;
    _commitRightButton.tag = kCommitRightButtonTag;
    
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    /*
     初始状态:
                1> 问题文本不显示
                2> 老师、学生头像：暗 学生头像：小
                3> 跟读按钮：隐藏
     */
    
    _stuHeadImgV.alpha = 0.3;
    _teaHeadImgView.alpha = 0.3;
    _followAnswerButton.hidden = YES;
    [self narrowStuHeadImage];
    
    [_CommitLeftButton setBackgroundColor:[UIColor whiteColor]];
    [_CommitLeftButton setTitleColor:_pointColor forState:UIControlStateNormal];
    _CommitLeftButton.hidden = YES;
    
    [_commitRightButton setBackgroundColor:[UIColor whiteColor]];
    [_commitRightButton setTitleColor:_pointColor forState:UIControlStateNormal];
    _commitRightButton.hidden = YES;
    
    _CommitLeftButton.layer.masksToBounds = YES;
    _CommitLeftButton.layer.cornerRadius = _CommitLeftButton.frame.size.height/2;
    _commitRightButton.layer.masksToBounds = YES;
    _commitRightButton.layer.cornerRadius = _CommitLeftButton.frame.size.height/2;
    
}

#pragma mark - 创建时间进度条
- (void)createTimeProgress
{
    CGRect timeRect = _stuHeadImgViewRect;
    timeRect.origin.x -= 20;
    timeRect.origin.y -= 20;
    timeRect.size.width += 40;
    timeRect.size.height += 40;
    _progressView = [[CircleProgressView alloc]initWithFrame:timeRect];
    _progressView.backgroundColor = [UIColor clearColor];
    [_progressView settingProgress:0.0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    [_stuView addSubview:_progressView];
    
    _progressView.hidden = YES;
    _progressView.center = _stuView.center;
}

#pragma mark - 时间进度变化
- (void)progressTimeReduce
{
    _markTimeChangeCounts ++;
    float tip = 1.0/kLevel_3_time/10.0*_markTimeChangeCounts;
    [_progressView settingProgress:tip andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    if (tip >= 1)
    {
        [self followAnswer:_followAnswerButton];
    }
}

#pragma mark - 放大学生的头像
- (void)enlargementStuHeadImage
{
    _stuHeadImgV.frame = _stuHeadImgViewRect;
    _stuHeadImgV.layer.cornerRadius = _stuHeadImgViewRect.size.width/2;
}

#pragma mark - 缩小学生的头像
- (void)narrowStuHeadImage
{
    _progressView.hidden = YES;
    [_progressView settingProgress:0 andColor:_timeProgressColor andWidth:3 andCircleLocationWidth:3];
    _stuHeadImgV.frame = _stuHeadImgViewRect_small;
    _stuHeadImgV.layer.cornerRadius = _stuHeadImgViewRect_small.size.width/2;
}

#pragma mark - 切换问题变换文本
- (void)showCurrentQuestionText
{
    _teaQuestionLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    _teaQuestionLabel.text = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"];
}

#pragma mark - 视图已经出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
         停顿3秒 给学生准备时间 然后开始：
                                    1）问题文本出现 (要有动画效果)
                                    2）老实头像变亮
                                    3）播放问题音频
     */
    // 停顿3秒 开始point3流程
    
    
    if (!_pointFinished)// 此处加条件判断：如果是从其他界面返回则不走流程
    {
        _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareQuestion_ask) userInfo:nil repeats:NO];
    }
}

#pragma mark - 准备提问
- (void)prepareQuestion_ask
{
    // 停掉定时器
    [self stopTimer];
    
    // 1) 文字出现动画
    [self questionAnimation];
    // 2）头像--> 亮
    [UIView animateWithDuration:1 animations:^{
        _teaHeadImgView.alpha = 1;
        _stuHeadImgV.alpha = 0.3;
    }];
    // 3）播放音频
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(playQuestion_ask) userInfo:nil repeats:NO];
}

#pragma mark - 文字动画
- (void)questionAnimation
{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_teaQuestionLabel cache:YES];
    [self showCurrentQuestionText];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
}



#pragma mark -- 播放问题音频
- (void)playQuestion_ask
{
    // 获取音频路径
    NSString *audiourl = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"audiourl"];
    
    NSString *audioPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],audiourl];
    
    [audioPlayer playerPlayWithFilePath:audioPath];
}

#pragma MARK -- 播放完成 回调
- (void)playerCallBack
{
     // 播放完成 开始录音 保存本地
    [self prepareAnswer];
}

#pragma mark - 准备回答
- (void)prepareAnswer
{
    [UIView animateWithDuration:2 animations:^{
        [self enlargementStuHeadImage];
        _stuHeadImgV.alpha = 1;
        _teaHeadImgView.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showFollowButton) userInfo:nil repeats:NO];
}

- (void)showFollowButton
{
    [self stopTimer];
    _followAnswerButton.hidden = NO;
    [self followAnswer:_followAnswerButton];
}

#pragma mark - 停止定时器
- (void)stopTimer
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
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

- (IBAction)followAnswer:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected = NO;
       // 结束回答
        btn.hidden = YES;
        [_recordManager stopRecord];
        [self stopTimer];
    }
    else
    {
        btn.selected = YES;
        // 开始录音
        [self startRecord];
        [self showTimeProgress];
        
    }
}

- (void)showTimeProgress
{
    _progressView.hidden = NO;
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressTimeReduce) userInfo:nil repeats:YES];
}

#pragma mark - 开始录音
- (void)startRecord
{
    NSString *filePath = [NSString stringWithFormat:@"%@/Part%d-%d-%ld.wav",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint],_currentQuestionCounts+1];
    [_recordPathArray addObject:filePath];
   [_recordManager prepareRecorderWithFilePath:filePath];
}

#pragma mark - 录音结束回调
- (void)recordFinished:(RecordManager *)manager
{
    NSTimeInterval time = [manager.endDate timeIntervalSinceDate:manager.beginDate];
    // 时间总长 累加 ---- 待确定
    _recordTime += round(time);
    // 增加录音时长
    [OralDBFuncs addPlayTime:_recordTime ForUser:[OralDBFuncs getCurrentUserName]];
    
    // 合成json文件所需
    NSString *level = [NSString stringWithFormat:@"%d",[[_currentPointDict objectForKey:@"level"] intValue]];
    NSString *partid = [_currentPointDict objectForKey:@"partid"];
    NSDictionary *questioDic = [_questioListArray objectAtIndex:_currentQuestionCounts];
    NSString *questionid = [questioDic objectForKey:@"id"];
    NSString *questiontext = [questioDic objectForKey:@"question"];
    NSDictionary *answerDic = [[questioDic objectForKey:@"answerlist"] objectAtIndex:0];
    
    NSLog(@"~~~~~~~~~\nlevel:%@\npartid:%@\nquestionid:%@\nquestionText:%@\n~~~~~~",level,partid,questionid,questiontext);
    
    NSString *answerid = [answerDic objectForKey:@"id"];
    NSString *audioUrl = [NSString stringWithFormat:@"Part%d-%d-%ld.wav",[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint],_currentQuestionCounts+1];
    
    NSDictionary *subDic = @{@"answerid":answerid,@"audioUrl":audioUrl,@"level":level,@"partid":partid,@"questionid":questionid,@"questiontext":questiontext,@"topicid":[_topicInfoDict objectForKey:@"id"],@"longtime":[NSNumber numberWithInt:round(time)]};
    [_partInfoArray addObject:subDic];
    
    [self nextQuestion_ask];
}

#pragma mark - 进行下一题
- (void)nextQuestion_ask
{
    _currentQuestionCounts++;
    _markTimeChangeCounts = 0;
    if (_currentQuestionCounts<_sumQuestionCounts)
    {
        // 继续
        [UIView animateWithDuration:2 animations:^{
            [self narrowStuHeadImage];
            _stuHeadImgV.alpha = 0.3;
        }];
        [self questionCountChanged_ask];
        _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(prepareQuestion_ask) userInfo:nil repeats:NO];
    }
    else
    {
        // 此处存储 用户 当前part 关卡3已结束  无论提交与否 成绩单页面都要展示 所以作此标记
        // 标记用户闯关数 以便于解锁下一个part  标记用户关卡3完成次数 用于成绩单页面对比
        [OralDBFuncs setPartLevel3Finished:YES AddPracticeNum:YES UnLockNum:[OralDBFuncs getCurrentPart] Topic:[OralDBFuncs getCurrentTopic] User:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
        // 提交给老师按钮 显示
        _CommitLeftButton.hidden = NO;
        _commitRightButton.hidden = NO;
    }
}

#pragma mark -- 标记当前进行的问题数
- (void)questionCountChanged_ask
{
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:kTopQueCountButtonTag+i];
        if (i == _currentQuestionCounts)
        {
            btn.selected = YES;
        }
        else
        {
            btn.selected = NO;
        }
    }
}

#pragma mark - 提交
#pragma mark -- 提交按钮被点击
- (IBAction)commitButtonClicked:(id)sender
{
    _pointFinished = YES;
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == kCommitLeftButtonTag)
    {
        // 稍后提交
        // 标记是否提交 未提交 在成绩单页面可以提交
        [OralDBFuncs setPartLevel3Commit:NO withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
        // 标记提交时合成json文件所需的内容 成绩单页面可直接用
        [OralDBFuncs setTopicAnswerJsonArray:_partInfoArray Topic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:YES];
        // 标记提交时合成zip文件所需的内容 成绩单页面可直接用
        [OralDBFuncs setTopicAnswerZipArray:_recordPathArray Topic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:YES];
        [self backToTopicPage];
        
        // 合成json文件 打包zip  在后续成绩单界面 直接用zip  ---- 错误 未考虑无默认老师情况 暂时pass
//        if ([self makeUpJsonFile])
//        {
//            [self zipCurrentPartFile];
//            // 稍后提交
//            [self backToTopicPage];
//            //1、 标记 关卡3是否提交
//            [OralDBFuncs setPartLevel3Commit:NO withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
//        }
//        else
//        {
//            NSLog(@"打包文件失败");
//        }
        
    }
    else if (btn.tag == kCommitRightButtonTag)
    {
        if (kCurrentNetStatus)
        {
            // 判断是否有默认老师 无---跳转到选择老师界面  有----直接提交
            if ([OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]])
            {
                _teacherId = [OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]];
                // 有默认老师 监测网络状态 对比本地设置  直接提交
                [self jugeNetState];
            }
            else
            {
                // 无默认老师  提示用户选择老师 选择后再提交
                MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]initWithNibName:@"MyTeacherViewController" bundle:nil];
                myTeacherVC.delegate = self;
                [self.navigationController pushViewController:myTeacherVC animated:YES];
            }
        }
        else
        {
            // 当前无网络链接
            UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前无网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertV show];
        }
    }
}

#pragma mark - 检测网络状态 参数：yes 请求part资源信息  no test资源信息
- (void)jugeNetState
{
    // 本地设置 是否允许2g3g4g 提交 （此处有点繁琐 原因设置界面有两个选项：1、wifi下下载  2、2g3g4g下下载 目前暂时这样）
    BOOL net_wifi = [OralDBFuncs getNet_WiFi_Download];
    BOOL net_2g3g4g = [OralDBFuncs getNet_2g3g4g_Download];
    
    switch ([DetectionNetWorkState netStatus])
    {
        case NotReachable:
        {
            // 无网络状态 （按照逻辑此处不会有 前面已经判断）
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前无网络链接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case ReachableViaWiFi:
        {
            // wifi
            [self startRequst];
        }
            break;
        case ReachableViaWWAN:
        {
            // 2g3g4g
            if (net_2g3g4g)
            {
                [self startRequst];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前网络为2g/3g/4g网络，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续",nil];
                [alertView show];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 警告框 delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex == 1)
    {
        [self startRequst];
    }
    
    if (_commitSuccess)
    {
        // 提交成功
        [self backToTopicPage];
    }
}


#pragma mark - 提交
- (void)startRequst
{
    _loading_View.hidden = NO;
    [self changeLoadingViewTitle:@"正在提交给老师，请稍后..."];
    [self.view bringSubviewToFront:_loading_View];
    BOOL makeUpSuccess = [self makeUpJsonFile];
    if (makeUpSuccess)
    {
        NSData *zipData = [NSData dataWithContentsOfFile:[self zipCurrentPartFile]];
        
        // 网络提交 uploadfile
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kPartCommitUrl];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"part" forKey:@"uploadfile"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             if (zipData)
             {
                 [formData appendPartWithFileData:zipData name:@"uploadfile" fileName:@"part.zip" mimeType:@"application/zip"];
             }
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             _loading_View.hidden = YES;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
             NSLog(@"%@",dic);
             if ([[dic objectForKey:@"respCode"] intValue] == 1000)
             {
                 // 标记 关卡3已经提交
                 [OralDBFuncs setPartLevel3Commit:YES withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
                 // 此处需修改
                 [OralDBFuncs setPartLevel3CommitNum:1 Topic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
                 // 提交成功后回到topic详情页面
                 _commitSuccess = YES;
                 [self showAlertViewWithMessage:@"提交成功"];
             }
             else
             {
                 _commitSuccess = NO;
                 NSLog(@"提交失败");
                 NSLog(@"%@",[dic objectForKey:@"remark"]);
                 [self commitFailed];
             }
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             _commitSuccess = NO;
             _loading_View.hidden = YES;
             NSLog(@"失败乃");
             [self commitFailed];
         }];

    }
    else
    {
        NSLog(@"合成json文件失败");
    }    
}

- (void)commitFailed
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}





#pragma mark - 压缩zip包
- (NSString *)zipCurrentPartFile
{
    NSString *zipPath = [NSString stringWithFormat:@"%@/part.zip",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = [zip CreateZipFile2:zipPath];
    if (ret)
    {
        for (NSString *audioPath  in _recordPathArray)
        {
            NSString *audioName = [[audioPath componentsSeparatedByString:@"/"] lastObject];
            [zip addFileToZip:audioPath newname:audioName];
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@/part.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
        [zip addFileToZip:jsonPath newname:@"part.json"];
    }
    NSLog(@"%@",zipPath);
    return zipPath;
}


#pragma mark - 合成json文件 保存本地
- (BOOL)makeUpJsonFile
{
    NSString *topicid = [_topicInfoDict objectForKey:@"id"];
    // 获取闯关分数 前两关
    TopicRecord *record = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]];
   
    NSMutableArray *checkPoint = [[NSMutableArray alloc]init];
    for (int i = 0; i < 3; i ++)
    {
        NSDictionary *levelDic = [[_currentPartDict objectForKey:@"levellist"] objectAtIndex:i];
        NSString *level = [NSString stringWithFormat:@"%d",[[levelDic objectForKey:@"level"] intValue]];
        NSString *levelid = [levelDic objectForKey:@"id"];
        
        int currentPart = [OralDBFuncs getCurrentPart];
        int currentPoint = i+1;
        int score = [self getScoreWithPart:currentPart Point:currentPoint Record:record];
        NSString *pass_mark;
        if (i < 2)
        {
            pass_mark = @"通关";
        }
        else
        {
            pass_mark = @"未通关";
        }
        NSDictionary *subDic = @{@"ifsubmitteacher":@"否",@"level":level,@"levelid":levelid,@"score":[NSNumber numberWithInt:score],@"status":pass_mark,@"topicid":topicid,@"userid":[OralDBFuncs getCurrentUserID]};
        [checkPoint addObject:subDic];
    }
    
    NSDictionary *finalDict = @{@"partInfo":_partInfoArray,@"checkPoint":checkPoint,@"teacherid":_teacherId};
    NSLog(@"%@",finalDict);
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalDict options:NSJSONWritingPrettyPrinted error:&parseError];
   
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/part.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    BOOL saveSuc = [jsonData writeToFile:jsonFilePath atomically:YES];
    return saveSuc;
}

#pragma mark - 获取分数
- (int)getScoreWithPart:(int)currentPart Point:(int)point Record:(TopicRecord *)record
{
    switch (currentPart)
    {
        case 1:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p1_1;
                }
                    break;
                case 2:
                {
                    return  record.p1_2;
                }
                    break;
                case 3:
                {
                    return record.p1_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p2_1;
                }
                    break;
                case 2:
                {
                    return record.p2_2;
                }
                    break;
                case 3:
                {
                    return record.p2_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p3_1;
                }
                    break;
                case 2:
                {
                    return record.p3_2;
                }
                    break;
                case 3:
                {
                    return record.p3_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return 0;
}

#pragma mark - 返回topic详情页
- (void)backToTopicPage
{
    for (UIViewController *viewControllers in self.navigationController.viewControllers)
    {
        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
        {
            [self.navigationController popToViewController:viewControllers animated:YES];
            break;
        }
    }
}


#pragma mark - 界面将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    audioPlayer.target = nil;
    if (_reduceTimer != nil)
    {
        [self stopTimer];
    }
}

#pragma mark - 选取老师后回调
- (void)selectTeacherId:(NSString *)teacherID
{
    _teacherId = teacherID;
    NSLog(@"选取老师后回调---老师id:%@",_teacherId);

    [self jugeNetState];
}

@end
