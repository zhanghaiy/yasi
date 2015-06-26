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
#import "NSURLConnectionRequest.h"
#import "OralDBFuncs.h"


@interface MyTeacherViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_myTeaTableV;
    NSMutableArray *_teacherArray;
    FooterView *_footerView;
    NSString *_teacherId;
    
    BOOL _markDefault;
}
@end

@implementation MyTeacherViewController
#define kTeaTableViewCellHeight 76
#define kFooterViewHeight 60
#define kSelectedButonTag 99

- (void)startRequest
{
    // 选择老师 userId teacherName change
    NSString *str = [NSString stringWithFormat:@"%@%@?userId=%@",kBaseIPUrl,kChooseTeacherUrl,[OralDBFuncs getCurrentUserID]];
    NSLog(@"~~~~~~选择老师：%@~~~~~~",str);
    [NSURLConnectionRequest requestWithUrlString:str target:self aciton:@selector(requestFinished:) andRefresh:YES];
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSLog(@"选择老师反馈结果：%@",dict);
        _teacherArray = [dict objectForKey:@"teacherinfolist"];
        [_myTeaTableV reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"我的老师"];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-70, 24, 70, 44)];
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setTitleColor:_backColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [rightButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:rightButton];
    
    _footerView = [[[NSBundle mainBundle]loadNibNamed:@"FooterView" owner:self options:0] lastObject];
    _footerView.backgroundColor = [UIColor clearColor];
    [_footerView.selectedButton addTarget:self action:@selector(settingDefaultTeacher:) forControlEvents:UIControlEventTouchUpInside];
    
    _myTeaTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+2, kScreentWidth, kScreenHeight-50) style:UITableViewStylePlain];
    _myTeaTableV.delegate = self;
    _myTeaTableV.dataSource = self;
    _myTeaTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTeaTableV];
    _myTeaTableV.backgroundColor = [UIColor clearColor];
    
    [self startRequest];
}


- (void)finishButtonClicked:(UIButton *)btn
{
    // 完成
    if (_markDefault)
    {
        // 存储默认老师
        [OralDBFuncs setDefaultTeacherID:_teacherId UserName:[OralDBFuncs getCurrentUserName]];
    }
    if (self.delegate)
    {
        [self.delegate selectTeacherId:_teacherId];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置默认老师
- (void)settingDefaultTeacher:(UIButton *)btn
{
    if (btn.selected)
    {
        btn.selected = NO;
        _markDefault = NO;
    }
    else
    {
        btn.selected = YES;
        _markDefault = YES;
    }
}



- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _teacherArray.count;
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
    
    NSDictionary *dic = [_teacherArray objectAtIndex:indexPath.row];
    
    cell.teacherDesLabel.text = [dic objectForKey:@"signiture"];
    cell.teacherName.text = [dic objectForKey:@"teachername"];
    
    cell.selectButton.tag = kSelectedButonTag + indexPath.row;
    [cell.selectButton addTarget:self action:@selector(selectTeacxher:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - 选择老师
- (void)selectTeacxher:(UIButton *)btn
{
    for (int i = 0; i < _teacherArray.count; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:i+kSelectedButonTag];
        if (newBtn.tag == btn.tag)
        {
            newBtn.selected = YES;
            _teacherId = [[_teacherArray objectAtIndex:i] objectForKey:@"teacherid"];
        }
        else
        {
            newBtn.selected = NO;
        }
    }
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
