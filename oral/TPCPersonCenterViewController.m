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
    [rightButton setFrame:CGRectMake(kScreentWidth-50, 7, 30, 30)];
    rightButton.backgroundColor = [UIColor purpleColor];
    [rightButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [self.navTopView addSubview:rightButton];
    [self uiConfig];
}

- (void)uiConfig
{
    _personInfoBackView.backgroundColor = [UIColor colorWithRed:83/255.0 green:157/255.0 blue:170/255.0 alpha:1];
    _personBackImgV.image = [UIImage imageNamed:@""];
    
    // 用户头像圆形
    _personHeadButton.layer.masksToBounds = YES;
    _personHeadButton.layer.cornerRadius = _personHeadButton.bounds.size.height/2;
    _personHeadButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _personHeadButton.layer.borderWidth =2;
    
    
    // 性别 星座背景色 后续修改 暂时用此颜色
    _sexButton.backgroundColor = [UIColor colorWithRed:131/255.0 green:177/255.0 blue:181/255.0 alpha:1];
    _ConstellationButton.backgroundColor = [UIColor colorWithRed:131/255.0 green:177/255.0 blue:181/255.0 alpha:1];
    _sexButton.layer.cornerRadius= _sexButton.bounds.size.height/2;
    _ConstellationButton.layer.cornerRadius= _ConstellationButton.bounds.size.height/2;
    
    _myClassLabel.textColor = _textColor;
    _progressTitleLabel.textColor = _textColor;
    
    _enterClassButton.tag = kEnterClassButtonTag;
    _enterProgressButton.tag = kEnterProgressButtonTag;
    
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
@end
