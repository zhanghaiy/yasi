//
//  TPCPersonCenterViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TPCPersonCenterViewController.h"
#import "PersonClassViewController.h"


@interface TPCPersonCenterViewController ()

@end

@implementation TPCPersonCenterViewController
#define kEnterClassButtonTag 111
#define kEnterProgressButtonTag 112



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"我的后院"];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-45, (self.navTopView.frame.size.height-24-20)/2+24, 20, 20)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"person_setting"] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [self.navTopView addSubview:rightButton];
    self.navTopView.backgroundColor = _backgroundViewColor;
    [self uiConfig];
}

- (void)uiConfig
{
    // 用户头像圆形
    _personHeadButton.layer.masksToBounds = YES;
    _personHeadButton.layer.cornerRadius = _personHeadButton.bounds.size.height/2;
    _personHeadButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _personHeadButton.layer.borderWidth =2;
    
    // 性别 星座背景色 后续修改 暂时用此颜色
    _sexButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    _ConstellationButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    _sexButton.layer.cornerRadius= _sexButton.bounds.size.height/2;
    _ConstellationButton.layer.cornerRadius= _ConstellationButton.bounds.size.height/2;
    
    _enterClassButton.tag = kEnterClassButtonTag;
    _pointProgressButton.tag = kEnterProgressButtonTag;
    
    [_enterClassButton setTitleColor:_textColor forState:UIControlStateNormal];
    [_pointProgressButton setTitleColor:_textColor forState:UIControlStateNormal];
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
- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enterButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == kEnterProgressButtonTag)
    {
        // 闯关进度
    }
    else if (btn.tag == kEnterClassButtonTag)
    {
        // 我的班级
        PersonClassViewController *classVc = [[PersonClassViewController alloc]initWithNibName:@"PersonClassViewController" bundle:nil];
        [self.navigationController pushViewController:classVc animated:YES];
    }
}

- (IBAction)editButtonClicked:(id)sender
{
    // 编辑个人信息
}
@end
