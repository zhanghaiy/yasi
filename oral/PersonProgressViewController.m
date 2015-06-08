//
//  PersonProgressViewController.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonProgressViewController.h"
#import "CheckScoreViewController.h"


@interface PersonProgressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableV;
    NSInteger _cellHeigth_alone;
    UIScrollView *_topScrollV;
    UIScrollView *_bottomScrollV;
}
@end

@implementation PersonProgressViewController
#define kTopBtnBaseTag 500
#define kTopProBaseTag 1500

#define kBottomBtnTag 1000
#define kBottomProBaseTag 2500

- (void)uiConfig
{
    _topBackView.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = kPart_Button_Color;
    _timeLAbel.textColor = kPart_Button_Color;
    _progressLabel.textColor = kPart_Button_Color;
    _progressV.progress = 0.8;
    _progressV.color = kPart_Button_Color;
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 205, kScreentWidth, kScreenHeight-205) style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    [self.view addSubview:_tableV];
    
    // 计算cell高度 因为是横向滑动 页面展示时 1、3个 2、9个 要是的上下的大小一致
    _cellHeigth_alone = (kScreenHeight-205-2*30-20)/4;
    [self createPractisedTopicScrollView];
    [self createPractisingTopicScrollView];
}

#pragma mark - 正在练习的scrollview
- (void)createPractisingTopicScrollView
{
    _topScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone+20)];
    _topScrollV.delegate = self;
    _topScrollV.pagingEnabled = YES;
    
    NSInteger topicCount = 6;// 模拟topic个数
    NSInteger pages = (topicCount%3?(topicCount/3+1):topicCount/3);
    NSInteger btnWith = _cellHeigth_alone-25;
    NSInteger btn_space = (kScreentWidth-3*btnWith)/4;
    _topScrollV.contentSize = CGSizeMake(kScreentWidth*pages, _cellHeigth_alone+20);

    NSInteger mark_topic_count=0;
    for (int i = 0; i < pages; i ++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (mark_topic_count<topicCount)
            {
                mark_topic_count ++;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(i*kScreentWidth+btn_space+j*(btnWith+btn_space), 12, btnWith, btnWith)];
                btn.tag = kTopBtnBaseTag + mark_topic_count;
                [btn setBackgroundImage:[UIImage imageNamed:@"topic_moni"] forState:UIControlStateNormal];
                [_topScrollV addSubview:btn];
                
                CustomProgressView *proV = [[CustomProgressView alloc]initWithFrame:CGRectMake(i*kScreentWidth+btn_space+j*(btnWith+btn_space), 25+btnWith, btnWith, 8)];
                proV.color = kPart_Button_Color;
                proV.progress = 0.3;
                proV.tag = kTopProBaseTag + mark_topic_count;
                [_topScrollV addSubview:proV];
            }
        }
    }
}

#pragma mark - 练习完成的scrollview
- (void)createPractisedTopicScrollView
{
    _bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone*3 )];
    _bottomScrollV.delegate = self;
    _bottomScrollV.pagingEnabled = YES;
    
    NSInteger topicCount = 14;// 模拟topic个数
    NSInteger pages = (topicCount%9?(topicCount/9+1):topicCount/9);
    NSInteger btnWith = _cellHeigth_alone-25;
    NSInteger btn_space = (kScreentWidth-3*btnWith)/4;
    _bottomScrollV.contentSize = CGSizeMake(kScreentWidth*pages, _cellHeigth_alone*3);
    
    NSInteger mark_topic_count=0;
    for (int i = 0; i < pages; i ++)
    {
        for (int j = 0; j < 3; j++)
        {
            for (int k = 0; k<3; k ++)
            {
                if (mark_topic_count<topicCount)
                {
                    mark_topic_count ++;
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(i*kScreentWidth+btn_space+k*(btnWith+btn_space), 12 + j*_cellHeigth_alone, btnWith, btnWith)];
                    btn.tag = kBottomBtnTag + mark_topic_count;
                    [btn setBackgroundImage:[UIImage imageNamed:@"topic_moni"] forState:UIControlStateNormal];

                    [_bottomScrollV addSubview:btn];
                }
            }
            
        }
    }
}

- (void)topicButton_topButton_Clicked:(UIButton *)btn
{
    NSInteger index = btn.tag - kTopBtnBaseTag;
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}

- (void)topicButton_bottomButton_Clicked:(UIButton *)btn
{
    NSInteger index = btn.tag - kBottomBtnTag;
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"闯关进度"];
    [self uiConfig];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.section == 0)
    {
        [cell addSubview:_topScrollV];
    }
    else if (indexPath.section == 1)
    {
        [cell addSubview:_bottomScrollV];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return _cellHeigth_alone+20;
    }
    else if (indexPath.section == 1)
    {
        return _cellHeigth_alone*3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *textArr = @[@"正在练习",@"练习完成"];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 30)];
    label.text = [textArr objectAtIndex:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = kText_Color;
    label.font = [UIFont systemFontOfSize:kFontSize2];
    return label;
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
