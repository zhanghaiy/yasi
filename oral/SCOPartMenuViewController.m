//
//  SCOPartMenuViewController.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "SCOPartMenuViewController.h"
#import "OralDBFuncs.h"
#import "AudioPlayer.h"
#import "ScoreMenuCell.h"
#import "Point_3_Section_Head_View.h"
#import "Point_3_Review_Head_View.h"
#import "Point_3_Review_Cell.h"
#import "Point_3_Commit_cell.h"
#import "Point_3_Commit_View.h"  //头视图 未反馈
#import "NSString+CalculateStringSize.h"
#import "NSURLConnectionRequest.h"
#import "ZipManager.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "ZipArchive.h"
#import "MyTeacherViewController.h"



@interface SCOPartMenuViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,SelectTeacherDelegate>
{
    Point_3_Commit_View *_commit_Head_View; // 提交 未提交头视图
    Point_3_Review_Head_View *_review_Head_View;// 反馈头视图
    
    BOOL _exit_point_3;// 判断用户是否练习过关卡3
    BOOL _commited;// 判断用户是否提交过
    BOOL _requestReviewSuccess;// 请求成功
    BOOL _open;// 标记是否展开
    int _openIndex;
    UIScrollView *_point_scroll_View;       // 滚动视图
    NSMutableArray *_text_array_point_1;    // 问题文本等信息
    NSMutableArray *_text_array_point_2;    // 问题文本等信息
    NSMutableArray *_text_array_point_3;    // 问题文本等信息
    
    NSMutableArray *_score_array_point_1;   // 数据库存储分数
    NSMutableArray *_score_array_point_2;   // 数据库存储分数
    NSMutableArray *_score_array_point_3;   // 网络请求回来
    NSDictionary *_review_sum_dict;         // 总评
    
    NSMutableArray *_section_array_point_3;// 头视图数组
    
    AudioPlayer *_audioPlayerManager;
    NSString *_defaulTeacherID;
}
@end

@implementation SCOPartMenuViewController

#define kTopViewHeight 44
#define kPointButtonTag  10
#define kPointButtonWidth (kScreentWidth/3)

#define kPointScrollViewTag 20
#define kTableViewBaseTag 25
#define kSectionHeadPoint3Tag 30
#define kPoint3_Section_BackBtn_Tag 100
#define kTeacherReviewButtonTAg 200
#define kPlaySelfButtonTag 300

#pragma mark  - 路径有关
#pragma mark -- 获取本地路径
- (NSString *)getPoint3ReviewBasePath
{
    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
    return path;
}
#pragma mark -- 获取解压后路径
- (NSString *)getPoint3UnZipPath
{
    NSString *path = [NSString stringWithFormat:@"%@/PartReview",[self getPoint3ReviewBasePath]];
    return path;
}


#pragma mark -- 合成数据源
- (BOOL)makeUpDataArray
{
    // 本地json文件 用于查找问题文本 等信息
    
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
    {
        return NO;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    NSDictionary *mainDic = [jsonDict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSDictionary *current_Part_Dic = [[mainDic objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    
    // 关卡1资源构成
    NSArray *question_array_point_1 = [[[current_Part_Dic objectForKey:@"levellist"] objectAtIndex:0] objectForKey:@"questionlist"];
    _score_array_point_1 = [[NSMutableArray alloc]init];
    _text_array_point_1 = [[NSMutableArray alloc]init];
    for (NSDictionary *subdic in question_array_point_1)
    {
        NSArray *answer_array = [subdic objectForKey:@"answerlist"];
        for (NSDictionary *subsubDic in answer_array)
        {
            NSString *answerId = [subsubDic objectForKey:@"id"];
            NSString *answerText = [subsubDic objectForKey:@"answer"];
            [_text_array_point_1 addObject:answerText];
            
            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:1])
            {
                PracticeBookRecord *record = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:1];
                [_score_array_point_1 addObject:record];
            }
            
        }
    }
    
    NSArray *question_array_point_2 = [[[current_Part_Dic objectForKey:@"levellist"] objectAtIndex:1] objectForKey:@"questionlist"];
    
    _score_array_point_2 = [[NSMutableArray alloc]init];
    _text_array_point_2 = [[NSMutableArray alloc]init];
    for (NSDictionary *subdic in question_array_point_2)
    {
        NSArray *answer_array = [subdic objectForKey:@"answerlist"];
        for (NSDictionary *subsubDic in answer_array)
        {
            NSString *answerId = [subsubDic objectForKey:@"id"];
            NSString *answerText = [subsubDic objectForKey:@"answer"];
            [_text_array_point_2 addObject:answerText];
            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:2])
            {
                PracticeBookRecord *record = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerId partNum:[OralDBFuncs getCurrentPart] andLevelNum:2];
                [_score_array_point_2 addObject:record];
            }
        }
    }
    
    
    NSArray *question_array_point_3 = [[[current_Part_Dic objectForKey:@"levellist"] lastObject] objectForKey:@"questionlist"];
    _text_array_point_3 = [[NSMutableArray alloc]init];
    for (int i = 0; i < question_array_point_3.count; i ++)
    {
        NSDictionary *point_3_dic = [question_array_point_3 objectAtIndex:i];
        NSString *questionText = [point_3_dic objectForKey:@"question"];
        NSString *questionID = [point_3_dic objectForKey:@"id"];
        NSString *answerAudioPath = [NSString stringWithFormat:@"%@/part%d-3-%d.wav",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES],[OralDBFuncs getCurrentPart],i+1];
        NSLog(@"%@",answerAudioPath);
        // 此处获取时长
        float duration = [self getAudioDurationWithPath:answerAudioPath];
        NSDictionary *makeDic = @{@"question":questionText,@"questionid":questionID,@"answerPath":answerAudioPath,@"duration":[NSNumber numberWithFloat:duration]};
        [_text_array_point_3 addObject:makeDic];
    }
    return YES;
}

#pragma mark -- 获取本地音频时长
- (float)getAudioDurationWithPath:(NSString *)audioPath
{
    NSLog(@"%@",audioPath);
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioPath];
    AVURLAsset *audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    NSLog(@"获取本地音频时长:%f",audioDurationSeconds);
    return audioDurationSeconds;
}

#pragma mark - UIConfig
#pragma mark -- 创建关卡切换按钮
- (void)createBaseControls
{
    UIView *topPointBUttonView = [[UIView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+1, kScreentWidth, kTopViewHeight)];
    topPointBUttonView.backgroundColor = _backgroundViewColor;
    [self.view addSubview:topPointBUttonView];
    
    for (int i = 0; i < 3; i ++)
    {
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pointButton setFrame:CGRectMake(i*kPointButtonWidth, 0, kPointButtonWidth, kTopViewHeight)];
        [pointButton setTitle:[NSString stringWithFormat:@"Part%d-%d",[OralDBFuncs getCurrentPart],i+1] forState:UIControlStateNormal];
        [pointButton setTitleColor:_pointColor forState:UIControlStateSelected];
        [pointButton setTitleColor:_textColor forState:UIControlStateNormal];
        
        pointButton.tag = kPointButtonTag + i;
        pointButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_normal];
        [pointButton addTarget:self action:@selector(pointButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topPointBUttonView addSubview:pointButton];
        if (i == 0)
        {
            pointButton.selected = YES;
            pointButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
        }
    }
    
    // 滚动视图 scrollview
    
    _point_scroll_View = [[UIScrollView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+kTopViewHeight, kScreentWidth, kScreenHeight-KNavTopViewHeight-kTopViewHeight-1)];
    _point_scroll_View.tag = kPointScrollViewTag;
    _point_scroll_View.contentSize = CGSizeMake(kScreentWidth*3, kScreenHeight-89);
    _point_scroll_View.delegate = self;
    _point_scroll_View.backgroundColor = _backgroundViewColor;
    _point_scroll_View.pagingEnabled = YES;
    [self.view addSubview:_point_scroll_View];
    
    _point_scroll_View.showsHorizontalScrollIndicator = NO;
    _point_scroll_View.showsVerticalScrollIndicator = NO;
    
    for (int i = 0; i < 3; i ++)
    {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i*kScreentWidth, 0, kScreentWidth, _point_scroll_View.bounds.size.height) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag  = kTableViewBaseTag+i;
        tableView.backgroundColor = _backgroundViewColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [_point_scroll_View addSubview:tableView];
    }
}

#pragma mark -- 关卡按钮被点击
- (void)pointButtonClicked:(UIButton *)btn
{
    [self changePointButtonSelected:btn.tag-kPointButtonTag];
    [UIView animateWithDuration:0.5 animations:^{
        _point_scroll_View.contentOffset = CGPointMake(kScreentWidth*(btn.tag - kPointButtonTag), 0);
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
            newBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
        }
        else
        {
            newBtn.selected = NO;
            newBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_normal];
        }
    }
}
#pragma mark -- 创建区头视图
- (Point_3_Section_Head_View *)create_point3_section_view_Tag:(NSInteger)viewTag andInfoDict:(NSDictionary *)dict
{
    // 计算文字大小
    NSString *text = [[_text_array_point_3 objectAtIndex:viewTag] objectForKey:@"question"];
    CGRect rect = [NSString CalculateSizeOfString:text Width:(kScreentWidth-30) Height:9999 FontSize:kFontSize_14];
    
    Point_3_Section_Head_View *sec_head_View = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Section_Head_View" owner:self options:0] lastObject];
    sec_head_View.tag = viewTag+kSectionHeadPoint3Tag;
    sec_head_View.question_label.text = text;
    if (rect.size.height>25)
    {
        [sec_head_View setFrame:CGRectMake(0, 0, kScreentWidth, 60+(rect.size.height-25))];
    }
    else
    {
        [sec_head_View setFrame:CGRectMake(0, 0, kScreentWidth, 60)];
    }
    sec_head_View.back_button.tag = kPoint3_Section_BackBtn_Tag + viewTag;
    [sec_head_View.back_button addTarget:self action:@selector(openPoint_3_SelectedCell:) forControlEvents:UIControlEventTouchUpInside];
    [sec_head_View bringSubviewToFront:sec_head_View.markLabel];
    
    
    if (_review_point_3)
    {
        sec_head_View.markLabel.hidden = YES;
    }
    else
    {
        sec_head_View.markLabel.hidden = NO;
        sec_head_View.markLabel.text = @"点开看看自己的回答情况吧";
        sec_head_View.text_review_imgV.hidden = YES;
        sec_head_View.audio_review_imgV.hidden = YES;
    }

    
    
    return sec_head_View;
}

#pragma mark -- 判断point1、2是否有成绩
- (void)notHaveScoreMenu
{
    UITableView *tableV_point_1 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag];
    UITableView *tableV_point_2 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+1];
    if (_score_array_point_1.count==0)
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, tableV_point_1.frame.size.height-tableV_point_1.frame.origin.y)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = kPart_Button_Color;
        lab.font = [UIFont systemFontOfSize:kFontSize_normal];
        lab.text = @"暂无成绩";
        tableV_point_1.tableHeaderView = lab;
    }
    
    if (_score_array_point_2.count==0)
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, tableV_point_2.frame.size.height-tableV_point_2.frame.origin.y)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = kPart_Button_Color;
        lab.font = [UIFont systemFontOfSize:kFontSize_normal];
        lab.text = @"暂无成绩";
        tableV_point_2.tableHeaderView = lab;
    }
}

#pragma mark -- 关卡3 无成绩头视图
- (void)setPoint_3_table_head_view_notPracticed
{
    UITableView *tableV_point_3 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, tableV_point_3.frame.size.height-tableV_point_3.frame.origin.y)];
    lab.text = @"暂无成绩";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = kPart_Button_Color;
    lab.font = [UIFont systemFontOfSize:kFontSize_normal];
    tableV_point_3.tableHeaderView = lab;
}

#pragma mark -- 关卡3 已提交头视图
- (void)setPoint_3_commited_head_view
{
    UITableView *tableV_point_3 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
    _commit_Head_View = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Commit_View" owner:self options:0] lastObject];
    [_commit_Head_View.commit_Button setTitle:@"已提交" forState:UIControlStateNormal];
    [_commit_Head_View.commit_Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commit_Head_View.commit_Button.enabled = NO;
    _commit_Head_View.commit_des_Label.text = @"已提交给老师，请耐心等待老师反馈~~~~";
    _commit_Head_View.commit_des_Label.textColor = kPart_Button_Color;
    tableV_point_3.tableHeaderView = _commit_Head_View;
}

#pragma mark -- 关卡3 未提交头视图
- (void)setPoint_3_notcommited_head_view
{
    UITableView *tableV_point_3 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
    _commit_Head_View = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Commit_View" owner:self options:0] lastObject];
    _commit_Head_View.commit_des_Label.text = @"提交你的回答给老师吧，会有很大的提高哦~~~";
    _commit_Head_View.commit_des_Label.textColor = kPart_Button_Color;

    [_commit_Head_View.commit_Button setTitle:@"提交" forState:UIControlStateNormal];
    [_commit_Head_View.commit_Button setTitleColor:kPart_Button_Color forState:UIControlStateNormal];
    [_commit_Head_View.commit_Button addTarget:self action:@selector(commitCurrentPart:) forControlEvents:UIControlEventTouchUpInside];
    tableV_point_3.tableHeaderView = _commit_Head_View;
}


#pragma mark - 展开
#pragma mark -- 展开cell
- (void)openPoint_3_SelectedCell:(UIButton *)btn
{
    _open = YES;
    _openIndex = (int)(btn.tag - kPoint3_Section_BackBtn_Tag);
    UITableView *tabV = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
    [tabV reloadData];
}

#pragma mark -- 展开老师总评
- (void)openTeacherSumReview:(UITapGestureRecognizer *)tap
{
    UITableView *point_3_tableV = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
    if (_review_point_3)
    {
        point_3_tableV.tableHeaderView = [self openedViewOfPoint_3_reviewedWithDict:_review_sum_dict];
    }
}
#pragma mark -- 展开后总评价 界面
static UIView *openView;
- (UIView *)openedViewOfPoint_3_reviewedWithDict:(NSDictionary *)dic
{
    if (openView == nil)
    {
        openView = [[UIView alloc]init];
    }

    BOOL _review_text=NO;
    NSInteger reviewWidth = 90;
    NSInteger reviewHeight = 35;
    NSInteger viewHeight = 130;
    // 判断 是文字还是音频
    if ([[dic objectForKey:@"teacherurl"] length])
    {
        // 音频
    }
    else
    {
        _review_text = YES;
        // 文字
        NSString *reviewText = [dic objectForKey:@"teacherevaluate"];
        // 计算文字大小
        CGRect rect_1 = [NSString CalculateSizeOfString:reviewText Width:99999 Height:15 FontSize:kFontSize_14];
        // 两种情况 1、宽度小于1行 2、多行
        if (rect_1.size.width>(kScreentWidth-90))
        {
            // 2 、 多行
            CGRect rect_2 = [NSString CalculateSizeOfString:reviewText Width:(kScreentWidth-90) Height:99999 FontSize:kFontSize_14];
            viewHeight = 130+rect_2.size.height-reviewHeight;
            reviewHeight = round(rect_2.size.height);
        }
        else
        {
            // 1、1行
            reviewWidth = round(rect_1.size.width)+20;
            reviewHeight = 35;
            viewHeight = 130;
        }
    }
    
    [openView setFrame:CGRectMake(0, 0, kScreentWidth, viewHeight)];
    openView.backgroundColor = [UIColor whiteColor];
    
    UILabel *desLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, kScreentWidth-105, 30)];
    desLab.text = @"老师给你综合评价喽~快点开看看吧~~";
    desLab.textColor = kPart_Button_Color;
    desLab.font =[UIFont systemFontOfSize:kFontSize_14];
    [openView addSubview:desLab];
    
    UIButton *scoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scoreBtn setFrame:CGRectMake(kScreentWidth-75, 15, 60, 40)];
    scoreBtn.layer.masksToBounds = YES;
    scoreBtn.layer.cornerRadius = scoreBtn.frame.size.height/2;
    scoreBtn.backgroundColor = kPart_Button_Color;
    [scoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scoreBtn setTitle:[NSString stringWithFormat:@"%.1f",[[_review_dict_point_3 objectForKey:@"score"] floatValue]] forState:UIControlStateNormal];
    scoreBtn.titleLabel.font =  [UIFont systemFontOfSize:kFontSize_16];
    [openView addSubview:scoreBtn];
    
   
    
    UIImageView *reviewImgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 50, 20, 15)];
    [openView addSubview:reviewImgV];
    
    
    UIButton *teacherHeadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [teacherHeadBtn setFrame:CGRectMake(15, 75, 45, 45)];
    [teacherHeadBtn setBackgroundImage:[UIImage imageNamed:@"class_teacher_head"] forState:UIControlStateNormal];
    [teacherHeadBtn setImageWithURL:[NSURL URLWithString:[_review_dict_point_3 objectForKey:@"teachericon"]] placeholderImage:[UIImage imageNamed:@"class_teacher_head"]];
    
    teacherHeadBtn.layer.masksToBounds = YES;
    teacherHeadBtn.layer.cornerRadius = teacherHeadBtn.frame.size.height/2;
    [openView addSubview:teacherHeadBtn];
    
    UIImageView *spotImgV = [[UIImageView alloc]initWithFrame:CGRectMake(65, 95, 5, 5)];
    spotImgV.backgroundColor = kPart_Button_Color;
    spotImgV.layer.masksToBounds = YES;
    spotImgV.layer.cornerRadius = spotImgV.frame.size.height/2;
    [openView addSubview:spotImgV];
    
    UIButton *reviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reviewBtn setFrame:CGRectMake(75, 80, reviewWidth, reviewHeight)];
    reviewBtn.backgroundColor = kPart_Button_Color;
    reviewBtn.layer.masksToBounds = YES;
    float ratio = reviewHeight>35?5:reviewBtn.frame.size.height/2;
    reviewBtn.layer.cornerRadius = ratio;
    reviewBtn.titleLabel.font =[UIFont systemFontOfSize:kFontSize_14];
    
    reviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    reviewBtn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10);
    
    [openView addSubview:reviewBtn];
    
    if (_review_text)
    {
        // 文字
        [reviewBtn setTitle:[dic objectForKey:@"teacherevaluate"] forState:UIControlStateNormal];
        [reviewImgV setImage:[UIImage imageNamed:@"Text_review"]];
    }
    else
    {
        [reviewImgV setImage:[UIImage imageNamed:@"audio_review"]];
        int time = round([[dic objectForKey:@"teacherurllength"] floatValue]/1000);
        [reviewBtn setTitle:[NSString stringWithFormat:@"%d\"",time] forState:UIControlStateNormal];
        [reviewBtn addTarget:self action:@selector(playSumReview:) forControlEvents:UIControlEventTouchUpInside];
    }
    return openView;
}

#pragma mark - 播放
#pragma mark -- 播放总评
- (void)playSumReview:(UIButton *)btn
{
    // 播放评价音频 -- 待完善
    NSString *reviewUrl = [_review_sum_dict objectForKey:@"teacherurl"];
    NSString *reviewPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPoint3UnZipPath],reviewUrl];
    NSLog(@"老师评价的音频路径：%@。。。。。\n",reviewPath);
    [_audioPlayerManager playerPlayWithFilePath:reviewPath];
}

#pragma mark -- 播放自己回答录音
- (void)playerSelfAnswer:(UIButton*)btn
{
    NSLog(@"播放自己回答录音");
    NSInteger index = btn.tag - kPlaySelfButtonTag;
    // 播放
    NSDictionary *dic = [_text_array_point_3 objectAtIndex:index];
    NSString *audioPath = [dic objectForKey:@"answerPath"];
    NSLog(@"%@",audioPath);
    [_audioPlayerManager playerPlayWithFilePath:audioPath];
}
#pragma mark -- 播放老师评价
- (void)playReviewAudio:(UIButton *)btn
{
    NSInteger index = btn.tag - kTeacherReviewButtonTAg;
    NSString *questionId = [[_text_array_point_3 objectAtIndex:index] objectForKey:@"questionid"];
    NSDictionary *selecDic = [self retrievalReviewDictWithQuestionID:questionId];
    NSString *reviewUrl = [selecDic objectForKey:@"teacherurl"];
    NSString *reviewPath = [NSString stringWithFormat:@"%@/temp/%@",[self getPoint3UnZipPath],reviewUrl];
    NSLog(@"老师评价的音频路径：%@。。。。。\n",reviewPath);
}

#pragma mark -- 播放完成回调
- (void)playerCallBack:(AudioPlayer *)audioPlayer
{
    NSLog(@"playfinished");
}


#pragma mark - 加载View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:[OralDBFuncs getCurrentTopic]];
    
    // 音频播放器
    _audioPlayerManager = [AudioPlayer getAudioManager];
    _audioPlayerManager.target = self;
    _audioPlayerManager.action = @selector(playerCallBack:);
    
    // 创建滚动列表控件 等等
    [self createBaseControls];
    BOOL analysizeSucess = [self makeUpDataArray];
    [self notHaveScoreMenu];
    
    if (analysizeSucess)
    {
        // 解析成功
        // 是否练习过 关卡3
        _exit_point_3 = [OralDBFuncs getPartLevel3PracticeedwithTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
        // 是否提交
        _commited = [OralDBFuncs getPartLevel3CommitwithTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
        // 关卡3 列表控件
        UITableView *tableV_point_3 = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
        if (_exit_point_3)// 练习过关卡3
        {
            // 反馈头视图
            _review_Head_View = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Review_Head_View" owner:self options:0] lastObject];
            
            // 反馈头视图点击事件
            UITapGestureRecognizer *tap_review = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openTeacherSumReview:)];
            [_review_Head_View addGestureRecognizer:tap_review];
            // 循环创建区头视图 加入数组
            _section_array_point_3 = [[NSMutableArray alloc]init];
            for (int i = 0; i < _text_array_point_3.count; i ++)
            {
                [_section_array_point_3 addObject:[self create_point3_section_view_Tag:i andInfoDict:nil]];
            }
            if (_commited)// 已提交
            {
                // 已提交
                [self setPoint_3_commited_head_view];
                if (_review_point_3)// 已反馈
                {
                    tableV_point_3.tableHeaderView = _review_Head_View;
                    // 网络请求
                    [self requestLevel_3_watingInfo];
                }
            }
            else
            {
                // 未提交 可查看自己的回答音频等信息
                [self setPoint_3_notcommited_head_view];
            }
        }
        else // 未练习过
        {
            // 设置未练习头视图 （提示用户暂无成绩）
            [self setPoint_3_table_head_view_notPracticed];
        }
    }
    else
    {
        // 本地文件不存在 没有成绩单
        NSLog(@"本地文件不存在 没有成绩单");
        [self setPoint_3_table_head_view_notPracticed];
    }
}

#pragma mark - 提交
#pragma mark -- 提交按钮被点击
- (void)commitCurrentPart:(UIButton *)btn
{
    [self jugeCouldCommit_Part];
}

#pragma mark -- 判断是否可以直接提交
- (void)jugeCouldCommit_Part
{
    if ([OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]])
    {
        // 有默认老师
        _defaulTeacherID = [OralDBFuncs getDefaultTeacherIDForUserName:[OralDBFuncs getCurrentUserName]];
        [self jugeNetState];
    }
    else
    {
        MyTeacherViewController *myTeacherVC = [[MyTeacherViewController alloc]initWithNibName:@"MyTeacherViewController" bundle:nil];
        myTeacherVC.delegate = self;
        [self.navigationController pushViewController:myTeacherVC animated:YES];
    }
}

#pragma mark -- 开始提交
- (void)starCommitToTeacher_point_3
{
    // 提交给老师
    if ([self makeUpJsonFile])
    {
        _loading_View.hidden = NO;
        [self.view bringSubviewToFront:_loading_View];
        NSString *zipPath =  [self zipCurrentPartFile];
        NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
        // 网络提交 uploadfile
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kPartCommitUrl];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"part" forKey:@"uploadfile"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             if (zipData)
             {
                 [formData appendPartWithFileData:zipData name:@"uploadfile" fileName:@"part.zip" mimeType:@"application/zip"];
             }
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             _loading_View.hidden = YES;
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
             NSLog(@"%@",dic);
             if ([[dic objectForKey:@"respCode"] intValue] == 1000)
             {
                 // 标记 关卡3已经提交
                 [OralDBFuncs setPartLevel3Commit:YES withTopic:[OralDBFuncs getCurrentTopic] andUserName:[OralDBFuncs getCurrentUserName] PartNum:[OralDBFuncs getCurrentPart]];
                 _commited = YES;
                 [_commit_Head_View.commit_Button setTitle:@"已提交" forState:UIControlStateNormal];
             }
             else
             {
                 NSLog(@"提交失败");
                 NSLog(@"%@",[dic objectForKey:@"remark"]);
                 [self commitFail_point_3];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             _loading_View.hidden = YES;
             [self commitFail_point_3];
             NSLog(@"失败乃");
         }];
    }
    else
    {
        // 合成json文件失败
    }
}


#pragma mark -- 构成json文件
- (BOOL)makeUpJsonFile
{
    NSString *jsonPath_local = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    NSData *jsonData_local = [NSData dataWithContentsOfFile:jsonPath_local];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData_local options:0 error:nil];
    // 整个topic资源信息
    NSDictionary *mainDic = [dict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSDictionary *curentPartDic = [[mainDic objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    
    NSString *topicid = [OralDBFuncs getCurrentTopicID];
    // 获取闯关分数 前两关
    TopicRecord *record = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]];
    NSMutableArray *checkPoint = [[NSMutableArray alloc]init];
    for (int i = 0; i < 3; i ++)
    {
        NSDictionary *levelDic = [[curentPartDic objectForKey:@"levellist"] objectAtIndex:i];
        NSString *level = [NSString stringWithFormat:@"%d",[[levelDic objectForKey:@"level"] intValue]];
        NSString *levelid = [levelDic objectForKey:@"id"];
        
        int currentPart = [OralDBFuncs getCurrentPart];
        int currentPoint = i+1;
        int score = [self getScoreWithPart:currentPart Point:currentPoint Record:record];
        NSString *pass_mark;
        if (i < 2)
        {
            pass_mark = @"通关";
        }
        else
        {
            pass_mark = @"未通关";
        }
        NSDictionary *subDic = @{@"ifsubmitteacher":@"否",@"level":level,@"levelid":levelid,@"score":[NSNumber numberWithInt:score],@"status":pass_mark,@"topicid":topicid,@"userid":[OralDBFuncs getCurrentUserID]};
        [checkPoint addObject:subDic];
    }
    
    NSArray *partInfoArray = [OralDBFuncs getTopicAnswerJsonArrayWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:YES];
    
    NSDictionary *finalDict = @{@"partInfo":partInfoArray,@"checkPoint":checkPoint,@"teacherid":_defaulTeacherID};
    NSLog(@"%@",finalDict);
    
    NSError *parseError = nil;
    NSData *jsonData_makeUped = [NSJSONSerialization dataWithJSONObject:finalDict options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/part.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    BOOL saveSuc = [jsonData_makeUped writeToFile:jsonFilePath atomically:YES];
    return saveSuc;
}

#pragma mark -- 压缩zip包
- (NSString *)zipCurrentPartFile
{
    NSString *zipPath = [NSString stringWithFormat:@"%@/part.zip",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = [zip CreateZipFile2:zipPath];
    if (ret)
    {
        NSArray *recordArray = [OralDBFuncs getTopicAnswerZipArrayWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName] ISPart:YES];
        for (NSString *audioPath  in recordArray)
        {
            NSString *audioName = [[audioPath componentsSeparatedByString:@"/"] lastObject];
            [zip addFileToZip:audioPath newname:audioName];
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@/part.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
        [zip addFileToZip:jsonPath newname:@"part.json"];
    }
    NSLog(@"%@",zipPath);
    return zipPath;
}

#pragma mark -- 获取关卡1和2分数
- (int)getScoreWithPart:(int)currentPart Point:(int)point Record:(TopicRecord *)record
{
    switch (currentPart)
    {
        case 1:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p1_1;
                }
                    break;
                case 2:
                {
                    return  record.p1_2;
                }
                    break;
                case 3:
                {
                    return record.p1_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p2_1;
                }
                    break;
                case 2:
                {
                    return record.p2_2;
                }
                    break;
                case 3:
                {
                    return record.p2_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (point)
            {
                case 1:
                {
                    return record.p3_1;
                }
                    break;
                case 2:
                {
                    return record.p3_2;
                }
                    break;
                case 3:
                {
                    return record.p3_3;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return 0;
}


#pragma mark -- 检测网络状态 参数：yes 请求part资源信息  no test资源信息
- (void)jugeNetState
{
    BOOL net_wifi = [OralDBFuncs getNet_WiFi_Download];
    BOOL net_2g3g4g = [OralDBFuncs getNet_2g3g4g_Download];
    
    switch ([DetectionNetWorkState netStatus])
    {
        case NotReachable:
        {
            // 无网络状态
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前无网络链接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case ReachableViaWiFi:
        {
            // wifi
            [self starCommitToTeacher_point_3];
        }
            break;
        case ReachableViaWWAN:
        {
            // 2g3g4g
            if (net_2g3g4g)
            {
                [self starCommitToTeacher_point_3];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"当前网络为2g/3g/4g网络，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续",nil];
                [alertView show];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 选择老师回调
- (void)selectTeacherId:(NSString *)teacherID
{
    _defaulTeacherID = teacherID;
    [self jugeNetState];
}


#pragma mark -- 警告框 delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex == 1)
    {
        [self starCommitToTeacher_point_3];
    }
}

#pragma mark -- 提交失败警告框
- (void)commitFail_point_3
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"提交失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

#pragma mark - 网络
#pragma mark -- 请求已处理信息
- (void)requestLevel_3_watingInfo
{
    NSString *urlSTr = [NSString stringWithFormat:@"%@%@?waitingid=%@",kBaseIPUrl,kReviewWatingEvent,[_review_dict_point_3 objectForKey:@"waitingid"]];
    NSLog(@"%@",urlSTr);
    [NSURLConnectionRequest requestWithUrlString:urlSTr target:self aciton:@selector(request_point_3_CallBack:) andRefresh:YES];
}

#pragma mark -- 网络请求反馈
- (void)request_point_3_CallBack:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            // 请求闯关反馈成功
            NSString *zipUrl = [dict objectForKey:@"zipfileurl"];
            [NSURLConnectionRequest requestWithUrlString:zipUrl target:self aciton:@selector(requestPointZip:) andRefresh:YES];
        }
    }
}

#pragma mark -- 请求zip回调
- (void)requestPointZip:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSData *zipData = request.downloadData;
        BOOL unzip = [self unZipReviewData:zipData];
        if (unzip)
        {
            // 解压成功 刷新界面
            NSLog(@"解压成功 刷新界面");
            _requestReviewSuccess = YES;
            [self analysizePartJson];
            UITableView *tabV = (UITableView *)[self.view viewWithTag:kTableViewBaseTag+2];
            tabV.tableHeaderView = _review_Head_View;
            [tabV reloadData];
        }
        else
        {
            NSLog(@"失败");
        }
    }
}

#pragma mark -- 解压zip包
- (BOOL)unZipReviewData:(NSData*)zipData
{
    // 存储zip包路径
    NSString *zipSavePath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
    NSLog(@"存储zip包路径:%@",zipSavePath);
    if (![[NSFileManager defaultManager]fileExistsAtPath:zipSavePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:zipSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL zipSaveSuccess = [zipData writeToFile:[NSString stringWithFormat:@"%@/PartReview.zip",zipSavePath] atomically:YES];
    
    if (zipSaveSuccess)
    {
        // 保存zip包成功 解压zip路径
        NSString *zipToPath = [NSString stringWithFormat:@"%@/Documents/%@/PartReview",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:zipToPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:zipToPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSLog(@"~~~~~%@~~~~~~~",zipToPath);
        [ZipManager unzipFileFromPath:[NSString stringWithFormat:@"%@/PartReview.zip",zipSavePath] ToPath:zipToPath];
        return YES;
    }
    else
    {
        // 保存失败
        return NO;
    }
}

#pragma mark -- 解析本地json
- (void)analysizePartJson
{
    NSString *partReviewPath = [NSString stringWithFormat:@"%@/Documents/%@/PartReview/temp/waitinginfo.json",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
    NSData *data = [NSData dataWithContentsOfFile:partReviewPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    _score_array_point_3 = [dict objectForKey:@"teacheranswerlist"];
    for (NSDictionary *subdic in _score_array_point_3)
    {
        if (![[subdic objectForKey:@"questionid"] length])
        {
            NSLog(@"%@",[subdic objectForKey:@"questionid"]);
            _review_sum_dict = subdic;
        }
    }
    NSString *scoreStr = [NSString stringWithFormat:@"%.1f",[[_review_sum_dict objectForKey:@"score"] floatValue]];
    [_review_Head_View.review_score_button setTitle:scoreStr forState:UIControlStateNormal];
    if ([[_review_sum_dict objectForKey:@"teacherurl"] length])
    {
        [_review_Head_View.review_Tip_ImgV setImage:[UIImage imageNamed:@"audio_review"]];
    }
    else
    {
        [_review_Head_View.review_Tip_ImgV setImage:[UIImage imageNamed:@"Text_review"]];
    }
}



#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kTableViewBaseTag+2)
    {
        // point3
        if (_exit_point_3)
        {
            return _text_array_point_3.count;
        }
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag-kTableViewBaseTag)
    {
        case 0:
        {
            // point 1
            return _score_array_point_1.count;
        }
            break;
        case 1:
        {
            // point 2
            return _score_array_point_2.count;
        }
            break;
        case 2:
        {
            // point 3
            if (_exit_point_3)
            {
                return 1;
            }
            return 0;
        }
            break;
        default:
            break;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag - kTableViewBaseTag == 2)
    {
        return ((UIView *)[_section_array_point_3 objectAtIndex:section]).frame.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kTableViewBaseTag+2)
    {
        Point_3_Section_Head_View *view = [_section_array_point_3 objectAtIndex:section];
        if (_review_point_3&&_requestReviewSuccess)//已反馈
        {
            view.markLabel.hidden = YES;
            view.text_review_imgV.hidden = NO;
            view.audio_review_imgV.hidden = YES;
            NSString *questionID = [[_text_array_point_3 objectAtIndex:section] objectForKey:@"questionid"];
            NSDictionary *subDic = [self retrievalReviewDictWithQuestionID:questionID];
            if ([[subDic objectForKey:@"teacherurl"] length])
            {
                // 语音评价 大小不变
                [view.text_review_imgV setImage:[UIImage imageNamed:@"audio_review"]];
            }
            else if([[subDic objectForKey:@"teacherevaluate"] length])
            {
                // 文字评价 根据文字大小改变frame
                [view.text_review_imgV setImage:[UIImage imageNamed:@"Text_review"]];
            }
        }
        else
        {
            if (_open&&_openIndex == section)
            {
                view.markLabel.hidden = YES;
            }
            else
            {
                view.markLabel.hidden = NO;
            }
        }
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *linLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 1)];
    return linLab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag-kTableViewBaseTag) {
        case 0:
        {
            NSString *text = [_text_array_point_1 objectAtIndex:indexPath.row];
            CGRect rect = [NSString CalculateSizeOfString:[self filterHTML:text] Width:kScreentWidth-75 Height:9999 FontSize:kFontSize_17];
            if (rect.size.height>50)
            {
                return 75+(int)rect.size.height-50;
            }
            return 75;
        }
            break;
        case 1:
        {
            NSString *text = [_text_array_point_2 objectAtIndex:indexPath.row];
            CGRect rect = [NSString CalculateSizeOfString:[self filterHTML:text] Width:kScreentWidth-80 Height:9999 FontSize:kFontSize_17];
            if (rect.size.height>50)
            {
                return 75+(int)rect.size.height-50;
            }
            return 75;
        }
            break;
        case 2:
        {
            if (_open&& _openIndex == indexPath.section)
            {
                if (_review_point_3&&_commited)
                {
                    // 已反馈
                    NSString *questionID = [[_text_array_point_3 objectAtIndex:indexPath.section] objectForKey:@"questionid"];
                    NSDictionary *subDic = [self retrievalReviewDictWithQuestionID:questionID];
                    if ([[subDic objectForKey:@"teacherurl"] length])
                    {
                        // 语音评价 大小不变
                        return 120;
                    }
                    else if([[subDic objectForKey:@"teacherevaluate"] length])
                    {
                       // 文字评价 根据文字大小改变frame
                        NSString *reviewText = [subDic objectForKey:@"teacherevaluate"];

                        CGRect rect = [NSString CalculateSizeOfString:reviewText Width:kScreentWidth-30 Height:99999 FontSize:kFontSize_14];
                        if (rect.size.height>25)
                        {
                            return rect.size.height-25+120;
                        }
                    }
                    return 120;
                }
                else
                {
                    return 60;
                }
            }
            return 0;
        }
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag - kTableViewBaseTag)
    {
        case 0:
        {
            // point 1 跟读 此处cell 可重复利用闯关成功页面cell
            static NSString *cellId = @"successCell_point1";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            PracticeBookRecord *record = [_score_array_point_1 objectAtIndex:indexPath.row];
            [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
            [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
            NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
            NSInteger index = record.lastScore>=80?0:(record.lastScore>=60?1:2);
            cell.scoreButton.backgroundColor =  [colorArr objectAtIndex:index];
            return cell;
        }
            break;
        case 1:
        {
            static NSString *cellId = @"ScoreMenuCell_point2";
            ScoreMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ScoreMenuCell" owner:self options:0] lastObject];
            }
            PracticeBookRecord *record = [_score_array_point_2 objectAtIndex:indexPath.row];
            [cell.textWebView loadHTMLString:record.lastText baseURL:nil];
            [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
            NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
            NSInteger index = record.lastScore>=80?0:(record.lastScore>=60?1:2);
            cell.scoreButton.backgroundColor =  [colorArr objectAtIndex:index];
            return cell;
        }
            break;
        case 2:
        {
            if (_review_point_3&&_commited)// 已反馈
            {
                static NSString *cellId = @"Point_3_Review_Cell";
                Point_3_Review_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Review_Cell" owner:self options:0] lastObject];
                }
                NSDictionary *userAnswerDic = [_text_array_point_3 objectAtIndex:indexPath.section];
                [cell.player_button setTitle:[NSString stringWithFormat:@"%.1f\"",round([[userAnswerDic objectForKey:@"duration"] floatValue]) ] forState:UIControlStateNormal];
                // 用户自己的头像
                [cell.stu_head_imgV setImage:[UIImage imageNamed:@"person_head_image"]];
                
                cell.player_button.tag = indexPath.section + kPlaySelfButtonTag;
                [cell.player_button addTarget:self action:@selector(playerSelfAnswer:) forControlEvents:UIControlEventTouchUpInside];
                // 老师反馈
                NSDictionary *reviewDic = [_score_array_point_3 objectAtIndex:indexPath.section];
                // 老师头像
                [cell.tea_head_imgV setImageWithURL:[NSURL URLWithString:[_review_dict_point_3 objectForKey:@"teachericon"]] placeholderImage:[UIImage imageNamed:@"class_teacher_head"]];
                if ([[reviewDic objectForKey:@"teacherurl"] length])
                {
                    // 语音评价 可播放
                    NSString *timeDuration = [NSString stringWithFormat:@"%d\"",[[reviewDic objectForKey:@"teacherurllength"] intValue]/1000];
                    [cell.tea_review_button setTitle:timeDuration forState:UIControlStateNormal];
                    cell.tea_review_button.tag = indexPath.row + kTeacherReviewButtonTAg;
                    [cell.tea_review_button addTarget:self action:@selector(playReviewAudio:) forControlEvents:UIControlEventTouchUpInside];
                }
                else if ([[reviewDic objectForKey:@"teacherevaluate"] length])
                {
                    NSString *review_text = [reviewDic objectForKey:@"teacherevaluate"];
                    [cell.tea_review_button setTitle:review_text forState:UIControlStateNormal];

                    // 计算文字大小
                    CGRect rect_1 = [NSString CalculateSizeOfString:review_text Width:99999 Height:15 FontSize:kFontSize_14];
                    
                    // 两种情况 1、宽度小于1行 2、多行
                    CGRect oraginalRect = cell.tea_review_button.frame;
                    if (rect_1.size.width>(kScreentWidth-90)){
                        // 2 、 多行
                        CGRect rect_2 = [NSString CalculateSizeOfString:review_text Width:(kScreentWidth-90) Height:99999 FontSize:kFontSize_14];
                        if (rect_2.size.height>35){
                            oraginalRect.size.height = rect_2.size.height;
                        }
                        oraginalRect.origin.x = 15;
                        oraginalRect.size.width = kScreentWidth-90;
                        [cell.tea_review_button setFrame:oraginalRect];
                        cell.tea_review_button.layer.cornerRadius = 5;
                    }
                    else{
                        // 1、1行
                        [cell.tea_review_button setFrame:CGRectMake(kScreentWidth-75-rect_1.size.width, oraginalRect.origin.y, rect_1.size.width, 35)];
                    }
                }
                else{
                    [cell.tea_review_button setTitle:@"暂无评价" forState:UIControlStateNormal];
                }
                
                if (_open&&_openIndex==indexPath.section){
                    //
            
                }
                else {
                    cell.hidden = YES;
                }
                return cell;
            }
            else //已提交 未提交 未反馈
            {
                static NSString *cellId = @"Point_3_Commit_cell";
                Point_3_Commit_cell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil)
                {
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"Point_3_Commit_cell" owner:self options:0] lastObject];
                }
                
                NSDictionary *userAnswerDic = [_text_array_point_3 objectAtIndex:indexPath.section];
                [cell.playerButton setTitle:[NSString stringWithFormat:@"%.0f\"",round([[userAnswerDic objectForKey:@"duration"] floatValue]) ] forState:UIControlStateNormal];
                cell.playerButton.tag = indexPath.section + kPlaySelfButtonTag;
                [cell.playerButton addTarget:self action:@selector(playerSelfAnswer:) forControlEvents:UIControlEventTouchUpInside];
                // 用户自己的头像
                [cell.stu_head_imgV setImage:[UIImage imageNamed:@"person_head_image"]];
                if (_open&&_openIndex == indexPath.section)
                {
                    cell.hidden = NO;
                }
                else
                {
                    cell.hidden = YES;
                }
                return cell;
            }
        }
            break;
   
            
        default:
            break;
    }
    return nil;
}

#pragma mark - 去掉html标签
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




#pragma mark - 根据问题id 查找问题的评价
- (NSDictionary *)retrievalReviewDictWithQuestionID:(NSString *)questionid
{
    for (NSDictionary *subDic in _score_array_point_3)
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


#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger count = scrollView.contentOffset.x/kScreentWidth;
    [self changePointButtonSelected:count];
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
