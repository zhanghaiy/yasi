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
#import "NSURLConnectionRequest.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface ClassDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    UITableView *_stu_Progress_TableView;
    NSArray *_stu_Progress_Array;
    NSDictionary *_teaInfoDict;
}
@end

@implementation ClassDetailViewController
#define kNoticeViewHeight 110
#define kTeacherViewHeight 80
#define kOutClassAlertViewTag 120



#pragma mark - 配置UI
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

#pragma mark - 警告框delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kOutClassAlertViewTag)
    {
        //
    }
}

#pragma mark - 退出班级
- (void)outClass
{
    // 退出本班
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"退出本班" otherButtonTitles:@"取消",nil];
    sheet.delegate = self;
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
         //退出本班
        [self outClassRequest];
    }
}

#pragma mark - 退出班级
- (void)outClassRequest
{
    // userId  classId
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?userId=%@&classId=%@",kBaseIPUrl,kStuOutClassUrlString,userId,_classId];
    NSLog(@"退出班级url%@",urlString);
    [NSURLConnectionRequest requestWithUrlString:urlString target:self aciton:@selector(outClassFinished:) andRefresh:YES];
}

#pragma mark - 退出班级反馈
- (void)outClassFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:[dict objectForKey:@"remark"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertV.tag = kOutClassAlertViewTag;
            [alertV show];
        }
        else
        {
            // 退出班级失败
        }
    }
    else
    {
        // 失败
    }
    
}


#pragma mark - 请求班级详情信息
- (void)requestClassInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@?classId=%@&teacherId=%@",kBaseIPUrl,kSelectClassMemoUrl,_classId,_teacherId];
    NSLog(@"%@",url);
    [NSURLConnectionRequest requestWithUrlString:url target:self aciton:@selector(requestFinished:) andRefresh:YES];
}

#pragma mark - 请求班级详情信息反馈
- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length]>0)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSLog(@"%@",dic);
        _stu_Progress_Array = [dic objectForKey:@"studentlist"];
        [_stu_Progress_TableView reloadData];
        
        _teaInfoDict = [[dic objectForKey:@"teacherlist"] lastObject];
        
        [_teaHeadImageBtn setImageWithURL:[NSURL URLWithString:[_teaInfoDict objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"class_teacher_head"]];
        _teaDesLabel.text = [[[_teaInfoDict objectForKey:@"teacherinfo"] lastObject] objectForKey:@"content"];
        _classNameLabel.text = [_teaInfoDict objectForKey:@"teachername"];
    }
}

#pragma mark - 请求班级公告
- (void)requestClassNotice
{
    NSString *classNoticeUrl = [NSString stringWithFormat:@"%@%@?classId=%@",kBaseIPUrl,kSelectClassNewNoticeUrl,_classId];
    NSLog(@"请求班级公告: %@~~~",classNoticeUrl);
    [NSURLConnectionRequest requestWithUrlString:classNoticeUrl target:self aciton:@selector(requestClassNoticeFinished:) andRefresh:YES];
}

- (void)requestClassNoticeFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            // 请求成功
            if ([[dict objectForKey:@"noticelist"] count])
            {
                // 有公告
                NSDictionary *newNoticeDic = [[dict objectForKey:@"noticelist"] lastObject];
                if ([[newNoticeDic objectForKey:@"content"] length])
                {
                    _noticeDesLabel.text = [newNoticeDic objectForKey:@"content"];
                }
                else
                {
                    _noticeDesLabel.text = @"暂无公告";
                }
            }
            else
            {
                // 暂无公告
                NSLog(@"暂无公告");
                _noticeDesLabel.text = @"暂无公告";
            }
        }
        else
        {
            NSString *remark = [dict objectForKey:@"remark"];
            NSLog(@"%@",remark);
        }
    }
}


#pragma mark - 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"雅思一班"];
    
    if (_teacherId==nil)
    {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(kScreentWidth-40, (self.navTopView.frame.size.height-24-20)/2+24, 20, 20)];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"class_rigthButton"] forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
        
        [rightButton addTarget:self action:@selector(outClass) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navTopView addSubview:rightButton];
    }
    
    
    self.view.backgroundColor = _backgroundViewColor;
    [self uiConfig];
    
    _stu_Progress_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+kNoticeViewHeight+kTeacherViewHeight+4, kScreentWidth, kScreenHeight-KNavTopViewHeight-kNoticeViewHeight-kTeacherViewHeight-4) style:UITableViewStylePlain];
    _stu_Progress_TableView.delegate = self;
    _stu_Progress_TableView.dataSource = self;
    _stu_Progress_TableView.backgroundColor = _backgroundViewColor;
    _stu_Progress_TableView.separatorColor = [UIColor colorWithWhite:240/255.0 alpha:1];
    [self.view addSubview:_stu_Progress_TableView];
    
    [self requestClassInfo];
    [self requestClassNotice];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stu_Progress_Array.count;
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
    
    NSDictionary *dict = [_stu_Progress_Array objectAtIndex:indexPath.row];
    [cell.stuHeadImageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"person_head_image"]];
    cell.stuNameLabel.text = [dict objectForKey:@"studentname"];
    cell.stuPassCountLabel.text = [NSString stringWithFormat:@"%d/%d",[[dict objectForKey:@"countpassclasstype"] intValue],[[dict objectForKey:@"countclasstype"] intValue]];
    float progress = [[dict objectForKey:@"countpassclasstype"] floatValue]/[[dict objectForKey:@"countclasstype"] floatValue];
    NSLog(@"%f",progress);
    cell.stuPassProgressView.progress = progress;
    cell.stuPassProgressView.color = kPart_Button_Color;

    
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

#pragma mark - 进入老师个人中心
- (IBAction)enter_tea_person_center:(id)sender
{
    TeacherPersonCenterViewController *teaPersonCenterVC = [[TeacherPersonCenterViewController alloc]initWithNibName:@"TeacherPersonCenterViewController" bundle:nil];
    teaPersonCenterVC.teacherDic = _teaInfoDict;
    teaPersonCenterVC.teacherId = _teacherId;
    [self.navigationController pushViewController:teaPersonCenterVC animated:YES];
}

#pragma mark - 展开公告信息
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

#pragma mark - 折叠公告
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
