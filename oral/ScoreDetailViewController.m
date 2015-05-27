//
//  ScoreDetailViewController.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreDetailViewController.h"
#import "ScoreMenuCell.h"
#import "ScorePoint_3_Cell.h"

#import "TableView_headView.h"
#import "TableView_headView_commited.h"
#import "section_HeadView.h"
#import "AudioPlayer.h"

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
    
    NSMutableArray *_sectionViewArray;
    NSArray *questionArray;
    
    TableView_headView *_point_3_tab_headView;
    TableView_headView_commited *_point_3_tab_headView_commited;
    section_HeadView *_point_3_section_headView;
//    UIView *_point_3_section_headView_commited;
    
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    
//    [self createPoint_3SectionHeadView];
//    [self createPoint_3SectionHeadView_commited];
    [self createPoint_3TabHeadView];
    [self createPoint_3TabHeadView_commited];
    [self createPlayer];
    
    _commit = NO;
    questionArray =  @[@"Should students travel abroad to broaden their horizons?",@"Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons Should students travel abroad to broaden their horizons",@"Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?Should students travel abroad to broaden their horizons?"];
    
    _sectionViewArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < questionArray.count; i ++)
    {
        [_sectionViewArray addObject:[self createPoint_3SectionHeadViewWithString:[questionArray objectAtIndex:i] andTAg:i+kPoint_3_sectionViewTag]];
    }
    
    [self uiConfig];
    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    if (_commit)
    {
        point_3_tableV.tableHeaderView = _point_3_tab_headView_commited;
    }
    else
    {
        point_3_tableV.tableHeaderView = _point_3_tab_headView;
    }
}

- (void)uiConfig
{
    // 顶部 关卡
    _topBackV = [[UIView alloc]initWithFrame:CGRectMake(0, 45, kScreentWidth, kTopViewHeight)];
    _topBackV.backgroundColor = _backgroundViewColor;
    [self.view addSubview:_topBackV];
    
    for (int i = 0; i < 3; i ++)
    {
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pointButton setFrame:CGRectMake(i*kPointButtonWidth, 0, kPointButtonWidth, kTopViewHeight)];
        [pointButton setTitle:[NSString stringWithFormat:@"Part%ld-%d",self.currentPartCounts+1,i+1] forState:UIControlStateNormal];
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
    
    _pointScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 89, kScreentWidth, kScreenHeight-89)];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag-kTableViewTag == 2)
    {
        return 1;
    }
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kTableViewTag+2)
    {
        return _sectionViewArray.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag-kTableViewTag == 2)
    {
        if (_commit)
        {
            // 提交后的 -- 待完善
            return 75;
        }
        else
        {
            if (_openIndex == indexPath.section)
            {
                if (_open)
                {
                    // 此处需要根据现实的富文本大小判断高度 ---待完善
                    CGRect rect = [self getRectWithText:[questionArray objectAtIndex:indexPath.section] Width:kScreentWidth-20 FontSize:12];
                    NSInteger hhh = (rect.size.height>60)?rect.size.height-60:0;
                    return 120+hhh;
                }
                return 0;
            }
            return 0;
        }
    }

    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag - kTableViewTag == 2)
    {
        if (_commit)
        {
            // 提交后的 -- 待完善
            return 75;
        }
        else
        {
            if (_openIndex == section)
            {
                if (_open)
                {
                    return 0;
                }
                return ((UIView *)[_sectionViewArray objectAtIndex:section]).frame.size.height;
            }
            return ((UIView *)[_sectionViewArray objectAtIndex:section]).frame.size.height;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 头视图
    if (tableView.tag - kTableViewTag == 2)
    {
        /*
         关卡3 此处有两种情况 1、未提交：只有问题 2、提交：问题 老师的回答
         */
        if (_commit)
        {
            // 已提交
            
        }
        else
        {
           // 未提交
            return [_sectionViewArray objectAtIndex:section];
        }
    }
    return nil;
}

#pragma mark - 绘制cell
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
            static NSString *cellId = @"sucCell";
            ScorePoint_3_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScorePoint_3_Cell" owner:self options:0] lastObject];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.controlsColor = _pointColor;
            cell.questionLabel.numberOfLines = 0;
            cell.questionLabel.textColor = _textColor;
            cell.questionLabel.text = [questionArray objectAtIndex:indexPath.section];
            
            cell.audioButton.tag = indexPath.section + kAudioButtonTag;
            [cell.audioButton addTarget:self action:@selector(playMyAnswer:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_commit)
        {
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_commit)
        {
            return 1;
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
    _point_3_tab_headView = [[[NSBundle mainBundle]loadNibNamed:@"TableView_headView" owner:self options:0] lastObject];
    _point_3_tab_headView.titleLabel.textColor = _backColor;
    [_point_3_tab_headView.commitButton setBackgroundColor:_backColor];
    [_point_3_tab_headView.commitButton addTarget:self action:@selector(commitToTeacher:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)commitToTeacher:(UIButton *)btn
{
    // 提交给老师 从本地获取数据 压缩zip包 上传服务端
}

#pragma mark - 创建未提交区视图
- (UIView *)createPoint_3SectionHeadViewWithString:(NSString *)text andTAg:(NSInteger)tag
{
    NSInteger width = kScreentWidth-20;
    NSInteger fontSize = 12;
    CGRect rect = [self getRectWithText:text Width:width FontSize:fontSize];
    // 头视图
    UIView *point_3_secView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, kPoint_3_sectionHeight+(rect.size.height>25?rect.size.height-25:0))];
    point_3_secView.backgroundColor = [UIColor whiteColor];
    point_3_secView.tag = tag;
    // 问题
    UILabel *questionLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, kScreentWidth-20, point_3_secView.frame.size.height-35)];
    questionLab.text = text;
    questionLab.textAlignment = NSTextAlignmentLeft;
    questionLab.numberOfLines = 0;
    questionLab.font = [UIFont systemFontOfSize:fontSize];
    [point_3_secView addSubview:questionLab];
    // 提示
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(10, point_3_secView.frame.size.height-20, kScreentWidth-20, 15)];
    tipLab.text = @"点击产看自己对此问题的回答";
    tipLab.textAlignment = NSTextAlignmentLeft;
    tipLab.font = [UIFont systemFontOfSize:fontSize-2];
    [point_3_secView addSubview:tipLab];
    point_3_secView.userInteractionEnabled = YES;
    
    questionLab.textColor = _textColor;
    tipLab.textColor = _textColor;
    // 添加手势 点击展开
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCell:)];
    [point_3_secView addGestureRecognizer:tap];
    
    return point_3_secView;
}

- (CGRect )getRectWithText:(NSString *)text Width:(NSInteger)width FontSize:(NSInteger)fontSize
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, 99999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont 							systemFontOfSize:fontSize]} context:nil];
    return  rect;
}

- (void)openCell:(UITapGestureRecognizer *)tap
{
    _open = YES;
    _openIndex = tap.view.tag-kPoint_3_sectionViewTag;
    UITableView *tabV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    [tabV reloadData];
}

#pragma mark - 创建老师反馈头视图
- (void)createPoint_3TabHeadView_commited
{
    _point_3_tab_headView_commited = [[[NSBundle mainBundle]loadNibNamed:@"TableView_headView_commited" owner:self options:0] lastObject];
}

#pragma mark - 创建老师反馈区视图
- (void)createPoint_3SectionHeadView_commited
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

@end
