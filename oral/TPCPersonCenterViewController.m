//
//  TPCPersonCenterViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TPCPersonCenterViewController.h"
#import "PersonClassViewController.h"
#import "PersonSettingViewController.h"
#import "PersonProgressViewController.h"
#import "PersonEditViewController.h"
#import "NSURLConnectionRequest.h"
#import "PersonInfoModel.h"
#import "UIButton+WebCache.h"


@interface TPCPersonCenterViewController ()
{
//    PersonInfoModel *_personModel;
    NSDictionary *_personInfoDic;
}
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
    [rightButton setFrame:CGRectMake(kScreentWidth-40, (self.navTopView.frame.size.height-24-20)/2+24, 20, 20)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"person_setting"] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    
    [rightButton addTarget:self action:@selector(personSetting) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navTopView addSubview:rightButton];
    self.navTopView.backgroundColor = _backgroundViewColor;
    [self uiConfig];
    
    [self requestPersonInfo];
}

- (void)personSetting
{
    PersonSettingViewController *personSetVC = [[PersonSettingViewController alloc]initWithNibName:@"PersonSettingViewController" bundle:nil];
    [self.navigationController pushViewController:personSetVC animated:YES];
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

#pragma mark - 网络请求
- (void)requestPersonInfo
{
    NSString *userid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?userId=%@",kBaseIPUrl,kUserInfoUrl,userid];
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestEnd:) andRefresh:YES];
}

- (void)requestEnd:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        _personInfoDic = [[dict objectForKey:@"studentInfos"] lastObject];
        [self blankPersonInfo];
    }
}


- (void)blankPersonInfo
{
    // 头像
    if ([[_personInfoDic objectForKey:@"icon"] length]>0)
    {
        NSString *iconUrl = [_personInfoDic objectForKey:@"icon"];
        [_personHeadButton setImageWithURL:[NSURL URLWithString:iconUrl]];
    }
    else
    {
        
    }
    
    if ([[_personInfoDic objectForKey:@"birthday"] length]>0)
    {
        // 生日
        NSString *birthday = [_personInfoDic objectForKey:@"birthday"];
        _birthLabel.text = birthday;
    }
    else
    {
        
    }
    
    if ([[_personInfoDic objectForKey:@"hobbies"] length]>0)
    {
        // 爱好
        NSString *hobbies = [_personInfoDic objectForKey:@"hobbies"];
        _loveLabel.text = hobbies;
    }
    else
    {
        
    }

    
    if ([[_personInfoDic objectForKey:@"constellation"] length]>0)
    {
        // 星座
        NSString *constellation = [_personInfoDic objectForKey:@"constellation"];
        [_ConstellationButton setTitle:constellation forState:UIControlStateNormal];
    }
    else
    {
        
    }
    
    if ([[_personInfoDic objectForKey:@"sex"] length]>0)
    {
        // 性别
        NSString *sex = [_personInfoDic objectForKey:@"sex"];
        [_sexButton setTitle:sex forState:UIControlStateNormal];
    }
    else
    {
        
    }
    
    if ([[_personInfoDic objectForKey:@"nickname"] length]>0)
    {
        // 昵称
        NSString *nickname = [_personInfoDic objectForKey:@"nickname"];
        _nameLabel.text = nickname;
    }
    else
    {
        
    }
    
    if ([[_personInfoDic objectForKey:@"signiture"] length]>0)
    {
        // 个性签名
        NSString *signiture = [_personInfoDic objectForKey:@"signiture"];\
        _signatureLabel.text = signiture;
    }
    else
    {
        
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
        PersonProgressViewController *progressVC = [[PersonProgressViewController alloc]initWithNibName:@"PersonProgressViewController" bundle:nil];
        [self.navigationController pushViewController:progressVC animated:YES];
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
    PersonEditViewController *editVC = [[PersonEditViewController alloc]initWithNibName:@"PersonEditViewController" bundle:nil];
    [self.navigationController pushViewController:editVC animated:YES];
}
@end
