//
//  CheckSuccessViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckSuccessViewController.h"
#import "TPCCheckpointViewController.h"
#import "CheckKeyWordViewController.h"
#import "CheckAskViewController.h"
#import "SuccessCell.h"


@interface CheckSuccessViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIColor *_oraColor;
    UIColor *_blueColor;
    
}

@end

@implementation CheckSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 分数显示top区域有两种颜色 1：黄色 2： 蓝色
    _oraColor = [UIColor colorWithRed:242/255.0 green:222/255.0 blue:44/255.0 alpha:1];
    _blueColor = [UIColor blueColor];// 暂时 后续补上
    self.lineLab.hidden = YES;
    self.navTopView.hidden = YES;
    [self uiConfig];
}

- (void)uiConfig
{
    _topBackView.backgroundColor = _oraColor;
    _middleBackView.backgroundColor = [UIColor whiteColor];
    _bottomBackView.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _topScoreLabel.backgroundColor = [UIColor clearColor];
    
    
    _topShareButton.backgroundColor = [UIColor whiteColor];
    [_topShareButton setTitleColor:_oraColor forState:UIControlStateNormal];
    _topShareButton.layer.masksToBounds = YES;
    _topShareButton.layer.cornerRadius = _topShareButton.frame.size.height/2;
    
    _backButton.backgroundColor = _backColor;
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = _backButton.frame.size.height/2;
    
    _continueButton.backgroundColor = _backColor;
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueButton.layer.masksToBounds = YES;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2;
    
    _midTitleLabel.textColor = _backColor;
    _midTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    _topScoreLabel.textColor = [UIColor whiteColor];
    _topDesLabel.textColor = [UIColor whiteColor];
    
    _midTableView.delegate = self;
    _midTableView.dataSource = self;
    _midTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celId = @"cell";
    SuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if ( cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SuccessCell" owner:self options:0] lastObject];
    }
    
    cell.desLabel.text = @"Good grades~Continue to work hard，Continue to work hard，Continue to work hard";
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


- (IBAction)backToLastPage:(id)sender
{
    for (UIViewController *viewControllers in self.navigationController.viewControllers)
    {
        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
        {
            [self.navigationController popToViewController:viewControllers animated:YES];
            break;
        }
    }
}
- (IBAction)continueNextPoint:(id)sender
{
    CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
    keyVC.pointCounts = _pointCount+1;
    keyVC.topicName = self.topicName;
    keyVC.currentPartCounts = self.currentPartCounts;
    [self.navigationController pushViewController:keyVC animated:YES];
}
@end
