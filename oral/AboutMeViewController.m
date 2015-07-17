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
    [self addTitleLabelWithTitle:@"关于我们"];
    
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    self.view.backgroundColor = _backgroundViewColor;
    
    _lineLabel.backgroundColor = _backgroundViewColor;
    _appNameLabel.textColor = kText_Color;
    
    
    
    // 介绍 label
    NSString *text = @"  \"开口说\"是提供给广大雅思学子们练习和检验雅思口语能力的一款应用。内含口语不同主题练习、进阶功能，并且提供学生与教师针对口语方面的互动平台\n  ";
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-40 Height:99999 FontSize:kFontSize_14];
    NSInteger heig = rect.size.height + 20;
    
    UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 250, kScreentWidth-40, heig)];
    desLabel.text = text;
    desLabel.textAlignment = NSTextAlignmentLeft;
    desLabel.numberOfLines = 0;
    desLabel.textColor = kText_Color;
    desLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    [self.view addSubview:desLabel];
    
    [self.view sendSubviewToBack:_backImgV];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
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
