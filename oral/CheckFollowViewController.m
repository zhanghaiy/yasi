//
//  CheckFollowViewController.m
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckFollowViewController.h"
#import "AudioPlayer.h"


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

#pragma mark - 标记当前进行的问题数
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

#pragma mark - UI控件的调整
- (void)uiConfig
{
    // 问题总数View
    _questionCountsView.backgroundColor = [UIColor clearColor];
    NSInteger btnWid = _questionCountsView.frame.size.height/1334*2*kScreenHeight-2*9;
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), 9, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        btn.tag = kTopQueCountButtonTag+i;
        if (i == 0)
        {
            btn.selected = YES;
        }
        [_questionCountsView addSubview:btn];
    }
    
    // 老师部分控件
    _teacherHeadImgView.layer.masksToBounds = YES;
    _teacherHeadImgView.layer.cornerRadius = _teacherHeadImgView.bounds.size.height/1334*kScreenHeight;
    //    _teacherHeadImgView.backgroundColor = [UIColor purpleColor];
    _teacherHeadImgView.layer.borderColor = [UIColor colorWithRed:142/255.0 green:232/255.0 blue:208/255.0 alpha:1].CGColor;
    [_teacherHeadImgView setImage:[UIImage imageNamed:@"touxiang"]]
    ;
    _teacherHeadImgView.layer.borderWidth = 2;
    
    _teacherQueationBackView.layer.masksToBounds = YES;
    _teacherQueationBackView.layer.cornerRadius = _teacherQueationBackView.frame.size.height/1334*kScreenHeight;
    //    _teacherQueationBackView.backgroundColor = [UIColor purpleColor];
    _teacherView.backgroundColor = [UIColor clearColor];
    
    _questionTextLabel.text = @"What is your favourite animal?";
    _questionTextLabel.textColor = [UIColor colorWithRed:62/255.0 green:66/255.0 blue:67/255.0 alpha:1];
    _questionTextLabel.textAlignment = NSTextAlignmentCenter;
    _questionTextLabel.numberOfLines = 0;
    
    // 学生部分控件
    UIColor *stuColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    _studentView.backgroundColor = [UIColor whiteColor];
    _stuTitleLabel.textColor = stuColor;//跟读颜色
    [self changeAnswerProgress];//当前回答数：1
    _stuAnswerCountsLabel.textColor = stuColor;
    _answerTextLabel.textColor = [UIColor colorWithWhite:125/255.0 alpha:1];
    _answerBottomView.backgroundColor = [UIColor clearColor];
    _lineLabel.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
    
    _timeProgressLabel.backgroundColor = stuColor;
    
    _stuImageView.layer.masksToBounds = YES;
    _stuImageView.layer.cornerRadius = _stuImageView.frame.size.height/667*kScreenHeight/2;
    _stuImageView.layer.borderWidth = 2;
    _stuImageView.layer.borderColor = [UIColor colorWithRed:142/255.0 green:232/255.0 blue:208/255.0 alpha:1].CGColor;
    
    CGRect rect = _timeProgressLabel.frame;
    rect.size.width = rect.size.width/375*kScreentWidth;
    _timeProgressLabel.frame = rect;
    _timeProgressRect = rect;
    
    //显示英文文本  问题 回答
    [self showCurrentQuestionText];
    [self showCurrentAnswerText];
    
    // 分数按钮
    _scoreButton.layer.cornerRadius = _scoreButton.frame.size.height/2;
    [_scoreButton setBackgroundColor:[UIColor colorWithRed:43/255.02 green:217/255.0 blue:149/255.0 alpha:1]];
    
    _bottomView.backgroundColor = [UIColor clearColor];
    _answerButton.hidden = YES;
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    // 加入练习簿 下一题
    [_nextButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
    [_addPracticeButton setTitleColor:[UIColor colorWithWhite:112/255.0 alpha:1] forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1] forState:UIControlStateSelected];
    [_addPracticeButton setTitleColor:[UIColor colorWithRed:131/255.0 green:230/255.0 blue:204/255.0 alpha:1] forState:UIControlStateSelected];
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
    
    [self playQuestion];
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
        [self playAnswer];
    }
    else
    {
        _startAnswer = NO;
        // 跟读 录音 (思必驰)
        _answerButton.hidden = NO;// 展示跟读按钮
       
        [self answerButtonClicked:_answerButton];
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
    // 文本
    [self showCurrentAnswerText];
    //合成音频路径
    NSString *audiourl = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"audiourl"];
    NSArray *audioArr = [audiourl componentsSeparatedByString:@"."];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:[audioArr objectAtIndex:0] ofType:[audioArr lastObject]];
    [audioPlayer playerPlayWithFilePath:audioPath];
}

#pragma mark - 展示问题文本
- (void)showCurrentQuestionText
{
    _questionTextLabel.text = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"];
//     //服务端提供的文本带有html标签 要去掉
//    NSString *questionStr = [self filterHTML:[dict objectForKey:@"question"]];
}

#pragma mark - 展示回答文本
- (void)showCurrentAnswerText
{
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    _answerTextLabel.text = [self filterHTML:[[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"]];
    //    _answerTextLabel.text = [self makeUpBlankStringWithDict:dict];
}

#pragma mark - 去掉html标签
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

#pragma mark - 组成填空的字符串（part2用到）暂时放着
- (NSString *)makeUpBlankStringWithDict:(NSDictionary *)dict
{
    NSMutableString *blankStr = [NSMutableString stringWithString:[self filterHTML:[dict objectForKey:@"answer"]]];
    NSString *keyWord = [self filterHTML:[dict objectForKey:@"keyword"]];
    NSArray *keyArray = [keyWord componentsSeparatedByString:@"||"];
    for (int i = 0; i < keyArray.count; i ++)
    {
        NSRange keyRange = [blankStr rangeOfString:[keyArray objectAtIndex:i]];
        if (keyRange.location != NSNotFound)
        {
            [blankStr replaceCharactersInRange:keyRange withString:@"______"];
        }
    }
    return blankStr;
}

#pragma mark - 模拟思必驰反馈
#pragma mark - 开启思必驰
- (void)startSBC
{

}

#pragma mark - 思必驰反馈（停止思必驰）
- (void)sBCCallBack
{
    // 展示分数
    _timeProgressLabel.hidden = YES;// 隐藏时间进度条
    _timeProgressLabel.frame = _timeProgressRect;//回复时间进度条 以便下次使用
    _stuImageView.hidden = YES;// 隐藏学生头像
    _scoreButton.hidden = NO; // 展示分数区域
    
    // 隐藏回答按钮  展示下一题区域
    _answerButton.hidden = YES;
    _addPracticeButton.hidden = NO;
    _nextButton.hidden = NO;
    
    // 展示每个单词发音情况
    
    
}

#pragma mark - 时间倒计时
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
        //倒计时结束 停止跟读
        [self answerButtonClicked:_answerButton];
        _answerButton.hidden = YES;
    }
}

#pragma mark - 关闭定时器
- (void)stopReduceTimer
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

- (IBAction)addPractiseBook:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected  = NO;
    }
    else
    {
        btn.selected  = YES;
    }
    // 加入练习
    
    // 下一题
    [self next];
}

- (IBAction)nextQuestion:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected  = NO;
    }
    else
    {
        btn.selected  = YES;
    }
    // 下一题
    [self next];
}

- (void)next
{
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
    if (_currentAnswerCounts<_sumAnswerCounts)
    {
        // 继续当前问题
        _startAnswer = YES;//标记 用于播放器回调方法
        [self playAnswer];
    }
    else
    {
        // 进行下一问题
        _currentQuestionCounts++;// 当前问题数加1
        if (_currentQuestionCounts<_sumQuestionCounts)
        {
            // 下一题
            [self questionCountChanged];//标记当前进行的问题数
            _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
            [self playQuestion];

        }
        else
        {
            // 所有问题回答完毕
            
        }
    }
}

#pragma mark - 动态改变当前回答进度
- (void)changeAnswerProgress
{
    _stuAnswerCountsLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentAnswerCounts+1,_sumAnswerCounts];
}

@end
