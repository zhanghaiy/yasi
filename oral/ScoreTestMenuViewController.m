//
//  ScoreTestMenuViewController.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreTestMenuViewController.h"
#import "TestReviewCell.h"
#import "NSURLConnectionRequest.h"
#import "OralDBFuncs.h"
#import "ZipManager.h"
#import "UIButton+WebCache.h"

@interface ScoreTestMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_reviewTableV;
    UIView *_headerV;
//    NSArray *_textArray;// 模拟
    NSMutableArray *_review_array;
}
@end

@implementation ScoreTestMenuViewController
#define kHeaderViewHeight 105

#define kCellHeight 100
#define kTextBackBaseWIdth (kScreentWidth-100)
#define kTextBackBaseHeight 34
#define kTextBaseWIdth (kScreentWidth-120)
#define kTextBaseHeight 20
#define kCellFont 12

#pragma mark - 网络
#pragma mark -- 请求当前topic的模考已处理事项
- (void)requestWating
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?waitingid=%@",kBaseIPUrl,kReviewWatingEvent,[_watingDict objectForKey:@"waitingid"]];
    NSLog(@"%@",urlStr);
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestWatingInfo:) andRefresh:YES];
}

#pragma mark -- 请求当前topic的已处理事项  回调
- (void)requestWatingInfo:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        //
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dic objectForKey:@"respCode"] integerValue] == 1000)
        {
            // 请求模考反馈成功 --- 待完善
            NSString *zipUrl = [dic objectForKey:@"zipfileurl"];
            [NSURLConnectionRequest requestWithUrlString:zipUrl target:self aciton:@selector(requestZip:) andRefresh:YES];
        }
    }
}

#pragma mark -- 请求zip回调
- (void)requestZip:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
       BOOL unzip = [self unZipReviewData:request.downloadData];
        if (unzip)
        {
            // 解压成功 刷新界面
            NSLog(@"解压成功 刷新界面");
            [self makeUPReviewArray];
            [_reviewTableV reloadData];
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
    BOOL zipSaveSuccess = [zipData writeToFile:[NSString stringWithFormat:@"%@/testReview.zip",zipSavePath] atomically:YES];
    
    if (zipSaveSuccess)
    {
        // 保存zip包成功 解压zip路径
        NSString *zipToPath = [NSString stringWithFormat:@"%@/Documents/%@/testReview",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
        NSLog(@"~~~~~%@~~~~~~~",zipToPath);
       [ZipManager unzipFileFromPath:[NSString stringWithFormat:@"%@/testReview.zip",zipSavePath] ToPath:zipToPath];
        return YES;
    }
    else
    {
        // 保存失败
        return NO;
    }
}

#pragma mark - 合成数据源
- (void)makeUPReviewArray
{
    _review_array = [[NSMutableArray alloc]init];
    NSString *jsonPath = [NSString stringWithFormat:@"%@/Documents/%@/testReview/temp/waitinginfo.json",NSHomeDirectory(),[OralDBFuncs getCurrentTopic]];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *review_main_dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    /*
     
     teacheranswerlist
     "questionid" : "5DA750E0DE434A5A9CF16E981CC1196F",
     "score" : null,
     "teacherevaluate" : "",
     "teacherurl" : "46726.mp3",
     "teacherurllength" : 6420
     }
     */
    NSArray *teacheranswerlist = [review_main_dic objectForKey:@"teacheranswerlist"];
    for (NSDictionary *subDic in teacheranswerlist)
    {
        if ([[subDic objectForKey:@"questionid"] length]>2)
        {
             [_review_array addObject:subDic];
        }
        else
        {
            // 总评
            [_review_array insertObject:subDic atIndex:0];
        }
    }
    NSLog(@"%@",_review_array);
}

#pragma mark - 根据问题id查找问题文本
- (NSString *)selectQuestionTextWithQuestionID:(NSString *)questionID
{
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/mockinfo.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:NO]];
    NSLog(@"%@",jsonPath);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:jsonPath])
    {
        // 有文件
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary *testDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSArray *QuestionList = [[testDic objectForKey:@"mockquestion"] objectForKey:@"questionlist"];
        for (NSDictionary *subDic in QuestionList)
        {
            NSArray *questionArray = [subDic objectForKey:@"question"];
            for (NSDictionary *subsubDic in questionArray)
            {
                NSString *questionId = [subsubDic objectForKey:@"id"];
                if ([questionID isEqualToString:questionId])
                {
                    return [subsubDic objectForKey:@"question"];
                }
            }
        }
        return @"找不到匹配的问题!";
    }
    else
    {
        return @"本地文件损坏或不存在，找不到问题资源";
    }
}

#pragma mark - 视图加载
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:[OralDBFuncs getCurrentTopic]];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    _reviewTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _reviewTableV.delegate = self;
    _reviewTableV.dataSource = self;
    _reviewTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_reviewTableV];
    
    _reviewTableV.backgroundColor = _backgroundViewColor;
    
    [self requestWating];
}

#pragma mark - 计算文字大小
- (CGRect)getCellHeightWithText:(NSString *)text andWidth:(NSInteger)width Height:(NSInteger)height Font:(NSInteger)fontSize
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return rect;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _review_array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 此处+5 式界面美观 不至于有紧凑感
    NSInteger question_height;
    NSString *question = [self selectQuestionTextWithQuestionID:[[_review_array objectAtIndex:indexPath.section] objectForKey:@"questionid"]];
    CGRect questionRect = [self getCellHeightWithText:question andWidth:(kScreentWidth-40) Height:9999 Font:kFontSize_14];
    if (questionRect.size.height>25)
    {
        question_height = questionRect.size.height-25;
    }
    else
    {
        question_height = 0;
    }
    
    NSDictionary *reviewDic = [_review_array objectAtIndex:indexPath.section];
    if ([reviewDic objectForKey:@"teacherevaluate"])
    {
        NSString *teacherevaluate = [reviewDic objectForKey:@"teacherevaluate"];
        CGRect rect = [self getCellHeightWithText:teacherevaluate andWidth:kTextBaseWIdth Height:9999 Font:kCellFont];
        return ((rect.size.height>kTextBaseHeight)?kCellHeight + rect.size.height-kTextBaseHeight+5:kCellHeight)+question_height;
    }
    return kCellHeight+question_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"TestReviewCell";
    TestReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"TestReviewCell" owner:self options:0] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.reviewLabel.numberOfLines = 0;
    cell.controlsColor = _pointColor;
    cell.reviewLabel.font = [UIFont systemFontOfSize:kCellFont];
    
    NSDictionary *reviewDic = [_review_array objectAtIndex:indexPath.section];

    if (indexPath.section == 0)
    {
        // 综合评价
        cell.titleLabel.text = @"综合评价";
        cell.scoreButton.hidden = NO;
        // 分数颜色 根据分数变化
        cell.scoreButton.backgroundColor = _perfColor;
        [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",[[reviewDic objectForKey:@"score"] intValue]] forState:UIControlStateNormal];
    }
    else
    {
        NSString *questionId = [reviewDic objectForKey:@"questionid"];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@",[self selectQuestionTextWithQuestionID:questionId]];
        cell.titleLabel.numberOfLines = 0;
        
        CGRect questionRect = [self getCellHeightWithText:cell.titleLabel.text andWidth:(kScreentWidth-30) Height:9999 Font:kFontSize_14];
        if (questionRect.size.height>25)
        {
            cell.titleLabel.frame = CGRectMake(15, 10, kScreentWidth-30, questionRect.size.height);
        }
    }
    
    if ([[reviewDic objectForKey:@"teacherevaluate"] length]>=1)
    {
        cell.reviewLabel.text = [reviewDic objectForKey:@"teacherevaluate"];
        CGRect textRec = [self getCellHeightWithText:[reviewDic objectForKey:@"teacherevaluate"] andWidth:kTextBaseWIdth Height:99999 Font:kCellFont];
        if (textRec.size.height>kTextBaseHeight)
        {
            // 多行
            [cell.reviewBackView setFrame:CGRectMake(75, 25+cell.titleLabel.frame.size.height, kTextBackBaseWIdth, textRec.size.height+15)];
            [cell.reviewLabel setFrame:CGRectMake(10, 7, kTextBaseWIdth, textRec.size.height)];
            
            NSInteger head_W = 45;
            NSInteger head_Y = cell.reviewBackView.frame.origin.y+cell.reviewBackView.frame.size.height/2-head_W/2;
            
            NSInteger spot_W = 5;
            NSInteger spot_Y = cell.reviewBackView.frame.origin.y+cell.reviewBackView.frame.size.height/2-spot_W/2;
            
            [cell.headButton setFrame:CGRectMake(15, head_Y, head_W, head_W)];
            [cell.spotImgV setFrame:CGRectMake(20+head_W, spot_Y, spot_W, spot_W)];
        }
        else
        {
            // 一行
            textRec = [self getCellHeightWithText:[reviewDic objectForKey:@"teacherevaluate"] andWidth:9999 Height:15 Font:kCellFont];
            [cell.reviewBackView setFrame:CGRectMake(75, 25+cell.titleLabel.frame.size.height, textRec.size.width+50, 35)];
            [cell.reviewLabel setFrame:CGRectMake(10, 7, textRec.size.width+30, 20)];
        }
    }
    else
    {
        [cell.reviewBackView setFrame:CGRectMake(75, 25+cell.titleLabel.frame.size.height, 100, 35)];
        [cell.reviewLabel setFrame:CGRectMake(10, 7, 80, 20)];
        if ([[reviewDic objectForKey:@"teacherurllength"] isKindOfClass:[NSNull class]])
        {
            cell.reviewLabel.text = [NSString stringWithFormat:@"暂无评价"];
        }
        else
        {
            cell.reviewLabel.text = [NSString stringWithFormat:@" %d\"",[[reviewDic objectForKey:@"teacherurllength"] intValue]];
        }
    }
    NSInteger head_W = 45;
    NSInteger head_Y = cell.reviewBackView.frame.origin.y+cell.reviewBackView.frame.size.height/2-head_W/2;
    NSInteger spot_W = 5;
    NSInteger spot_Y = cell.reviewBackView.frame.origin.y+cell.reviewBackView.frame.size.height/2-spot_W/2;
    [cell.headButton setFrame:CGRectMake(15, head_Y, head_W, head_W)];
    [cell.spotImgV setFrame:CGRectMake(20+head_W, spot_Y, spot_W, spot_W)];
    cell.reviewBackView.layer.cornerRadius = cell.reviewBackView.bounds.size.height/2;
    // 老师头像
    [cell.headButton setImageWithURL:[_watingDict objectForKey:@"teachericon"] placeholderImage:[UIImage imageNamed:@"personDefault"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 1)];
    lineLab.backgroundColor = _backgroundViewColor;
    return lineLab;
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
