//
//  ClassIntroduceViewController.m
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassIntroduceViewController.h"
#import "NSString+CalculateStringSize.h"
#import "TeacherPersonCenterViewController.h"

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
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightButton setFrame:CGRectMake(kScreentWidth-40, (self.navTopView.frame.size.height-24-20)/2+24, 20, 20)];
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"class_rigthButton"] forState:UIControlStateNormal];
//    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
//    
//    [rightButton addTarget:self action:@selector(outClass) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.navTopView addSubview:rightButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    [self uiConfig];
}

#pragma mark - 退出班级
- (void)outClass
{
  
}


- (void)uiConfig
{
    // 班级图片
    _classImgV.layer.masksToBounds = YES;
    _classImgV.layer.cornerRadius = 5;
    _classImgV.layer.borderColor = [UIColor whiteColor].CGColor;
    _classImgV.layer.borderWidth = 2;
    
    // 加入按钮
    [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _joinButton.titleLabel.font = [UIFont fontWithName:@"STHeitiJ-Medium" size:kFontSize2];
    
    // 老师头像
    _classTeacherView.backgroundColor = [UIColor whiteColor];
    
    _teaHeadImageButton.layer.masksToBounds = YES;
    _teaHeadImageButton.layer.cornerRadius = _teaHeadImageButton.bounds.size.height/2;
    _teaHeadImageButton.layer.borderWidth = 1;
    _teaHeadImageButton.layer.borderColor = [UIColor colorWithRed:225/255.0 green:235/255.0 blue:235/255.0 alpha:1].CGColor;
    
    // 文字颜色
    _classTitleLabel.textColor = _textColor;
    _teacherNameLabel.textColor = _backColor;

    _classDesLabel.textColor = _textColor;
    _teacherDesLabel.textColor = _textColor;
    _teaDetailLabel.textColor = _textColor;
    _classInfoView.backgroundColor = [UIColor whiteColor];
    
    
}
#pragma mark - 根据文字确定frame
- (void)getClassDesRect
{
    NSString *text = @"雅思一班是由王老师一手创办的，主要是将大体的一些技巧或者如何很好地学习，通过考试,雅思一班是由王老师一手创办的，主要是将大体的一些技巧或者如何很好地学习，通过考试";
    _classDesLabel.text = text;
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-30 Height:9999 FontSize:kFontSize2];
    if (rect.size.height>40)
    {
        CGRect desRect = _classDesLabel.frame;
        desRect.size.width = kScreentWidth-30;
        desRect.size.height = rect.size.height;
        _classDesLabel.frame = desRect;
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

- (IBAction)joinButtonClicked:(id)sender
{
    
}

- (IBAction)enter_Teacher_person_center:(id)sender
{
    //
    TeacherPersonCenterViewController *teaPersonCenterVC = [[TeacherPersonCenterViewController alloc]initWithNibName:@"TeacherPersonCenterViewController" bundle:nil];
    [self.navigationController pushViewController:teaPersonCenterVC animated:YES];
}
@end
