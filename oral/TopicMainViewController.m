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
#import "NetManager.h"
#import "UIButton+WebCache.h"

@interface TopicMainViewController ()<UITableViewDataSource,UITableViewDelegate>
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
#define kNavBarHeight 45
//#define kScreentWidth [UIScreen mainScreen].bounds.size.width
//#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kmainCellHeight ((kScreenHeight-kNavBarHeight)/3)
#define kRightCellHeight ((kScreenHeight-kNavBarHeight-kmainCellHeight*2/3)/7)
#define kRightTableY (kScreenHeight-(kRightCellHeight*7)-kNavBarHeight)/2
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _selectFromRight = NO;
    UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [personBtn setFrame:CGRectMake(0, 0, 35, 35)];
    personBtn.center = self.navTopView.center;
    [personBtn setBackgroundImage:[UIImage imageNamed:@"touxiang.png"] forState:UIControlStateNormal];
    [personBtn addTarget:self action:@selector(toPersonCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:personBtn];
    
    // 模拟数据源
//    _topicArray = @[@{@"imageName":@"topic.png",@"title":@"My favourite sport",@"color":[UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1]},@{@"imageName":@"topic1.png",@"title":@"I like music",@"color":[UIColor colorWithRed:248/255.0 green:227/255.0 blue:68/255.0 alpha:1]},@{@"imageName":@"topic2.png",@"title":@"My travel",@"color":[UIColor colorWithRed:176/255.0 green:0/255.0 blue:241/255.0 alpha:1]},@{@"imageName":@"topic.png",@"title":@"My favourite sport",@"color":[UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1]},@{@"imageName":@"topic1.png",@"title":@"I like music",@"color":[UIColor colorWithRed:248/255.0 green:227/255.0 blue:68/255.0 alpha:1]},@{@"imageName":@"topic2.png",@"title":@"My travel",@"color":[UIColor colorWithRed:176/255.0 green:0/255.0 blue:241/255.0 alpha:1]},@{@"imageName":@"topic.png",@"title":@"My favourite sport",@"color":[UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1]},@{@"imageName":@"topic1.png",@"title":@"I like music",@"color":[UIColor colorWithRed:248/255.0 green:227/255.0 blue:68/255.0 alpha:1]},@{@"imageName":@"topic2.png",@"title":@"My travel",@"color":[UIColor colorWithRed:176/255.0 green:0/255.0 blue:241/255.0 alpha:1]},@{@"imageName":@"topic.png",@"title":@"My favourite sport",@"color":[UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1]},@{@"imageName":@"topic2.png",@"title":@"My travel",@"color":[UIColor colorWithRed:176/255.0 green:0/255.0 blue:241/255.0 alpha:1]},@{@"imageName":@"topic.png",@"title":@"My favourite sport",@"color":[UIColor colorWithRed:87/255.0 green:225/255.0 blue:190/255.0 alpha:1]}];
    
    _topicTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, kScreentWidth, kScreenHeight-kNavBarHeight) style:UITableViewStylePlain];
    _topicTableView.delegate = self;
    _topicTableView.dataSource = self;
    _topicTableView.tag = kTopicMainTableViewTag;
    _topicTableView.showsHorizontalScrollIndicator = NO;
    _topicTableView.showsVerticalScrollIndicator = NO;
    _topicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_topicTableView];
    
    _rightTableView = [[UITableView alloc]initWithFrame:CGRectMake(kScreentWidth, 45+kRightTableY, kRightCellHeight, kRightCellHeight*7) style:UITableViewStylePlain];
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    _rightTableView.tag = kRightTableVIewTag;
    _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rightTableView.showsHorizontalScrollIndicator = NO;
    _rightTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_rightTableView];
    
    [self requestTopicInfo];
}

- (void)requestTopicInfo
{
    NetManager *netManager = [[NetManager alloc]init];
    netManager.target = self;
    netManager.action = @selector(requestFinished:);
    [netManager netGetUrl:[NSString stringWithFormat:@"%@%@",kBaseIPUrl,kTopicListUrl]];
}

- (void)requestFinished:(NetManager *)netManager
{
    if (netManager.success)
    {
        if (netManager.downLoadData)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:netManager.downLoadData options:0 error:nil];
            _topicArray = [dict objectForKey:@"etctlist"];
            [_topicTableView reloadData];
            [_rightTableView reloadData];
        }
    }
    else
    {
        // 失败
        NSLog(@"网络错误");
    }
}


#pragma mark - 数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _topicArray.count;
}

#pragma mark - 高度
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

#pragma mark - 绘制cell
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
        [cell.topicButton setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"bgimgurl"]]];
        cell.topicTitle.text = [dic objectForKey:@"classtype"];
        
        NSArray *colorArr = [[dic objectForKey:@"classcolor"] componentsSeparatedByString:@","];
        if (colorArr.count == 3)
        {
            NSInteger red = [[colorArr objectAtIndex:0] integerValue];
            NSInteger orange = [[colorArr objectAtIndex:1] integerValue];
            NSInteger blue = [[colorArr objectAtIndex:2] integerValue];
            cell.progressColor = [UIColor colorWithRed:red/255.0 green:orange/255.0 blue:blue/255.0 alpha:1];
            
        }
        // 暂时写死  此处是根据本地数据（自己存储的）来算出用户的进度
        cell.topicProgressV.progress = 0.8;
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

        cell.smallTopicButton.tag = indexPath.row+kTopicButtonTag*10;
        [cell.smallTopicButton addTarget:self action:@selector(jumpToCurrentTopic:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

#pragma mark - 进入闯关界面
- (void)startPass:(UIButton *)btn
{
    NSLog(@"%ld",btn.tag);
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
    else if (count<3)
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
    NSLog(@"%f",scrollView.contentOffset.y / kmainCellHeight);
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
