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
    
    AudioPlayer *audioPlayer;
}


@end

@implementation CheckFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    audioPlayer = [AudioPlayer getAudioManager];
    audioPlayer.target = self;
    audioPlayer.action = @selector(playerCallBack);
    
    [self addBackButtonWithImageName:@"back-white"];
    [self addTitleLabelWithTitleWithTitle:@"Part1-1"];
    self.navTopView.backgroundColor = [UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1];
    self.titleLab.textColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [self uiConfig];
    [self moNiDataFromLocal];
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
    _topicInfoDict = [dict objectForKey:@"classtypeinfo"];
    _currentPartDict = [[_topicInfoDict objectForKey:@"partlist"] objectAtIndex:_currentPartCounts];
    _currentPointDict = [[_currentPartDict objectForKey:@"levellist"] objectAtIndex:_currentPointCounts];
    _questioListArray = [_currentPointDict objectForKey:@"questionlist"];
    
    _sumQuestionCounts = _questioListArray.count;
    _currentQuestionCounts = 0;
    
     _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
    _sumAnswerCounts = _currentAnswerListArray.count;
    _currentAnswerCounts = 0;
}

#pragma mark - 获取最新的问题资源数据
- (void)maketheNewData
{
   _currentAnswerListArray = [[_questioListArray objectAtIndex:_currentQuestionCounts] objectForKey:@"answerlist"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *dict = [_questioListArray objectAtIndex:_currentQuestionCounts];
    NSString *questionStr = [dict objectForKey:@"question"];
    
    _questionTextLabel.text = questionStr;
    
    
    NSString *audiourl = [dict objectForKey:@"audiourl"];
    NSArray *audioArr = [audiourl componentsSeparatedByString:@"."];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:[audioArr objectAtIndex:0] ofType:[audioArr lastObject]];
    _currentQuestionFinished = NO;
    [self playAudioWithPath:audioPath];
    
}

- (void)playAudioWithPath:(NSString *)audioPath
{
    [audioPlayer playerPlayWithFilePath:audioPath];
    [audioPlayer beginePlay];
}

- (void)playerCallBack
{
    NSLog(@"playerCallBack");
    if (_currentAnswerCounts<_sumAnswerCounts)
    {
        // 播放回答音频
    }
}

- (void)uiConfig
{
    // 问题总数View
    _questionCountsView.backgroundColor = [UIColor clearColor];
    NSInteger btnWid = _questionCountsView.frame.size.height/1334*2*kScreenHeight-2*9;
    for (int i = 0; i < 2; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(20+i*(btnWid+10), 9, btnWid, btnWid)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-white"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"questionCount-blue"] forState:UIControlStateSelected];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:KThidFontSize];
        [btn setTitleColor:[UIColor colorWithRed:144/255.0 green:231/255.0 blue:208/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
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
    _stuTitleLabel.textColor = stuColor;
    _stuAnswerCountsLabel.textColor = stuColor;
    _answerTextLabel.textColor = [UIColor colorWithWhite:125/255.0 alpha:1];
    _answerBottomView.backgroundColor = [UIColor clearColor];
    _lineLabel.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
    
    _timeProgressLabel.backgroundColor = stuColor;
    
    _stuImageView.layer.masksToBounds = YES;
    _stuImageView.layer.cornerRadius = _stuImageView.frame.size.height/667*kScreenHeight/2;
    _stuImageView.layer.borderWidth = 2;
    _stuImageView.layer.borderColor = [UIColor colorWithRed:142/255.0 green:232/255.0 blue:208/255.0 alpha:1].CGColor;
    
    _bottomView.backgroundColor = [UIColor clearColor];
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
