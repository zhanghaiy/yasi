//
//  CheckScoreViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckScoreViewController.h"
#import "ScoreMenuTestView.h"
#import "CustomProgressView.h"// 进度条
#import "ScoreTestMenuViewController.h"
#import "OralDBFuncs.h"
#import "AudioPlayer.h"
#import "NSURLConnectionRequest.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"

#import "SCOPartMenuViewController.h"

#import "MyTeacherViewController.h"
#import "ZipManager.h"
#import "ZipArchive/ZipArchive.h"

@interface CheckScoreViewController ()<UIScrollViewDelegate,SelectTeacherDelegate>
{
    UIScrollView *_backScrollV;
    UISegmentedControl *_segment;
    float _decreaseRatio;// 根据音频时间换算出进度条每次减少的比率
    NSInteger _ClickedIndex;
    NSTimer *_timer;
    
    NSArray *_partListArray;
    int _currentPlayCount;
    NSMutableArray *_playPathArray;
    int _markPlayCounts;
    
    AudioPlayer *_playerManager;
    NSArray *_currentTestArray;
    
    float _test_part_sumTime;
    
    
    NSMutableArray *_watingInfoArray;// 老师已处理事项的数组
    
    BOOL _wating_test;// 标记是否有模考的反馈
    NSDictionary *_watingDict_test; // 模考反馈基本信息
    NSString *_defaultTeacherID;
}
@end

@implementation CheckScoreViewController
#define kPartButtonWidth 230
#define kPartButtonHeight 100
#define kPartButtonTag 333
#define kTestViewTAg 555

#define kPlayButtonTag 55
// 音频时间View tag
#define kProgressViewTag 66

#define kTestCommitButtonTag 77
#define kTestCommitButtonHeight 37
#define kTestCommitButtonWidth 100

#pragma mark - 将问题音频 答案音频 文件名 组成一个数据 便于使用
- (void)analysizeTestJson
{
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/mockinfo.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:nil];
        _partListArray = [[dic objectForKey:@"mockquestion"] objectForKey:@"questionlist"];
        
        _playPathArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < _partListArray.count; i ++)
        {
            NSDictionary *partDic = [_partListArray objectAtIndex:i];
            NSArray *question = [partDic objectForKey:@"question"];
            
            NSMutableArray *part_alone_array = [[NSMutableArray alloc]init];
            for (int j = 0; j < question.count; j ++)
            {
                NSDictionary *questionDic =[question objectAtIndex:j];
                NSString *questionAudioUrl = [questionDic objectForKey:@"url"];
                NSString *answerAudioUrl = [NSString stringWithFormat:@"test-%d-%d.wav",i+1,j+1];
                NSDictionary *dic = @{@"quesUrl":questionAudioUrl,@"answerUrl":answerAudioUrl};
                [part_alone_array addObject:dic];
            }
            [_playPathArray addObject:part_alone_array];
        }
    }
    else
    {
        NSLog(@"json文件路径不存在");
    }
}


#pragma mark - UI配置
- (void)uiConfig
{
    // -------------分段控制器-----------
    // 先创建数组 给分段控件赋值
    NSArray *array = [[NSArray alloc]initWithObjects:@"模考", @"关卡",nil];
    // 创建一个分段控件
    _segment = [[UISegmentedControl alloc]initWithItems:array];
    // 分段控件的位置
    _segment.frame = CGRectMake((kScreentWidth-110)/2, KNavTopViewHeight + 12, 110, 35);
    // 分段控件的选中颜色
    _segment.tintColor = _pointColor;
    for (UIView *view in _segment.subviews)
    {
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = _segment.frame.size.height/2;
    }
    
    // 默认启动选择索引
    _segment.selectedSegmentIndex = 0;
    // 圆角半径
    _segment.layer.masksToBounds = YES;
    _segment.layer.cornerRadius = 35/2;
    _segment.layer.borderColor = _pointColor.CGColor;
    _segment.layer.borderWidth = 1;
    // 分段控件点击方法
    [_segment addTarget:self action:@selector(segment:) forControlEvents:UIControlEventValueChanged];
    // 添加到视图上
    [self.view addSubview:_segment];
    // -------------scrollView-----------
    
    _backScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, kScreentWidth, kScreenHeight-100)];
    _backScrollV.pagingEnabled = YES;
    _backScrollV.delegate = self;
    _backScrollV.contentSize = CGSizeMake(kScreentWidth*2, kScreenHeight-100);
    [self.view addSubview:_backScrollV];
    // 模考
    
    // 判断是否参加过模考
    if ([OralDBFuncs getTestFinishedWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName]])
    {
        // 参加过模考
        for (int i = 0; i < 3; i ++)
        {
            // 40 40
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 20+i*100, kScreentWidth-80, 30)];
            label.text = [NSString stringWithFormat:@"Part%d",i+1];
            label.textColor = _pointColor;
            label.font = [UIFont systemFontOfSize:kFontSize_14];
            [_backScrollV addSubview:label];
            
            UIView *testBAckView = [[UIView alloc]initWithFrame:CGRectMake(40, 60+i*100, kScreentWidth-80, 45)];
            testBAckView.backgroundColor = _backgroundViewColor;
            testBAckView.layer.masksToBounds = YES;
            testBAckView.layer.cornerRadius = testBAckView.bounds.size.height/2;
            [_backScrollV addSubview:testBAckView];
            
            UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [playButton setFrame:CGRectMake(5, 5, 35, 35)];
            [playButton setBackgroundImage:[UIImage imageNamed:@"Prac_play_n"] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[UIImage imageNamed:@"Prac_play_s"] forState:UIControlStateSelected];
            [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            playButton.tag = kPlayButtonTag +i;
            [testBAckView addSubview:playButton];
            
            // 进度条
            CustomProgressView *progressV = [[CustomProgressView alloc]initWithFrame:CGRectMake(50, 20, testBAckView.frame.size.width-70, 4)];
            progressV.tag = kProgressViewTag+i;
            progressV.backgroundColor = [UIColor whiteColor];
            progressV.progress = 1;
            progressV.progressView.backgroundColor = _pointColor;
            [testBAckView addSubview:progressV];
        }
        
        // 提交按钮
        NSInteger yyy = kScreenHeight<500?(kScreenHeight-kTestCommitButtonHeight-10-100):380;
        UIButton *commitTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitTestButton setFrame:CGRectMake((kScreentWidth-kTestCommitButtonWidth)/2, yyy, kTestCommitButtonWidth, kTestCommitButtonHeight)];
        
        // 一共三种状态 1：未提交 --》tijiao geilaoshi
        
        [commitTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        commitTestButton.layer.cornerRadius = kTestCommitButtonHeight/2;
        commitTestButton.backgroundColor = _pointColor;
        commitTestButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
        [commitTestButton addTarget:self action:@selector(commitTest:) forControlEvents:UIControlEventTouchUpInside];
        commitTestButton.tag = kTestCommitButtonTag;
        [_backScrollV addSubview:commitTestButton];
        
        [commitTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        // 判断是否莫考过 --- 未完待续
        BOOL commited = [OralDBFuncs getTestCommitTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName]];
        if (commited)
        {
            // 已提交
            [commitTestButton setTitle:@"等待老师评价" forState:UIControlStateNormal];
            commitTestButton.enabled = NO;
        }
        else
        {
            // 未提交
            [commitTestButton setTitle:@"提交给老师" forState:UIControlStateNormal];
        }
    }
    else
    {
       // 未模考
        UILabel *testTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, kScreentWidth, 80)];
        testTipLabel.text = @"暂无模考信息";
        testTipLabel.textColor = _pointColor;
        testTipLabel.textAlignment = NSTextAlignmentCenter;
        testTipLabel.font = [UIFont systemFontOfSize:kFontSize_14];
        [_backScrollV addSubview:testTipLabel];
    }
    
    
    
    // 闯关
    NSArray *partButtonNameArray = @[@"Part-One",@"Part-Two",@"Part-Three"];
    for (int i = 0; i < partButtonNameArray.count; i ++)
    {
        // 240 100
        UIButton *partButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [partButton setFrame:CGRectMake(kScreentWidth+75, 65+i*(kPartButtonHeight+15), kScreentWidth-150, kPartButtonHeight)];
        [partButton setTitle:[partButtonNameArray objectAtIndex:i] forState:UIControlStateNormal];
        [partButton setTitleColor:_pointColor forState:UIControlStateNormal];
        partButton.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
        partButton.layer.masksToBounds = YES;
        partButton.layer.cornerRadius = kPartButtonHeight/2;
        partButton.titleLabel.font = [UIFont systemFontOfSize:25];
        partButton.tag = kPartButtonTag + i;
        [partButton addTarget:self action:@selector(partButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backScrollV addSubview:partButton];
    }
    
}



#pragma mark - 数据加载
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:[OralDBFuncs getCurrentTopic]];
    [self uiConfig];
    [self analysizeTestJson];

    for (int i = 0; i < 3; i ++)
    {
        ScoreMenuTestView *testV = (ScoreMenuTestView *)[self.view viewWithTag:kTestViewTAg+i];
        testV.timeBackLabel.backgroundColor  =[UIColor purpleColor];
        testV.timeBackLabel.frame = CGRectMake(50, 18, 30, 20);
        testV.timeLabel.backgroundColor = _pointColor;
        testV.progress = 1;
    }
    
    _playerManager = [AudioPlayer getAudioManager];
    _playerManager.action = @selector(playTestFinished:);
    _playerManager.target = self;
    
    _watingInfoArray = [[NSMutableArray alloc]init];
    [self requestTestWating];
}

#pragma mark - 网络
#pragma mark -- 请求老师已处理事项
- (void)requestTestWating
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?userId=%@",kBaseIPUrl,kSelectNewWatingEvent,[OralDBFuncs getCurrentUserID]];
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestWatingFinished:) andRefresh:YES];
}

#pragma mark -- 请求老师已处理事项 回调
- (void)requestWatingFinished:(NSURLConnectionRequest *)reuqest
{
    if ([reuqest.downloadData length])
    {
        // 有数据
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:reuqest.downloadData options:0 error:nil];
        if ([[dic objectForKey:@"respCode"] integerValue] == 1000)
        {
            NSArray *waitingList = [dic objectForKey:@"waitingList"];
            // 此处需：遍历数组 找到 当前topic 当前的模考反馈信息 此处需和后台确认
            if (waitingList.count)
            {
                // 老师已反馈  从反馈中找到当前topic 的 反馈 1、闯关反馈 2、模考反馈
                for (NSDictionary *watingListDic in waitingList)
                {
                    NSString *topicid = [watingListDic objectForKey:@"topicid"];
                    if ([topicid isEqualToString:_topicId])
                    {
                        // 关卡3
                        if ([[watingListDic objectForKey:@"part"] intValue])
                        {
                            // part3
                            [_watingInfoArray addObject:watingListDic];
                        }
                        
                        if ([[watingListDic objectForKey:@"part"]length]==0)
                        {
                            // 此处为模考反馈 给用户提示可以查看评价
                            _wating_test = YES;
                            _watingDict_test = watingListDic;
                            
                            UIButton *commitButton_test = (UIButton *)[self.view viewWithTag:kTestCommitButtonTag];
                            [commitButton_test setTitle:@"查看老师反馈" forState:UIControlStateNormal];
                        }
                    }
                }
            }
            else
            {
                // 没有反馈
                NSLog(@" 没有反馈");
            }
        }
    }
}



#pragma mark - 模考
#pragma mark -- 模考提交按钮被点击
- (void)commitTest:(UIButton *)commitButton
{
    // 1：未提交给老师 提交老师  2：已经提交 但是未反馈 3：老师已反馈
    if (![OralDBFuncs getTestCommitTopic:[OralDBFuncs getCurrentUserID] andUserName:[OralDBFuncs getCurrentUserName]])
    {
        // 提交给老师 先判断是否可以提交
        [self jugeCouldCommit];
    }
    

    if (_wating_test)
    {
        // 如果老师已反馈 在此判断反馈的是否是最新的
        ScoreTestMenuViewController *testVC = [[ScoreTestMenuViewController alloc]init];
        NSInteger commitNUm = [OralDBFuncs getTestCommitedNumberTopic:[OralDBFuncs getCurrentTopic] User:[OralDBFuncs getCurrentUserName]];
        NSInteger currentNum = [[_watingDict_test objectForKey:@"hissn"] integerValue];
        if ([OralDBFuncs getTestCommitTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName]]&& (commitNUm == currentNum))
        {
            testVC.watingDict = _watingDict_test;
        }
        [self.navigationController pushViewController:testVC animated:YES];
    }
}
#pragma mark -- 判断是否可以直接提交
- (void)jugeCouldCommit
{
    if ([OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]])
    {
        _defaultTeacherID = [OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]];
        // 有默认老师
        [self commitTestInfo];
    }
    else
    {
        MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]initWithNibName:@"MyTeacherViewController" bundle:nil];
        myTeacherVC.delegate = self;
        [self.navigationController pushViewController:myTeacherVC animated:YES];
    }
}

#pragma mark -- 开始提交模考
- (void)commitTestInfo
{
    _loading_View.hidden = NO;
    
    BOOL json = [self makeUpJsonFile_test];
    if (json)
    {
        // 压缩
        NSString *testZipPath = [self zipCurrentTestFile];
        NSData *zipData = [NSData dataWithContentsOfFile:testZipPath];
        
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
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             _loading_View.hidden = YES;
             if (operation.responseData)
             {
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
                 if ([[dict objectForKey:@"respCode"] intValue] == 1000)
                 {
                     // 提交成功
                     [OralDBFuncs setTestCommit:YES withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName]];
                     NSLog(@"模考提交老师成功");
                     UIButton *commitBtn = (UIButton *)[self.view viewWithTag:kTestCommitButtonTag];
                     [commitBtn setTitle:@"已提交" forState:UIControlStateNormal];
                 }
                 else
                 {
                     NSLog(@"提交失败：%@",[dict objectForKey:@"remark"]);
                 }
             }
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             _loading_View.hidden = YES;
             NSLog(@"失败乃");
         }];
    }
    else
    {
        // 合成json文件失败
    }
}


#pragma mark -- 选择老师回调
- (void)selectTeacherId:(NSString *)teacherID
{
    _defaultTeacherID = teacherID;
    [self commitTestInfo];
}

#pragma mark -- 合成模考json文件
- (BOOL)makeUpJsonFile_test
{
    NSArray *jsonArray =  [OralDBFuncs getTopicAnswerJsonArrayWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:NO];
    NSDictionary *modelpartInfo = @{@"modelpartInfo":jsonArray,@"teacherid":_defaultTeacherID,@"topic":[OralDBFuncs getCurrentTopicID],@"useid":[OralDBFuncs getCurrentUserID]};
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelpartInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/modelpart.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO]];
    BOOL saveSuc = [jsonData writeToFile:jsonFilePath atomically:YES];
    return saveSuc;
}

#pragma mark -- 压缩模考zip包
- (NSString *)zipCurrentTestFile
{
    NSArray *testAudioPathArray = [OralDBFuncs getTopicAnswerZipArrayWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:NO];
    NSString *zipPath = [NSString stringWithFormat:@"%@/modelpart.zip",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = [zip CreateZipFile2:zipPath];
    if (ret)
    {
        for (NSString *testAudioPath  in testAudioPathArray)
        {
            NSString *audioName = [[testAudioPath componentsSeparatedByString:@"/"] lastObject];
            [zip addFileToZip:testAudioPath newname:audioName];
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@/modelpart.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO]];
        [zip addFileToZip:jsonPath newname:@"modelpart.json"];
    }
    //    NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
    return zipPath;
}


#pragma mark - 模考播放
#pragma mark -- 播放音频按钮点击事件
- (void)playButtonClicked:(UIButton *)playButton
{
    for (int i = 0; i < 3; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:kPlayButtonTag+1];
        if (newBtn.tag != playButton.tag)
        {
            newBtn.selected = NO;
            [self stopTimer];
            [_playerManager stopPlay];
        }
    }
    // 调用播放器 进度条随着播放逐渐减少  ---- 待完善
    if (playButton.selected)
    {
        playButton.selected = NO;
        [self stopTimer];
        [_playerManager stopPlay];
    }
    else
    {
        _ClickedIndex = playButton.tag - kPlayButtonTag;
        playButton.selected = YES;
        NSInteger inde = playButton.tag - kPlayButtonTag;
        [self circlePlayQuestionAndAnswerWithIndex:inde];
    }
}

#pragma mark -- 循环播放当前part的音频
- (void)circlePlayQuestionAndAnswerWithIndex:(NSInteger)index
{
    _currentTestArray = [_playPathArray objectAtIndex:index];
    _markPlayCounts = 0;
    _test_part_sumTime = [OralDBFuncs getTestPartDurationWithPart:(int)index Topic:[OralDBFuncs getCurrentTopic] Username:[OralDBFuncs getCurrentUserName]];
    [self startTimeReduce];
    [self playQuestion_test];
}

#pragma mark -- 播放问题
- (void)playQuestion_test
{
    NSString *questionName = [[_currentTestArray objectAtIndex:_markPlayCounts/2] objectForKey:@"quesUrl"];
    NSString *questionPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO],questionName];
    if ([[NSFileManager defaultManager]fileExistsAtPath:questionPath])
    {
        [_playerManager playerPlayWithFilePath:questionPath];
    }
    else
    {
       // 找不到音频路径
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前路径下找不到音频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertV show];
    }
}

#pragma mark -- 播放回答
- (void)playAnswer_test
{
    NSString *answerName = [[_currentTestArray objectAtIndex:_markPlayCounts/2] objectForKey:@"answerUrl"];
    NSString *answerPath = [NSString stringWithFormat:@"%@/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO],answerName];
    if ([[NSFileManager defaultManager]fileExistsAtPath:answerPath])
    {
        [_playerManager playerPlayWithFilePath:answerPath];
    }
    else
    {
        // 找不到音频路径
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前路径下找不到音频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertV show];
    }
}

#pragma mark -- 播放结束
- (void)playTestFinished:(AudioPlayer *)player
{
    _markPlayCounts++;
    if (_markPlayCounts/2 < _currentTestArray.count)
    {
        if (_markPlayCounts%2)
        {
            // 奇数 播放回答
            [self playAnswer_test];
        }
        else
        {
            [self playQuestion_test];
        }
    }
    else
    {
        // 全部播放完成
        [self stopTimer];
    }
}

#pragma mark -- 开启倒计时
- (void)startTimeReduce
{
    // 此处为 ： 时间进度条减小 获取到所有音频大小 然后加起来 构成倒计时
    // 获取音频文件的时长----待完善
    CustomProgressView *progressV = (CustomProgressView *)[self.view viewWithTag:kProgressViewTag+_ClickedIndex];
    progressV.progress = 1;
    _decreaseRatio = 1.0/_test_part_sumTime/10;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeDaoJiShi) userInfo:nil repeats:YES];
}

#pragma mark -- 停止倒计时
- (void)stopTimer
{
    [_timer invalidate];
     _timer = nil;
}

#pragma mark -- 音频倒计时
- (void)timeDaoJiShi
{
    CustomProgressView *progressV = (CustomProgressView *)[self.view viewWithTag:kProgressViewTag+_ClickedIndex];
    progressV.progress -= _decreaseRatio;
    
    if (progressV.progress<=0)
    {
        [self stopTimer];
        UIButton *playBtn = (UIButton *)[self.view viewWithTag:kPlayButtonTag+_ClickedIndex];
        playBtn.selected = NO;
    }
}

#pragma mark - 闯关
#pragma mark -- 闯关按钮被点击
- (void)partButtonClicked:(UIButton *)btn
{
     // part1 -- 3
    int _enterCurrentPart = (int)(btn.tag-kPartButtonTag+1);
    [OralDBFuncs setCurrentPart:_enterCurrentPart];

    NSDictionary *currentWatingDIc;
    BOOL have_currentPart_review = NO;
    for (NSDictionary *watingDic in _watingInfoArray)
    {
        NSInteger review_partNum = [[watingDic objectForKey:@"part"] intValue];
        if (_enterCurrentPart == review_partNum)
        {
            currentWatingDIc = watingDic;
            have_currentPart_review = YES;
            break;
        }
    }
    
    SCOPartMenuViewController *scoreVC = [[SCOPartMenuViewController alloc]initWithNibName:@"SCOPartMenuViewController" bundle:nil];
    // 首先判断最新一次的闯关是否提交 若果未提交 则肯定没反馈（就算有也是之前的）
    BOOL _commit = [OralDBFuncs getPartLevel3CommitwithTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
    if (have_currentPart_review&&_commit)
    {
        // 提交了 那么有可能有反馈 下面对比当前反馈是否是最新一次的练习的反馈
        NSInteger hissn = [[currentWatingDIc objectForKey:@"hissn"] integerValue];
        NSInteger commitNum = [OralDBFuncs getPartLevel3CommitNumTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
        if (hissn == commitNum)
        {
            scoreVC.review_point_3 = YES;
            scoreVC.review_dict_point_3 = currentWatingDIc;
        }
        else
        {
            scoreVC.review_point_3 = NO;
        }
    }
    [self.navigationController pushViewController:scoreVC animated:YES];
}

#pragma mark - 切换按钮
- (void)segment:(UISegmentedControl *)segment
{
    //    选中的下标
    _backScrollV.contentOffset = CGPointMake(segment.selectedSegmentIndex*kScreentWidth, 0);
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/kScreentWidth;
    _segment.selectedSegmentIndex = page;
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
