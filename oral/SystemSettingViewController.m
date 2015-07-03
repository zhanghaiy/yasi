//
//  SystemSettingViewController.m
//  oral
//
//  Created by cocim01 on 15/6/30.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "OralDBFuncs.h"



@interface SystemSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableV;
    NSArray *_systemArray;
}
@end

#define kSwithBaseTag 44


@implementation SystemSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"网络设置"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    _systemArray = @[@"2g/3g/4g网络下下载",@"WiFi网络下下载",@"清除缓存"];
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 75, kScreentWidth, kScreenHeight-75) style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.separatorColor = _backgroundViewColor;
    _tableV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_tableV];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _systemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"system_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    if (indexPath.row<_systemArray.count-1)
    {
        UISwitch *swt = [[UISwitch alloc]initWithFrame:CGRectMake(kScreentWidth-80, 7, 50, 25)];
        if (indexPath.row == 0)
        {
            // 2g3g4g
            swt.on = [OralDBFuncs getNet_2g3g4g_Download];
        }
        else
        {
            // wifi
            swt.on = [OralDBFuncs getNet_WiFi_Download];
        }
        [swt addTarget:self action:@selector(switchMethod:) forControlEvents:UIControlEventValueChanged];
        
        swt.onTintColor = kPart_Button_Color;
        swt.tintColor = _backgroundViewColor;
        swt.tag = indexPath.row + kSwithBaseTag;
        [cell addSubview:swt];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = kPart_Button_Color;
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = [_systemArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _systemArray.count-1)
    {
        // 清除缓存
        
    }
}

- (void)switchMethod:(UISwitch *)swith
{
    //    开关状态
    if (swith.tag == kSwithBaseTag)
    {
        // 2g/3g/4g网络下下载
        if(swith.on==YES)
        {
            [OralDBFuncs setNet_2g3g4g_Download:YES];
        }
        else
        {
            [OralDBFuncs setNet_2g3g4g_Download:NO];
        }
    }
    else if (swith.tag == kSwithBaseTag+1)
    {
       // WiFi网络下下载
        if(swith.on==YES)
        {
            [OralDBFuncs setNet_WiFi_Download:YES];
        }
        else
        {
            [OralDBFuncs setNet_WiFi_Download:NO];
        }
    }
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
