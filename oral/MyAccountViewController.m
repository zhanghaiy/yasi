//
//  MyAccountViewController.m
//  oral
//
//  Created by cocim01 on 15/6/30.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "MyAccountViewController.h"
#import "OralDBFuncs.h"
#import "LogInViewController.h"


@interface MyAccountViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableV ;
    NSArray *_settingArray;
    UIView *_footerV;
}
@end

#define kFooterViewHeight 55


@implementation MyAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"我的账号"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    NSString *userName = [NSString stringWithFormat:@"用户名：%@",[OralDBFuncs getCurrentUserName]];
    NSString *userId = [NSString stringWithFormat:@"用户ID：%@",[OralDBFuncs getCurrentUserID]];
    _settingArray = @[userName,userId];
    
    
    _footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, kFooterViewHeight)];
    UIButton *outBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [outBtn setFrame:CGRectMake(20, 10, kScreentWidth-40, kFooterViewHeight-20)];
    [outBtn setBackgroundColor:kPart_Button_Color];
    outBtn.layer.masksToBounds = YES;
    outBtn.layer.cornerRadius = 15;
    [outBtn addTarget:self action:@selector(outBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [outBtn setTitle:@"退出当前账号" forState:UIControlStateNormal];
    outBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [outBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_footerV addSubview:outBtn];
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 75, kScreentWidth, kScreenHeight-75) style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorColor = _backgroundViewColor;
    _tableV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_tableV];

}

#pragma mark - 退出当前账号
- (void)outBtnClicked:(UIButton *)btn
{
    NSLog(@"退出当前账号");
    
    /*
        删除当前用户的用户名 用户id
     */
    [OralDBFuncs removeCurrentUserNameAndUserID];
    
    LogInViewController *logInVC = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil];
    [self presentViewController:logInVC animated:YES completion:nil];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _settingArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"setting_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_settingArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = kText_Color;
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSize1];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _footerV;
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
