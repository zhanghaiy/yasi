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
#import "NSString+CalculateStringSize.h"


@interface CheckPractiseBookViewController ()<UITableViewDataSource,UITableViewDelegate,DFAiengineSentProtocol,UIWebViewDelegate>
{
    UITableView *_practiseTableV;
    AudioPlayer *_playerManager;
    
    DFAiengineSentObject *_dfAiengine;//思必驰引擎
    NSInteger _markCurrentPractise_index;// 当前练习的索引 --- cell索引
    
    NSMutableArray *_practiceArray;// 列表控件数据源 内容：练习记录
    
    int _markButtonTag;// 标记被点击的button
    
    NSTimer *_sbcTimer;// 定时器 全局=----方便
    NSInteger _markAnswerTime; // 累计时间
    PracticeBookRecord *_currentPracticeRecord;// 标记当前正在练习的记录
    NSMutableDictionary *_answerTextDict;// topic下 所有练习题的text文本 开启思必驰引擎时用到 整合起来 用时方便
    
    PracticeFollowButton *_currentPracticeButton;// 标记正在跟读的按钮  以便倒计时 时方便获取 （用途：此按钮 1、用于 思必驰-->开关 2、 时间倒计时 ）
}
@end

@implementation CheckPractiseBookViewController
#define kCellHeight 150
// webview宽度 用于计算文本高度
#define kWebViewWidth (kScreentWidth-80)


#pragma mark - 合成练习簿数据
- (void)makeUpPracticeBookDataArray
{
    _practiceArray = [[NSMutableArray alloc]init];
    if ([OralDBFuncs getAddPracticeTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName]] != nil)
    {
        NSArray *answerIdArray = [OralDBFuncs getAddPracticeTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName]];
        _answerTextDict = [[NSMutableDictionary alloc]init];
        for (NSDictionary *answerDic in answerIdArray)
        {
            [_practiceArray addObject:[OralDBFuncs getPracticeBookRecordFor:[OralDBFuncs getCurrentUserName] withAnswerId:[answerDic objectForKey:@"id"]]];
            
            [_answerTextDict setObject:[answerDic objectForKey:@"text"] forKey:[answerDic objectForKey:@"id"]];
        }
    }
}

#pragma mark - 视图 加载
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"练习簿"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    [self makeUpPracticeBookDataArray];
    
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

#pragma mark - 播放回调
- (void)playFinished:(id)obj
{
    // 播放完成 将按钮回复默认状态
    UIButton *btn = (UIButton *)[self.view viewWithTag:_markButtonTag];
    btn.selected = NO;
}

#pragma mark - tableview delegate
#pragma mark - cell数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _practiceArray.count;
}

#pragma mark - cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
        此处根据文字大小计算出宽高 ---待完善
     */
    PracticeBookRecord *record = [_practiceArray objectAtIndex:indexPath.row];
    NSString *text = [_answerTextDict objectForKey:record.answerId];
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-80 Height:99999 FontSize:kFontSize_15];
    if (rect.size.height>70)
    {
        return kCellHeight+rect.size.height-70;
    }
    return kCellHeight;
}

#pragma mark - 绘制cell
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
    PracticeBookRecord *record = [_practiceArray objectAtIndex:indexPath.row];
    [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
    [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
    int colorIndex = record.lastScore>=80?0:(record.lastScore>=60?1:2);
    NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
    [cell.scoreButton setBackgroundColor:[colorArr objectAtIndex:colorIndex]];
    
    [cell.followButton settingProgress:0.0 andColor:_badColor andWidth:1 andCircleLocationWidth:3];
    
    return cell;
}

- (void)pracCellCallBack:(PractiseCell *)cell
{
    _markCurrentPractise_index = cell.cellIndex;
    _markButtonTag = (int)cell.buttonIndex;

    // 根据：1、cellIndex的值 来取数据 2、buttonIndex 找按钮
    UIButton *btn = (UIButton *)[cell viewWithTag:cell.buttonIndex];
    _currentPracticeRecord = [_practiceArray objectAtIndex:cell.cellIndex];

    // 参考答案音频路径
    NSString *referPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],_currentPracticeRecord.referAudioName];

    // 自己联系音频路径
    NSString *answerPath = [NSString stringWithFormat:@"%@/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],_currentPracticeRecord.lastAudioName];
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
                [_sbcTimer invalidate];
                _sbcTimer = nil;
            }
            else
            {
                if ([btn isKindOfClass:[PracticeFollowButton class]])
                {
                    _currentPracticeButton = (PracticeFollowButton *)btn;
                    btn.selected = YES;
                    // 开启思必驰引擎
                    NSString *lastText = [_answerTextDict objectForKey:_currentPracticeRecord.answerId];
                    NSLog(@"开启思必驰引擎 : 文本： %@",lastText);
                    [self startSBCAiengineWithText:lastText];
                    _markAnswerTime = 0;
                    [self showTimeProgress];
                }
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
                BOOL deleteSuc = [OralDBFuncs deletePracticeBookRecordFor:[OralDBFuncs getCurrentUserName] withAnswerId:_currentPracticeRecord.answerId];
                if (deleteSuc)
                {
                    NSLog(@"删除成功");
                    [OralDBFuncs deleteAddPracticeTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] AnswerId:_currentPracticeRecord.answerId];
                    [self makeUpPracticeBookDataArray];
                    [_practiseTableV reloadData];
                }
                else
                {
                    NSLog(@"删除失败~~");
                }
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
    float tip = 1.0/KAnswerSumTime/10.0*_markAnswerTime;
    [_currentPracticeButton settingProgress:tip andColor:_badColor
                            andWidth:1 andCircleLocationWidth:3];
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
    NSLog(@"%@",text);
    if(_dfAiengine)
        [_dfAiengine startEngineFor:[self filterHTML:text]];
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
    // 增加练习时间
    [OralDBFuncs addPracticeTime:round(result.systime) ForUser:[OralDBFuncs getCurrentUserName]];
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
    NSString *sbcToPath =  [NSString stringWithFormat:@"%@/%@",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],_currentPracticeRecord.lastAudioName];
    NSData *fileData = [NSData dataWithContentsOfFile:sbcPath];
    BOOL saveSuc = [fileData writeToFile:sbcToPath atomically:YES];
    if (saveSuc)
    {
        // 删除原来的文件
        [[NSFileManager defaultManager]removeItemAtPath:sbcPath error:nil];
    }

    // 存储一条记录 到数据库
    BOOL addSuc = [OralDBFuncs addPracticeBookRecordFor:[OralDBFuncs getCurrentUserName] withAnswerId:_currentPracticeRecord.answerId andReferAudioName:_currentPracticeRecord.referAudioName andLastAUdioName:_currentPracticeRecord.lastAudioName andLastText:msg1 andLastScore:result.overall Pron:result.pron Integrity:result.integrity fluency:[[result.fluency objectForKey:@"overall"] intValue]];
    if (addSuc)
    {
        NSLog(@"更新成功");
    }
    else
    {
        NSLog(@"更新失败");
    }
    
    [self makeUpPracticeBookDataArray];
    [_practiseTableV reloadData];
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
