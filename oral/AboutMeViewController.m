//
//  AboutMeViewController.m
//  oral
//
//  Created by cocim01 on 15/6/29.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "AboutMeViewController.h"
#import "NSString+CalculateStringSize.h"


@interface AboutMeViewController ()

@end

@implementation AboutMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"关于我们"];
    
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    self.view.backgroundColor = _backgroundViewColor;
    
    _lineLabel.backgroundColor = _backgroundViewColor;
    _appNameLabel.textColor = kText_Color;
    
    
    
    // 介绍 label
    NSString *text = @"  截至2014年，雅思考试已获得全球135个国家逾9000所教育机构、雇主单位、专业协会和政府部门的认可；雅思考试作为全球留学及移民类英语测评的领导者，每年有超过200万人次的考生参加雅思考试。雅思考试（IELTS），外文名International English Language Testing System，由剑桥大学考试委员会外语考试部、英国文化协会及IDP教育集团共同管理，是一种针英语能力，为打算到使用英语的国家学习、工作或定居的人们设置的英语水平考试。\n  ";
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-40 Height:99999 FontSize:kFontSize1];
    NSInteger heig = rect.size.height + 20;
    
    UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 250, kScreentWidth-40, heig)];
    desLabel.text = text;
    desLabel.textAlignment = NSTextAlignmentLeft;
    desLabel.numberOfLines = 0;
    desLabel.textColor = kText_Color;
    desLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [self.view addSubview:desLabel];
    
    [self.view sendSubviewToBack:_backImgV];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

//- (void)uiconfig
//{
//    NSInteger logo_Y = 90;
//    NSInteger logo_H = 100;
//    _logoIngV.frame = CGRectMake((kScreentWidth-logo_H)/2, logo_Y, logo_H, logo_H);
//    
//    [_lineLabel setFrame:CGRectMake(30, logo_H+logo_Y+10, kScreentWidth-60, 1)];
//    _lineLabel.backgroundColor = _backgroundViewColor;
//    
//    NSInteger appName_Y = _lineLabel.frame.origin.y+_lineLabel.frame.size.height + 10;
//    [_appNameLabel setFrame:CGRectMake(20, appName_Y, kScreentWidth-40, 20)];
//    _appNameLabel.textAlignment = NSTextAlignmentCenter;
//    _appNameLabel.textColor = kText_Color;
//    
//    
//    NSString *text = @"  截至2014年，雅思考试已获得全球135个国家逾9000所教育机构、雇主单位、专业协会和政府部门的认可；雅思考试作为全球留学及移民类英语测评的领导者，每年有超过200万人次的考生参加雅思考试。雅思考试（IELTS），外文名International English Language Testing System，由剑桥大学考试委员会外语考试部、英国文化协会及IDP教育集团共同管理，是一种针英语能力，为打算到使用英语的国家学习、工作或定居的人们设置的英语水平考试。";
//    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-40 Height:99999 FontSize:kFontSize1];
//    NSInteger heig = rect.size.height + 20;
//    [_introduceLabel setFrame:CGRectMake(20, appName_Y+30, kScreentWidth-40, heig)];
//    _introduceLabel.text = text;
//    
//    [_backImgV setFrame:CGRectMake(10, 75, kScreentWidth-20, kScreenHeight-85)];
//}

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
