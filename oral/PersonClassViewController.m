//
//  PersonClassViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonClassViewController.h"
#import "ClassCell.h"
#import "ClassIntroduceViewController.h"
#import "ClassDetailViewController.h"
#import "ClassSearchViewController.h"

@interface PersonClassViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_myClassTableV;
    NSMutableArray *_classLIstArray;
}
@end

@implementation PersonClassViewController
#define kCellHeight 75
#define kClassButtonTag 100

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"我的班级"];
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-40, 24+(KNavTopViewHeight-24-25)/2, 25, 25)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"class_search"] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [rightButton addTarget:self action:@selector(searchClass) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:rightButton];
    
    
    _myClassTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+5, kScreentWidth, kScreenHeight-5-KNavTopViewHeight) style:UITableViewStylePlain];
    _myClassTableV.delegate = self;
    _myClassTableV.dataSource = self;
    _myClassTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myClassTableV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_myClassTableV];
}

- (void)searchClass
{
    ClassSearchViewController *searchVC = [[ClassSearchViewController alloc]initWithNibName:@"ClassSearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UITableView delegate dataSource
#pragma mark - numberOfRows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

#pragma mark - 去掉多余分割线
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - 绘制cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SearchClassCell";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ClassCell" owner:self options:0] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.classImageButton.tag = kClassButtonTag + indexPath.row;
    [cell.classImageButton addTarget:self action:@selector(enterClassIntroducePage:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - 选中班级 进入班级详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 进入班级详情
    ClassDetailViewController *classDetailVC = [[ClassDetailViewController alloc]initWithNibName:@"ClassDetailViewController" bundle:nil];
    [self.navigationController pushViewController:classDetailVC animated:YES];
}


- (void)enterClassIntroducePage:(UIButton *)btn
{
    // 进入班级介绍
    ClassIntroduceViewController *classIntroduceVC  = [[ClassIntroduceViewController alloc]initWithNibName:@"ClassIntroduceViewController" bundle:nil];
    [self.navigationController pushViewController:classIntroduceVC animated:YES];
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
