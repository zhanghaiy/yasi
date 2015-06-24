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
#import "AudioPlayer.h"

#import "Score_Point3_Cell.h"
#import "Score_Point3_Footer_View.h"
#import "Score_Point3_Section_View.h"
#import "Score_Point3_TableHeaderView_commited.h"
#import "OralDBFuncs.h"
#import "NSString+CalculateStringSize.h"
#import "NSURLConnectionRequest.h"

@interface ScoreDetailViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *_topBackV;
    UIScrollView *_pointScrollV;
    
    BOOL _open;// 是否展开
    NSInteger _openIndex;// 展开的索引
    
    BOOL _practiced_point_3; //关卡3是否练习过
    BOOL _commit_point_3;// point3是否已提交
    
    NSMutableArray *_point3_section_array; // 区 头视图
    NSMutableArray *_point3_footer_array;   // 区 尾部视图
    

    TableView_headView *_point3_tableHeaderView;// 未提交状态
    Score_Point3_TableHeaderView_commited *_point3_TableHeaderView_commited;// 提交状态
    AudioPlayer *_audioPlayerManager;
    
    NSMutableArray *_point_1_scoreMenu_Array;
    NSMutableArray *_point_2_scoreMenu_Array;
    NSMutableArray *_point_1_text_Array;
    NSMutableArray *_point_2_text_Array;
    NSMutableArray *_point_3_text_Array;
    
    BOOL _requestReviewSuccess;
    
    NSMutableArray *_reviewArray;
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


#pragma mark - 获取本地音频时长
- (float)getAudioDurationWithPath:(NSString *)audioPath
{
    NSLog(@"%@",audioPath);
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioPath];
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    NSLog(@"%f",audioDurationSeconds);
    return audioDurationSeconds;
}

#pragma mark - 合成point 1 、2 、数据源
- (void)makeUpPoint_1andpoint_2DataArray
{
    NSString *jsonPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/info.json",[OralDBFuncs getCurrentTopic]];
    NSLog(@"%@",jsonPath);
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    NSDictionary *mainDic = [dict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSDictionary *current_Part_Dic = [[mainDic objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    
    NSArray *point_1_question_array = [[[current_Part_Dic objectForKey:@"levellist"] objectAtIndex:0] objectForKey:@"questionlist"];
    
    _point_1_scoreMenu_Array = [[NSMutableArray alloc]init];
    _point_1_text_Array = [[NSMutableArray alloc]init];
    for (NSDictionary *subdic in point_1_question_array)
    {
        NSArray *answer_array = [subdic objectForKey:@"answerlist"];
        for (NSDictionary *subsubDic in answer_array)
        {
            NSString *answerId = [subsubDic objectForKey:@"id"];
            NSString *answerText = [subsubDic objectForKey:@"answer"];
            [_point_1_text_Array addObject:answerText];
            
            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:1])
            {
                PracticeBookRecord *record = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:1];
                [_point_1_scoreMenu_Array addObject:record];
            }
            
        }
    }
    
    NSArray *point_2_question_array = [[[current_Part_Dic objectForKey:@"levellist"] objectAtIndex:1] objectForKey:@"questionlist"];
    
    _point_2_scoreMenu_Array = [[NSMutableArray alloc]init];
    _point_2_text_Array = [[NSMutableArray alloc]init];
    for (NSDictionary *subdic in point_2_question_array)
    {
        NSArray *answer_array = [subdic objectForKey:@"answerlist"];
        for (NSDictionary *subsubDic in answer_array)
        {
            NSString *answerId = [subsubDic objectForKey:@"id"];
            NSString *answerText = [subsubDic objectForKey:@"answer"];
            [_point_2_text_Array addObject:answerText];
            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:2])
            {
                PracticeBookRecord *record = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:2];
                [_point_2_scoreMenu_Array addObject:record];
            }
        }
    }
    
    
    NSArray *point_3_question_array = [[[current_Part_Dic objectForKey:@"levellist"] lastObject] objectForKey:@"questionlist"];
    _point_3_text_Array = [[NSMutableArray alloc]init];
    for (int i = 0; i < point_3_question_array.count; i ++)
    {
        NSDictionary *point_3_dic = [point_3_question_array objectAtIndex:i];
        NSString *questionText = [point_3_dic objectForKey:@"question"];
        NSString *questionID = [point_3_dic objectForKey:@"id"];
        NSString *answerAudioPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/part%d-3-%d.wav",[OralDBFuncs getCurrentTopic],[OralDBFuncs getCurrentPart],i];
        // 此处获取时长
        float duration = [self getAudioDurationWithPath:answerAudioPath];
        NSDictionary *makeDic = @{@"question":questionText,@"questionid":questionID,@"answerPath":answerAudioPath,@"duration":[NSNumber numberWithFloat:duration]};
        [_point_3_text_Array addObject:makeDic];
    }
    
}


#pragma mark - SubViews
#pragma mark -- 创建区头视图
- (Score_Point3_Section_View *)create_point3_section_view_Tag:(NSInteger)viewTag andInfoDict:(NSDictionary *)dict
{
    // 计算文字大小
    NSString *text = [[_point_3_text_Array objectAtIndex:viewTag] objectForKey:@"question"];
    CGRect rect = [NSString CalculateSizeOfString:text Width:(kScreentWidth-30) Height:9999 FontSize:12];
    
    Score_Point3_Section_View *sectionView = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_Section_View" owner:self options:0] lastObject];
    sectionView.tag = viewTag+kPoint3_Section_Tag;
    sectionView.titleLAbel.text = text;
    if (_review_part)
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

#pragma mark -- 创建区尾部视图
- (Score_Point3_Footer_View *)create_point3_footer_view_Tag:(NSInteger)viewTag andReviewDict:(NSDictionary *)review_dic
{
    Score_Point3_Footer_View *sectionView = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_Footer_View" owner:self options:0] lastObject];
    sectionView.tag = viewTag+kPoint3_Footer_Tag;
    if (review_dic == nil)
    {
        [sectionView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    else
    {
        [sectionView setFrame:CGRectMake(0, 0, kScreentWidth, 70)];
        /*
         此处需根据老师的反馈 音频 或者 文字 来改变控件的frame
         "teacherurllength": 3260,
         "teacherevaluate": "",
         "score": 7,
         "questionid": "2920D77CAA0049FB87204E0F46CABB97",
         "teacherurl": "2621.mp3"
         */
        if ([[review_dic objectForKey:@"teacherurl"] length])
        {
            // 语音评价
            sectionView.reviewLabel.text = [NSString stringWithFormat:@"%d\"",[[review_dic objectForKey:@"teacherurllength"] intValue]/1000];
            [sectionView.headImgV setImage:[UIImage imageNamed:@"touxiang.png"]];
        }
        else
        {
            NSString *reviewText = [review_dic objectForKey:@"teacherevaluate"];
            sectionView.reviewLabel.text = reviewText;
            // 计算文字大小
            CGRect rect_1 = [NSString CalculateSizeOfString:reviewText Width:99999 Height:15 FontSize:kFontSize2];
            
            // 两种情况 1、宽度小于1行 2、多行
            if (rect_1.size.width>(kScreentWidth-90))
            {
                // 2 、 多行
                CGRect rect_2 = [NSString CalculateSizeOfString:reviewText Width:(kScreentWidth-90) Height:99999 FontSize:kFontSize2];
                [sectionView setFrame:CGRectMake(0, 0, kScreentWidth, 70+(rect_2.size.height-25))];
                [sectionView.reviewLabel setFrame:CGRectMake(12, 13, kScreentWidth-90, rect_2.size.height)];
                sectionView.layer.cornerRadius = 5;
            }
            else
            {
                // 1、1行
                [sectionView.reviewLabel setFrame:CGRectMake(kScreentWidth-78-rect_1.size.width, 13, rect_1.size.width, 30)];
            }
        }

    }    
    return sectionView;
}

#pragma mark - 请求已处理信息
- (void)requestLevel_3_watingInfo
{
    NSString *urlSTr = [NSString stringWithFormat:@"%@%@?waitingid=%@",kBaseIPUrl,kReviewWatingEvent,[_watingDic objectForKey:@"waitingid"]];
    [NSURLConnectionRequest requestWithUrlString:urlSTr target:self aciton:@selector(requestLevel_3_watingInfoCallBack:) andRefresh:YES];
}

#pragma mark - 请求关卡3老师反馈
#pragma mark -- 网络请求反馈
- (void)requestLevel_3_watingInfoCallBack:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            _requestReviewSuccess = YES;
            _reviewArray = [dict objectForKey:@"teacheranswerlist"];
            UITableView *tabV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
            [tabV reloadData];
        }
    }
}

#pragma mark -- 合成point_3_footer 数据
- (void)makeUpFooterView_point_3
{
    _point3_footer_array = [[NSMutableArray alloc]init];
    for (int i = 0; i < _point_3_text_Array.count; i ++)
    {
        NSString *questionId = [[_point_3_text_Array objectAtIndex:i] objectForKey:@"questionid"];
        
        NSDictionary *selecDic = [self retrievalReviewDictWithQuestionID:questionId];
        [_point3_footer_array addObject:[self create_point3_footer_view_Tag:i andReviewDict:selecDic]];
    }
}

#pragma mark -- 根据问题id 查找问题的评价
- (NSDictionary *)retrievalReviewDictWithQuestionID:(NSString *)questionid
{
    for (NSDictionary *subDic in _reviewArray)
    {
        if ([subDic objectForKey:@"questionid"])
        {
            NSString *questionID = [subDic objectForKey:@"questionid"];
            if ([questionID isEqualToString:questionid])
            {
                return subDic;
            }
        }
    }
    return nil;
}

#pragma mark -- 总评价 展开 -- 待完善
- (void)openTeacherReview:(UIButton *)btn
{
    // 展开 老师总评价
    //    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    
    if (_review_part)
    {
        
    }
    
}


#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    
    // 未提交头视图
    [self createPoint_3TabHeadView];
    // 创建播放器
    [self createPlayer];
    
    // 合成point1 point2 数据源
    [self makeUpPoint_1andpoint_2DataArray];
    [self uiConfig];
    
    _requestReviewSuccess = NO;
    // 以下是关卡3 根据老师是否评价 修改界面元素
    _openIndex = -1;
    _point3_section_array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < _point_3_text_Array.count; i ++)
    {
        [_point3_section_array addObject:[self create_point3_section_view_Tag:i andInfoDict:nil]];
    }
    // 未提交时头视图
    _point3_tableHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"TableView_headView" owner:self options:0] lastObject];
    // 已反馈头视图
    _point3_TableHeaderView_commited = [[[NSBundle mainBundle]loadNibNamed:@"Score_Point3_TableHeaderView_commited" owner:self options:0] lastObject];

    
    // 判断是否练习过
    if ([OralDBFuncs getPartLevel3PracticeedwithTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]])
    {
        //已练习
        _practiced_point_3 = YES;
        // 判断是否提交
        _commit_point_3 = [OralDBFuncs getPartLevel3CommitwithTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
    }
    else
    {
        // 未练习
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 40)];
        lab.text = @"暂无成绩";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = kPart_Button_Color;
        lab.font = [UIFont systemFontOfSize:kFontSize2];
        
        UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
        point_3_tableV.tableFooterView = lab;
    }

    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewTag+2];
    if (_review_part)
    {
        [_point3_TableHeaderView_commited.backBtn addTarget:self action:@selector(openTeacherReview:) forControlEvents:UIControlEventTouchUpInside];

        point_3_tableV.tableHeaderView = _point3_TableHeaderView_commited;
    }
    else
    {
        point_3_tableV.tableHeaderView = _point3_tableHeaderView;
        if (_commit_point_3)
        {
            // 已提交 显示待评价
            [_point3_tableHeaderView.commitButton setTitle:@"已提交" forState:UIControlStateNormal];
            _point3_tableHeaderView.titleLabel.text = @"已经提交给老师，等待老师评价~~~~";
        }
        else
        {
            // 未提交 显示提交
            // 已提交 显示待评价
            [_point3_tableHeaderView.commitButton setTitle:@"提交" forState:UIControlStateNormal];
            _point3_tableHeaderView.titleLabel.text = @"提交给老师点评~~~~";
        }
    }
    
    // 请求老师反馈
    if (_review_part)
    {
        //
        [self requestLevel_3_watingInfo];
    }
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
        [pointButton setTitle:[NSString stringWithFormat:@"Part%d-%d",[OralDBFuncs getCurrentPart],i+1] forState:UIControlStateNormal];
        [pointButton setTitleColor:_pointColor forState:UIControlStateSelected];
         [pointButton setTitleColor:_textColor forState:UIControlStateNormal];
        
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
    
    _pointScrollV.showsHorizontalScrollIndicator = NO;
    _pointScrollV.showsVerticalScrollIndicator = NO;
    
    for (int i = 0; i < 3; i ++)
    {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i*kScreentWidth, 0, kScreentWidth, _pointScrollV.bounds.size.height) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag  = kTableViewTag+i;
        tableView.backgroundColor = _backgroundViewColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [_pointScrollV addSubview:tableView];
        
        if (i == 0)
        {
            if (_point_1_scoreMenu_Array.count==0)
            {
                UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 40)];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = kPart_Button_Color;
                lab.font = [UIFont systemFontOfSize:kFontSize2];
                lab.text = @"暂无成绩";
                tableView.tableHeaderView = lab;
            }
        }
        else if (i == 1)
        {
            if (_point_2_scoreMenu_Array.count==0)
            {
                UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 40)];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = kPart_Button_Color;
                lab.font = [UIFont systemFontOfSize:kFontSize2];
                lab.text = @"暂无成绩";
                tableView.tableHeaderView = lab;
            }
        }
    }
}

#pragma mark - 列表控件 delegate
#pragma mark -- ROW 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag-kTableViewTag == 2)
    {
        return 1;
    }
    else if (tableView.tag == kTableViewTag)
    {
        return _point_1_scoreMenu_Array.count;
    }
    else if (tableView.tag == kTableViewTag + 1)
    {
        return _point_2_scoreMenu_Array.count;
    }
    return 0;
}
#pragma mark -- 区 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_practiced_point_3)
        {
            // 练习过
            return _point3_section_array.count;
        }
        else
        {
            return 0;
        }
    }
    return 1;
}

#pragma mark -- cell -- Height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag-kTableViewTag == 2)
    {
        if (_open&& _openIndex == indexPath.section)
        {
            return 60;
        }
        return 0;
    }
    else if (tableView.tag == kTableViewTag)
    {
        
        NSString *text = [_point_1_text_Array objectAtIndex:indexPath.row];
        CGRect rect = [NSString CalculateSizeOfString:[self filterHTML:text] Width:kScreentWidth-75 Height:9999 FontSize:20];
        if (rect.size.height>50)
        {
            return 75+rect.size.height-50;
        }
        return 75;
    }
    else if (tableView.tag == kTableViewTag+1)
    {
        NSString *text = [_point_2_text_Array objectAtIndex:indexPath.row];
        CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-80 Height:9999 FontSize:20];
        if (rect.size.height>50)
        {
            return 75+rect.size.height-50;
        }
        return 75;
    }

    return 0;
}

#pragma mark -- 区 头视图 -- 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        return ((UIView *)[_point3_section_array objectAtIndex:section]).frame.size.height;
    }
    return 0;
}

#pragma mark -- 区 头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 头视图
    if (tableView.tag == kTableViewTag+2)
    {
        Score_Point3_Section_View *view = [_point3_section_array objectAtIndex:section];
        if (_review_part)
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

#pragma mark -- 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag)
    {
        case kTableViewTag:
        {
            // point 1 跟读 此处cell 可重复利用闯关成功页面cell
            static NSString *cellId = @"successCell_point1";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            PracticeBookRecord *record = [_point_1_scoreMenu_Array objectAtIndex:indexPath.row];
            [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
            [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
            return cell;
        }
            break;
        case kTableViewTag+1:
        {
            // point 2 填空 此处cell 同上
            static NSString *cellId = @"ScoreMenuCell_point2";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            PracticeBookRecord *record = [_point_1_scoreMenu_Array objectAtIndex:indexPath.row];
            [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
            [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
            
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
            // 自己的回答信息
            
            NSDictionary *dict = [_point_3_text_Array objectAtIndex:indexPath.section];
            cell.reviewLabel.text = [NSString stringWithFormat:@"%d\"",[[dict objectForKey:@"duration"] intValue]];
            
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

#pragma mark -- 区 尾部视图 -- View
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_review_part)
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

#pragma mark -- 区 尾部视图 -- 高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewTag+2)
    {
        if (_review_part)
        {
            if (_openIndex==section &&_open)
            {
                if (_requestReviewSuccess)
                {
                    return ((UIView *)[_point3_footer_array objectAtIndex:section]).frame.size.height;
                }
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

#pragma mark - 选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 选中播放音频
}




#pragma mark - 播放器有关方法

//#pragma mark - 播放自己的音频
//- (void)playMyAnswer:(UIButton *)btn
//{
//    // 播放回答音频 此处暂时写死 --- 待完善
//    NSString *audioPath = [[NSBundle mainBundle]pathForResource:@"Question_3224" ofType:@"mp3"];
//    [_audioPlayerManager playerPlayWithFilePath:audioPath];
//}

#pragma mark -- 创建播放器
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
    NSLog(@"playfinished");
}


#pragma mark - 总体界面的元素变化
#pragma mark -- 切换关卡
- (void)pointButtonClicked:(UIButton *)btn
{
    [self changePointButtonSelected:btn.tag-kPointButtonTag];
    [UIView animateWithDuration:0.5 animations:^{
        _pointScrollV.contentOffset = CGPointMake(kScreentWidth*(btn.tag - kPointButtonTag), 0);
    }];
}

#pragma mark -- 任何时刻选中一个
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

#pragma mark -- 滑动滚动视图
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger count = scrollView.contentOffset.x/kScreentWidth;
    [self changePointButtonSelected:count];
}

#pragma mark -- 创建未提交头视图
- (void)createPoint_3TabHeadView
{
    _point3_tableHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"TableView_headView" owner:self options:0] lastObject];
    _point3_tableHeaderView.titleLabel.textColor = _backColor;
    [_point3_tableHeaderView.commitButton setBackgroundColor:_backColor];
    [_point3_tableHeaderView.commitButton addTarget:self action:@selector(commitToTeacher:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- 去掉html标签
-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}


#pragma mark -- 提交按钮 part
- (void)commitToTeacher:(UIButton *)btn
{
    // 提交给老师 从本地获取数据 压缩zip包 上传服务端
}

#pragma mark -- 展开选中的cell
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
