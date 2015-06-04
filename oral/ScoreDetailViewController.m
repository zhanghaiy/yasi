//
//  ScoreDetailViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreDetailViewController.h"
#import "ScoreMenuCell.h" // point1 2 cell
//#import "ScorePoint_3_Cell.h"

#import "TableView_headView.h"
//#import "TableView_headView_commited.h"
//#import "section_HeadView.h"
#import "AudioPlayer.h"

//#import "Score_Footer_View.h"
#import "Score_Point3_Cell.h"
#import "Score_Point3_Footer_View.h"
#import "Score_Point3_Section_View.h"
#import "Score_Point3_TableHeaderView_commited.h"

@interface ScoreDetailViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *_topBackV;
    UIScrollView *_pointScrollV;
    
    BOOL _open;// 是否展开
    NSInteger _openIndex;// 展开的索引
    
    BOOL _commit;// point3是否已提交
    
    // 每个关卡 每个问题的富文本 不一样 所以需要计算cell高度
    NSInteger _cellHeight_point3;
    NSInteger _cellHeight_point2;
    NSInteger _cellHeight_point1;
    
    NSArray *questionArray;
    NSMutableArray *_point3_section_array;
    NSMutableArray *_point3_footer_array;

    TableView_headView *_point3_tableHeaderView;// 未提交状态
    Score_Point3_TableHeaderView_commited *_point3_TableHeaderView_commited;// 提交状态
    AudioPlayer *_audioPlayerManager;
    
}
@end

@implementation ScoreDetailViewController

#define kBackScrollViewTag 666
#define kPointButtonWidth (kScreentWidth/3)
#define kPointButtonTag 1111
#define kTopViewHeight 44
#define kTableViewTag 2222
#define kPoint_3_sectionViewTag 6666
#define kPoint_3_sectionHeight 60
#define kAudioButtonTag 7777

#define kPoint3_Section_Tag 888
#define kPoint3_Footer_Tag 999

#define kPoint3_Section_BackBtn_Tag 500

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];

    [self createPoint_3TabHeadView];// 未提交头视图
    [self createPlayer];
    
    _commit = NO;
    _openIndex = -1;
    questionArray =  @[@"Should students travel abroad to broaden their horizons?",@"Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons Should students travel abroad to broaden their horizons",@"Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?"];
    
    _point3_section_array = [[NSMutableArray alloc]init];
    _point3_footer_array = [[NSMutableArray alloc]init];

    for (int i = 0; i < questionArray.count; i ++)
    {
        [_point3_section_array addObject:[self create_point3_section_view_Tag:i andInfoDict:nil]];
        [_point3_footer_array addObject:[self create_point3_footer_view_Tag:i]];
    }
   
    [self uiConfig];
    
    _point3_TableHeaderView_commited = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_TableHeaderView_commited" owner:self options:0] lastObject];
    [_point3_TableHeaderView_commited.backBtn addTarget:self action:@selector(openTeacherReview:) forControlEvents:UIControlEventTouchUpInside];

    
    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    if (_commit)
    {
        point_3_tableV.tableHeaderView = _point3_TableHeaderView_commited;
    }
    else
    {
        point_3_tableV.tableHeaderView = _point3_tableHeaderView;
    }
    
}


- (void)openTeacherReview:(UIButton *)btn
{
    // 展开 老师总评价
    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];

    if (_commit)
    {
        
    }
    
}

#pragma mark - 创建区头视图
- (Score_Point3_Section_View *)create_point3_section_view_Tag:(NSInteger)viewTag andInfoDict:(NSDictionary *)dict
{
    // 计算文字大小
    NSString *text = [questionArray objectAtIndex:viewTag];
    CGRect rect = [self getRectWithText:text Width:(kScreentWidth-30) FontSize:12];
    
    Score_Point3_Section_View *sectionView = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_Section_View" owner:self options:0] lastObject];
    sectionView.tag = viewTag+kPoint3_Section_Tag;
    sectionView.titleLAbel.text = text;
    if (_commit)
    {
        sectionView.reviewImgV.hidden = NO;
    }
    else
    {
        sectionView.desLabel.hidden = NO;
    }
    if (rect.size.height>30)
    {
        [sectionView setFrame:CGRectMake(0, 0, kScreentWidth, 60+(rect.size.height-35))];
    }
    else
    {
        [sectionView setFrame:CGRectMake(0, 0, kScreentWidth, 60)];
    }
    
    sectionView.backButton.tag = kPoint3_Section_BackBtn_Tag + viewTag;
    [sectionView.backButton addTarget:self action:@selector(openSelectedCell:) forControlEvents:UIControlEventTouchUpInside];
    
    return sectionView;
}

#pragma mark - 创建区尾部视图
- (Score_Point3_Footer_View *)create_point3_footer_view_Tag:(NSInteger)viewTag
{
    Score_Point3_Footer_View *sectionView = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_Footer_View" owner:self options:0] lastObject];
    sectionView.tag = viewTag+kPoint3_Footer_Tag;
    [sectionView setFrame:CGRectMake(0, 0, kScreentWidth, 70)];
    
    /*
         此处需根据老师的反馈 音频 或者 文字 来改变控件的frame
     */

    
    return sectionView;
}

#pragma mark - UI配置
- (void)uiConfig
{
    // 顶部 关卡
    _topBackV = [[UIView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+1, kScreentWidth, kTopViewHeight)];
    _topBackV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_topBackV];
    
    for (int i = 0; i < 3; i ++)
    {
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pointButton setFrame:CGRectMake(i*kPointButtonWidth, 0, kPointButtonWidth, kTopViewHeight)];
        [pointButton setTitle:[NSString stringWithFormat:@"Part%d-%d",self.currentPartCounts+1,i+1] forState:UIControlStateNormal];
        [pointButton setTitleColor:_pointColor forState:UIControlStateSelected];
         [pointButton setTitleColor:_textColor forState:UIControlStateNormal];
//        pointButton.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
        
        pointButton.tag = kPointButtonTag + i;
        pointButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize2];
        [pointButton addTarget:self action:@selector(pointButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topBackV addSubview:pointButton];
        if (i == 0)
        {
            pointButton.selected = YES;
        }
    }
    
    _pointScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+kTopViewHeight+1, kScreentWidth, kScreenHeight-KNavTopViewHeight-kTopViewHeight-1)];
    _pointScrollV.tag = kBackScrollViewTag;
    _pointScrollV.contentSize = CGSizeMake(kScreentWidth*3, kScreenHeight-89);
    _pointScrollV.delegate = self;
    _pointScrollV.backgroundColor = _backgroundViewColor;
    _pointScrollV.pagingEnabled = YES;
    [self.view addSubview:_pointScrollV];
    
    for (int i = 0; i < 3; i ++)
    {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i*kScreentWidth, 0, kScreentWidth, _pointScrollV.bounds.size.height) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag  = kTableViewTag+i;
        tableView.backgroundColor = _backgroundViewColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_pointScrollV addSubview:tableView];
    }
}

#pragma mark - 列表控件 delegate
#pragma mark - - ROW 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag-kTableViewTag == 2)
    {
        return 1;
    }
    return 6;
}
#pragma mark - - Section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kTableViewTag+2)
    {
        return _point3_section_array.count;
    }
    return 1;
}

#pragma mark - ROW -- Height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag-kTableViewTag == 2)
    {
        if (_commit)
        {
            // 提交后的 -- 待完善
            if (_openIndex == indexPath.section && _open)
            {
                return 60;
            }
            return 0;
        }
        else
        {
            if (_open&& _openIndex == indexPath.section)
            {
                return 60;
            }
            return 0;
        }
    }

    return 75;
}

#pragma mark - - Section HeaderView --- Height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        return ((UIView *)[_point3_section_array objectAtIndex:section]).frame.size.height;
    }
    return 0;
}
#pragma mark - - SectionHeaderView  --- View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 头视图
    if (tableView.tag == kTableViewTag+2)
    {
        Score_Point3_Section_View *view = [_point3_section_array objectAtIndex:section];
        if (_commit)
        {
            view.reviewImgV.hidden = NO;
            view.desLabel.hidden = YES;
        }
        else
        {
            if (_openIndex == section )
            {
                view.desLabel.hidden = YES;
            }
            else
            {
                view.desLabel.hidden = NO;
            }
            view.reviewImgV.hidden = YES;
        }
        
        return view;
    }
    return nil;
}

#pragma mark - - 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag)
    {
        case kTableViewTag:
        {
            // point 1 跟读 此处cell 可重复利用闯关成功页面cell
            static NSString *cellId = @"successCell";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            return cell;
        }
            break;
        case kTableViewTag+1:
        {
            // point 2 填空 此处cell 同上
            static NSString *cellId = @"sucCell";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            
            return cell;
        }
            break;
        case kTableViewTag+2:
        {
            // point 3 问答 此处cell 可折叠
            static NSString *cellId = @"Score_Point3_Cell";
            
            Score_Point3_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_Cell" owner:self options:0] lastObject];
            }
            if (_openIndex == indexPath.section && _open)
            {
                //
            }
            else
            {
                cell.hidden = YES;
            }
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - - Section Footer ----- View
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_commit)
        {
            if (_open && _openIndex== section)
            {
                return [_point3_footer_array objectAtIndex:section];
            }
            return nil;
        }
        else
        {
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 1)];
            lab.backgroundColor = _backgroundViewColor;
            return lab;
        }
    }
    return nil;
}

#pragma mark - - Section Footer ----- height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_commit)
        {
            if (_openIndex==section &&_open)
            {
                return 70;
            }
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0.1;
}


- (void)playMyAnswer:(UIButton *)btn
{
    // 播放回答音频 此处暂时写死 --- 待完善
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:@"Question_3224" ofType:@"mp3"];
    [_audioPlayerManager playerPlayWithFilePath:audioPath];
}

- (void)createPlayer
{
    _audioPlayerManager = [AudioPlayer getAudioManager];
    _audioPlayerManager.target = self;
    _audioPlayerManager.action = @selector(playFinished:);
}

- (void)pasePlayer
{
    [_audioPlayerManager pausePlay];
}

- (void)stopPlayer
{
    [_audioPlayerManager stopPlay];
}

- (void)playFinished:(AudioPlayer *)player
{
    //
}


#pragma mark - 切换关卡
- (void)pointButtonClicked:(UIButton *)btn
{
    [self changePointButtonSelected:btn.tag-kPointButtonTag];
    [UIView animateWithDuration:0.5 animations:^{
        _pointScrollV.contentOffset = CGPointMake(kScreentWidth*(btn.tag - kPointButtonTag), 0);
    }];
}

#pragma mark - 任何时刻选中一个
- (void)changePointButtonSelected:(NSInteger)count
{
    for (int i = 0; i < 3; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:kPointButtonTag+i];
        if (newBtn.tag == count+kPointButtonTag)
        {
            newBtn.selected = YES;
        }
        else
        {
            newBtn.selected = NO;
        }
    }
}

#pragma mark - 滑动滚动视图
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger count = scrollView.contentOffset.x/kScreentWidth;
    [self changePointButtonSelected:count];
}

#pragma mark - 创建未提交头视图
- (void)createPoint_3TabHeadView
{
    _point3_tableHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"TableView_headView" owner:self options:0] lastObject];
    _point3_tableHeaderView.titleLabel.textColor = _backColor;
    [_point3_tableHeaderView.commitButton setBackgroundColor:_backColor];
    [_point3_tableHeaderView.commitButton addTarget:self action:@selector(commitToTeacher:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 提交按钮
- (void)commitToTeacher:(UIButton *)btn
{
    // 提交给老师 从本地获取数据 压缩zip包 上传服务端
}

#pragma mark - 计算文字大小
- (CGRect )getRectWithText:(NSString *)text Width:(NSInteger)width FontSize:(NSInteger)fontSize
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, 99999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont 							systemFontOfSize:fontSize]} context:nil];
    return  rect;
}

#pragma mark - 展开选中的cell
- (void)openSelectedCell:(UIButton *)btn
{
    _open = YES;
    _openIndex = btn.tag-kPoint3_Section_BackBtn_Tag;
    
    UITableView *tabV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    [tabV reloadData];
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
