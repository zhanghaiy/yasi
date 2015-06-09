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
    
    NSInteger scrollVHeight = kScreentWidth*12/25;
    CGRect rec = _topScrollV.frame;
    rec.size.width = kScreentWidth;
    rec.size.height = scrollVHeight;
    _topScrollV.frame = rec;
    
    _topScrollV.delegate = self;
    _topScrollV.contentSize = CGSizeMake(kScreentWidth*_pictureArray.count, scrollVHeight);
    _topScrollV.pagingEnabled = YES;
    
    [self requestTeacherInfo];
    
    _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65+scrollVHeight, kScreentWidth, kScreenHeight-scrollVHeight-65) style:UITableViewStylePlain];
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
    [btn setTitle:@"    班级列表" forState:UIControlStateNormal];
    btn.titleLabel.font =  [UIFont systemFontOfSize:kFontSize1];
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
    CGRect rect = _topScrollV.bounds;

    NSInteger _pageControl_H = 20;
    NSInteger _pageControl_Y = rect.size.height+65 - _pageControl_H;
    NSInteger _pageControl_X = (kScreentWidth-20*_pictureArray.count-10)/2;
    for (int i = 0; i < _pictureArray.count; i ++)
    {
        rect.origin.x = i * kScreentWidth;
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:rect];
        imgV.image = [UIImage imageNamed:@"class_introduce_back"];
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
    _currentImageIndex = 0;
    _picShowTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changPicture) userInfo:nil repeats:YES];
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
    [self.navigationController pushViewController:personClassVC animated:YES];
}
  


@end
