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

@interface CheckPractiseBookViewController ()<UITableViewDataSource,UITableViewDelegate,DFAiengineSentProtocol>
{
    UITableView *_practiseTableV;
    AudioPlayer *_playerManager;
    DFAiengineSentObject *_dfAiengine;
    NSInteger _markCurrentPractise_index;
}
@end

@implementation CheckPractiseBookViewController
#define kCellHeight 150
// webview宽度 用于计算文本高度
#define kWebViewWidth (kScreentWidth-80)


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"练习簿"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    
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
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    cell.recive_score = 90;
    return cell;
}

- (void)pracCellCallBack:(PractiseCell *)cell
{
    // 根据：1、cellIndex的值 来取数据 2、buttonIndex 找按钮
    UIButton *btn = (UIButton *)[cell viewWithTag:cell.buttonIndex];
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
                // 开始播放
                NSString *audioPath;
                [_playerManager playerPlayWithFilePath:audioPath];
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
                NSString *audioPath;
                [_playerManager playerPlayWithFilePath:audioPath];
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
                [self startSBCAiengine];
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
                
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - 思必驰语音引擎
#pragma mark - 开启思必驰引擎
- (void)startSBCAiengine
{
    // 参考文本
    NSString *text;// = [[_currentAnswerListArray objectAtIndex:_currentAnswerCounts] objectForKey:@"answer"];
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
    [self performSelectorOnMainThread:@selector(showResult:) withObject:[NSString stringWithFormat:@"%d",result.overall] waitUntilDone:NO];
    
    NSString *msg1 = [_dfAiengine getRichResultString:result.details];
    NSLog(@"%@",msg1);
    [self performSelectorOnMainThread:@selector(showHtmlMsg:) withObject:msg1 waitUntilDone:NO];
    
}

#pragma mark - 展示每个单词发音情况
- (void)showHtmlMsg:(NSString *)htmlStr
{
    // 展示每个单词发音情况 彩色文本
}
#pragma mark - 展示分数
- (void)showResult:(NSString *)score
{
    /*
     根据反馈结果填空
     0,213,136  绿色  80<=x<=100
     246,215,0  黄色  60<=x<80
     212,0,44   红色   0<=x<60
     待完善
     */
    NSArray *colorArray = @[_perfColor,_goodColor,_badColor];
    int scoreCun = [score intValue]>=80?0:([score intValue]>=60?1:2);
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
