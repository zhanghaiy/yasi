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

@interface CheckSuccessViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    UIColor *_oraColor;
    UIColor *_blueColor;
    NSMutableArray *_scoreMenuArray;
}

@end

@implementation CheckSuccessViewController


- (void)uiConfig
{
    _topBackView.backgroundColor = _oraColor;
    _middleBackView.backgroundColor = [UIColor whiteColor];
    _bottomBackView.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _topScoreLabel.backgroundColor = [UIColor clearColor];
    
    
    _topShareButton.backgroundColor = [UIColor whiteColor];
    [_topShareButton setTitleColor:_oraColor forState:UIControlStateNormal];
    _topShareButton.layer.masksToBounds = YES;
    _topShareButton.layer.cornerRadius = _topShareButton.frame.size.height/2;
    
    _backButton.backgroundColor = _backColor;
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = _backButton.frame.size.height/2;
    
    _continueButton.backgroundColor = _backColor;
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueButton.layer.masksToBounds = YES;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2;
    
    _midTitleLabel.textColor = _backColor;
    _midTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    _topScoreLabel.textColor = [UIColor whiteColor];
    _topDesLabel.textColor = [UIColor whiteColor];
    
    _midTableView.delegate = self;
    _midTableView.dataSource = self;
    _midTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

#pragma mark - 获取总分
- (void)getSumScore
{
    // 获取总分
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
    NSArray *colorArray = @[_perfColor,_goodColor,_badColor];
    int index = score>=80?0:(score>=60?1:2);
    _topBackView.backgroundColor = [colorArray objectAtIndex:index];
    [_topShareButton setTitleColor:[colorArray objectAtIndex:index] forState:UIControlStateNormal];
    // 根据分数 设置标题
    NSArray *textArray = @[@"成绩不错呦~超过了%62的小伙伴!",@"成绩不错呦~超过了%62的小伙伴!",@"没及格~需要加强联系呦~努力努力！！！！"];
    _topDesLabel.text = [textArray objectAtIndex:index];
    if (index==2)
    {
        // 不及格 不可以继续闯关
//        _continueButton.enabled = NO;
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 分数显示top区域有两种颜色 1：黄色 2： 蓝色
    _oraColor = [UIColor colorWithRed:242/255.0 green:222/255.0 blue:44/255.0 alpha:1];
    _blueColor = [UIColor blueColor];// 暂时 后续补上
    self.lineLab.hidden = YES;
    self.navTopView.hidden = YES;
    [self uiConfig];
    
    // 获取总分 此处由于时间问题 一直崩溃 暂不获取
    [self getSumScore];
    // 合成成绩单数据源
    _scoreMenuArray = [[NSMutableArray alloc]init];
    [self makeUpScoreMenu];
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
    // 整个topic资源信息
    NSDictionary *dict = [maindict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSDictionary *subDict = [[dict objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    NSArray *questionList = [[[subDict objectForKey:@"levellist"] objectAtIndex:[OralDBFuncs getCurrentPoint]-1] objectForKey:@"questionlist"];
    for (NSDictionary *subSubdict in questionList)
    {
        NSArray *answerArray = [subSubdict objectForKey:@"answerlist"];
        for (NSDictionary *subSubSubDic in answerArray)
        {
            [_scoreMenuArray addObject:subSubSubDic];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _scoreMenuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celId = @"cell";
    SuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if ( cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SuccessCell" owner:self options:0] lastObject];
    }
    NSString *answerId = [[_scoreMenuArray objectAtIndex:indexPath.row] objectForKey:@"id"];
   PracticeBookRecord *scoreInfoRecord = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:[OralDBFuncs getCurrentPoint]];
    NSLog(@"~~~~~%@~~~~~~~~",scoreInfoRecord.lastText);
    [cell.htmlWebView loadHTMLString:scoreInfoRecord.lastText baseURL:nil];
    cell.htmlWebView.delegate = self;
    
    NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
    int scoreCun = scoreInfoRecord.lastScore>=80?0:(scoreInfoRecord.lastScore>=60?1:2);
    [cell.scoreButton setBackgroundColor:[colorArr objectAtIndex:scoreCun]];
    [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",scoreInfoRecord.lastScore] forState:UIControlStateNormal];

    
    return cell;
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
