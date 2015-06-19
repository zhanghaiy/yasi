//
//  CheckScoreViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckScoreViewController.h"
#import "ScoreDetailViewController.h"
#import "ScoreMenuTestView.h"
#import "CustomProgressView.h"// 进度条
#import "ScoreTestMenuViewController.h"
#import "OralDBFuncs.h"

@interface CheckScoreViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_backScrollV;
    UISegmentedControl *_segment;
    float _decreaseRatio;// 根据音频时间换算出进度条每次减少的比率
    NSInteger _ClickedIndex;
    NSTimer *_timer;
    
    NSArray *_partListArray;
    int _currentPlayCount;
    NSMutableArray *_playPathArray;
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
    NSString *jsonPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicTest/temp/mockinfo.json",[OralDBFuncs getCurrentTopic]];
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
            NSString *answerAudioUrl = [NSString stringWithFormat:@"test%d-%d.wav",i+1,j+1];
            NSDictionary *dic = @{@"quesUrl":questionAudioUrl,@"answerUrl":answerAudioUrl};
            [part_alone_array addObject:dic];
        }
        [_playPathArray addObject:part_alone_array];
    }
    
}


#pragma mark - 数据加载
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
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
    for (int i = 0; i < 3; i ++)
    {
        // 40 40
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 20+i*100, kScreentWidth-80, 30)];
        label.text = [NSString stringWithFormat:@"Part%d",i+1];
        label.textColor = _pointColor;
        label.font = [UIFont systemFontOfSize:kFontSize1];
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
        NSLog(@"~~~~~~~~%ld",progressV.tag);

    }
    
    // 提交按钮
    NSInteger yyy = kScreenHeight<500?(kScreenHeight-kTestCommitButtonHeight-10-100):380;
    UIButton *commitTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitTestButton setFrame:CGRectMake((kScreentWidth-kTestCommitButtonWidth)/2, yyy, kTestCommitButtonWidth, kTestCommitButtonHeight)];
    
    // 一共三种状态 1：未提交 --》tijiao geilaoshi 
    
    [commitTestButton setTitle:@"提交给老师" forState:UIControlStateNormal];
    [commitTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitTestButton setTitle:@"查看反馈" forState:UIControlStateSelected];
    [commitTestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    commitTestButton.layer.cornerRadius = kTestCommitButtonHeight/2;
    commitTestButton.backgroundColor = _pointColor;
    commitTestButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [commitTestButton addTarget:self action:@selector(commitTest:) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollV addSubview:commitTestButton];
    
    
    // 判断是否莫考过 --- 未完待续
    
    
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

#pragma mark - 模考
#pragma mark - - 提交模考
- (void)commitTest:(UIButton *)commitButton
{
    // 1：未提交给老师 提交老师  2：已经提交 但是未反馈 3：老师已反馈
    ScoreTestMenuViewController *testVC = [[ScoreTestMenuViewController alloc]init];
    [self.navigationController pushViewController:testVC animated:YES];
}
#pragma mark - - 播放音频按钮点击事件
- (void)playButtonClicked:(UIButton *)playButton
{
    // 调用播放器 进度条随着播放逐渐减少  ---- 待完善
    if (playButton.selected)
    {
        playButton.selected = NO;
    }
    else
    {
        _ClickedIndex = playButton.tag - kPlayButtonTag;
        playButton.selected = YES;
    }
    
    switch (playButton.tag - kPlayButtonTag)
    {
        case 0:
        {
            // part1
        }
            break;
        case 1:
        {
            // part2
        }
            break;
        case 2:
        {
           // part3
        }
            break;
        default:
            break;
    }
}

// 循环播放当前part的音频 ----- 待完善
- (void)circlePlayQuestionAndAnswerWithIndex:(int)index
{
    NSArray *partAttay = [_playPathArray objectAtIndex:index];
    
}



- (void)startPlay
{
    // 此处为 ： 时间进度条减小 获取到所有音频大小 然后加起来 构成倒计时
    // 获取音频文件的时长----待完善
    CustomProgressView *progressV = (CustomProgressView *)[self.view viewWithTag:kProgressViewTag+_ClickedIndex];
    progressV.progress = 1;
    _decreaseRatio = 1.0/4.2/10;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeDaoJiShi) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    [_timer invalidate];
     _timer = nil;
}

#pragma mark - - 音频倒计时
- (void)timeDaoJiShi
{
    CustomProgressView *progressV = (CustomProgressView *)[self.view viewWithTag:kProgressViewTag+_ClickedIndex];
    NSLog(@"~~~~~~~~%ld",progressV.tag);
    progressV.progress -= _decreaseRatio;
    NSLog(@"%f",progressV.progress);
    
    if (progressV.progress<=0)
    {
        [self stopTimer];
        UIButton *playBtn = (UIButton *)[self.view viewWithTag:kPlayButtonTag+_ClickedIndex];
        playBtn.selected = NO;
    }
}

#pragma mark - 闯关
#pragma mark - - 闯关按钮被点击
- (void)partButtonClicked:(UIButton *)btn
{
     // part1 -- 3
    ScoreDetailViewController *scoreVC = [[ScoreDetailViewController alloc]initWithNibName:@"ScoreDetailViewController" bundle:nil];
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
