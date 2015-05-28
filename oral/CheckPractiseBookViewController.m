//
//  CheckPractiseBookViewController.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckPractiseBookViewController.h"
#import "PractiseCell.h"

@interface CheckPractiseBookViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_practiseTableV;
}
@end

@implementation CheckPractiseBookViewController
#define kCellHeight 150


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"练习簿"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    
    _practiseTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 45, kScreentWidth, kScreenHeight-45) style:UITableViewStylePlain];
    _practiseTableV.delegate = self;
    _practiseTableV.dataSource = self;
    _practiseTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_practiseTableV];
    
    _practiseTableV.backgroundColor = _backgroundViewColor;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    PractiseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PractiseCell" owner:self options:0] lastObject];
    }
    
    return cell;
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
