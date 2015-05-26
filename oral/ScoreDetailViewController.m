//
//  ScoreDetailViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreDetailViewController.h"
#import "ScoreMenuCell.h"


@interface ScoreDetailViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *_topBackV;
    UIScrollView *_pointScrollV;
}
@end

@implementation ScoreDetailViewController

#define kPointButtonWidth (kScreentWidth/3)
#define kPointButtonTag 1111
#define kTopViewHeight 44
#define kTableViewTag 2222

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    
    [self uiConfig];
}

- (void)uiConfig
{
    // 顶部 关卡
    _topBackV = [[UIView alloc]initWithFrame:CGRectMake(0, 45, kScreentWidth, kTopViewHeight)];
    _topBackV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_topBackV];
    
    for (int i = 0; i < 3; i ++)
    {
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pointButton setFrame:CGRectMake(i*kPointButtonWidth, 0, kPointButtonWidth, kTopViewHeight)];
        [pointButton setTitle:[NSString stringWithFormat:@"Part%ld-%d",self.currentPartCounts+1,i+1] forState:UIControlStateNormal];
        [pointButton setTitleColor:_pointColor forState:UIControlStateSelected];
         [pointButton setTitleColor:_textColor forState:UIControlStateNormal];
//        pointButton.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
        
        pointButton.tag = kPointButtonTag + i;
        pointButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize2];
        [pointButton addTarget:self action:@selector(pointButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topBackV addSubview:pointButton];
        if (i == 0)
        {
            pointButton.selected = YES;
        }
    }
    
    _pointScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 89, kScreentWidth, kScreenHeight-89)];
    _pointScrollV.contentSize = CGSizeMake(kScreentWidth*3, kScreenHeight-89);
    _pointScrollV.delegate = self;
    _pointScrollV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_pointScrollV];
    
    for (int i = 0; i < 3; i ++)
    {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i*kScreentWidth, 0, kScreentWidth, _pointScrollV.bounds.size.height) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag  = kTableViewTag+i;
        tableView.backgroundColor = _backgroundViewColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_pointScrollV addSubview:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag)
    {
        case kTableViewTag:
        {
            // point 1 跟读 此处cell 可重复利用闯关成功页面cell
            static NSString *cellId = @"successCell";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            
            return cell;
        }
            break;
        case kTableViewTag+1:
        {
            // point 2 填空 此处cell 同上
            static NSString *cellId = @"sucCell";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            
            return cell;
        }
            break;
        case kTableViewTag+2:
        {
            // point 3 问答 此处cell 可折叠
            static NSString *cellId = @"sucCell";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)pointButtonClicked:(UIButton *)btn
{
    for (int i = 0; i < 3; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:kPointButtonTag+i];
        if (newBtn.tag == btn.tag)
        {
            newBtn.selected = YES;
        }
        else
        {
            newBtn.selected = NO;
        }
    }
    _pointScrollV.contentOffset = CGPointMake(kScreentWidth*(btn.tag - kPointButtonTag), 0);
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
