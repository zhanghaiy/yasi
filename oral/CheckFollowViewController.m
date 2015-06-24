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
#import "TPCCheckpointViewController.h"
#import "DFAiengineSentObject.h"
#import "OralDBFuncs.h"


@interface CheckFollowViewController ()<DFAiengineSentProtocol,UIWebViewDelegate>
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
    
    DFAiengineSentObject *_dfEngine;
    
    NSString *_currentAnswerId;
    NSString *_currentAnswerHtml;
    NSString *_currentAnswerText;
    NSString *_currentAnswerAudioName;// 自己录音
    NSString *_currentAnswerReferAudioName;// 参考录音
    int _currentAnswerScore;
    int _currentAnswerPron;
    int _currentAnswerIntegrity;
    int _currentAnswerFluency;
    
    float _sumScore;
    int _sumCounts;
    NSMutableArray *_markAllAnswerIdArray;
}


@end

@implementation CheckFollowViewController
#define kTopQueCountButtonTag 5555
#define kFollowLabelTag 222
#define kAnswerTextLabelTag 223
#define kQuestionTextLabelTag 224


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
    tipLab.textColor = _backgroundViewColor;
    tipLab.font = [UIFont systemFontOfSize:KFourFontSize];
    tipLab.layer.masksToBounds = YES;
    tipLab.layer.cornerRadius = 3;
    tipLab.layer.borderColor = _backgroundViewColor.CGColor;
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
    // 按钮高度
    NSInteger countViewHeight = _questionCountsView.frame.size.height;
    NSInteger btnWid = 30;
    // 根据总问题数创建按钮
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), (countViewHeight-btnWid)/2, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        // 选中
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:_backColor forState:UIControlStateNormal];
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
    _teacherHeadImgView.layer.cornerRadius = _teacherHeadImgView.bounds.size.height/2;
    _teacherHeadImgView.layer.borderColor = _backColor.CGColor;
    _teacherHeadImgView.layer.borderWidth = 2;
    [_teacherHeadImgView setImage:[UIImage imageNamed:@"touxiang"]];
    
    // 问题背景----layer
    _teacherQueationBackView.layer.masksToBounds = YES;
    _teacherQueationBackView.layer.cornerRadius = _teacherQueationBackView.frame.size.height/2;
    _teacherView.backgroundColor = [UIColor clearColor];
    // 问题文本 多行显示
    _questionTextLabel.text = @"";//起始为空
    _questionTextLabel.textColor = _textColor;
    _questionTextLabel.textAlignment = NSTextAlignmentCenter;
    _questionTextLabel.numberOfLines = 0;
    
    // 学生部分控件
    _studentView.backgroundColor = [UIColor whiteColor];
    _stuTitleLabel.textColor = _backColor;//跟读颜色
    _stuTitleLabel.text = @"";//起始为空
    [self changeAnswerProgress];//当前回答数：1
    _stuAnswerCountsLabel.textColor = _backColor;

    // webView
    _answerTextWebView.hidden = NO;
    _answerTextWebView.delegate =self;
    
    _lineLabel.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
    // 时间进度条
    _timeProgressLabel.backgroundColor = _backColor;
    
    _studentView.frame = CGRectMake(15, 216, kScreentWidth-30,  kScreenHeight-216-162);
    
    // 标记时间进度条原始frame
    CGRect rect = _timeProgressLabel.frame;
    rect.size.width = kScreentWidth-130;
    rect.origin.x = 15;
    rect.origin.y = _studentView.frame.size.height-41;
    _timeProgressLabel.frame = rect;
    _timeProgressRect = rect;
    // 学生头像
    _stuImageView.layer.masksToBounds = YES;
    _stuImageView.layer.cornerRadius = _stuImageView.frame.size.height/2;
    _stuImageView.layer.borderWidth = 2;
    _stuImageView.layer.borderColor = _backColor.CGColor;
    
    // 分数按钮
    _scoreButton.layer.cornerRadius = _scoreButton.frame.size.height/2;
    [_scoreButton setBackgroundColor:_backColor];
    //隐藏跟读按钮
    _answerButton.hidden = YES;
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    // 下一题
    [_nextButton setTitleColor:_pointColor forState:UIControlStateNormal];
    [_nextButton setAdjustsImageWhenHighlighted:NO];
    _nextButton.layer.masksToBounds = YES;
    _nextButton.layer.cornerRadius = _nextButton.frame.size.height/2;
    [_nextButton setBackgroundColor:[UIColor whiteColor]];
    
    
    // 加入练习簿
    [_addPracticeButton setTitleColor:_pointColor forState:UIControlStateNormal];
    [_addPracticeButton setAdjustsImageWhenHighlighted:YES];
    _addPracticeButton.layer.masksToBounds = YES;
    _addPracticeButton.layer.cornerRadius = _addPracticeButton.frame.size.height/2;
    [_addPracticeButton setBackgroundColor:[UIColor whiteColor]];
    
    _nextButton.hidden = YES;
    _addPracticeButton.hidden = YES;
    
    
    // 起始状态：老师头像暗 学生头像 暗 文本不显示
    _teacherHeadImgView.alpha = 0.3;
    _stuImageView.alpha = 0.3;
    _questionTextLabel.text = @"";
    
    _stuTitleLabel.tag = kFollowLabelTag;
    _questionTextLabel.tag = kQuestionTextLabelTag;
    
    // 回答区域圆角
    _studentView.layer.cornerRadius = 5;
    
    _stuTitleLabel.backgroundColor =[UIColor clearColor];
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
     */
    
    NSString *jsonPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/info.json",[OralDBFuncs getCurrentTopic]];

    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    _topicInfoDict = [dict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSLog(@"%d  %d",[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint]);
    _currentPartDict = [[_topicInfoDict objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    // 当前关卡信息 关卡一
    _currentPointDict = [[_currentPartDict objectForKey:@"levellist"] objectAtIndex:[OralDBFuncs getCurrentPoint]-1];
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
    
    _sumCounts = 0;
    _sumScore = 0;
    _markAllAnswerIdArray = [[NSMutableArray alloc]init];
    
    [OralDBFuncs setCurrentPoint:1];
    
    
    _answerTime = KAnswerSumTime;
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerCallBack);
    
    NSString *title = [NSString stringWithFormat:@"Part%d-%d",[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint]];
    [self addTitleLabelWithTitleWithTitle:title];
    self.navTopView.backgroundColor = _backColor;
    self.titleLab.textColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [self moNiDataFromLocal];
    [self uiConfig];
    
    _dfEngine = [[DFAiengineSentObject alloc]initSentEngine:self withUser:@"cocim_haiyan"];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self prepareQuestion];
}

#pragma mark - 各阶段逻辑
#pragma mark - - 文字动画
- (void)textAnimationInView:(UIView *)lable
{
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:lable cache:YES];
    [self showCurrentQuestionText];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
}

/*
 以下： 播放问题音频、回答音频 开始跟读 均采用定时器延时 为了实现界面控件先后动画
 */
#pragma mark - 播放问题准备
#pragma mark - 播放之前动画
- (void)prepareQuestion
{
    _questionTextLabel.font = [UIFont systemFontOfSize:0];
    [self showCurrentQuestionText];
    [self textAnimationInView:_questionTextLabel];
    [UIView animateWithDuration:0.5 animations:^{
        _questionTextLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        _teacherHeadImgView.alpha = 1;
        _stuImageView.alpha = 0.3;
    }];
    
   [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(playQuestion) userInfo:nil repeats:NO];
}

#pragma mark -- 播放问题音频
- (void)playQuestion
{
    // 获取音频路径
    NSString *audiourl = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"audiourl"];
    
    NSString *audioPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/%@",[OralDBFuncs getCurrentTopic],audiourl];
    NSLog(@"%@",audioPath);
    [audioPlayer playerPlayWithFilePath:audioPath];
}


#pragma mark - 播放回答准备
#pragma mark - 回答前动画
- (void)prepareAnswer
{
    // 文本
    [self showCurrentAnswerText];
    [UIView animateWithDuration:0.5 animations:^{
        
        _teacherHeadImgView.alpha = 1;
        _stuImageView.alpha = 0.3;
        
    }];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playAnswer) userInfo:nil repeats:NO];
}

#pragma mark - 播放回答音频
- (void)playAnswer
{
    //合成音频路径
    NSString *audiourl = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"audiourl"];
    NSString *audioPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/%@",[OralDBFuncs getCurrentTopic],audiourl];
    [audioPlayer playerPlayWithFilePath:audioPath];
    
    NSString *answerid = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"id"];
    [_markAllAnswerIdArray addObject:answerid];
}

#pragma mark - 播放完成回调
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


#pragma mark - 跟读准备
#pragma mark - 动画
- (void)prepareFollow
{
    // 停顿 1S
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(followTextShow) userInfo:nil repeats:NO];
}

#pragma mark - 显示-->请跟读
- (void)followTextShow
{
    [self stopReduceTimer];
    _stuTitleLabel.text = @"请跟读";
    [self textAnimationInView:_stuTitleLabel];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stuImageBrite) userInfo:nil repeats:NO];
}

#pragma mark - 头像-->亮
- (void)stuImageBrite
{
    [self stopReduceTimer];
    [UIView animateWithDuration:1 animations:^{
        _stuImageView.alpha = 1;
        _teacherHeadImgView.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(willFollowRecord) userInfo:nil repeats:NO];
}

#pragma mark - 跟读按钮-->显示
- (void)willFollowRecord
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    _answerButton.hidden = NO;// 展示跟读按钮
    [self answerButtonClicked:_answerButton];
}


#pragma mark - 切换问题变换文本
#pragma mark - 展示问题文本
- (void)showCurrentQuestionText
{
    _questionTextLabel.text = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"];
}

#pragma mark - 展示回答文本
- (void)showCurrentAnswerText
{
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    NSString *str = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"] ;
    [_answerTextWebView loadHTMLString:str baseURL:nil];
}

#pragma mark - webViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *bodyStyleVertical = @"document.getElementsByTagName('body')[0].style.verticalAlign = 'middle';";
    NSString *bodyStyleHorizontal = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";
    
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleVertical];
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleHorizontal];
    [webView stringByEvaluatingJavaScriptFromString:mapStyle];
}

#pragma mark - 去掉html标签 (未用到----2015.06.11)
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
    return html;
}


#pragma mark - 思必驰语音引擎
#pragma mark - 开启思必驰引擎
- (void)startSBCAiengine
{
    NSString *text = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"];
    if(_dfEngine)
        [_dfEngine startEngineFor:[self filterHTML:text]];
}
#pragma mark - 结束思必驰引擎
- (void)stopSBCAiengine
{
    // 展示分数
    [_dfEngine stopEngine];
    
}

#pragma mark - 思必驰反馈
-(void)processAiengineSentResult:(DFAiengineSentResult *)result
{
//    NSDictionary *fluency = result.fluency;
//    NSString *msg = [NSString stringWithFormat:@"总体评分：%d\n发音：%d，完整度：%d，流利度：%d", result.overall, result.pron, result.integrity, ((NSNumber *)[fluency objectForKey:@"overall"]).intValue];
//    NSLog(@"%@",msg);
//    [self performSelectorOnMainThread:@selector(showResult:) withObject:[NSString stringWithFormat:@"%d",result.overall] waitUntilDone:NO];
    
//    NSString *msg1 = [_dfEngine getRichResultString:result.details];
//    NSLog(@"%@",msg1);
//    [self performSelectorOnMainThread:@selector(showHtmlMsg:) withObject:msg1 waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(showResult:) withObject:result waitUntilDone:NO];
    
}



#pragma mark - 思必驰反馈信息
- (void)showResult:(DFAiengineSentResult *)result
{
    // 若思必驰出错 停止
    if (_reduceTimer)
    {
        [_reduceTimer invalidate];
        _reduceTimer = nil;
        _answerButton.selected = NO;
    }
    // 获取录音时长
    long recordTime = result.systime;
    // 增加录音时长
    [OralDBFuncs addPlayTime:recordTime ForUser:[OralDBFuncs getCurrentUserName]];
    // 转移思必驰录音 清空原有的
    NSString *sbcPath = [NSString stringWithFormat:@"%@/Documents/record/%@.wav",NSHomeDirectory(),result.recordId];
    NSString *sbcToPath =  [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/part%d-%d-%ld-%ld.wav",[OralDBFuncs getCurrentTopic],[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint],_currentQuestionCounts+1,_currentAnswerCounts+1];
    NSData *fileData = [NSData dataWithContentsOfFile:sbcPath];
    BOOL saveSuc = [fileData writeToFile:sbcToPath atomically:YES];
    if (saveSuc)
    {
        // 删除原来的文件
        [[NSFileManager defaultManager]removeItemAtPath:sbcPath error:nil];
    }
    
    // 存储的字段赋值
    NSString *msg1 = [_dfEngine getRichResultString:result.details];
    _currentAnswerHtml = msg1;
    [_answerTextWebView loadHTMLString:_currentAnswerHtml baseURL:nil];
    _currentAnswerScore = result.overall;
    _currentAnswerIntegrity = result.integrity;
    _currentAnswerFluency = [[result.fluency objectForKey:@"overall"] intValue];
    _currentAnswerPron = result.pron;
    _currentAnswerAudioName = [[sbcToPath componentsSeparatedByString:@"/"] lastObject];
    _currentAnswerReferAudioName = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"audiourl"];
    NSLog(@"%@",_currentAnswerReferAudioName);
    _currentAnswerId = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"id"];
    NSLog(@"%@",_currentAnswerId);
    
    NSLog(@"%d",[OralDBFuncs getCurrentPart]);
    
    // 存储一条记录 到数据库
    BOOL saveSuccess = [OralDBFuncs replaceLastRecordFor:[OralDBFuncs getCurrentUserName] TopicName:[OralDBFuncs getCurrentTopic] answerId:_currentAnswerId partNum:[OralDBFuncs getCurrentPart] levelNum:[OralDBFuncs getCurrentPoint] withRecordId:[OralDBFuncs getCurrentRecordId] lastText:_currentAnswerHtml lastScore:_currentAnswerScore lastPron:_currentAnswerPron lastIntegrity:_currentAnswerIntegrity lastFluency:_currentAnswerFluency lastAudioName:_currentAnswerAudioName];
    NSLog(@"saveSuccess:%d",saveSuccess);
    
    _timeProgressLabel.hidden = YES;// 隐藏时间进度条
    _timeProgressLabel.frame = _timeProgressRect;//回复时间进度条 以便下次使用
    _stuImageView.hidden = YES;// 隐藏学生头像
    _scoreButton.hidden = NO;
    
    // 隐藏回答按钮  展示下一题区域
    _answerButton.hidden = YES;
    _addPracticeButton.hidden = NO;
    _nextButton.hidden = NO;
    
    /*
     根据反馈结果填空
     0,213,136  绿色  80<=x<=100
     246,215,0  黄色  60<=x<80
     212,0,44   红色   0<=x<60
     待完善
     */
    NSArray *colorArray = @[_perfColor,_goodColor,_badColor];
    int scoreCun = _currentAnswerScore>=80?0:(_currentAnswerScore>=60?1:2);
    [_scoreButton setTitle:[NSString stringWithFormat:@"%d",_currentAnswerScore] forState:UIControlStateNormal];
    [_scoreButton setBackgroundColor:[colorArray objectAtIndex:scoreCun]];
    
    _sumScore += _currentAnswerScore;
    _sumCounts ++;
}



#pragma mark - 定时器
#pragma mark -  时间倒计时
- (void)timeReduce
{
    CGRect rect = _timeProgressLabel.frame;
    rect.origin.x ++;
    rect.size.width --;
    _timeProgressLabel.frame = rect;
    if (rect.size.width<=0)
    {
        [self stopReduceTimer];
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
        // 停止sbc
        [self stopSBCAiengine];
        // 停止倒计时
        [self stopReduceTimer];
    }
    else
    {
        btn.selected = YES;
        // 开启思必驰
        [self startSBCAiengine];
        // 时间进度条变化
        _timeProgressLabel.frame = _timeProgressRect;
        float widdd = _timeProgressRect.size.width;
        float time = _answerTime/widdd;
        _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timeReduce) userInfo:nil repeats:YES];
    }
}

#pragma mark - 加入练习本
- (IBAction)addPractiseBook:(id)sender
{
    // 加入练习
    
     // 此处将当前练习数据加入练习簿
    NSString *_tipStr;
    NSString *pracAnswerAudioName = [NSString stringWithFormat:@"practice-%@",_currentAnswerAudioName];
    
    NSString *pracPath =  [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/%@",[OralDBFuncs getCurrentTopic],_currentAnswerAudioName];
    
    NSString *pracToPath =  [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/%@",[OralDBFuncs getCurrentTopic],pracAnswerAudioName];
    
    NSData *praData = [NSData dataWithContentsOfFile:pracPath];
    [praData writeToFile:pracToPath atomically:YES];
    // 加入练习簿
    BOOL suc = [OralDBFuncs addPracticeBookRecordFor:[OralDBFuncs getCurrentUserName] withAnswerId:_currentAnswerId andReferAudioName:_currentAnswerReferAudioName andLastAUdioName:pracAnswerAudioName andLastText:_currentAnswerHtml andLastScore:_currentAnswerScore Pron:_currentAnswerPron Integrity:_currentAnswerIntegrity fluency:_currentAnswerFluency];
    NSLog(@"%d",suc);
    if (suc)
    {
        _tipStr = @"成功加入练习簿";
        NSString *text = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"];
        
        [OralDBFuncs setAddPracticeTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] AnswerId:_currentAnswerId   AnswerText:text];
    }
    else
    {
        _tipStr = @"加入练习簿失败";
    }

    // 给用户提示  加入是否成功
    UILabel *tipLab = (UILabel *)[self.view viewWithTag:1111];
    CGRect rect = tipLab.frame;
    rect.size.width = 100;
    rect.size.height = 30;
    [UIView animateWithDuration:0.5 animations:^{
        tipLab.frame = rect;
    }];
    tipLab.text = _tipStr;
    tipLab.textColor = _pointColor;
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(addBookFinished) userInfo:nil repeats:NO];
}


#pragma mark -- 成功加入练习簿
- (void)addBookFinished
{
    [self stopReduceTimer];
    UILabel *tipLab = (UILabel *)[self.view viewWithTag:1111];
    tipLab.frame = CGRectMake((kScreentWidth-100)/2, kScreenHeight-40, 0, 0);
    // 下一题
    [self jugePointIsFinished_follow];
}

#pragma mark - 下一题
- (IBAction)nextQuestion:(id)sender
{
    // 下一题
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(jugePointIsFinished_follow) userInfo:nil repeats:NO];
}


#pragma mark - 判断闯关是否结束
- (void)jugePointIsFinished_follow
{
    [self stopReduceTimer];
    _answerTime = KAnswerSumTime;
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
        if (_currentQuestionCounts<_sumQuestionCounts)
        {
            // 下一题
            [self questionCountChanged1];//标记当前进行的问题数
            [self changeAnswerProgress];
            _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
            [self prepareQuestion];
        }
        else
        {
            //关卡结束 跳转过渡页
            //计算总分 存储记录 提交服务端 (网络提交暂时搁置)
            float levelScore = _sumScore/_sumCounts;
            [OralDBFuncs updateTopicRecordFor:[OralDBFuncs getCurrentUserName] with:[OralDBFuncs getCurrentTopic] part:[OralDBFuncs getCurrentPart] level:[OralDBFuncs getCurrentPoint] andScore:levelScore];
            NSLog(@"~~~~~~~~~~~~~~~");
            
            CheckSuccessViewController *successVC = [[CheckSuccessViewController alloc]initWithNibName:@"CheckSuccessViewController" bundle:nil];
            [self.navigationController pushViewController:successVC animated:YES];
        }
        
    }
    else
    {
        // 继续当前问题
        [self changeAnswerProgress];
        _startAnswer = YES;//标记 用于播放器回调方法
        [self prepareAnswer];
    }
}


#pragma mark -- 标记当前进行的问题数
- (void)questionCountChanged1
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
     _dfEngine = nil;
}

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

@end
