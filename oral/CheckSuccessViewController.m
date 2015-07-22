//
//  CheckSuccessViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckSuccessViewController.h"
#import "TPCCheckpointViewController.h"
#import "CheckKeyWordViewController.h"
#import "CheckAskViewController.h"
#import "SuccessCell.h"
#import "OralDBFuncs.h"
#import "NSString+CalculateStringSize.h"
#import "DeviceManager.h"
#import "NSURLConnectionRequest.h"

@interface CheckSuccessViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    NSMutableArray *_scoreMenuArray;
    NSMutableArray *_answer_Cintent_Array;
    NSMutableDictionary *_answer_DB_Dictionary;
    
    NSString *_sharePath;
    NSString *_shareText;
    BOOL _sucess_share;
}

@end

@implementation CheckSuccessViewController
#define kCellHeght 70
#define kShareCateButtonTag 89
#define kShareViewHeight (220.0/667*kScreenHeight)
#define kShareBtnHeight (50.0/667*kScreenHeight)
#define kSpace_Y (kShareViewHeight-kShareBtnHeight*2)/3
#define kSpace_X (kScreentWidth-kShareBtnHeight*3)/4
#define kShareBackViewTag 4789

- (void)uiConfig
{
    // 修改frame
    float topView_H = 350.0/667*kScreenHeight;
    float shareBtn_W = 100.0/375*kScreentWidth;
    float shareBtn_H = 50.0/667*kScreenHeight;
    float tipLabel_H = 30;
    float space_share_toBottom = 15.0/667*kScreenHeight;
    float score_H = 180.0/667*kScreenHeight;
    float score_Y = topView_H-5-space_share_toBottom-shareBtn_H-tipLabel_H-score_H;
    [_topBackView setFrame:CGRectMake(0, 0, kScreentWidth, topView_H)];
    [_topScoreLabel setFrame:CGRectMake(0, score_Y, kScreentWidth, score_H)];
    [_topShareButton setFrame:CGRectMake((kScreentWidth-shareBtn_W)/2, topView_H-space_share_toBottom-shareBtn_H, shareBtn_W, shareBtn_H)];
    
    [_topDesLabel setFrame:CGRectMake(0, topView_H-space_share_toBottom-shareBtn_H-tipLabel_H-5, kScreentWidth, tipLabel_H)];
    // 底部按钮
    float bottom_btn_W = 110.0/375*kScreentWidth;
    float bottom_btn_H = 50.0/667*kScreenHeight;
    NSInteger space_bottom = (kScreentWidth-bottom_btn_W*2)/3;
    [_backButton setFrame:CGRectMake(kScreentWidth/2-bottom_btn_W-space_bottom/2, kScreenHeight-5-bottom_btn_H, bottom_btn_W, bottom_btn_H)];
    [_continueButton setFrame:CGRectMake(kScreentWidth/2+space_bottom/2, kScreenHeight-5-bottom_btn_H, bottom_btn_W, bottom_btn_H)];


    // 中间文字
    float menu_label_H = 40.0/667*kScreenHeight;
    float menu_label_Y = topView_H;
    [_midTitleLabel setFrame:CGRectMake(0, menu_label_Y, kScreentWidth, menu_label_H)];
    [_midTableView setFrame:CGRectMake(0, menu_label_Y+menu_label_H, kScreentWidth, kScreenHeight-menu_label_Y-menu_label_H-bottom_btn_H-10)];
    // 闯关成绩单文字颜色
    
    
    // 圆角半径
    // 总分数
    _topShareButton.hidden = NO;
    _topShareButton.layer.masksToBounds = YES;
    _topShareButton.layer.cornerRadius = _topShareButton.frame.size.height/2;
    // 再来一次/返回  按钮
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = _backButton.frame.size.height/2;
    _continueButton.layer.masksToBounds = YES;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2;
    
    // 列表控件 delegate
    _midTableView.delegate = self;
    _midTableView.dataSource = self;
    _midTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _midTableView.showsHorizontalScrollIndicator = NO;
    _midTableView.showsVerticalScrollIndicator = NO;
    
    // 背景色
    _continueButton.backgroundColor = kPart_Button_Color;
    _backButton.backgroundColor = kPart_Button_Color;
    _midTableView.backgroundColor = _backgroundViewColor;
    _topScoreLabel.backgroundColor = [UIColor clearColor];
    _topShareButton.backgroundColor = [UIColor whiteColor];
    
    // 文字大小
    _midTitleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
    _continueButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
    _backButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
    _topDesLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
    _topShareButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_Button_normal];
    
    // 文字颜色
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _midTitleLabel.textColor = kPart_Button_Color;
    _topDesLabel.textColor = [UIColor whiteColor];
    _topScoreLabel.textColor = [UIColor whiteColor];
    
    // 文字 对其方式
    _midTitleLabel.textAlignment = NSTextAlignmentCenter;
    _topDesLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - 获取总分 从数据库
- (void)getSumScore
{
    // 获取总分

    NSInteger sumScore = 0;
    if ([OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]])
    {
        TopicRecord *topicRecord = [OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]];
        if ([OralDBFuncs getCurrentPart] == 1)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                sumScore = topicRecord.p1_1;
            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                sumScore = topicRecord.p1_2;
            }
        }
        else if ([OralDBFuncs getCurrentPart] == 2)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                sumScore = topicRecord.p2_1;
            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                sumScore = topicRecord.p2_2;
            }
        }
        else if ([OralDBFuncs getCurrentPart] == 3)
        {
            if ([OralDBFuncs getCurrentPoint] == 1)
            {
                sumScore = topicRecord.p3_1;

            }
            else if ([OralDBFuncs getCurrentPoint] == 2)
            {
                sumScore = topicRecord.p3_2;
            }
        }
    }
    
    _topScoreLabel.text = [NSString stringWithFormat:@"%d",sumScore];
    // 根据分数设置颜色
    // 2中颜色
    UIColor *color_fail = [UIColor colorWithRed:250/255.0 green:220/255.0 blue:18/255.0 alpha:1];
    UIColor *color_sucess = [UIColor colorWithRed:0 green:179/255.0 blue:231/255.0 alpha:1];
    NSArray *color_array = @[color_fail,color_sucess];
    int index = sumScore>=60?1:0;
    
    // 根据分数 改变控件颜色
    _topBackView.backgroundColor = [color_array objectAtIndex:index];
    [_topShareButton setTitleColor:[color_array objectAtIndex:index] forState:UIControlStateNormal];
    [_topShareButton setBackgroundColor:[UIColor whiteColor]];
    [_topShareButton setTitleColor:[color_array objectAtIndex:index] forState:UIControlStateNormal];
    
    // 根据分数 设置标题
    if (sumScore>=60)
    {
        // 网络请求百分比
        [self requestScorePercentWithScore:sumScore];
    }
    else
    {
        _topDesLabel.text = @"闯关失败~再接再厉！";
        _shareText = @"闯关失败~再接再厉！";
    }
    
//    if (!index)
//    {
//        // 不及格 不可以继续闯关
//        _continueButton.enabled = NO;
//        _continueButton.backgroundColor = kUnEnabledColor;
//    }
}

#pragma mark - 网络请求 百分比
- (void)requestScorePercentWithScore:(NSInteger)score
{
    /*
        分数	score	M
        课程ID	topcid	M
        PART号	part	M
        关卡ID	levelid	M
        用户ID	userid	M
     */
    _loading_View.hidden = NO;
    [self.view bringSubviewToFront:_loading_View];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?score=%ld&topcid=%@&part=%d&levelid=%@&userid=%@",kBaseIPUrl,kSelectScorePercent,score,[OralDBFuncs getCurrentTopicID],[OralDBFuncs getCurrentPart],[OralDBFuncs getCurrentLevelID],[OralDBFuncs getCurrentUserID]];
    [NSURLConnectionRequest requestWithUrlString:urlStr target:self aciton:@selector(requestPercentEnd:) andRefresh:YES];
}

- (void)requestPercentEnd:(NSURLConnectionRequest *)request
{
    _loading_View.hidden = YES;
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            // 成功
            NSString *text = [NSString stringWithFormat:@"成绩不错，超过了%@的小伙伴~~",[dict objectForKey:@"newSize"]];
            _shareText = text;// 标记分享的文字 （标记百分比）
            _topDesLabel.text = text;
        }
        else
        {
            NSLog(@"%@",[dict objectForKey:@"remark"]);
        }
    }
    else
    {
        NSString *text = [NSString stringWithFormat:@"网络出错了，查询不到你超过的小伙伴"];
        _topDesLabel.text = text;
    }
}

#pragma mark - 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 分数显示top区域有两种颜色 1：黄色 2： 蓝色
    self.lineLab.hidden = YES;
    self.navTopView.hidden = YES;
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiConfig];
    // 获取总分 此处由于时间问题 一直崩溃 暂不获取
    [self getSumScore];

    // 合成成绩单数据源
    _scoreMenuArray = [[NSMutableArray alloc]init];
    [self makeUpScoreMenu];
    [self createShareView];
}

#pragma mark - 组成成绩单
- (void)makeUpScoreMenu
{
    /*
     数据结构
     _topicInfoDict--> topic闯关信息---> dict(字典)
     当前topic所有part--> partListArray = [_topicInfoDict objectForKey:@"partlist"] -->数组
     当前part--> curretPartDict = [partListArray objectAtIndex:_currentPartCounts] -->字典
     当前part的所有关卡信息 -- > pointArray = [curretPart objectForKey:@"levellist"] --> 数组
     当前关卡信息 pointDict = [pointArray objectAtIndex:_currentPointCounts] --> 字典
     */
    //    NSString *path = [[NSBundle mainBundle]pathForResource:@"info" ofType:@"json"];
    
    NSString *jsonPath = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *maindict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // 整个topic资源信息
    NSDictionary *dict = [maindict objectForKey:@"classtypeinfo"];
    // 当前part资源信息
    NSDictionary *subDict = [[dict objectForKey:@"partlist"] objectAtIndex:[OralDBFuncs getCurrentPart]-1];
    NSArray *questionList = [[[subDict objectForKey:@"levellist"] objectAtIndex:[OralDBFuncs getCurrentPoint]-1] objectForKey:@"questionlist"];
    _answer_Cintent_Array = [[NSMutableArray alloc]init];
    _answer_DB_Dictionary = [[NSMutableDictionary alloc]init];
    for (NSDictionary *subSubdict in questionList)
    {
        NSArray *answerArray = [subSubdict objectForKey:@"answerlist"];
        for (NSDictionary *subSubSubDic in answerArray)
        {
            NSString *answerID = [subSubSubDic objectForKey:@"id"];
            [_answer_Cintent_Array addObject:subSubSubDic];

            if ([OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerID partNum:[OralDBFuncs getCurrentPart] andLevelNum:[OralDBFuncs getCurrentPoint]])
            {
                PracticeBookRecord *scoreInfoRecord = [OralDBFuncs getLastRecordFor:[OralDBFuncs getCurrentUserName] topicName:[OralDBFuncs getCurrentTopic] answerId:answerID partNum:[OralDBFuncs getCurrentPart] andLevelNum:[OralDBFuncs getCurrentPoint]];
                [_answer_DB_Dictionary setObject:scoreInfoRecord forKey:answerID];
            }
            
        }
    }
}

#pragma mark - 去掉html标签 (未用到----2015.06.11)
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


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [self filterHTML:[[_answer_Cintent_Array objectAtIndex:indexPath.row] objectForKey:@"answer"]];
    NSLog(@"%@",text);
    CGRect rect = [NSString CalculateSizeOfString:text Width:kScreentWidth-90 Height:99999 FontSize:kFontSize_17];
    NSLog(@"文字：%f",rect.size.height);
    return (int)rect.size.height+30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _answer_Cintent_Array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celId = @"cell";
    SuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if ( cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SuccessCell" owner:self options:0] lastObject];
        
        cell.htmlWebView.scrollView.scrollEnabled=NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *answerId = [[_answer_Cintent_Array objectAtIndex:indexPath.row] objectForKey:@"id"];
    PracticeBookRecord *record = [_answer_DB_Dictionary objectForKey:answerId];
    cell.htmlWebView.delegate = self;
    NSLog(@"~~~%@~~~~~",record.lastText);
    [cell.htmlWebView loadHTMLString:record.lastText baseURL:nil];
    
    NSArray *colorArr = @[_perfColor,_goodColor,_badColor];
    int scoreCun = record.lastScore>=80?0:(record.lastScore>=60?1:2);
    [cell.scoreButton setBackgroundColor:[colorArr objectAtIndex:scoreCun]];
    [cell.scoreButton setTitle:[NSString stringWithFormat:@"%d",record.lastScore] forState:UIControlStateNormal];
    NSLog(@"cell-- webview:%f",cell.htmlWebView.frame.size.height);
    return cell;
}



- (void)didReceiveMemoryWarning
{
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


#pragma mark - 再来一次按钮被点击
- (IBAction)backToLastPage:(id)sender
{
    for (UIViewController *viewControllers in self.navigationController.viewControllers)
    {
        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
        {
            [self.navigationController popToViewController:viewControllers animated:YES];
            break;
        }
    }
}

#pragma mark - 继续闯关按钮被点击
- (IBAction)continueNextPoint:(id)sender
{
    CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
    [self.navigationController pushViewController:keyVC animated:YES];
}

#pragma mark - 分享
#pragma mark -- 创建分享底部弹出View
- (void)createShareView
{
    UIView *shareBackV = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreentWidth, kShareViewHeight+30)];
    shareBackV.tag = kShareBackViewTag;
    shareBackV.backgroundColor = _backgroundViewColor;
    shareBackV.layer.masksToBounds = YES;
    shareBackV.layer.cornerRadius = 5;
    [self.view addSubview:shareBackV];
    
    NSArray *shareTitleArray = @[@"QQ",@"微信",@"微博",@"人人"];
    NSArray *shareImageArray = @[[UIImage imageNamed:@"QQ"],[UIImage imageNamed:@"微信"],[UIImage imageNamed:@"新浪"],[UIImage imageNamed:@"人人"]];
    NSInteger hang = (shareTitleArray.count%3)?(shareTitleArray.count/3+1):shareTitleArray.count/3;
    for (int i = 0; i < hang; i ++)
    {
        for (int j = 0; j < 3; j ++)
        {
            if ((i*3+j)<shareTitleArray.count)
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(kSpace_X+j*(kShareBtnHeight+kSpace_X), kSpace_Y+i*(kShareBtnHeight+kSpace_Y), kShareBtnHeight, kShareBtnHeight)];
                [btn addTarget:self action:@selector(shareCategory:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = kShareCateButtonTag+(i*3)+j;
                [btn setBackgroundImage:[shareImageArray objectAtIndex:(i*3)+j] forState:UIControlStateNormal];
                [shareBackV addSubview:btn];
            }
        }
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake((kScreentWidth-80)/2, kShareViewHeight-20, 80, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = kPart_Button_Color;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSize_16];
    [cancelBtn addTarget:self action:@selector(moveToHidden) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2;
    [shareBackV addSubview:cancelBtn];
}

#pragma mark -- 分享按钮点击事件
- (IBAction)shareButtonClicked:(id)sender
{
    NSLog(@"shareButtonClicked");
    UIView *shareV = [self.view viewWithTag:kShareBackViewTag];
    [UIView animateWithDuration:1 animations:^{
        [shareV setFrame:CGRectMake(0, kScreenHeight-kShareViewHeight-30, kScreentWidth, kShareViewHeight+30)];
    }];
}

#pragma mark -- 截图
- (void)getImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScreentWidth, kScreenHeight), NO, 1.0);  //NO，YES 控制是否透明
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _sharePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/imag.png"];
    NSData *imaDa = UIImageJPEGRepresentation(img, 1);
    [imaDa writeToFile:_sharePath atomically:YES];
}


#pragma mark -- 移走底部弹出分享控件
- (void)moveToHidden
{
    UIView *shareV = [self.view viewWithTag:kShareBackViewTag];
    [UIView animateWithDuration:1 animations:^{
        [shareV setFrame:CGRectMake(0, kScreenHeight, kScreentWidth, kShareViewHeight+30)];
    }];
}

#pragma mark -- 选择分享的平台
- (void)shareCategory:(UIButton *)btn
{
    switch (btn.tag-kShareCateButtonTag)
    {
        case 0:
        {
            // QQ
            [self shareWithType:ShareTypeQQ];
        }
            break;
        case 1:
        {
            // 微信 朋友圈
            [self shareWithType:ShareTypeWeixiTimeline];
        }
            break;
        case 2:
        {
            // 微博
            [self shareWithType:ShareTypeSinaWeibo];
        }
            break;
        case 3:
        {
            // 人人
            [self shareWithType:ShareTypeRenren];
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 开始分享
- (void)shareWithType:(ShareType)type
{
    //构造分享内容
    NSArray *detailTextArr = @[@"我在玩【开口说】雅思口语，大家一起来挑战吧！",@"我在玩【开口说】雅思口语，求安慰，大家一起来帮我吧！"];
    NSString *detail = [detailTextArr objectAtIndex:_sucess_share?0:1];
    id<ISSContent> publishContent = [ShareSDK content:_shareText defaultContent:@"默认分享内容，没内容时显示" image:[ShareSDK imageWithPath:_sharePath] title:@"ShareSDK" url:@"http://www.apple.com/cn/itunes/charts/" description:detail mediaType:SSPublishContentMediaTypeNews];
    [ShareSDK clientShareContent:publishContent //内容对象
                            type:type//ShareTypeWeixiSession //平台类型
                   statusBarTips:YES
                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {//返回事件
                              
                              if (state == SSPublishContentStateSuccess)
                              {
                                  NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功!"));
                              }
                              else if (state == SSPublishContentStateFail)
                              {
                                  NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败!"), [error errorCode], [error errorDescription]);
                              }
                          }];

}

@end
