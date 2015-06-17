//
//  CheckPractiseBookViewController.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckPractiseBookViewController.h"
#import "PractiseCell.h"
#import "AudioPlayer.h"
#import "DFAiengineSentObject.h"
#import "OralDBFuncs.h"


@interface CheckPractiseBookViewController ()<UITableViewDataSource,UITableViewDelegate,DFAiengineSentProtocol>
{
    UITableView *_practiseTableV;
    AudioPlayer *_playerManager;
    DFAiengineSentObject *_dfAiengine;
    NSInteger _markCurrentPractise_index;// 当前练习的索引
    
    NSMutableArray *_practiceArray;
    
    int _markButtonTag;// 标记被点击的button
    
    CircleProgressView *_currentCircleV;// 当前练习的cell的圆形进度条View
    NSTimer *_sbcTimer;
    NSInteger _markAnswerTime; // 累计时间
    NSInteger _sumAnswerTime;// 总时间
    PracticeBookRecord *_currentPracticeRecord;
}
@end

@implementation CheckPractiseBookViewController
#define kCellHeight 150
// webview宽度 用于计算文本高度
#define kWebViewWidth (kScreentWidth-80)

- (void)makeUpPracticeMenu
{
    /*
     数据结构
     
     _topicInfoDict--> topic闯关信息---> dict(字典)
     当前topic所有part--> partListArray = [_topicInfoDict objectForKey:@"partlist"] -->数组
     当前part--> curretPartDict = [partListArray objectAtIndex:_currentPartCounts] -->字典
     当前part的所有关卡信息 -- > pointArray = [curretPart objectForKey:@"levellist"] --> 数组
     当前关卡信息 pointDict = [pointArray objectAtIndex:_currentPointCounts] --> 字典
     */
    //    NSString *path = [[NSBundle mainBundle]pathForResource:@"info" ofType:@"json"];
    
    NSString *jsonPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/info.json",[OralDBFuncs getCurrentTopic]];
    NSLog(@"~~~~~~~~~~~jsonPath:%@~~~~~~",jsonPath);
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSLog(@"~~~~~~jsonData:%@",jsonData);
    NSDictionary *maindict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    NSDictionary *dict = [maindict objectForKey:@"classtypeinfo"];
    
    if (_practiceArray.count)
    {
        [_practiceArray removeAllObjects];
    }
    for (int ii = 0; ii < 3; ii++)
    {
        // 当前part资源信息
        NSDictionary *subDict = [[dict objectForKey:@"partlist"] objectAtIndex:ii];
        for (int i = 0; i < 3; i ++)
        {
            NSArray *questionList = [[[subDict objectForKey:@"levellist"] objectAtIndex:i] objectForKey:@"questionlist"];
            for (NSDictionary *subSubdict in questionList)
            {
                NSArray *answerArray = [subSubdict objectForKey:@"answerlist"];
                for (NSDictionary *subSubSubDic in answerArray)
                {
                    NSString *answerId = [subSubSubDic objectForKey:@"id"];
                    NSLog(@"%@",answerId);
                    if([OralDBFuncs isInPracticeBook:[OralDBFuncs getCurrentUserName] withAnswerId:answerId])
                    {
                        [_practiceArray addObject:[OralDBFuncs getPracticeBookRecordFor:[OralDBFuncs getCurrentUserName] withAnswerId:answerId]];
                    }
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"练习簿"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    _sumAnswerTime = 10;
    
    _practiceArray = [[NSMutableArray alloc]init];
    [self makeUpPracticeMenu];
    
    _practiseTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+1, kScreentWidth, kScreenHeight-KNavTopViewHeight-1) style:UITableViewStylePlain];
    _practiseTableV.delegate = self;
    _practiseTableV.dataSource = self;
    _practiseTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_practiseTableV];
    
    _practiseTableV.backgroundColor = _backgroundViewColor;
    
    _playerManager = [AudioPlayer getAudioManager];
    _playerManager.target = self;
    _playerManager.action = @selector(playFinished:);
    
    _dfAiengine = [[DFAiengineSentObject alloc]initSentEngine:self withUser:@"haiyan"];
    
}


- (void)stopPlay
{
    [_playerManager stopPlay];
}

- (void)playFinished:(id)obj
{
    // 播放完成
    
    UIButton *btn = (UIButton *)[self.view viewWithTag:_markButtonTag];
    btn.selected = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _practiceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
        此处根据文字大小计算出宽高 ---待完善
     */
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PractiseCell";
    PractiseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PractiseCell" owner:self options:0] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.cellIndex = indexPath.row;
    cell.delegate = self;
    cell.action = @selector(pracCellCallBack:);
    cell.partLabel.textColor = _pointColor;
//    cell.recive_score = 90;
    
    PracticeBookRecord *record = [_practiceArray objectAtIndex:indexPath.row];
    [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
    [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
    int colorIndex = record.lastScore>=80?0:(record.lastScore>=60?1:2);
    NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
    [cell.scoreButton setBackgroundColor:[colorArr objectAtIndex:colorIndex]];
    
    cell.circleProV.backgroundColor = [UIColor clearColor];
    cell.circleProV.layer.cornerRadius = cell.circleProV.frame.size.height/2;
    [cell.circleProV settingProgress:0.0 andColor:_badColor andWidth:1 andCircleLocationWidth:2];
    
    return cell;
}

- (void)pracCellCallBack:(PractiseCell *)cell
{
    _markCurrentPractise_index = cell.cellIndex;
    _markButtonTag = (int)cell.buttonIndex;
    // 根据：1、cellIndex的值 来取数据 2、buttonIndex 找按钮
    UIButton *btn = (UIButton *)[cell viewWithTag:cell.buttonIndex];
    _currentPracticeRecord = [_practiceArray objectAtIndex:cell.cellIndex];
    NSString *referAnswerAudioName = _currentPracticeRecord.referAudioName;
    NSString *answerAudioName = [NSString stringWithFormat:@"%@",_currentPracticeRecord.lastAudioName];
    NSString *lastText = [self filterHTML:_currentPracticeRecord.lastText];
    
    // 参考答案音频路径
    NSString *referPath = [NSString stringWithFormat:@"%@/Documents/%@/topicResource/temp/%@",NSHomeDirectory(),[OralDBFuncs getCurrentTopic],referAnswerAudioName];
    // 自己联系音频路径
    NSString *answerPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/%@",[OralDBFuncs getCurrentTopic],answerAudioName];
    NSLog(@"%@",answerPath);
    NSLog(@"%@",referPath);
    
    switch (btn.tag-cell.cellIndex)
    {
        case kPract_Listen_self_Button_Tag:
        {
            //播放自己练习过的音频
            if (btn.selected)
            {
                btn.selected = NO;
                // 暂停播放
                [_playerManager stopPlay];
            }
            else
            {
                btn.selected = YES;
                // 开始播放 路径待完善
                [_playerManager playerPlayWithFilePath:answerPath];
            }
        }
            break;
        case kPract_Play_answer_Button_Tag:
        {
            //播放正确发音音频
            if (btn.selected)
            {
                btn.selected = NO;
                // 暂停播放
                [_playerManager stopPlay];
            }
            else
            {
                btn.selected = YES;
                // 开始播放
                [_playerManager playerPlayWithFilePath:referPath];
            }
        }
            break;
        case kPract_Follow_Button_Tag:
        {
            //跟读 练习 可以得到反馈（思必驰）
            if (btn.selected)
            {
                btn.selected = NO;
                // 停止思必驰
                [self stopSBCAiengine];
            }
            else
            {
                btn.selected = YES;
                // 开启思必驰引擎
                [self startSBCAiengineWithText:lastText];
                
//                _sumAnswerTime = 10;
//                _markAnswerTime = 0;
//                _currentCircleV = cell.circleProV;
//                [self showTimeProgress];
            }
        }
            break;
        case kPract_Delete_Button_Tag:
        {
            //删除此练习题
            if (btn.selected)
            {
                btn.selected = NO;
                //
            }
            else
            {
                btn.selected = YES;
                // 从练习簿里删除此条记录
//                [OralDBFuncs ]
            }
        }
            break;
        default:
            break;
    }
}

- (void)showTimeProgress
{
    _sbcTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressTimeReduce) userInfo:nil repeats:YES];
}


#pragma mark - 时间进度变化
- (void)progressTimeReduce
{
    _markAnswerTime ++;
    float tip = 1.0/_sumAnswerTime/10.0*_markAnswerTime;
    [_currentCircleV settingProgress:tip andColor:_badColor
                            andWidth:1 andCircleLocationWidth:2];
    if (tip >= 1)
    {
        // 停止思必驰
        [self stopSBCAiengine];
        // 停止倒计时
        [_sbcTimer invalidate];
        _sbcTimer = nil;
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:_markButtonTag];
        btn.selected = NO;
    }
}



#pragma mark - 思必驰语音引擎
#pragma mark - 开启思必驰引擎
- (void)startSBCAiengineWithText:(NSString *)text
{
    // 参考文本
    if(_dfAiengine)
        [_dfAiengine startEngineFor:text];
}
#pragma mark - 结束思必驰引擎
- (void)stopSBCAiengine
{
    // 展示分数
    [_dfAiengine stopEngine];
    
}

#pragma mark - 思必驰反馈
-(void)processAiengineSentResult:(DFAiengineSentResult *)result
{
    NSDictionary *fluency = result.fluency;
    NSString *msg = [NSString stringWithFormat:@"总体评分：%d\n发音：%d，完整度：%d，流利度：%d", result.overall, result.pron, result.integrity, ((NSNumber *)[fluency objectForKey:@"overall"]).intValue];
    NSLog(@"%@",msg);
    [self performSelectorOnMainThread:@selector(showResult:) withObject:result waitUntilDone:NO];
}

#pragma mark - 展示分数
- (void)showResult:(DFAiengineSentResult *)result
{
    // 获取录音时长
    long recordTime = result.systime;
    // 增加练习时长
    [OralDBFuncs addPracticeTime:recordTime ForUser:[OralDBFuncs getCurrentUserName]];
    
    // 存储的字段赋值
    NSString *msg1 = [_dfAiengine getRichResultString:result.details];
    
    // 转移思必驰录音 清空原有的
    NSString *sbcPath = [NSString stringWithFormat:@"%@/Documents/record/%@.wav",NSHomeDirectory(),result.recordId];
    NSString *sbcToPath =  [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/%@",[OralDBFuncs getCurrentTopic],_currentPracticeRecord.lastAudioName];
    NSData *fileData = [NSData dataWithContentsOfFile:sbcPath];
    BOOL saveSuc = [fileData writeToFile:sbcToPath atomically:YES];
    if (saveSuc)
    {
        // 删除原来的文件
        [[NSFileManager defaultManager]removeItemAtPath:sbcPath error:nil];
    }

    // 存储一条记录 到数据库
   [OralDBFuncs updatePracticeBookRecordFor:_currentPracticeRecord.userName withAnswerId:_currentPracticeRecord.answerId andResultText:msg1 score:result.overall pron:result.pron integrity:result.integrity fluency:[[result.fluency objectForKey:@"overall"] intValue] andLastAudioName:_currentPracticeRecord.lastAudioName];
    
    _currentPracticeRecord.lastText = msg1;
    _currentPracticeRecord.lastScore = result.overall;
    _currentPracticeRecord.lastIntegrity = result.integrity;
    _currentPracticeRecord.lastPron = result.pron;

    [_practiceArray replaceObjectAtIndex:_markCurrentPractise_index withObject:_currentPracticeRecord];
//    [self makeUpPracticeMenu];
    [_practiseTableV reloadData];
    
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
