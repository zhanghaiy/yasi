//
//  MyTeacherViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "MyTeacherViewController.h"
#import "FooterView.h"
#import "MyTeacherCell.h"

@interface MyTeacherViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_myTeaTableV;
    NSMutableArray *_teacherArray;
    FooterView *_footerView;
}
@end

@implementation MyTeacherViewController
#define kTeaTableViewCellHeight 76
#define kFooterViewHeight 60

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"我的老师"];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-70, 0, 70, self.navTopView.frame.size.height)];
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setTitleColor:_backColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [self.navTopView addSubview:rightButton];
    
    _footerView = [[[NSBundle mainBundle]loadNibNamed:@"FooterView" owner:self options:0] lastObject];
    _footerView.backgroundColor = [UIColor clearColor];
    
    
    _myTeaTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, kScreentWidth, kScreenHeight-50) style:UITableViewStylePlain];
    _myTeaTableV.delegate = self;
    _myTeaTableV.dataSource = self;
    _myTeaTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTeaTableV];
    _myTeaTableV.backgroundColor = [UIColor clearColor];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MyTeacherCell";
    MyTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MyTeacherCell" owner:self options:0] lastObject];
    }
    cell.teacherName.textColor = _backColor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTeaTableViewCellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    _footerView.titleLabel.textColor = _backColor;
    return _footerView;
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
