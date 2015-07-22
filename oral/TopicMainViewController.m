//
//  TopicMainViewController.m
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicMainViewController.h"
#import "CustomProgressView.h"
#import "TopicCell.h"
#import "RightMainCell.h"
#import "TPCCheckpointViewController.h"
#import "TPCPersonCenterViewController.h"
#import "UIButton+WebCache.h"
#import "OralDBFuncs.h"
#import "TopicInfoManager.h"
#import "NSURLConnectionRequest.h"

@interface TopicMainViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *_topicTableView;
    UITableView *_rightTableView;
    NSArray *_topicArray;
    float _topicContentY;
    BOOL _selectFromRight;
}
@end

@implementation TopicMainViewController
#define kTopicMainTableViewTag 555
#define kRightTableVIewTag 556
#define kTopicButtonTag 566
#define kNavBarHeight 66

#define kmainCellHeight ((kScreenHeight-kNavBarHeight)/3)
#define kRightCellHeight ((kScreenHeight-kNavBarHeight-kmainCellHeight*2/3)/7)
#define kRightCellWith (kRightCellHeight*240.0/200.0)

#define kRightTableY (kScreenHeight-(kRightCellHeight*7)-kNavBarHeight)/2

#define kPersonButtonTag 1992


#pragma mark - 视图加载
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _selectFromRight = NO;
    UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [personBtn setFrame:CGRectMake((kScreentWidth-35)/2, 24+(kNavBarHeight-24-35)/2, 35, 35)];
    personBtn.tag = 1992;
    personBtn.layer.masksToBounds = YES;
    personBtn.layer.cornerRadius = personBtn.frame.size.height/2;
    if ([[OralDBFuncs getCurrentUserIconUrl] length]>1)
    {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[OralDBFuncs getCurrentUserIconUrl]]];
        NSLog(@"%@",[OralDBFuncs getCurrentUserIconUrl]);
        [personBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    }
    else
    {
        [personBtn setBackgroundImage:[UIImage imageNamed:@"personDefault"] forState:UIControlStateNormal];
    }
    
    [personBtn addTarget:self action:@selector(toPersonCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:personBtn];
    
    _topicTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, kScreentWidth, kScreenHeight-kNavBarHeight) style:UITableViewStylePlain];
    _topicTableView.delegate = self;
    _topicTableView.dataSource = self;
    _topicTableView.tag = kTopicMainTableViewTag;
    _topicTableView.showsHorizontalScrollIndicator = NO;
    _topicTableView.showsVerticalScrollIndicator = NO;
    _topicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_topicTableView];
    
    _rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(kScreentWidth, 45+kRightTableY, kRightCellWith, kRightCellHeight*7) style:UITableViewStylePlain];
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    _rightTableView.tag = kRightTableVIewTag;
    _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rightTableView.showsHorizontalScrollIndicator = NO;
    _rightTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_rightTableView];
    
    _loading_View.hidden = NO;
    [self.view bringSubviewToFront:_loading_View];
    NSString *urlSTr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kTopicListUrl];
    [NSURLConnectionRequest requestWithUrlString:urlSTr target:self aciton:@selector(requestFinished:) andRefresh:kCurrentNetStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *personBtn = (UIButton *)[self.view viewWithTag:kPersonButtonTag];
    if ([[OralDBFuncs getCurrentUserIconUrl] length]>1)
    {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[OralDBFuncs getCurrentUserIconUrl]]];
        NSLog(@"%@",[OralDBFuncs getCurrentUserIconUrl]);
        [personBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    }
    else
    {
        [personBtn setBackgroundImage:[UIImage imageNamed:@"personDefault"] forState:UIControlStateNormal];
    }
}

#pragma mark - 网络反馈
- (void)requestFinished:(NSURLConnectionRequest *)request
{
    _loading_View.hidden = YES;
    if (request.downloadData)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dic objectForKey:@"respCode"] intValue] == 1000)
        {
            _topicArray = [dic objectForKey:@"etctlist"];
            // 单例存储topic信息
            [self saveTopicInfo];
            [_topicTableView reloadData];
            [_rightTableView reloadData];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:[dic objectForKey:@"remark"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求topic信息失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"重新请求", nil];
        [alertView show];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *urlSTr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kTopicListUrl];
        [NSURLConnectionRequest requestWithUrlString:urlSTr target:self aciton:@selector(requestFinished:) andRefresh:YES];
    }
}

#pragma mark - 存储topic信息 后续界面会用到
- (void)saveTopicInfo
{
    TopicInfoManager *topicManager = [TopicInfoManager getTopicInfoManager];
    for (NSDictionary *subDic in _topicArray)
    {
        NSString *topicID = [subDic objectForKey:@"id"];
        [topicManager setTopicDetailInfo:subDic TopicID:topicID];
    }
}

#pragma mark - UItableView delegate
#pragma mark - - 数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _topicArray.count;
}

#pragma mark - - 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kTopicMainTableViewTag)
    {
        return kmainCellHeight;
    }
    else if (tableView.tag == kRightTableVIewTag)
    {
        return kRightCellHeight;
    }
    return 0;
}

#pragma mark - - 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kTopicMainTableViewTag)
    {
        static NSString *cellId = @"TopicCell";
        TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"TopicCell" owner:self options:0] lastObject];
        }
        NSDictionary *dic = [_topicArray objectAtIndex:indexPath.row];
//            [cell.topicButton setBackgroundImage:[UIImage imageNamed:@"topic_new_test"] forState:UIControlStateNormal];
       
        [cell.topicButton setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"bgimgurl"]]];
        cell.topicTitle.text = [dic objectForKey:@"classtype"];
        cell.progressColor = kPart_Button_Color;

        // 暂时写死  此处是根据本地数据（自己存储的）来算出用户的进度
        TopicRecord *currentRecord = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[dic objectForKey:@"classtype"]];
        float progress = currentRecord.completion/9.0;
        
        [cell.topicProgressV performSelector:@selector(setProVProgress:) withObject:[NSNumber numberWithFloat:progress]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.topicButton.tag = indexPath.row+kTopicButtonTag;
        [cell.topicButton addTarget:self action:@selector(startPass:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (tableView.tag == kRightTableVIewTag)
    {
        static  NSString *cellid = @"smallCell";
        RightMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"RightMainCell" owner:self options:0] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dict = [_topicArray objectAtIndex:indexPath.row];
        [cell.smallTopicButton setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"bgimgurl"]]];
//        [cell.smallTopicButton setImage:[UIImage imageNamed:@"topic_new_test"] forState:UIControlStateNormal];

        cell.smallTopicButton.tag = indexPath.row+kTopicButtonTag*10;
        [cell.smallTopicButton addTarget:self action:@selector(jumpToCurrentTopic:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

#pragma mark - 进入闯关界面
- (void)startPass:(UIButton *)btn
{
    NSDictionary *selectedTopicDict = [_topicArray objectAtIndex:btn.tag - kTopicButtonTag];
    TPCCheckpointViewController *checkVC = [[TPCCheckpointViewController alloc]initWithNibName:@"TPCCheckpointViewController" bundle:nil];
    checkVC.topicDict = selectedTopicDict;
    [self.navigationController pushViewController:checkVC animated:YES];
}

#pragma mark - 右侧小按钮点击事件
- (void)jumpToCurrentTopic:(UIButton *)btn
{
    _selectFromRight = YES;
    [self rightTableViewHidden];
    // 将点击topic移到中间
    NSInteger count = btn.tag - kTopicButtonTag*10;
    if (count>_topicArray.count-3)
    {
        _topicTableView.contentOffset = CGPointMake(0, (_topicArray.count-3)*kmainCellHeight);
    }
    else if (count<2)
    {
        _topicTableView.contentOffset = CGPointMake(0, 0);
    }
    else
    {
        _topicTableView.contentOffset = CGPointMake(0, (count-1)*kmainCellHeight);
    }
}

#pragma mark - 滑动列表时调用该方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_selectFromRight == NO)
    {
        if (scrollView.tag == kTopicMainTableViewTag)
        {
            [self rightTableViewShow];
            
            if (_topicArray.count>7)
            {
                if (_topicContentY<scrollView.contentOffset.y)
                {
                    // 上面的
                    float cou = scrollView.contentOffset.y/kmainCellHeight;
                    if (cou>7)
                    {
                        _rightTableView.contentOffset = CGPointMake(0, cou*kRightCellHeight);
                    }
                }
                else
                {
                    // 下面的
                    float cou = scrollView.contentOffset.y/kmainCellHeight;
                    if (cou<_topicArray.count-7)
                    {
                        _rightTableView.contentOffset = CGPointMake(0, cou*kRightCellHeight);
                        
                    }
                }
            }
        }
        _topicContentY = scrollView.contentOffset.y;
    }
    else
    {
        _selectFromRight = NO;
    }
}

//#pragma mark - 向下滑动
//- (void)down
//{
//    if (_topicTableView.contentOffset.y/kmainCellHeight+7<_topicArray.count)
//    {
//        _rightTableView.contentOffset = CGPointMake(0, (_topicTableView.contentOffset.y/kmainCellHeight)*kRightCellHeight);
//    }
//    else
//    {
//        _rightTableView.contentOffset = CGPointMake(0, (_topicArray.count-7)*kRightCellHeight);
//    }
//}
//
//#pragma mark - 向上滑动
//- (void)up
//{
//    // 若想右侧列表展示主列表后面的数据 将7--->10即可
//    if (_topicTableView.contentOffset.y/kmainCellHeight-7>0)
//    {
//        _rightTableView.contentOffset = CGPointMake(0, (_topicTableView.contentOffset.y/kmainCellHeight-7)*kRightCellHeight);
//    }
//    else
//    {
//        _rightTableView.contentOffset = CGPointMake(0, 0);
//    }
//}

#pragma mark - 左移
- (void)rightTableViewShow
{
    CGRect rect = _rightTableView.frame;
    rect.origin.x = self.view.frame.size.width-kRightCellHeight;
    [UIView animateWithDuration:0.3 animations:^{
        _rightTableView.frame = rect;
    }];
}

#pragma mark - 右移
- (void)rightTableViewHidden
{
    CGRect rect = _rightTableView.frame;
    rect.origin.x = self.view.frame.size.width;
    [UIView animateWithDuration:0.1 animations:^{
        _rightTableView.frame = rect;
    }];
}

#pragma mark - 右移隐藏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self rightTableViewHidden];
}

/*
 - (void)equeal
 {
 [self.view bringSubviewToFront:_rightTableView];
 if (_topicTableView.contentOffset.y/160<_topicArray.count-7)
 {
 _rightTableView.contentOffset = CGPointMake(0, (_topicTableView.contentOffset.y/160)*60);
 }
 else
 {
 _rightTableView.contentOffset = CGPointMake(0, (_topicArray.count-7)*60);
 }
 _rightTableView.hidden = NO;
 }
 */

#pragma mark - 跳转到个人中心
- (void)toPersonCenter
{
    TPCPersonCenterViewController *personVC = [[TPCPersonCenterViewController alloc]initWithNibName:@"TPCPersonCenterViewController" bundle:nil];
    [self.navigationController pushViewController:personVC animated:YES];
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
