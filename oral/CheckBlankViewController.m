//
//  CheckBlankViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckBlankViewController.h"
#import "AudioPlayer.h"
#import "CheckSuccessViewController.h"
#import "TPCCheckpointViewController.h"
#import "DFAiengineSentObject.h"
#import "OralDBFuncs.h"
#import "NSString+CalculateStringSize.h"

@interface CheckBlankViewController ()<DFAiengineSentProtocol,UIWebViewDelegate>
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
    
    NSMutableArray *_saveAnswerIdArray;
    UIWebView *_answerTextWebV;
    
    BOOL _showReview_Html;
}
@end

@implementation CheckBlankViewController
#define kTopQueCountButtonTag 555
#define kFollowLabelTag 333
#define kAnswerTextLabelTag 334
#define kQuestionTextLabelTag 335

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _saveAnswerIdArray = [[NSMutableArray alloc]init];
    _sumScore = 0;
    _sumCounts = 0;
    _answerTime = KAnswerSumTime;
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerEnd);
    _currentPointCounts = 1;
    _showReview_Html = NO;
    
    // 设置当前关卡
    [OralDBFuncs setCurrentPoint:2];
    
    // 顶部title
    NSString *title = [NSString stringWithFormat:@"Part%d-%d",[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint]];
    [self addTitleLabelWithTitle:title];
    
    self.navTopView.backgroundColor = _backColor;
    self.titleLab.textColor = [UIColor whiteColor];
    // 背景色
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    // 解析本地json文件
    [self moNiDataFromLocal];
    // 当前关卡的id 存入本地  用于闯关成功界面 请求百分比
    NSString *levelID = [_currentPointDict objectForKey:@"id"];
    [OralDBFuncs setCurrentLevelID:levelID];

    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiConfig];// 配置UI界面
    [self createTipLabel];// 创建加入练习本提示界面
    
    // 初始化引擎
    _dfEngine = [[DFAiengineSentObject alloc]initSentEngine:self withUser:@"cocim_haiyan"];
}

#pragma mark - UI布局
#pragma mark - - 创建提示标签
// 用于提示用户操作成功
- (void)createTipLabel
{
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake((kScreentWidth-100)/2, kScreenHeight-35, 0, 0)];
    tipLab.tag = 1111;
    tipLab.text = @"成功加入练习簿";
    tipLab.backgroundColor = [UIColor clearColor];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = _pointColor;
    tipLab.font = [UIFont systemFontOfSize:kFontSize_12];
    tipLab.layer.masksToBounds = YES;
    tipLab.layer.cornerRadius = 3;
    tipLab.layer.borderColor = _pointColor.CGColor;
    tipLab.layer.borderWidth = 1;
    [self.view addSubview:tipLab];
}

#pragma mark - UI配置
- (void)uiConfig
{
    // 确定 frame 适配
    // 1--->问题总数View topview
    float question_CountButton_Back_Y = 65;
    float question_CountButton_Back_Height = 45.0/667*kScreenHeight;
    float question_CountButton_H = 30.0/667*kScreenHeight;
    
    [_topQuestionCountView setFrame:CGRectMake(0, question_CountButton_Back_Y, kScreentWidth, question_CountButton_H)];
    _topQuestionCountView.backgroundColor = _backgroundViewColor;

    // 根据总问题数创建按钮
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(question_CountButton_H+10), (question_CountButton_Back_Height-question_CountButton_H)/2, question_CountButton_H, question_CountButton_H)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        // 选中
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:_backColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
        btn.tag = kTopQueCountButtonTag+i;
        if (i == 0)
        {
            btn.selected = YES;// 默认：1
        }
        [_topQuestionCountView addSubview:btn];
    }
    
    // 2--->老师部分控件
    
    float tea_space_toTop = 15.0/667*kScreenHeight;
    float teacher_Y = question_CountButton_Back_Y+question_CountButton_Back_Height+tea_space_toTop;
    float teacher_Head_W = 65.0/667*kScreenHeight;
    float teacher_X = 20.0/375*kScreentWidth;
    
    [_teaHeadImgView setFrame:CGRectMake(teacher_X, teacher_Y, teacher_Head_W, teacher_Head_W)];
    [_teaQuestionBackImgV setFrame:CGRectMake(teacher_X+teacher_Head_W+10, teacher_Y, kScreentWidth-teacher_X*2-teacher_Head_W-10, teacher_Head_W)];
    [_teaQuestionLabel setFrame:CGRectMake(teacher_X+teacher_Head_W+10, teacher_Y, kScreentWidth-teacher_X*2-teacher_Head_W-10, teacher_Head_W)];

    // 老师头像 --- 设置圆角半径 layer
    _teaHeadImgView.layer.masksToBounds = YES;
    _teaHeadImgView.layer.cornerRadius = _teaHeadImgView.bounds.size.height/2;
    _teaHeadImgView.layer.borderColor = _backColor.CGColor;
    _teaHeadImgView.layer.borderWidth = 2;
    [_teaHeadImgView setImage:[UIImage imageNamed:@"teacher_normal"]];
    
    // 问题背景----layer
    _teaQuestionLabel.layer.masksToBounds = YES;
    _teaQuestionLabel.layer.cornerRadius = _teaQuestionLabel.frame.size.height/1334*kScreenHeight;
    // 问题文本 多行显示
    _teaQuestionLabel.text = @"";//起始为空
    _teaQuestionLabel.textColor = kText_Color;
    _teaQuestionLabel.textAlignment = NSTextAlignmentCenter;
    _teaQuestionLabel.numberOfLines = 0;
    _teaQuestionLabel.backgroundColor = [UIColor clearColor];
    [_teaQuestionLabel setBackgroundColor:[UIColor clearColor]];
    [_teaQuestionBackImgV setBackgroundColor:[UIColor whiteColor]];

    _teaQuestionBackImgV.layer.masksToBounds = YES;
    _teaQuestionBackImgV.layer.cornerRadius = _teaQuestionBackImgV.frame.size.height/2.0;

    // 3-->底部控件
    
    float follow_Button_H = 65.0/667*kScreenHeight;
    float follow_space_bottom = 30.0/667*kScreenHeight;
    
    [_followAnswerButton setFrame:CGRectMake((kScreentWidth-follow_Button_H)/2, kScreenHeight-follow_space_bottom-follow_Button_H, follow_Button_H, follow_Button_H)];
    
    // 学生部分控件
    
    // 4-->学生部分控件
    float stu_answer_back_Y = 30.0/667*kScreenHeight+teacher_Y+teacher_Head_W;
    float stu_answer_back_H = 280.0/667*kScreenHeight;
    
    [_studentView setFrame:CGRectMake(teacher_X, stu_answer_back_Y, kScreentWidth-teacher_X*2, stu_answer_back_H)];
    // 顶部
    [_stuFollowLabel setFrame:CGRectMake(10, 5, 150, 25)];
    [_stuCountLabel setFrame:CGRectMake(_studentView.frame.size.width-100, 5, 90, 25)];
    [_stuLineLabel setFrame:CGRectMake(0, 34, _studentView.frame.size.width, 1)];
    
    // 底部
    // 学生头像
    float stu_head_H = 55.0/667*kScreenHeight;
    float stu_head_space_bottom = 10.0/667*kScreenHeight;
    float stu_head_space_right = 10;
    
    float stu_head_X = _studentView.frame.size.width - stu_head_space_right-stu_head_H;
    float stu_head_Y = _studentView.frame.size.height-stu_head_space_bottom-stu_head_H;
    
    [_stuHeadImgView setFrame:CGRectMake(stu_head_X, stu_head_Y, stu_head_H, stu_head_H)];
    
    // 进度条
    float stu_Progress_W = _studentView.frame.size.width-stu_head_space_right*3-stu_head_H;
    [_stuTimeProgressLabel setFrame:CGRectMake(10, stu_head_Y+stu_head_H/2, stu_Progress_W, 2)];
    
    // 分数按钮
    
    float score_W = 100.0/667*kScreenHeight;
    float score_H = 50.0/375*kScreentWidth;
    float score_Y = _studentView.frame.size.height-5-score_H;
    float score_X = (_studentView.frame.size.width-score_W)/2;
    [_stuScoreButton setFrame:CGRectMake(score_X, score_Y, score_W, score_H)];
    
    _stuScoreButton.titleLabel.font = [UIFont systemFontOfSize:30];
    
    
    // webview
    float webview_x = 10;
    float webView_y = 40;
    float webView_w = _studentView.frame.size.width-webview_x*2;
    float webView_H = _studentView.frame.size.height-stu_head_space_bottom-stu_head_H-10-webView_y;
    _answerTextWebV = [[UIWebView alloc]initWithFrame:CGRectMake(webview_x, webView_y, webView_w, webView_H)];
    _answerTextWebV.hidden = NO;
    _answerTextWebV.delegate =self;
    [_studentView addSubview:_answerTextWebV];
    
    _studentView.backgroundColor = [UIColor whiteColor];
    _stuFollowLabel.textColor = _backColor;//跟读颜色
    _stuFollowLabel.text = @"";//起始为空
    [self changeAnswerProgress];//当前回答数：1
    _stuCountLabel.textColor = _backColor;
    
    _answerTextWebV.delegate = self;
    _stuLineLabel.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
    // 时间进度条
    _stuTimeProgressLabel.backgroundColor = _backColor;
    // 标记时间进度条原始frame
    _timeProgressRect = _stuTimeProgressLabel.frame;
    // 学生头像
    _stuHeadImgView.layer.masksToBounds = YES;
    _stuHeadImgView.layer.cornerRadius = _stuHeadImgView.frame.size.height/2;
    _stuHeadImgView.layer.borderWidth = 2;
    _stuHeadImgView.layer.borderColor = _backColor.CGColor;
    
    // 分数按钮
    _stuScoreButton.layer.cornerRadius = _stuScoreButton.frame.size.height/2;
    [_stuScoreButton setBackgroundColor:_backColor];
    
    //隐藏跟读按钮
    _followAnswerButton.hidden = YES;
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    
    
    // 起始状态：老师头像暗 学生头像 暗 文本不显示
    _teaHeadImgView.alpha = 0.3;
    _stuHeadImgView.alpha = 0.3;
    _teaQuestionLabel.text = @"";
    
    _stuFollowLabel.tag = kFollowLabelTag;
    _teaQuestionLabel.tag = kQuestionTextLabelTag;
    
    // 回答区域圆角
    _studentView.layer.cornerRadius = 5;
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
    
    // 当前进行的问题的回答列表
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    // 当前问题回答数
    _sumAnswerCounts = _currentAnswerListArray.count;
    // 正在回答数
    _currentAnswerCounts = 0;
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
    [self showCurrentQuestionText];
    [self textAnimationInView:_teaQuestionLabel];
    
    [UIView animateWithDuration:2 animations:^{
        _teaQuestionLabel.font = [UIFont systemFontOfSize:kFontSize_14];
        _teaHeadImgView.alpha = 1;
        _stuHeadImgView.alpha = 0.3;
    }];
    
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(willPlayQuestion) userInfo:nil repeats:NO];
}

- (void)willPlayQuestion
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    [self playQuestion];
}

#pragma mark - 跟读准备
- (void)prepareBlank
{
    // 1、展示answer的文本
    [self showCurrentAnswerText];
    // 后续的动画
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(blankTextShow) userInfo:nil repeats:NO];
}

#pragma mark - 显示-->请跟读
- (void)blankTextShow
{
    [self stopReduceTimer];
    _stuFollowLabel.text = @"请填空";
    [self textAnimationInView:_stuFollowLabel];
    
    [UIView animateWithDuration:1 animations:^{
        _stuFollowLabel.text = @"请填空";
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stuImageBrite_Blank) userInfo:nil repeats:NO];
}
#pragma mark ---头像-->亮
- (void)stuImageBrite_Blank
{
    [self stopReduceTimer];
    [UIView animateWithDuration:1 animations:^{
        _stuHeadImgView.alpha = 1;
        _teaHeadImgView.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(willFollowRecord_blank) userInfo:nil repeats:NO];
}

#pragma mark ---跟读按钮-->显示
- (void)willFollowRecord_blank
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
    _followAnswerButton.hidden = NO;// 展示跟读按钮
    [self followAnswerButtonClicked:_followAnswerButton];
}

#pragma mark - - 文字动画
- (void)textAnimationInView:(UILabel *)lable
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


#pragma mark - 播放器
#pragma mark -- 播放完成回调
- (void)playerEnd
{
    // 跟读 录音 (思必驰)
    [self prepareBlank];
}

#pragma mark -- 播放问题音频
- (void)playQuestion
{
    if (_reduceTimer)
    {
        [self stopReduceTimer];
    }
    // 获取音频路径
    NSString *audiourl = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"audiourl"];
    NSString *audioPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],audiourl];
    [audioPlayer playerPlayWithFilePath:audioPath];
}


#pragma mark - 切换问题变换文本
#pragma mark -- 展示问题文本
- (void)showCurrentQuestionText
{
    _teaQuestionLabel.text = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"];
    _teaQuestionLabel.font = [UIFont fontWithName:@"Arial" size:kFontSize_14];

}

#pragma mark -- 展示回答文本
- (void)showCurrentAnswerText
{
    _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    NSString *answerTextBlank = [self makeUpBlankStringWithDict:[_currentAnswerListArray objectAtIndex:_currentAnswerCounts]];
    
    int  ww = _answerTextWebV.frame.size.width;
    CGRect rect = [NSString CalculateSizeOfString:[self filterHTML:answerTextBlank] Width:ww Height:9999 FontSize:kFontSize_15];
    int  hh = rect.size.height;

     NSString *new_html =[NSString stringWithFormat:@"<style>#box{width:%dpx;height:%dpx;position: absolute;top:50%%;left:50%%;margin-top:%dpx;margin-left:%dpx;font-size:15;font-family:\"Arial\";}</style><div id='box'>%@</div>",ww,hh,-hh/2,-ww/2,answerTextBlank];
    [_answerTextWebV loadHTMLString:new_html baseURL:nil];
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

#pragma mark - 组成填空的字符串
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
- (void)startSBCAiengine
{
    NSString *text = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"];
    if(_dfEngine)
    {
        [_dfEngine startEngineFor:[self filterHTML:text]];
        NSString *answerid = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"id"];
        [_saveAnswerIdArray addObject:answerid];
    }
    else
    {
        _dfEngine = [[DFAiengineSentObject alloc]initSentEngine:self withUser:@"cocim_haiyan"];
        if (_dfEngine)
        {
            [_dfEngine startEngineFor:[self filterHTML:text]];
            NSString *answerid = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"id"];
            [_saveAnswerIdArray addObject:answerid];
        }
        else
        {
            UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"语音引擎初始化失败，回到主界面" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertV show];
        }
    }
}

#pragma mark  - 停止思必驰
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
    
//    NSString *msg1 = [_dfEngine getRichResultString:result.details];
//    [self performSelectorOnMainThread:@selector(showHtmlMsg:) withObject:msg1 waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(showResult:) withObject:result waitUntilDone:NO];
}


#pragma mark - 展示分数
- (void)showResult:(DFAiengineSentResult *)result
{
    _stuTimeProgressLabel.hidden = YES;// 隐藏时间进度条
    _stuTimeProgressLabel.frame = _timeProgressRect;//回复时间进度条 以便下次使用
    _stuHeadImgView.hidden = YES;// 隐藏学生头像
    _stuScoreButton.hidden = NO; // 展示分数区域
    _stuHeadImgView.alpha = 0.3;

    
    // 转移思必驰录音 清空原有的
    NSString *sbcPath = [NSString stringWithFormat:@"%@/Documents/record/%@.wav",NSHomeDirectory(),result.recordId];
    NSString *sbcToPath =  [NSString stringWithFormat:@"%@/part%d-%d-%ld-%ld.wav",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentPoint],_currentQuestionCounts+1,_currentAnswerCounts+1];
    NSData *fileData = [NSData dataWithContentsOfFile:sbcPath];
    BOOL saveSuc = [fileData writeToFile:sbcToPath atomically:YES];
    if (saveSuc)
    {
        // 删除原来的文件
        [[NSFileManager defaultManager]removeItemAtPath:sbcPath error:nil];
    }
    
    _showReview_Html = YES;
    NSString *str = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"];
    int  ww = _answerTextWebV.frame.size.width;
    CGRect rect = [NSString CalculateSizeOfString:[self filterHTML:str] Width:ww Height:9999 FontSize:kFontSize_15];
    int  hh = rect.size.height;
    _currentAnswerHtml = [_dfEngine getRichResultString:result.details];
    NSString *new_html =[NSString stringWithFormat:@"<style>#box{width:%dpx;height:%dpx;position: absolute;top:50%%;left:50%%;margin-top:%dpx;margin-left:%dpx;font-size:15;}</style><div id='box'>%@</div>",ww,hh,-hh/2,-ww/2,_currentAnswerHtml];
    // 展示每个单词发音情况
    [_answerTextWebV loadHTMLString:new_html baseURL:nil];
    
    
    // 存储分数有关
    _currentAnswerScore = result.overall;
    _currentAnswerIntegrity = result.integrity;
    _currentAnswerFluency = [[result.fluency objectForKey:@"overall"] intValue];
    _currentAnswerPron = result.pron;
    _currentAnswerAudioName = [[sbcToPath componentsSeparatedByString:@"/"] lastObject];
    _currentAnswerReferAudioName = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"audiourl"];
    _currentAnswerId = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"id"];
    
    // 获取录音时长
    long recordTime = result.systime;
    // 增加录音时长
    [OralDBFuncs addPlayTime:recordTime ForUser:[OralDBFuncs getCurrentUserName]];
    
    // 存储一条记录
    [OralDBFuncs replaceLastRecordFor:[OralDBFuncs getCurrentUserName] TopicName:[OralDBFuncs getCurrentTopic] answerId:_currentAnswerId partNum:[OralDBFuncs getCurrentPart] levelNum:[OralDBFuncs getCurrentPoint] withRecordId:[OralDBFuncs getCurrentRecordId] lastText:_currentAnswerHtml lastScore:_currentAnswerScore lastPron:_currentAnswerPron lastIntegrity:_currentAnswerIntegrity lastFluency:_currentAnswerFluency lastAudioName:_currentAnswerReferAudioName];
    
    /*
     根据反馈结果填空
     0,213,136  绿色  80<=x<=100
     246,215,0  黄色  60<=x<80
     212,0,44   红色   0<=x<60
     待完善
     */
    NSArray *colorArray = @[_perfColor,_goodColor,_badColor];
    int scoreCun = _currentAnswerScore>=80?0:(_currentAnswerScore>=60?1:2);
    [_stuScoreButton setTitle:[NSString stringWithFormat:@"%d",_currentAnswerScore] forState:UIControlStateNormal];
    [_stuScoreButton setBackgroundColor:[UIColor whiteColor]];
    [_stuScoreButton setTitleColor:[colorArray objectAtIndex:scoreCun] forState:UIControlStateNormal];

    _sumScore += _currentAnswerScore;
    _sumCounts ++;
    
    // 隐藏回答按钮  展示下一题区域
    _followAnswerButton.hidden = YES;
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(jugePointIsFinished) userInfo:nil repeats:NO];
}

#pragma mark - 定时器
#pragma mark -- 时间倒计时
- (void)timeReduce
{
    CGRect rect = _stuTimeProgressLabel.frame;
    rect.origin.x ++;
    rect.size.width --;
    _stuTimeProgressLabel.frame = rect;
    if (rect.size.width<=0)
    {
        [self stopReduceTimer];
        //倒计时结束 停止跟读
        [self followAnswerButtonClicked:_followAnswerButton];
        _followAnswerButton.hidden = YES;
    }
}

#pragma mark -- 关闭定时器
- (void)stopReduceTimer
{
    [_reduceTimer invalidate];
    _reduceTimer = nil;
}

#pragma mark - 下一题
- (IBAction)continueButtonClicked:(id)sender
{
    // 下一题
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(jugePointIsFinished) userInfo:nil repeats:NO];
}

#pragma mark - 跟读按钮被点击
- (IBAction)followAnswerButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected)
    {
        btn.selected = NO;
        // 停止倒计时
        [self stopReduceTimer];
        // 停止sbc
        [self stopSBCAiengine];
    }
    else
    {
        btn.selected = YES;
        // 开启思必驰
        [self startSBCAiengine];
        // 时间进度条变化
        _stuTimeProgressLabel.frame = _timeProgressRect;
        _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:15/_timeProgressRect.size.width target:self selector:@selector(timeReduce) userInfo:nil repeats:YES];
    }
}


#pragma mark - 判断闯关是否结束
- (void)jugePointIsFinished
{
    _showReview_Html = NO;
    [self stopReduceTimer];
    _answerTime = KAnswerSumTime;
    // 隐藏下一问题按钮区域
    // 隐藏分数 显示学生头像 时间进度条
    _stuScoreButton.hidden = YES;
    _stuTimeProgressLabel.hidden = NO;
    _stuHeadImgView.hidden = NO;
    
    _currentAnswerCounts++;// 当前回答数+1
    if (_currentAnswerCounts>=_sumAnswerCounts)
    {
        _currentAnswerCounts = 0;
        _currentQuestionCounts ++;
        if (_currentQuestionCounts<_sumQuestionCounts)
        {
            // 下一题
            [self questionCountChanged];//标记当前进行的问题数
            // 继续当前问题
            [self changeAnswerProgress];
            _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
            _sumAnswerCounts = _currentAnswerListArray.count;
            [self prepareQuestion];
        }
        else
        {
            float levelScore = _sumScore/_sumCounts;
            [OralDBFuncs updateTopicRecordFor:[OralDBFuncs getCurrentUserName] with:[OralDBFuncs getCurrentTopic] part:[OralDBFuncs getCurrentPart] level:[OralDBFuncs getCurrentPoint] andScore:levelScore];
            
            //关卡结束 跳转过渡页
            CheckSuccessViewController *successVC = [[CheckSuccessViewController alloc]initWithNibName:@"CheckSuccessViewController" bundle:nil];
            [self.navigationController pushViewController:successVC animated:YES];
        }
        
    }
    else
    {
        // 继续当前问题
        [self changeAnswerProgress];
        _startAnswer = YES;//标记 用于播放器回调方法
        [self prepareBlank];
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
    _stuCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentAnswerCounts+1,_sumAnswerCounts];
}

#pragma mark - 界面将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    audioPlayer.target = nil;
    if (_reduceTimer != nil)
    {
        [self stopReduceTimer];
    }
    if (_dfEngine)
    {
        [_dfEngine stopEngine];
        _dfEngine = nil;
    }
}

#pragma mark - webView 文字居中
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *bodyStyleVertical = @"document.getElementsByTagName('body')[0].style.verticalAlign = 'middle';";
    NSString *bodyStyleHorizontal = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleVertical];
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleHorizontal];
    [webView stringByEvaluatingJavaScriptFromString:mapStyle];
    
    //字体颜色
    if (_showReview_Html == NO)
    {
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#646464'"];
    }
}



@end
