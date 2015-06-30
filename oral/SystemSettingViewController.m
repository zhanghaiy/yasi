//
//  SystemSettingViewController.m
//  oral
//
//  Created by cocim01 on 15/6/30.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "SystemSettingViewController.h"

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
    
    _systemArray = @[@"消息提示开关",@"WiFi环境下载",@"清除缓存"];
    
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
        swt.on = YES;
        [swt addTarget:self action:@selector(switchMethod:) forControlEvents:UIControlEventValueChanged];
        
        swt.onTintColor = kPart_Button_Color;
        swt.tintColor = _backgroundViewColor;
        swt.tag = indexPath.row + kSwithBaseTag;
        [cell addSubview:swt];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = kPart_Button_Color;
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSize1];
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
        // 消息提示开关
        if(swith.on==YES)
        {
            
        }
        else
        {
            
        }
    }
    else if (swith.tag == kSwithBaseTag+1)
    {
       // WiFi环境下下载
        if(swith.on==YES)
        {
            
        }
        else
        {
            
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
