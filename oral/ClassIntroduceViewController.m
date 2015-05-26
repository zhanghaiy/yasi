//
//  ClassIntroduceViewController.m
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassIntroduceViewController.h"

@interface ClassIntroduceViewController ()

@end

@implementation ClassIntroduceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"雅思一班"];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    [self uiConfig];
}

- (void)uiConfig
{
    // 班级图片
    _classImgV.layer.masksToBounds = YES;
    _classImgV.layer.cornerRadius = 5;
    _classImgV.layer.borderColor = [UIColor whiteColor].CGColor;
    _classImgV.layer.borderWidth = 2;
    
    // 加入按钮
    _joinButton.layer.masksToBounds = YES;
    _joinButton.layer.cornerRadius = _joinButton.frame.size.height/2;
    _joinButton.backgroundColor = [UIColor colorWithRed:249/255.0 green:247/255.0 blue:242/255.0 alpha:1];
    [_joinButton setTitleColor:_backColor forState:UIControlStateNormal];
    
    // 老师头像
    _classTeacherView.backgroundColor = [UIColor whiteColor];
    
    _teaHeadImageButton.layer.masksToBounds = YES;
    _teaHeadImageButton.layer.cornerRadius = _teaHeadImageButton.bounds.size.height/2;
    _teaHeadImageButton.layer.borderWidth = 1;
    _teaHeadImageButton.layer.borderColor = _backColor.CGColor;
    
    // 文字颜色
    _classTitleLabel.textColor = _backColor;
    _teacherNameLabel.textColor = _backColor;

    _classDesLabel.textColor = _textColor;
    _teacherDesLabel.textColor = _textColor;
    _teaDetailLabel.textColor = _textColor;
    
    _classInfoView.backgroundColor = [UIColor whiteColor];
    
    
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

- (IBAction)joinButtonClicked:(id)sender {
}
@end
