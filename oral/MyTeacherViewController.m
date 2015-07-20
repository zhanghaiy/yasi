//
//  MyTeacherViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "MyTeacherViewController.h"
#import "FooterView.h"
#import "MyTeacherCell.h"
#import "NSURLConnectionRequest.h"
#import "OralDBFuncs.h"
#import "UIImageView+WebCache.h"

@interface MyTeacherViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_myTeaTableV;
    NSMutableArray *_teacherArray;
    FooterView *_footerView;
    NSString *_teacherId;
    BOOL _markDefault;
    BOOL _reloading;
    UIView *refreshV;
}
@end

@implementation MyTeacherViewController
#define kTeaTableViewCellHeight 76
#define kFooterViewHeight 60
#define kSelectedButonTag 99

#define kDownRefreshViewHeght 100
#define kDownRefreshViewTag 11
#define kLoadingImgViewHeight 50
#define kLoadingViewTag 22
#define kLoadingLabelTag 23


#pragma mark - 网络
#pragma mark -- 开始请求老师列表
- (void)startRequest
{
    // 选择老师 userId teacherName change
    NSString *str = [NSString stringWithFormat:@"%@%@?userId=%@change=1",kBaseIPUrl,kChooseTeacherUrl,[OralDBFuncs getCurrentUserID]];
    [NSURLConnectionRequest requestWithUrlString:str target:self aciton:@selector(requestFinished:) andRefresh:YES];
}

#pragma mark -- 请求老师列表反馈
- (void)requestFinished:(NSURLConnectionRequest *)request
{
    
    if (_reloading)
    {
        _reloading = NO;
        [self endReloadingUIConfig];
    }
    else
    {
        _loading_View.hidden = YES;
    }
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([dict objectForKey:@"respCode"])
        {
            _teacherArray = [dict objectForKey:@"teacherinfolist"];
            [_myTeaTableV reloadData];
            _myTeaTableV.contentOffset = CGPointMake(0, 0);
        }
        else
        {
            NSString *remark = [dict objectForKey:@"remark"];
            [self showAlertWithMessage:remark];
        }
    }
    else
    {
        [self showAlertWithMessage:@"请求失败"];
    }
}

#pragma mark -- 根据内容创建警告框
- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

#pragma mark - 视图加载
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:@"我的老师"];
    
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(kScreentWidth-70, 24, 70, 44)];
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setTitleColor:_backColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    [rightButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:rightButton];
    
    _footerView = [[[NSBundle mainBundle]loadNibNamed:@"FooterView" owner:self options:0] lastObject];
    _footerView.backgroundColor = [UIColor clearColor];
    [_footerView.selectedButton addTarget:self action:@selector(settingDefaultTeacher:) forControlEvents:UIControlEventTouchUpInside];
    _footerView.titleLabel.textColor = _backColor;

    _myTeaTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+2, kScreentWidth, kScreenHeight-50) style:UITableViewStylePlain];
    _myTeaTableV.delegate = self;
    _myTeaTableV.dataSource = self;
    _myTeaTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _myTeaTableV.tableFooterView = _footerView;
    [self.view addSubview:_myTeaTableV];
    _myTeaTableV.backgroundColor = [UIColor clearColor];
    
    _reloading = NO;
    _loading_View.hidden = YES;
    [self.view bringSubviewToFront:_loading_View];
    [self startRequest];
    
    [self addDownRefreshViewWithFrame:CGRectMake(0, -kDownRefreshViewHeght, kScreentWidth, kDownRefreshViewHeght)];
    [_myTeaTableV addSubview:refreshV];
}


#pragma mark - 完成按钮被点击
- (void)finishButtonClicked:(UIButton *)btn
{
    // 完成
    if (_markDefault)
    {
        // 存储默认老师
        [OralDBFuncs setDefaultTeacherID:_teacherId UserName:[OralDBFuncs getCurrentUserName]];
    }
    if (self.delegate)
    {
        [self.delegate selectTeacherId:_teacherId];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - delegate
#pragma mark -- 区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark -- 区高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_teacherArray.count == 0)
    {
        return 300;
    }
    return 0;
}

#pragma mark -- 区头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_teacherArray.count == 0)
    {
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 300)];
        lable.font = [UIFont systemFontOfSize:kFontSize_14];
        lable.text = @"暂无数据";
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = kPart_Button_Color;
        return lable;
    }
    return nil;
}

#pragma mark --  row 行个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _teacherArray.count;
}

#pragma mark -- 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MyTeacherCell";
    MyTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MyTeacherCell" owner:self options:0] lastObject];
    }
    cell.teacherName.textColor = _backColor;
    
    NSDictionary *dic = [_teacherArray objectAtIndex:indexPath.row];
    
    cell.teacherDesLabel.text = [dic objectForKey:@"signiture"];
    cell.teacherName.text = [dic objectForKey:@"teachername"];
    [cell.teaHeadImgV setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"teachericon"]] placeholderImage:[UIImage imageNamed:@"select_Teacher"]];
    cell.selectButton.tag = kSelectedButonTag + indexPath.row;
    [cell.selectButton addTarget:self action:@selector(selectTeacxher:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


#pragma mark -- cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTeaTableViewCellHeight;
}

#pragma mark - 选择老师
- (void)selectTeacxher:(UIButton *)btn
{
    for (int i = 0; i < _teacherArray.count; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:i+kSelectedButonTag];
        if (newBtn.tag == btn.tag)
        {
            newBtn.selected = YES;
            _teacherId = [[_teacherArray objectAtIndex:i] objectForKey:@"teacherid"];
        }
        else
        {
            newBtn.selected = NO;
        }
    }
}


#pragma mark - 下拉刷新
#pragma mark -- 创建下拉刷新界面
- (void)addDownRefreshViewWithFrame:(CGRect)frame
{
    refreshV = [[UIView alloc]initWithFrame:frame];
    UIImageView *loadingImgV = [[UIImageView alloc]initWithFrame:CGRectMake((kScreentWidth-kLoadingImgViewHeight)/2, (kDownRefreshViewHeght-kLoadingImgViewHeight)/2, kLoadingImgViewHeight, kLoadingImgViewHeight)];
    loadingImgV.animationDuration = 2;
    loadingImgV.animationImages = @[[UIImage imageNamed:@"loading_1"],[UIImage imageNamed:@"loading_2"],[UIImage imageNamed:@"loading_3"],[UIImage imageNamed:@"loading_4"]];
    loadingImgV.animationRepeatCount = -1;
    loadingImgV.tag = kLoadingViewTag;
    [loadingImgV setImage:[UIImage imageNamed:@"loading_1"]];
    loadingImgV.hidden = YES;
    [refreshV addSubview:loadingImgV];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, kDownRefreshViewHeght-40, kScreentWidth, 20)];
    label.font = [UIFont systemFontOfSize:kFontSize_second];
    label.text = @"下拉换一批老师";
    label.textColor = kPart_Button_Color;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = kLoadingLabelTag;
    [refreshV addSubview:label];
}

#pragma mark -- 开启加载动画
- (void)startAnimation
{
    UIImageView *imgV = (UIImageView *)[self.view viewWithTag:kLoadingViewTag];
    imgV.hidden = NO;
    [imgV startAnimating];
    UILabel *lab = (UILabel *)[self.view viewWithTag:kLoadingLabelTag];
    lab.hidden = YES;
}

#pragma mark -- 下拉列表时
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_reloading)
    {
        if (scrollView.contentOffset.y<-kDownRefreshViewHeght)
        {
            NSLog(@"下拉列表");
            _reloading = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_reloading)
    {
        NSLog(@"开始刷新");
        [self configRefreshUI];
        [self startRequest];
    }
}

#pragma mark -- 开启刷新动画
- (void)configRefreshUI
{
    [refreshV removeFromSuperview];
    [self addDownRefreshViewWithFrame:CGRectMake(0, KNavTopViewHeight, kScreentWidth, kDownRefreshViewHeght)];
    [self.view addSubview:refreshV];
    _myTeaTableV.frame = CGRectMake(0, kDownRefreshViewHeght+KNavTopViewHeight, kScreentWidth, kScreenHeight-kDownRefreshViewHeght-KNavTopViewHeight);
    [self startAnimation];
}

- (void)endReloadingUIConfig
{
    _myTeaTableV.frame = CGRectMake(0, kDownRefreshViewHeght+KNavTopViewHeight, kScreentWidth, kScreenHeight-kDownRefreshViewHeght-KNavTopViewHeight);
    [refreshV removeFromSuperview];
    _myTeaTableV.frame = CGRectMake(0, KNavTopViewHeight+2, kScreentWidth, kScreenHeight-kDownRefreshViewHeght-KNavTopViewHeight);
    [self addDownRefreshViewWithFrame:CGRectMake(0, -kDownRefreshViewHeght, kScreentWidth, kDownRefreshViewHeght)];
    [_myTeaTableV addSubview:refreshV];
}

#pragma mark -- 换一批老师 网络请求
- (void)changeTeacher
{
    [self startRequest];
}


#pragma mark - 设置默认老师
- (void)settingDefaultTeacher:(UIButton *)btn
{
    if (btn.selected)
    {
        btn.selected = NO;
        _markDefault = NO;
    }
    else
    {
        btn.selected = YES;
        _markDefault = YES;
    }
}


#pragma mark - 返回上一页
- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
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
