//
//  ClassDetailViewController.m
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassDetailViewController.h"
#import "ClassDetailCell.h"
#import "TeacherPersonCenterViewController.h"

@interface ClassDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_stu_Progress_TableView;
    NSArray *_stu_Progress_Array;
}
@end

@implementation ClassDetailViewController
#define kNoticeViewHeight 110
#define kTeacherViewHeight 80

- (void)uiConfig
{
    _noticeDesLabel.textColor = _textColor;
    _noticeLable.textColor = _textColor;
    _teaCateLabel.textColor = _textColor;
    _teaCateLabel.textColor = _textColor;
    _teaDesLabel.textColor = _textColor;
    _classNameLabel.textColor = _textColor;
    
    _teaHeadImageBtn.layer.masksToBounds = YES;
    _teaHeadImageBtn.layer.cornerRadius = _teaHeadImageBtn.frame.size.height/2;
    _teaHeadImageBtn.layer.borderColor = [UIColor colorWithWhite:235/255.0 alpha:1].CGColor;
    _teaHeadImageBtn.layer.borderWidth = 1;
    
}

#pragma mark - 退出班级
- (void)outClass
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"雅思一班"];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-40, (self.navTopView.frame.size.height-24-20)/2+24, 20, 20)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"class_rigthButton"] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize1];
    
    [rightButton addTarget:self action:@selector(outClass) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navTopView addSubview:rightButton];
    
    self.view.backgroundColor = _backgroundViewColor;
    [self uiConfig];
    
    _stu_Progress_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+kNoticeViewHeight+kTeacherViewHeight+4, kScreentWidth, kScreenHeight-KNavTopViewHeight-kNoticeViewHeight-kTeacherViewHeight-4) style:UITableViewStylePlain];
    _stu_Progress_TableView.delegate = self;
    _stu_Progress_TableView.dataSource = self;
    _stu_Progress_TableView.backgroundColor = _backgroundViewColor;
    _stu_Progress_TableView.separatorColor = [UIColor colorWithWhite:240/255.0 alpha:1];
    [self.view addSubview:_stu_Progress_TableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;//_stu_Progress_Array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"class_cell";
    ClassDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ClassDetailCell" owner:self options:0] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

- (IBAction)enter_tea_person_center:(id)sender
{
    TeacherPersonCenterViewController *teaPersonCenterVC = [[TeacherPersonCenterViewController alloc]initWithNibName:@"TeacherPersonCenterViewController" bundle:nil];
    [self.navigationController pushViewController:teaPersonCenterVC animated:YES];
}

- (IBAction)openNotice:(id)sender
{
    CGRect rect = _classBackView.frame;
    rect.size.height = 25;
    rect.size.width = kScreentWidth;
    
    CGRect rect2 = _teaBackView.frame;
    rect2.origin.y -= 94;
    rect2.size.width = kScreentWidth;
    
    CGRect rect3 = _stu_Progress_TableView.frame;
    rect3.origin.y -= 94;
    rect3.size.width = kScreentWidth;
    rect3.size.height = kScreenHeight-rect3.origin.y;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        _classBackView.frame = rect;
        _teaBackView.frame = rect2;
        _stu_Progress_TableView.frame = rect3;
        _noticeOpenButton.hidden = YES;
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(moveNotOpen) userInfo:nil repeats:NO];
}
- (IBAction)upOpenButtonClicked:(id)sender
{
    CGRect rect = _classBackView.frame;
    rect.size.height = 110;
    rect.size.width = kScreentWidth;
    
    CGRect rect2 = _teaBackView.frame;
    rect2.origin.y += 94;
    rect2.size.width = kScreentWidth;
    
    CGRect rect3 = _stu_Progress_TableView.frame;
    rect3.origin.y += 94;
    rect3.size.width = kScreentWidth;
    rect3.size.height = kScreenHeight-rect3.origin.y;
    
    [UIView animateWithDuration:0.5 animations:^{
        _classBackView.frame = rect;
        _teaBackView.frame = rect2;
        _stu_Progress_TableView.frame = rect3;
        _upOpenButton.hidden = YES;
    }];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(moveOpenButton) userInfo:nil repeats:NO];

}

- (void)moveNotOpen
{
    _upOpenButton.hidden = NO;
}

- (void)moveOpenButton
{
    _noticeOpenButton.hidden = NO;
}
@end
