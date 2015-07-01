//
//  TeacherPersonCenterViewController.m
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TeacherPersonCenterViewController.h"
#import "PersonClassViewController.h"
#import "NSURLConnectionRequest.h"
#import "TeacherCell.h"
#import "TeacherHeadView.h"
#import "UIImageView+WebCache.h"


@interface TeacherPersonCenterViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_pictureArray;
    NSArray *_infoListArray;
    NSTimer *_picShowTimer;
    NSInteger _currentImageIndex;
    
    UITableView *_tableV;
}
@end

@implementation TeacherPersonCenterViewController
#define kPageBtnBaseTag 200


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"某某老师"];
    
    self.navTopView.backgroundColor  = _backgroundViewColor;
    
    CGRect rec = _topScrollV.frame;
    rec.size.width = kScreentWidth;
    _topScrollV.frame = rec;
    
    _topScrollV.delegate = self;
    _topScrollV.pagingEnabled = YES;
    _topScrollV.backgroundColor = _backgroundViewColor;
    [self requestTeacherInfo];
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65+_topScrollV.frame.size.height+2, kScreentWidth, kScreenHeight-_topScrollV.frame.size.height-67) style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.backgroundColor = _backgroundViewColor;
    _tableV.separatorColor = _backgroundViewColor;
    [self.view addSubview:_tableV];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _infoListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TeacherCell";
    TeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"TeacherCell" owner:self options:0] lastObject];
    }
    NSDictionary *dict = [_infoListArray objectAtIndex:indexPath.row];
    cell.cateLabel.textColor = kText_Color;
    cell.desLabel.textColor = kText_Color;
    cell.cateLabel.text = [dict objectForKey:@"infotype"];
    cell.desLabel.text = [dict objectForKey:@"content"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TeacherHeadView *headV = [[[NSBundle mainBundle]loadNibNamed:@"TeacherHeadView" owner:self options:0] lastObject];
    [headV setFrame:CGRectMake(0, 0, kScreentWidth, 80)];
    headV.backgroundColor = [UIColor whiteColor];
    [headV.teaHeadImageV setImageWithURL:[NSURL URLWithString:[_teacherDic objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"class_teacher_head"]];
    headV.teaTitleLabel.text = [_teacherDic objectForKey:@"teachername"];
    headV.teaDesLabel.text = [[[_teacherDic objectForKey:@"teacherinfo"] lastObject] objectForKey:@"content"];
    
    return headV;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, kScreentWidth, 40)];
    [btn setBackgroundImage:[UIImage imageNamed:@"person_center_cellBack"] forState:UIControlStateNormal];
    [btn setTitleColor:kText_Color forState:UIControlStateNormal];
    [btn setTitle:@"班级列表" forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    但是问题又出来，此时文字会紧贴到做边框，我们可以设置
    btn.contentEdgeInsets = UIEdgeInsetsMake(0,15, 0, 0);
//    使文字距离做边框保持10个像素的距离。
    btn.titleLabel.font =  [UIFont systemFontOfSize:kFontSize_14];
    [btn addTarget:self action:@selector(enterTeaClassList) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - 网络请求
- (void)requestTeacherInfo
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?teacherId=%@",kBaseIPUrl,kSelectTeacherUrl,_teacherId];
    NSLog(@"%@",urlStr);
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestFinished:) andRefresh:YES];
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length]>0)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            //
            NSLog(@"%@",dict);
            
            _pictureArray = [dict objectForKey:@"teacherimagelist"];
            _infoListArray = [dict objectForKey:@"teacherinfolist"];
            [self createShowImageView];
            [_tableV reloadData];
        }
    }
}

#pragma mark - 根据数据创建图片View
- (void)createShowImageView
{
    _topScrollV.contentSize = CGSizeMake(kScreentWidth*_pictureArray.count, _topScrollV.frame.size.height);
    CGRect rect = _topScrollV.frame;

    NSInteger _pageControl_H = 20;
    NSInteger _pageControl_Y = rect.size.height+65 - _pageControl_H;
    NSInteger _pageControl_X = (kScreentWidth-20*_pictureArray.count-10)/2;
    for (int i = 0; i < _pictureArray.count; i ++)
    {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(i*kScreentWidth, 0, kScreentWidth, _topScrollV.frame.size.height)];
        [imgV setImageWithURL:[NSURL URLWithString:[[_pictureArray objectAtIndex:i] objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"teacher_Back"]];
        [_topScrollV addSubview:imgV];
        
        UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pageButton setFrame:CGRectMake(_pageControl_X+i*20, _pageControl_Y, 10, 10)];
        pageButton.layer.masksToBounds = YES;
        pageButton.layer.cornerRadius = 5;
        pageButton.layer.borderWidth = 1;
        pageButton.layer.borderColor = kPart_Button_Color.CGColor;
        pageButton.tag = kPageBtnBaseTag+i;
        [pageButton addTarget:self action:@selector(pageButtonChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pageButton];
        if (i == 0)
        {
            [pageButton setBackgroundColor:kPart_Button_Color];
        }
        [self.view bringSubviewToFront:pageButton];
    }
    if (_picShowTimer==nil)
    {
        _currentImageIndex = 0;
        _picShowTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changPicture) userInfo:nil repeats:YES];
    }
    
}

#pragma mark -切换图片
- (void)changPicture
{
    if (_currentImageIndex<_pictureArray.count-1)
    {
        _currentImageIndex++;
    }
    else
    {
        _currentImageIndex = 0;
    }
    _topScrollV.contentOffset = CGPointMake(kScreentWidth*_currentImageIndex, 0);
    UIButton *btn = (UIButton *)[self.view viewWithTag:_currentImageIndex+kPageBtnBaseTag];
    [self pageButtonChanged:btn];
}

#pragma mark - 切换page
- (void)pageButtonChanged:(UIButton *)btn
{
    for (int i = 0; i < _pictureArray.count; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:kPageBtnBaseTag+i];
        if (newBtn.tag == btn.tag)
        {
            [newBtn setBackgroundColor:kPart_Button_Color];
        }
        else
        {
            [newBtn setBackgroundColor:[UIColor clearColor]];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (((NSInteger)scrollView.contentOffset.x)%(NSInteger)kScreentWidth)
    {
        _currentImageIndex = scrollView.contentOffset.x/kScreentWidth;
        UIButton *btn = (UIButton *)[self.view viewWithTag:_currentImageIndex+kPageBtnBaseTag];
        [self pageButtonChanged:btn];
    }
    
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [_picShowTimer invalidate];
//    _picShowTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"%@",_pictureArray);
//    if (_pictureArray!=nil&&_picShowTimer==nil)
//    {
//        _currentImageIndex = 0;
//        _picShowTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changPicture) userInfo:nil repeats:YES];
//    }
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

- (void)enterTeaClassList
{
    PersonClassViewController *personClassVC = [[PersonClassViewController alloc]initWithNibName:@"PersonClassViewController" bundle:nil];
    personClassVC.pageTitleString = [NSString stringWithFormat:@"%@老师的班级",[_teacherDic objectForKey:@"teachername"]];
    personClassVC.teacherId = _teacherId;
    [self.navigationController pushViewController:personClassVC animated:YES];
}
  


@end
