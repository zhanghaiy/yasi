//
//  CheckFollowViewController.m
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckFollowViewController.h"
#import "AudioPlayer.h"
#import "CheckSuccessViewController.h"

@interface CheckFollowViewController ()
{
    NSDictionary *_topicInfoDict;// 整个topic信息
    NSDictionary *_currentPartDict;// 当前part资源信息
    NSDictionary *_currentPointDict;// 当前关卡资源信息
    NSArray *_questioListArray;
    NSArray *_currentAnswerListArray;
    
    NSInteger _sumQuestionCounts;//总的问题个数
    NSInteger _currentQuestionCounts;// 当前进行的问题
    NSInteger _sumAnswerCounts;//当前问题的总回答数
    NSInteger _currentAnswerCounts;// 当前回答数
   
    BOOL _currentQuestionFinished;
    BOOL _startAnswer;
    
    AudioPlayer *audioPlayer;
    
    NSInteger _answerTime;//跟读时间
    NSTimer *_reduceTimer;
    CGRect _timeProgressRect;// 用于标记时间进度条的原始frame
}


@end

@implementation CheckFollowViewController
#define kTopQueCountButtonTag 5555

#pragma mark - UI布局
#pragma mark -- 创建提示标签
// 用于提示用户操作成功
- (void)createTipLabel
{
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake((kScreentWidth-100)/2, kScreenHeight-40, 0, 0)];
    tipLab.tag = 1111;
    tipLab.text = @"成功加入练习簿";
    tipLab.backgroundColor = [UIColor whiteColor];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    tipLab.font = [UIFont systemFontOfSize:KFourFontSize];
    tipLab.layer.masksToBounds = YES;
    tipLab.layer.cornerRadius = 3;
    tipLab.layer.borderColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1].CGColor;
    tipLab.layer.borderWidth = 1;
    [self.view addSubview:tipLab];
}


#pragma mark -- UI控件的调整
- (void)uiConfig
{
    // 创建提示标签
    [self createTipLabel];
    // 问题总数View topview
    _questionCountsView.backgroundColor = [UIColor clearColor];
    // 计算出按钮高度  不同尺寸屏幕 高度不同
    NSInteger btnWid = _questionCountsView.frame.size.height/1334*2*kScreenHeight-2*9;
    // 根据总问题数创建按钮
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), 9, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        // 选中
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        btn.tag = kTopQueCountButtonTag+i;
        if (i == 0)
        {
            btn.selected = YES;// 默认：1
        }
        [_questionCountsView addSubview:btn];
    }
    
    // 老师部分控件
    // 老师头像 --- 设置圆角半径 layer
    _teacherHeadImgView.layer.masksToBounds = YES;
    _teacherHeadImgView.layer.cornerRadius = _teacherHeadImgView.bounds.size.height/1334*kScreenHeight;
    _teacherHeadImgView.layer.borderColor = [UIColor colorWithRed:142/255.0 green:232/255.0 blue:208/255.0 alpha:1].CGColor;
    _teacherHeadImgView.layer.borderWidth = 2;
    [_teacherHeadImgView setImage:[UIImage imageNamed:@"touxiang"]];
    
    // 问题背景----layer
    _teacherQueationBackView.layer.masksToBounds = YES;
    _teacherQueationBackView.layer.cornerRadius = _teacherQueationBackView.frame.size.height/1334*kScreenHeight;
    _teacherView.backgroundColor = [UIColor clearColor];
    // 问题文本 多行显示
    _questionTextLabel.text = @"";//起始为空
    _questionTextLabel.textColor = [UIColor colorWithRed:62/255.0 green:66/255.0 blue:67/255.0 alpha:1];
    _questionTextLabel.textAlignment = NSTextAlignmentCenter;
    _questionTextLabel.numberOfLines = 0;
    
    // 学生部分控件
    UIColor *stuColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    _studentView.backgroundColor = [UIColor whiteColor];
    _stuTitleLabel.textColor = stuColor;//跟读颜色
    _stuTitleLabel.text = @"";//起始为空
    [self changeAnswerProgress];//当前回答数：1
    _stuAnswerCountsLabel.textColor = stuColor;
    
    _answerTextLabel.text = @"";//起始为空
    _answerTextLabel.textColor = [UIColor colorWithWhite:125/255.0 alpha:1];
    _answerBottomView.backgroundColor = [UIColor clearColor];
    _lineLabel.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
    // 时间进度条
    _timeProgressLabel.backgroundColor = stuColor;
    // 标记时间进度条原始frame
    CGRect rect = _timeProgressLabel.frame;
    rect.size.width = rect.size.width/375*kScreentWidth;
    _timeProgressLabel.frame = rect;
    _timeProgressRect = rect;
    // 学生头像
    _stuImageView.layer.masksToBounds = YES;
    _stuImageView.layer.cornerRadius = _stuImageView.frame.size.height/667*kScreenHeight/2;
    _stuImageView.layer.borderWidth = 2;
    _stuImageView.layer.borderColor = [UIColor colorWithRed:142/255.0 green:232/255.0 blue:208/255.0 alpha:1].CGColor;
    
    // 分数按钮
    _scoreButton.layer.cornerRadius = _scoreButton.frame.size.height/2;
    [_scoreButton setBackgroundColor:[UIColor colorWithRed:43/255.02 green:217/255.0 blue:149/255.0 alpha:1]];
    // 底部View
    _bottomView.backgroundColor = [UIColor clearColor];
    //隐藏跟读按钮
    _answerButton.hidden = YES;
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    // 下一题
    [_nextButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
    [_nextButton setAdjustsImageWhenHighlighted:YES];
    [_nextButton setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1] forState:UIControlStateHighlighted];
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"nextQuestion"] forState:UIControlStateHighlighted];
    // 加入练习簿
    [_addPracticeButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
    [_addPracticeButton setAdjustsImageWhenHighlighted:YES];
    [_addPracticeButton setBackgroundImage:[UIImage imageNamed:@"exesize"] forState:UIControlStateHighlighted];
    [_addPracticeButton setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1] forState:UIControlStateHighlighted];
    
    // 起始状态：老师头像暗 学生头像 暗 文本不显示
    _teacherHeadImgView.alpha = 0.3;
    _stuImageView.alpha = 0.3;
    _questionTextLabel.text = @"";
    _answerTextLabel.text = @"";
}

#pragma mark - 模拟数据
- (void)moNiDataFromLocal
{
    /*
     数据结构
     
     _topicInfoDict--> topic闯关信息---> dict(字典)
     当前topic所有part--> partListArray = [_topicInfoDict objectForKey:@"partlist"] -->数组
     当前part--> curretPartDict = [partListArray objectAtIndex:_currentPartCounts] -->字典
     当前part的所有关卡信息 -- > pointArray = [curretPart objectForKey:@"levellist"] --> 数组
     当前关卡信息 pointDict = [pointArray objectAtIndex:_currentPointCounts] --> 字典
     pointDict
     
     ----待完善-----
     
     */
    NSString *path = [[NSBundle mainBundle]pathForResource:@"info" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    _topicInfoDict = [dict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    _currentPartDict = [[_topicInfoDict objectForKey:@"partlist"] objectAtIndex:_currentPartCounts];
    // 当前关卡信息
    _currentPointDict = [[_currentPartDict objectForKey:@"levellist"] objectAtIndex:_currentPointCounts];
    // 当前关卡所有问题
    _questioListArray = [_currentPointDict objectForKey:@"questionlist"];
    // 总问题数
    _sumQuestionCounts = _questioListArray.count;
    // 当前进行的问题 起始：0
    _currentQuestionCounts = 0;
    
    // 当前进行的问题的回答列表
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    // 当前问题回答数
    _sumAnswerCounts = _currentAnswerListArray.count;
    // 正在回答数
    _currentAnswerCounts = 0;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _answerTime = 15;
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerCallBack);
    
    [self addBackButtonWithImageName:@"back-white"];
    [self addTitleLabelWithTitleWithTitle:@"Part1-1"];
    self.navTopView.backgroundColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    self.titleLab.textColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [self moNiDataFromLocal];
    [self uiConfig];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self prepareQuestion];
}

#pragma mark - 各阶段逻辑
/*
 以下： 播放问题音频、回答音频 开始跟读 均采用定时器延时 为了实现界面控件先后动画
 */
#pragma mark - - 播放问题准备
- (void)prepareQuestion
{
    _questionTextLabel.font = [UIFont systemFontOfSize:0];
    [self showCurrentQuestionText];
    [UIView animateWithDuration:0.5 animations:^{
        _questionTextLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        _teacherHeadImgView.alpha = 1;
        _stuImageView.alpha = 0.3;
    }];
    
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(willPlayQuestion) userInfo:nil repeats:NO];
}

- (void)willPlayQuestion
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    [self playQuestion];
}

#pragma mark - - 播放回答准备
- (void)prepareAnswer
{
    _answerTextLabel.font = [UIFont systemFontOfSize:0];
    // 文本
    [UIView animateWithDuration:0.5 animations:^{
        [self showCurrentAnswerText];
        _answerTextLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        _teacherHeadImgView.alpha = 1;
        _stuImageView.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(willPlayAnswer) userInfo:nil repeats:NO];
}
- (void)willPlayAnswer
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    [self playAnswer];
}
#pragma mark - - 跟读准备
- (void)prepareFollow
{
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(followTextShow) userInfo:nil repeats:NO];
//    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stuImageBrite) userInfo:nil repeats:NO];
//    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(willFollowRecord) userInfo:nil repeats:NO];
}

#pragma mark ---显示-->请跟读
- (void)followTextShow
{
    [self stopReduceTimer];
    [UIView animateWithDuration:1 animations:^{
        _stuTitleLabel.text = @"请跟读";
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stuImageBrite) userInfo:nil repeats:NO];
}
#pragma mark ---头像-->亮
- (void)stuImageBrite
{
    [self stopReduceTimer];
    [UIView animateWithDuration:1 animations:^{
        _stuImageView.alpha = 1;
        _teacherHeadImgView.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(willFollowRecord) userInfo:nil repeats:NO];
}

#pragma mark ---跟读按钮-->显示
- (void)willFollowRecord
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    _answerButton.hidden = NO;// 展示跟读按钮
    [self answerButtonClicked:_answerButton];
}


#pragma mark - 播放器
#pragma mark -- 播放完成回调
- (void)playerCallBack
{
    NSLog(@"playerCallBack");
    if (_startAnswer==NO)
    {
        // 播放回答音频
        _startAnswer = YES;
        [self prepareAnswer];
    }
    else
    {
        _startAnswer = NO;
        // 跟读 录音 (思必驰)
        [self prepareFollow];
    }
}

#pragma mark -- 播放问题音频
- (void)playQuestion
{
    // 获取音频路径
    NSString *audiourl = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"audiourl"];
    NSArray *audioArr = [audiourl componentsSeparatedByString:@"."];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:[audioArr objectAtIndex:0] ofType:[audioArr lastObject]];
    [audioPlayer playerPlayWithFilePath:audioPath];
}


#pragma mark -- 播放回答音频
- (void)playAnswer
{
    //合成音频路径
    NSString *audiourl = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"audiourl"];
    NSArray *audioArr = [audiourl componentsSeparatedByString:@"."];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:[audioArr objectAtIndex:0] ofType:[audioArr lastObject]];
    [audioPlayer playerPlayWithFilePath:audioPath];
}

#pragma mark - 切换问题变换文本
#pragma mark -- 展示问题文本
- (void)showCurrentQuestionText
{
    _questionTextLabel.text = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"];
//     //服务端提供的文本带有html标签 要去掉
//    NSString *questionStr = [self filterHTML:[dict objectForKey:@"question"]];
}

#pragma mark -- 展示回答文本
- (void)showCurrentAnswerText
{
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    _answerTextLabel.text = [self filterHTML:[[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"]];
}

#pragma mark -- 去掉html标签
-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}


#pragma mark - 模拟思必驰反馈
#pragma mark -- 开启思必驰
- (void)startSBC
{

}

#pragma mark  -- 思必驰反馈（停止思必驰）
- (void)sBCCallBack
{
    // 展示分数
    _timeProgressLabel.hidden = YES;// 隐藏时间进度条
    _timeProgressLabel.frame = _timeProgressRect;//回复时间进度条 以便下次使用
    _stuImageView.hidden = YES;// 隐藏学生头像
    _scoreButton.hidden = NO; // 展示分数区域
    // 展示每个单词发音情况
    
    // 隐藏回答按钮  展示下一题区域
    _answerButton.hidden = YES;
    _addPracticeButton.hidden = NO;
    _nextButton.hidden = NO;
    [_nextButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
    [_addPracticeButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
//    if (_currentQuestionCounts<_sumQuestionCounts)
//    {
//        // 隐藏回答按钮  展示下一题区域
//        _answerButton.hidden = YES;
//        _addPracticeButton.hidden = NO;
//        _nextButton.hidden = NO;
//        [_nextButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
//        [_addPracticeButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
//    }
//    else
//    {
//       // 当前关卡结束 跳转页面
//    }
    
}

#pragma mark - 定时器
#pragma mark -- 时间倒计时
- (void)timeReduce
{
    CGRect rect = _timeProgressLabel.frame;
    float reduceWid = rect.size.width/_answerTime;
    rect.origin.x += reduceWid;
    rect.size.width -= reduceWid;
    _timeProgressLabel.frame = rect;
    _answerTime --;
    if (_answerTime==0)
    {
        [self stopReduceTimer];
        //倒计时结束 停止跟读
        [self answerButtonClicked:_answerButton];
        _answerButton.hidden = YES;
    }
}

#pragma mark -- 关闭定时器
- (void)stopReduceTimer
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
}

#pragma mark - didReceiveMemoryWarning
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

#pragma mark- 跟读按钮被点击
- (IBAction)answerButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected = NO;
        // 停止倒计时
        [self stopReduceTimer];
        // 停止sbc
        [self sBCCallBack];
    }
    else
    {
        btn.selected = YES;
        // 开启思必驰
        [self startSBC];
        // 时间进度条变化
        _timeProgressLabel.frame = _timeProgressRect;
        _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeReduce) userInfo:nil repeats:YES];
    }
}

#pragma mark- 加入练习本
- (IBAction)addPractiseBook:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1]forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"exesize"] forState:UIControlStateNormal];

    // 加入练习
    [self addExsBook];
}


- (IBAction)addPractiseBookTouchDown:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1]forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"exesize"] forState:UIControlStateHighlighted];
}

#pragma mark -- 将当前练习数据加入练习簿
- (void)addExsBook
{
    // 此处将当前练习数据加入练习簿  ---待完成
    
    
    
    // 给用户提示  加入成功
    UILabel *tipLab = (UILabel *)[self.view viewWithTag:1111];
    CGRect rect = tipLab.frame;
    rect.size.width = 100;
    rect.size.height = 30;
    [UIView animateWithDuration:0.5 animations:^{
        tipLab.frame = rect;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(addBookFinished) userInfo:nil repeats:NO];
}

#pragma mark -- 成功加入练习簿
- (void)addBookFinished
{
    [self stopReduceTimer];
    UILabel *tipLab = (UILabel *)[self.view viewWithTag:1111];
    tipLab.frame = CGRectMake((kScreentWidth-100)/2, kScreenHeight-40, 0, 0);
    // 下一题
    [self jugePointIsFinished];
}

#pragma mark - 下一题
- (IBAction)nextQuestion:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1]forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nextQuestion"] forState:UIControlStateNormal];

    // 下一题
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(jugePointIsFinished) userInfo:nil repeats:NO];
//    [self jugePointIsFinished];
}

- (IBAction)nextQuestionTouchDown:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1]forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"nextQuestion"] forState:UIControlStateHighlighted];

}

#pragma mark -- 下一问题
- (void)next
{
    _stuTitleLabel.text = @"";
    if (_currentAnswerCounts<_sumAnswerCounts)
    {
        // 继续当前问题
        [self changeAnswerProgress];
        _startAnswer = YES;//标记 用于播放器回调方法
        [self prepareAnswer];
    }
    else
    {
        // 下一题
        [self questionCountChanged];//标记当前进行的问题数
        _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
        [self prepareQuestion];
    }
}



#pragma mark - 判断闯关是否结束
- (void)jugePointIsFinished
{
    [self stopReduceTimer];
    _answerTime = 15;
    // 隐藏下一问题按钮区域
    _nextButton.hidden = YES;
    _addPracticeButton.hidden = YES;
    _nextButton.selected = NO;
    _addPracticeButton.selected = NO;
    // 隐藏分数 显示学生头像 时间进度条
    _scoreButton.hidden = YES;
    _timeProgressLabel.hidden = NO;
    _stuImageView.hidden = NO;
    
    _currentAnswerCounts++;// 当前回答数+1
    if (_currentAnswerCounts>=_sumAnswerCounts)
    {
        _currentAnswerCounts = 0;
        _currentQuestionCounts ++;
    }
    
    if (_currentQuestionCounts<_sumQuestionCounts)
    {
        [self next];
    }
    else
    {
        //关卡结束 跳转过渡页
        CheckSuccessViewController *successVC = [[CheckSuccessViewController alloc]initWithNibName:@"CheckSuccessViewController" bundle:nil];
        [self.navigationController pushViewController:successVC animated:YES];
    }
}


#pragma mark -- 标记当前进行的问题数
- (void)questionCountChanged
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



#pragma mark -- 动态改变当前回答进度
- (void)changeAnswerProgress
{
    _stuAnswerCountsLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentAnswerCounts+1,_sumAnswerCounts];
}





#pragma mark - 界面将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    audioPlayer.target = nil;
    if (_reduceTimer != nil)
    {
        [self stopReduceTimer];
    }
}

@end
