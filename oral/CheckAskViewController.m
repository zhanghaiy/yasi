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

@interface CheckAskViewController ()
{
    NSDictionary *_topicInfoDict;// 整个topic信息
    NSDictionary *_currentPartDict;// 当前part资源信息
    NSDictionary *_currentPointDict;// 当前关卡资源信息
    NSArray *_questioListArray;
    NSInteger _sumQuestionCounts;//总的问题个数
    NSInteger _currentQuestionCounts;
   
    AudioPlayer *audioPlayer;
    RecordManager *_recordManager;
    
    NSInteger _answerTime;//跟读时间
    NSTimer *_reduceTimer;
    
    CGRect _stuHeadImgViewRect;// 放大后学生头像的frame
    CGRect _stuHeadImgViewRect_small;// 缩小的学生头像的frame
    
    CGRect _questionNomalRect;
    CGRect _questionSmallRect;
}
@end

@implementation CheckAskViewController
#define kTopQueCountButtonTag 333
#define kCommitLeftButtonTag 444
#define kCommitRightButtonTag 555

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
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _answerTime = 15;
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerCallBack);
    
    [self addBackButtonWithImageName:@"back-white"];
    [self addTitleLabelWithTitleWithTitle:@"Part1-3"];
    self.navTopView.backgroundColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    self.titleLab.textColor = [UIColor whiteColor];
    [self moNiDataFromLocal];
    [self uiConfig];
    
    _recordManager = [[RecordManager alloc]init];
    _recordManager.target = self;
    _recordManager.action = @selector(recordFinished:);
    _recordManager.filePath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
}

- (void)uiConfig
{
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _topView.backgroundColor = [UIColor clearColor];
    _teacherView.backgroundColor = [UIColor clearColor];
    
    // 背景颜色 去掉
    // 计算出按钮高度  不同尺寸屏幕 高度不同
    NSInteger btnWid = _topView.frame.size.height-2*8;
    // 根据总问题数创建按钮
    for (int i = 0; i < _sumQuestionCounts; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), 8, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        // 选中
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithRed:35/255.0 green:222/255.0 blue:191/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        btn.tag = kTopQueCountButtonTag+i;
        if (i == 0)
        {
            btn.selected = YES;// 默认：1
        }
        [_topView addSubview:btn];
    }
    

    
    // 获取到老师View的frame
    CGRect rect = _teacherView.frame;
    float ratio = rect.size.width/rect.size.height;
    rect.size.width = kScreentWidth;
    rect.size.height = kScreentWidth/ratio;
    _teacherView.frame = rect;
    
    _teaHeadImgView.image = [UIImage imageNamed:@"touxiang.png"];
    _teaHeadImgView.layer.masksToBounds = YES;
    _teaHeadImgView.layer.cornerRadius = (rect.size.height-30)/2;
    _teaHeadImgView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:222/255.0 blue:191/255.0 alpha:1].CGColor;
    _teaHeadImgView.layer.borderWidth = 1;
    
    NSInteger queBackHH = _teaHeadImgView.frame.size.width;
    NSInteger queBackX = 30 + queBackHH;
    NSInteger queBackWW = kScreentWidth - queBackX - 20;
    _teaQuestioBackV.frame = CGRectMake(queBackX, 10, queBackWW, queBackHH);
    
    
    // 问题背景----layer
    
    _teaQuestionBtn.titleLabel.numberOfLines = 0;
    _teaQuestionBtn.titleLabel.textColor = [UIColor colorWithRed:62/255.0 green:66/255.0 blue:67/255.0 alpha:1];
    _teaQuestionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_teaQuestionBtn setTitle:@"" forState:UIControlStateNormal];
//    _teaQuestionBtn.titleLabel.font = [UIFont systemFontOfSize:0];
    
    
    _teaQuestioBackV.layer.masksToBounds = YES;
    _teaQuestioBackV.backgroundColor = [UIColor whiteColor];
    _teaQuestioBackV.layer.cornerRadius = _teaQuestioBackV.frame.size.height/1334*kScreenHeight;
    
//    _teaQuestionLabel.layer.masksToBounds = YES;
//    _teaQuestionLabel.layer.cornerRadius = _teaQuestionLabel.frame.size.height/1334*kScreenHeight;
//    // 问题文本 多行显示
//    _teaQuestionLabel.text = @"";//起始为空
//    _teaQuestionLabel.textColor = [UIColor colorWithRed:62/255.0 green:66/255.0 blue:67/255.0 alpha:1];
//    _teaQuestionLabel.textAlignment = NSTextAlignmentCenter;
//    _teaQuestionLabel.numberOfLines = 0;
//    _teaQuestionLabel.backgroundColor = [UIColor whiteColor];
    
    
    
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateNormal];
    [_followAnswerButton setBackgroundImage:[UIImage imageNamed:@"answerButton-sele"] forState:UIControlStateSelected];
    
    _CommitLeftButton.tag = kCommitLeftButtonTag;
    _commitRightButton.tag = kCommitRightButtonTag;
    
    _stuHeadImgViewRect = _stuHeadImgV.frame;
    _stuHeadImgViewRect_small = _stuHeadImgViewRect;
    _stuHeadImgViewRect_small.origin.x += 10;
    _stuHeadImgViewRect_small.origin.y += 10;
    _stuHeadImgViewRect_small.size.width -= 20;
    _stuHeadImgViewRect_small.size.height -=20;
    
    _questionNomalRect = _teaQuestioBackV.bounds;
    _questionNomalRect.size.height -= 10;
    _questionNomalRect.size.width -= 10;
    _questionNomalRect.origin.x = 5;
    _questionNomalRect.origin.y = 5;
    
    _questionSmallRect = _questionNomalRect;
    _questionSmallRect.size.width = 0;
    
    _teaQuestionBtn.frame = _questionSmallRect;
    
    _stuHeadImgV.frame = _stuHeadImgViewRect_small;
    _stuHeadImgV.alpha = 0.3;
    _teaHeadImgView.alpha = 0.3;
    _followAnswerButton.hidden = YES;
}

#pragma mark - 切换问题变换文本
- (void)showCurrentQuestionText
{
    _teaQuestionBtn.titleLabel.font = [UIFont systemFontOfSize:KOneFontSize];
    [_teaQuestionBtn setTitle:[[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"question"] forState:UIControlStateNormal];
    _teaQuestionBtn.frame = _questionNomalRect;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(startQuestion) userInfo:nil repeats:NO];
}

- (void)startQuestion
{
    [self stopTimer];
    [self prepareQuestion];
}

#pragma mark - 准备提问
- (void)prepareQuestion
{
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(textAnimate) userInfo:nil repeats:NO];
}

- (void)textAnimate
{
    [self stopTimer];
    
    [UIView animateWithDuration:1 animations:^{
        [self showCurrentQuestionText];
        _teaHeadImgView.alpha = 1;
        _stuHeadImgV.alpha = 0.3;
    }];
    _reduceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playQuestion) userInfo:nil repeats:NO];

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

- (void)playerCallBack
{
     // 播放完成 开始录音 保存本地
    
//    [UIView animateWithDuration:1 animations:^{
//        
//    }];
    
    [self prepareAnswer];
}

#pragma mark - 准备回答
- (void)prepareAnswer
{
    _stuHeadImgV.alpha = 1;
    _teaHeadImgView.alpha = 0.3;
    
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
    }
    else
    {
        btn.selected = YES;
        // 开始录音
//        [self startRecord];
        [_recordManager prepareRecorderWithFileName:@"answer1"];
    }
}

#pragma mark - 开始录音
- (void)startRecord
{
    // 后续完善（根据数据）
   [_recordManager prepareRecorderWithFileName:@"answer1"];
}

#pragma mark - 录音结束回调
- (void)recordFinished:(RecordManager *)manager
{
    [self nextQuestion];
}

#pragma mark - 进行下一题
- (void)nextQuestion
{
//    _currentQuestionCounts++;
    if (_currentQuestionCounts<_sumQuestionCounts)
    {
        // 继续
        _teaQuestionBtn.titleLabel.font = [UIFont systemFontOfSize:0];
        [_teaQuestionBtn setTitle:@"" forState:UIControlStateNormal];
        _teaQuestionBtn.frame = _questionSmallRect;
        
        [self prepareQuestion];
    }
    else
    {
       // 提交给老师
        _CommitLeftButton.hidden = NO;
        _commitRightButton.hidden = NO;
    }
}


- (IBAction)commitButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == kCommitLeftButtonTag)
    {
        // 稍后提交
    }
    else if (btn.tag == kCommitRightButtonTag)
    {
        // 现在提交
    }
}
@end
