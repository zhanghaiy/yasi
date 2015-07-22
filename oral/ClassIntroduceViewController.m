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
#import "NSURLConnectionRequest.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "ApplyClassViewController.h"


@interface ClassIntroduceViewController ()
{
    NSString *_teacherId;
    NSDictionary *_infoDict;
}
@end

@implementation ClassIntroduceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:@"雅思一班"];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    [self uiConfig];
    [self requestClassInfo];
}

#pragma mark - 网络请求
- (void)requestClassInfo
{
    //7B76B93F49034BED88F95C68333578F2
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?classId=%@",kBaseIPUrl,kSelectClassInfoUrl,_classId];
    NSLog(@"%@",urlStr);
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestFinished:) andRefresh:YES];
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length]>0)
    {
        NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[mainDict objectForKey:@"respCode"] integerValue] == 1000)
        {
            // 成功 展示信息
            _infoDict = [[mainDict objectForKey:@"classlist"] lastObject];
            [_classImgV setImageWithURL:[NSURL URLWithString:[_infoDict objectForKey:@"classiocn"]] placeholderImage:[UIImage imageNamed:@"class_more"]];
            _classCountsLabel.text = [NSString stringWithFormat:@"%d/%d",[[_infoDict objectForKey:@"nowNumber"] intValue],[[_infoDict objectForKey:@"maxnumber"] intValue]];
            _classCreateTimeLabel.text = [NSString stringWithFormat:@"创建时间：%@",[_infoDict objectForKey:@"createtime"]];
            _teacherNameLabel.text = [_infoDict objectForKey:@"teachername"];
            [_teaHeadImageButton setImageWithURL:[NSURL URLWithString:[_infoDict objectForKey:@"teacheriocn"]] placeholderImage:[UIImage imageNamed:@"personDefault"]];
            _teacherId = [_infoDict objectForKey:@"teacherid"];
            
            [self getClassDesRectWithText:[_infoDict objectForKey:@"memo"]];
        }
    }
}

#pragma mark - UI配置
- (void)uiConfig
{
    // 班级图片
    _classImgV.layer.masksToBounds = YES;
    _classImgV.layer.cornerRadius = 5;
    _classImgV.layer.borderColor = [UIColor whiteColor].CGColor;
    _classImgV.layer.borderWidth = 2;
    
    // 加入按钮
    [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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
    _teaDetailLabel.textColor = _textColor;
    _classInfoView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 根据文字确定frame
- (void)getClassDesRectWithText:(NSString *)text
{
//    NSString *text = @"雅思一班是由王老师一手创办的，主要是将大体的一些技巧或者如何很好地学习，通过考试,雅思一班是由王老师一手创办的，主要是将大体的一些技巧或者如何很好地学习，通过考试";
    _classDesLabel.text = text;
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-30 Height:9999 FontSize:kFontSize_12];
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

#pragma mark - 加入班级 or 退出班级
- (IBAction)joinButtonClicked:(id)sender
{
    // 加入班级 退出班级
    ApplyClassViewController *applyVC = [[ApplyClassViewController alloc]initWithNibName:@"ApplyClassViewController" bundle:nil];
    [self.navigationController pushViewController:applyVC animated:YES];
}

#pragma mark - 进入老师界面
- (IBAction)enter_Teacher_person_center:(id)sender
{
    //
    
    TeacherPersonCenterViewController *teaPersonCenterVC = [[TeacherPersonCenterViewController alloc]initWithNibName:@"TeacherPersonCenterViewController" bundle:nil];
    teaPersonCenterVC.teacherId = _teacherId;
    teaPersonCenterVC.teacherDic = _infoDict;
    [self.navigationController pushViewController:teaPersonCenterVC animated:YES];
}
@end
