//
//  PersonProgressViewController.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonProgressViewController.h"
#import "CheckScoreViewController.h"
#import "NSURLConnectionRequest.h"
#import "PointProgressView.h"
#import "OralDBFuncs.h"
#import "TopicInfoManager.h"
#import "UIButton+WebCache.h"

@interface PersonProgressViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableV;
    PointProgressView *_proV_tableHeaderV;
    NSInteger _cellHeigth_alone;
    UIScrollView *_topScrollV;
    UIScrollView *_bottomScrollV;
    
    NSArray *_notPassListArray;
    NSArray *_passListArray;
    TopicInfoManager *_topicManager;
}
@end

@implementation PersonProgressViewController
#define kTopBtnBaseTag 500
#define kTopProBaseTag 1500

#define kBottomBtnTag 1000
#define kBottomProBaseTag 2500

#pragma mark - UI配置
- (void)uiConfig
{
    _proV_tableHeaderV = [[[NSBundle mainBundle]loadNibNamed:@"PointProgressView" owner:self options:0] lastObject];
    [_proV_tableHeaderV setFrame:CGRectMake(0, 0, kScreentWidth, 140)];
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableHeaderView = _proV_tableHeaderV;
    [self.view addSubview:_tableV];
    
    // 计算cell高度 因为是横向滑动 页面展示时 1、3个 2、9个 要是的上下的大小一致
    _cellHeigth_alone = (kScreenHeight-205-2*30-20)/4;
}

#pragma mark - 根据数据创建topic展示View
#pragma mark - - 正在练习的scrollview
- (void)createPractisingTopicScrollView
{
    _topScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone+20)];
    _topScrollV.delegate = self;
    _topScrollV.pagingEnabled = YES;
    _topScrollV.showsHorizontalScrollIndicator = NO;
    _topScrollV.showsVerticalScrollIndicator = NO;
    
    NSInteger topicCount = _notPassListArray.count;// 模拟topic个数
    if (topicCount==0)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone)];
        label.text = @"亲，最近没有练习呦，赶快去学习吧~~~~~~~~";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kPart_Button_Color;
        label.font = [UIFont systemFontOfSize:kFontSize_14];
        [_topScrollV addSubview:label];
    }
    else
    {
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
                    NSLog(@"%ld",mark_topic_count);
                    NSString *topicID = [[_notPassListArray objectAtIndex:mark_topic_count-1] objectForKey:@"classtypeid"];
                    NSDictionary *topicDetailDic = [_topicManager getTopicDetailInfoWithTopicID:topicID];
                    NSString *topicImgUrl = [topicDetailDic objectForKey:@"bgimgurl"];
                    NSLog(@"正在练习的:%@",topicImgUrl);

                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(i*kScreentWidth+btn_space+j*(btnWith+btn_space), 12, btnWith, btnWith)];
                    btn.tag = kTopBtnBaseTag + mark_topic_count;
                    [btn setImageWithURL:[NSURL URLWithString:topicImgUrl] placeholderImage:[UIImage imageNamed:@"33.jpg"]];

                    [btn addTarget:self action:@selector(topicButton_topButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                    
                    btn.layer.masksToBounds = YES;
                    btn.layer.cornerRadius = btn.frame.size.height/2;
                    btn.layer.borderWidth = 1;
                    btn.layer.borderColor = [UIColor clearColor].CGColor;
                    
                    
                    [_topScrollV addSubview:btn];
                    
                    TopicRecord *record = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[[_notPassListArray objectAtIndex:mark_topic_count-1] objectForKey:@"classtype"]];
                    float progress = record.completion/9.0;
                    CustomProgressView *proV = [[CustomProgressView alloc]initWithFrame:CGRectMake(i*kScreentWidth+btn_space+j*(btnWith+btn_space), 25+btnWith, btnWith, 8)];
                    proV.color = kPart_Button_Color;
                    proV.progress = progress;
                    proV.tag = kTopProBaseTag + mark_topic_count;
                    [_topScrollV addSubview:proV];
                }
            }
        }

    }
}

#pragma mark - - 练习完成的scrollview
- (void)createPractisedTopicScrollView
{
    _bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone*3 )];
    _bottomScrollV.delegate = self;
    _bottomScrollV.pagingEnabled = YES;
    _bottomScrollV.showsVerticalScrollIndicator = NO;
    _bottomScrollV.showsHorizontalScrollIndicator = NO;
    
    NSInteger topicCount = _passListArray.count;// 模拟topic个数
    if (topicCount==0)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, _cellHeigth_alone*2)];
        label.text = @"赶快抓紧时间学习吧亲\n\n您还没有完成的topic呦";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kPart_Button_Color;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:kFontSize_14];
        [_bottomScrollV addSubview:label];
    }
    else
    {
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
                        // 通过单例获取topic的图标URL
                        NSString *topicID = [[_passListArray objectAtIndex:mark_topic_count] objectForKey:@"classtypeid"];
                        NSDictionary *topicDetailDic = [_topicManager getTopicDetailInfoWithTopicID:topicID];
                        NSString *topicImgUrl = [topicDetailDic objectForKey:@"bgimgurl"];
                        NSLog(@"%@",topicImgUrl);
                        
                        mark_topic_count ++;
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(i*kScreentWidth+btn_space+k*(btnWith+btn_space), 12 + j*_cellHeigth_alone, btnWith, btnWith)];
                        btn.tag = kBottomBtnTag + mark_topic_count;
                        [btn setImageWithURL:[NSURL URLWithString:topicImgUrl] placeholderImage:[UIImage imageNamed:@"topic_moni"]];
                        [btn addTarget:self action:@selector(topicButton_bottomButton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
                        
                        btn.layer.masksToBounds = YES;
                        btn.layer.cornerRadius = btn.frame.size.height/2;
                        btn.layer.borderWidth = 1;
                        btn.layer.borderColor = [UIColor clearColor].CGColor;
                        
                        [_bottomScrollV addSubview:btn];
                    }
                }
                
            }
        }
    }

}

#pragma mark - - 正在练习的topic被点击
- (void)topicButton_topButton_Clicked:(UIButton *)btn
{
    // 传参数  进入成绩单 区分topic ----> 待完善
    NSInteger index = btn.tag - kTopBtnBaseTag;
    NSDictionary *dic = [_notPassListArray objectAtIndex:index];
    [OralDBFuncs setCurrentTopic:[dic objectForKey:@"classtype"]];
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}

#pragma mark - - 练习完成的topic被点击
- (void)topicButton_bottomButton_Clicked:(UIButton *)btn
{
    // 进入成绩单 区分topic ----> 待完善
    NSInteger index = btn.tag - kBottomBtnTag;
    NSDictionary *dic = [_passListArray objectAtIndex:index];
    [OralDBFuncs setCurrentTopic:[dic objectForKey:@"classtype"]];
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}


#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"闯关进度"];
    [self uiConfig];
    
    _topicManager = [TopicInfoManager getTopicInfoManager];
    
    [self requestTopicProgress];
}

#pragma mark - 网络请求
- (void)requestTopicProgress
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?userId=%@",kBaseIPUrl,kPersonInfoUrl,_userId];
    NSLog(@"%@",urlStr);
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestCallBack:) andRefresh:YES];
}

- (void)requestCallBack:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length]>0)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSDictionary *infoDic = [[dict objectForKey:@"studentInfos"] lastObject];
        _notPassListArray = [infoDic objectForKey:@"notPassList"];
        _passListArray = [infoDic objectForKey:@"passList"];
        [self createPractisedTopicScrollView];
        [self createPractisingTopicScrollView];
        
        //
        int timeDuration = round([[infoDic objectForKey:@"totallength"] doubleValue]/1000.0);
        _proV_tableHeaderV.timeLAbel.text = [NSString stringWithFormat:@"%d\"",timeDuration];
        _proV_tableHeaderV.progressV.progress = [[infoDic objectForKey:@"countpassclasstype"] floatValue]/[[dict objectForKey:@"countclasstype"] floatValue];
        _proV_tableHeaderV.progressV.color = kPart_Button_Color;
        _proV_tableHeaderV.progressLabel.text = [NSString stringWithFormat:@"%d/%d",[[infoDic objectForKey:@"countpassclasstype"]intValue],[[infoDic objectForKey:@"countclasstype"] intValue]];
        
        [_tableV reloadData];
    }
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
    label.font = [UIFont systemFontOfSize:kFontSize_12];
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
