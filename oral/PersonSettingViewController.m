//
//  PersonSettingViewController.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonSettingViewController.h"
#import "MyTeacherViewController.h"
#import "DeviceManager.h"

#import "AboutMeViewController.h"
#import "MyAccountViewController.h"
#import "SystemSettingViewController.h"
#import "NSURLConnectionRequest.h"

@interface PersonSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_settingTableV;
    NSArray *_textArray;
    NSArray *_imageArray;
}
@end

@implementation PersonSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"设置"];
    self.view.backgroundColor = _backgroundViewColor;
    _textArray = @[@"我的账号",@"账户充值",@"网络设置",@"版本更新",@"关于我们",@"默认老师"];
    _imageArray = @[@"",@"Recharge",@"netSetting",@"VersionUpdate",@"AboutMe",@"defaultTeacher"];
    
    _settingTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+10, kScreentWidth, kScreenHeight-KNavTopViewHeight-10) style:UITableViewStylePlain];
    _settingTableV.delegate = self;
    _settingTableV.dataSource = self;
    _settingTableV.separatorColor = _backgroundViewColor;
    _settingTableV.backgroundColor = _backgroundViewColor;
    if ([_settingTableV respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_settingTableV setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_settingTableV respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_settingTableV setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:_settingTableV];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"settingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSize1];
    cell.textLabel.textColor = kText_Color;
    [cell.imageView setImage:[UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]]];
    cell.textLabel.text = [_textArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    switch (indexPath.row)
    {
        case 0:
        {
            // 我的账户
            MyAccountViewController *myAccountVC = [[MyAccountViewController alloc]init];
            [self.navigationController pushViewController:myAccountVC animated:YES];
        }
            break;
        case 1:
        {
            // 账户充值
        }
            break;
        case 2:
        {
            // 网络设置
            SystemSettingViewController *systemSetVC = [[SystemSettingViewController alloc]init];
            [self.navigationController pushViewController:systemSetVC animated:YES];
        }
            break;
        case 3:
        {
            // 版本更新
//            [self systemUpdate];
        }
            break;
        case 4:
        {
            // 关于我们
            AboutMeViewController *aboutMeVC = [[AboutMeViewController alloc]initWithNibName:@"AboutMeViewController" bundle:nil];
            [self.navigationController pushViewController:aboutMeVC animated:YES];
        }
            break;
        case 5:
        {
            // 默认老师
            MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]init];
            [self.navigationController pushViewController:myTeacherVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 版本更新
- (void)systemUpdate
{
    /*
     1 根据 app 的 id 来查找：http://itunes.apple.com/lookup?id=你的应用程序的ID  你的应用程序的ID 是 itunes connect里的 Apple ID
     获取最新的版本信息 然后 和当前版本信息对比 若不一样 跳转界面 AppStore
     */
    NSString *appleId = @"";
    NSString *urlStr = @"http://itunes.apple.com/lookup";
    NSString *params = [NSString stringWithFormat:@"id=%@",appleId];
    NSLog(@"版本更新 获取版本信息：%@",params);
    [NSURLConnectionRequest requestPOSTUrlString:urlStr andParamStr:params target:self action:@selector(requestVersionFinished:) andRefresh:YES];
}

- (void)requestVersionFinished:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSLog(@"%@",dic);
    }
    else
    {
        NSLog(@"失败");
    }
}

- (void)didReceiveMemoryWarning
{
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
