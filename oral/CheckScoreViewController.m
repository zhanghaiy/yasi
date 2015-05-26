//
//  CheckScoreViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckScoreViewController.h"
#import "ScoreDetailViewController.h"


@interface CheckScoreViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_backScrollV;
    UISegmentedControl *_segment;
}
@end

@implementation CheckScoreViewController
#define kPartButtonWidth 230
#define kPartButtonHeight 100
#define kPartButtonTag 333

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    
    [self uiConfig];
    
}

- (void)uiConfig
{
// -------------分段控制器-----------
    // 先创建数组 给分段控件赋值
    NSArray *array = [[NSArray alloc]initWithObjects:@"模考", @"关卡",nil];
    // 创建一个分段控件
    _segment = [[UISegmentedControl alloc]initWithItems:array];
    // 分段控件的位置
    _segment.frame = CGRectMake((kScreentWidth-110)/2, 55, 110, 35);
    // 分段控件的选中颜色
    _segment.tintColor = _pointColor;
    // 默认启动选择索引
    _segment.selectedSegmentIndex = 0;
    // 圆角半径
    _segment.layer.masksToBounds = YES;
    _segment.layer.cornerRadius = 35/2;
    _segment.layer.borderColor = _pointColor.CGColor;
    _segment.layer.borderWidth = 1;
    // 分段控件点击方法
    [_segment addTarget:self action:@selector(segment:) forControlEvents:UIControlEventValueChanged];
    // 添加到视图上
    [self.view addSubview:_segment];
// -------------scrollView-----------
    
    _backScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, kScreentWidth, kScreenHeight-100)];
    _backScrollV.pagingEnabled = YES;
    _backScrollV.delegate = self;
    _backScrollV.contentSize = CGSizeMake(kScreentWidth*2, kScreenHeight-100);
    [self.view addSubview:_backScrollV];
    // 模考
    
    
    
    // 闯关
    NSArray *partButtonNameArray = @[@"Part-One",@"Part-Two",@"Part-Three"];
    for (int i = 0; i < partButtonNameArray.count; i ++)
    {
        // 240 100
        UIButton *partButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [partButton setFrame:CGRectMake(kScreentWidth+(kScreentWidth-kPartButtonWidth)/2, 40+i*(kPartButtonHeight+15), kPartButtonWidth, kPartButtonHeight)];
        [partButton setTitle:[partButtonNameArray objectAtIndex:i] forState:UIControlStateNormal];
        [partButton setTitleColor:_pointColor forState:UIControlStateNormal];
        partButton.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
        partButton.layer.masksToBounds = YES;
        partButton.layer.cornerRadius = kPartButtonHeight/2;
        partButton.titleLabel.font = [UIFont systemFontOfSize:25];
        partButton.tag = kPartButtonTag + i;
        [partButton addTarget:self action:@selector(partButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backScrollV addSubview:partButton];
    }
    
}

- (void)partButtonClicked:(UIButton *)btn
{
     // part1 -- 3
    ScoreDetailViewController *scoreVC = [[ScoreDetailViewController alloc]initWithNibName:@"ScoreDetailViewController" bundle:nil];
    scoreVC.currentPartCounts = btn.tag - kPartButtonTag;
    [self.navigationController pushViewController:scoreVC animated:YES];
}

- (void)segment:(UISegmentedControl *)segment
{
    //    选中的下标
    _backScrollV.contentOffset = CGPointMake(segment.selectedSegmentIndex*kScreentWidth, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/kScreentWidth;
    _segment.selectedSegmentIndex = page;
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
