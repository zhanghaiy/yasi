//
//  CheckSuccessViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckSuccessViewController.h"
#import "TPCCheckpointViewController.h"
#import "CheckKeyWordViewController.h"
#import "CheckAskViewController.h"
#import "SuccessCell.h"
#import "OralDBFuncs.h"
#import "NSString+CalculateStringSize.h"
#import "DeviceManager.h"


@interface CheckSuccessViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    NSMutableArray *_scoreMenuArray;
    NSMutableArray *_answer_Cintent_Array;
    NSMutableDictionary *_answer_DB_Dictionary;
}

@end

@implementation CheckSuccessViewController
#define kCellHeght 70

- (void)uiConfig
{
    // 修改frame
    float topView_H = 350.0/667*kScreenHeight;
    float shareBtn_W = 100.0/375*kScreentWidth;
    float shareBtn_H = 55.0/667*kScreenHeight;
    float tipLabel_H = 30;
    float space_share_toBottom = 15.0/667*kScreenHeight;
    float score_H = 180.0/667*kScreenHeight;
    float score_Y = topView_H-5-space_share_toBottom-shareBtn_H-tipLabel_H-score_H;
    [_topBackView setFrame:CGRectMake(0, 0, kScreentWidth, topView_H)];
    [_topScoreLabel setFrame:CGRectMake(0, score_Y, kScreentWidth, score_H)];
    [_topShareButton setFrame:CGRectMake((kScreentWidth-shareBtn_W)/2, topView_H-space_share_toBottom-shareBtn_H, shareBtn_W, shareBtn_H)];
    [_topDesLabel setFrame:CGRectMake(0, topView_H-space_share_toBottom-shareBtn_H-tipLabel_H-5, kScreentWidth, tipLabel_H)];
    // 底部按钮
    float bottom_btn_W = 110.0/375*kScreentWidth;
    float bottom_btn_H = 50.0/667*kScreenHeight;
    [_backButton setFrame:CGRectMake((kScreentWidth/2-bottom_btn_W)/2, kScreenHeight-5-bottom_btn_H, bottom_btn_W, bottom_btn_H)];
    [_continueButton setFrame:CGRectMake(kScreentWidth*3/4-bottom_btn_W/2, kScreenHeight-5-bottom_btn_H, bottom_btn_W, bottom_btn_H)];
    // 字体
    _continueButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_16];
    _backButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_16];
    // 背景色
    _backButton.backgroundColor = _backColor;
    _continueButton.backgroundColor = _backColor;

    // 文字色
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // 圆角半径
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = _backButton.frame.size.height/2;
    _continueButton.backgroundColor = _backColor;
    _continueButton.layer.masksToBounds = YES;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2;
    
    // 中间文字
    float menu_label_H = 40.0/667*kScreenHeight;
    float menu_label_Y = topView_H;
    [_midTitleLabel setFrame:CGRectMake(0, menu_label_Y, kScreentWidth, menu_label_H)];
    [_midTableView setFrame:CGRectMake(0, menu_label_Y+menu_label_H, kScreentWidth, kScreenHeight-menu_label_Y-menu_label_H-bottom_btn_H-10)];
    // 闯关成绩单文字颜色
    _midTitleLabel.textColor = _backColor;
    _midTitleLabel.textAlignment = NSTextAlignmentCenter;
    _midTitleLabel.font = [UIFont systemFontOfSize:kFontSize_16];
    _topScoreLabel.backgroundColor = [UIColor clearColor];
    _topShareButton.backgroundColor = [UIColor whiteColor];
    _topShareButton.layer.masksToBounds = YES;
    _topShareButton.layer.cornerRadius = _topShareButton.frame.size.height/2;
    
    // 描述 分数  文字颜色
    _topScoreLabel.textColor = [UIColor whiteColor];
    _topDesLabel.textColor = [UIColor whiteColor];
    
    _midTableView.delegate = self;
    _midTableView.dataSource = self;
    _midTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _midTableView.showsHorizontalScrollIndicator = NO;
    _midTableView.showsVerticalScrollIndicator = NO;
    
}

#pragma mark - 获取总分
- (void)getSumScore
{
    // 获取总分
    NSLog(@"~~~~~~~~~获取总分~~~~~~~");

    if ([OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]])
    {
        TopicRecord *topicRecord = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]];
        if ([OralDBFuncs getCurrentPart] == 1)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p1_1];
            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p1_2];
            }
        }
        else if ([OralDBFuncs getCurrentPart] == 2)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p2_1];
            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p2_2];
            }
        }
        else if ([OralDBFuncs getCurrentPart] == 3)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p3_1];
            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                _topScoreLabel.text = [NSString stringWithFormat:@"%d",topicRecord.p3_2];
            }
        }
        
    }
    
    // 根据分数设置颜色
    int score = [_topScoreLabel.text intValue];
    
    // 3种颜色 同闯关
//    NSArray *colorArray = @[_perfColor,_goodColor,_badColor];
//    int index = score>=80?0:(score>=60?1:2);
//    _topBackView.backgroundColor = [colorArray objectAtIndex:index];
//    [_topShareButton setTitleColor:[colorArray objectAtIndex:index] forState:UIControlStateNormal];

    
    // 2中颜色
    UIColor *color_fail = [UIColor colorWithRed:249/255.0 green:220/255.0 blue:18/255.0 alpha:1];
    UIColor *color_sucess = [UIColor colorWithRed:1/255.0 green:196/255.0 blue:255/255.0 alpha:1];
    
    NSArray *color_array = @[color_fail,color_sucess];
    int index = score>=60?1:0;

    _topBackView.backgroundColor = [color_array objectAtIndex:index];
    [_topShareButton setTitleColor:[color_array objectAtIndex:index] forState:UIControlStateNormal];

    // 根据分数 设置标题
    NSArray *textArray = @[@"成绩不错~~继续保持！！！",@"成绩中等~~继续努力！！！",@"成绩不理想，需要加强联系哦~~加油！！！！"];
    _topDesLabel.text = [textArray objectAtIndex:index];
    
    if (!index)
    {
        // 不及格 不可以继续闯关
        _continueButton.enabled = NO;
    }
    NSLog(@"~~~~~~~~~获取总分  end ~~~~~~~");

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 分数显示top区域有两种颜色 1：黄色 2： 蓝色
    self.lineLab.hidden = YES;
    self.navTopView.hidden = YES;
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiConfig];
    NSLog(@"测试bug ~~~~~~~ 001");
    // 获取总分 此处由于时间问题 一直崩溃 暂不获取
    [self getSumScore];
    NSLog(@"测试bug ~~~~~~~ 002");

    // 合成成绩单数据源
    _scoreMenuArray = [[NSMutableArray alloc]init];
    [self makeUpScoreMenu];
    NSLog(@"测试bug ~~~~~~~ 003");

}

- (void)makeUpScoreMenu
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
    
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *maindict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"整个topic资源信息");
    // 整个topic资源信息
    NSDictionary *dict = [maindict objectForKey:@"classtypeinfo"];
   
    NSLog(@"当前part资源信息");

    // 当前part资源信息
    NSDictionary *subDict = [[dict objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    NSArray *questionList = [[[subDict objectForKey:@"levellist"] objectAtIndex:[OralDBFuncs getCurrentPoint]-1] objectForKey:@"questionlist"];
    _answer_Cintent_Array = [[NSMutableArray alloc]init];
    _answer_DB_Dictionary = [[NSMutableDictionary alloc]init];
    for (NSDictionary *subSubdict in questionList)
    {
        NSArray *answerArray = [subSubdict objectForKey:@"answerlist"];
        for (NSDictionary *subSubSubDic in answerArray)
        {
            NSString *answerID = [subSubSubDic objectForKey:@"id"];
            [_answer_Cintent_Array addObject:subSubSubDic];
            NSLog(@"!!!!!!!!!PracticeBookRecord!!!!!!!!");

            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerID partNum:[OralDBFuncs getCurrentPart] andLevelNum:[OralDBFuncs getCurrentPoint]])
            {
                PracticeBookRecord *scoreInfoRecord = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerID partNum:[OralDBFuncs getCurrentPart] andLevelNum:[OralDBFuncs getCurrentPoint]];
                [_answer_DB_Dictionary setObject:scoreInfoRecord forKey:answerID];
            }
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[_answer_Cintent_Array objectAtIndex:indexPath.row] objectForKey:@"answer"];
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-80 Height:99999 FontSize:kFontSize_14];
    if (rect.size.height>kCellHeght-20)
    {
        NSInteger height = kCellHeght+rect.size.height-50;
        if (height%2)
        {
            height += 1;
        }
        return height;
    }
    return kCellHeght;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _answer_Cintent_Array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celId = @"cell";
    SuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if ( cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SuccessCell" owner:self options:0] lastObject];
        
        cell.htmlWebView.scrollView.scrollEnabled=NO;
        cell.htmlWebView.scrollView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *answerId = [[_answer_Cintent_Array objectAtIndex:indexPath.row] objectForKey:@"id"];
    PracticeBookRecord *record = [_answer_DB_Dictionary objectForKey:answerId];
    [cell.htmlWebView loadHTMLString:record.lastText baseURL:nil];
    cell.htmlWebView.delegate = self;
    
    NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
    int scoreCun = record.lastScore>=80?0:(record.lastScore>=60?1:2);
    [cell.scoreButton setBackgroundColor:[colorArr objectAtIndex:scoreCun]];
    [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
    return cell;
}



- (void)didReceiveMemoryWarning
{
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


- (IBAction)backToLastPage:(id)sender
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
- (IBAction)continueNextPoint:(id)sender
{
    CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
    [self.navigationController pushViewController:keyVC animated:YES];
}
@end
