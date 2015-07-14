//
//  TPCCheckpointViewController.m
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TPCCheckpointViewController.h"
#import "CheckFollowViewController.h"  // 跟读 part--->point1 关卡1
//#import "CheckBlankViewController.h"   // 填空 part--->point2 关卡2
//#import "CheckAskViewController.h"     // 问答 part--->point3 关卡3

#import "CheckPractiseBookViewController.h"
#import "CheckScoreViewController.h"

#import "ZipManager.h"

#import "CheckTestViewController.h"
#import "OralDBFuncs.h"
#import "ConstellationManager.h"
#import "DetectionNetWorkState.h"
#import "NSURLConnectionRequest.h"



@interface TPCCheckpointViewController ()<UIScrollViewDelegate,UIAlertViewDelegate>
{
    int _markPart;
    BOOL _requestTest_zipUrl;
    BOOL _request_part;// 请求闯关资源 和请求模考资源区分
}
@end

@implementation TPCCheckpointViewController

#define kLeftMarkButtonTag 1234
#define kPartButtonTag 222

#pragma mark - 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self changeLoadingViewTitle:@"正在加载资源文件,请稍后..."];
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    // 界面元素
    [self uiConfig];
    
    // 当前topicNAme
    NSString *topicName = [_topicDict objectForKey:@"classtype"];
    [self addTitleLabelWithTitle:topicName];
    
    // 合成练习id
    NSDate *date = [NSDate date];
    NSString *dateStr = [ConstellationManager transformNSStringWithDate:date];
    NSString *recordId = [NSString stringWithFormat:@"record%@",dateStr];
    // topicID
    NSString *topicID = [_topicDict objectForKey:@"id"];
    
    [OralDBFuncs setCurrentRecordId:recordId];  // 当前的练习id
    [OralDBFuncs setCurrentTopic:topicName];    // 当前topic名称
    [OralDBFuncs setCurrentTopicID:topicID];    // 当前topicID
}

#pragma mark - 在数据库中增加topic
- (void)addTopicToDB
{
    // 在数据库中标记当前topic
    if(![OralDBFuncs getTopicRecordFor:[OralDBFuncs getCurrentUserName] withTopic:[OralDBFuncs getCurrentTopic]])
    {
        if ([OralDBFuncs addTopicRecordFor:[OralDBFuncs getCurrentUserName] with:[OralDBFuncs getCurrentTopic]])
        {
            NSLog(@"success");
        }
        else
        {
            NSLog(@"fail");
        }
    }

}

#pragma mark - 视图已经出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 此处解锁  要求：动画过渡
    // 本地获取当前topic进度
    NSInteger complete = [OralDBFuncs getUnLockNumWithTopic:[OralDBFuncs getCurrentTopic] UserName:[OralDBFuncs getCurrentUserName]];
    // 解锁关卡按钮变为正常状态
    [self configPartBtnWithCompletion:complete];
    
    // 改变滚动视图的偏移量
    [UIView animateWithDuration:1 animations:^{
        _partScrollView.contentOffset = CGPointMake(_partScrollView.frame.size.width*complete, 0);
    }];
}

#pragma mark - 改变part按钮背景色 （用于解锁效果）
- (void)configPartBtnWithCompletion:(NSInteger)completion
{
    for (int i= 0; i < 3; i ++)
    {
        UIButton *partBtn = (UIButton *)[self.view viewWithTag:kPartButtonTag+i];
        if (i<=completion)
        {
            [partBtn setBackgroundColor:kPart_Button_Color];
            partBtn.enabled = YES;
        }
        else
        {
            [partBtn setBackgroundColor:kUnEnabledColor];
            partBtn.enabled = NO;
        }
    }
}

#pragma mark - UI调整
- (void)uiConfig
{
    // 手动调整frame
    float practice_Y = 120.0/667*kScreenHeight;
    float practice_X = 90.0/375.0*kScreentWidth;
    NSLog(@"%f",practice_X);
    
    float practice_W = 48;
    float practice_H = 51;
    [_exerciseBookBtn setFrame:CGRectMake(practice_X, practice_Y, practice_W, practice_H)];
    [_scoreButton setFrame:CGRectMake(kScreentWidth-practice_X-practice_W, practice_Y, practice_W, practice_H)];
    
    NSInteger practice_text_Y = practice_Y+practice_H+10;
    [_exeLable setFrame:CGRectMake(practice_X, practice_text_Y, practice_W, 20)];
    [_scoreLable setFrame:CGRectMake(kScreentWidth-practice_X-practice_W, practice_text_Y, practice_W, 20)];

    // 练习本  成绩单
    [_exerciseBookBtn setBackgroundImage:[UIImage imageNamed:@"exeBook"] forState:UIControlStateNormal];
    _exeLable.textColor = [UIColor colorWithRed:87/255.0 green:224/255.0 blue:192/255.0 alpha:1];
    
    [_scoreButton setBackgroundImage:[UIImage imageNamed:@"scoreMenu"] forState:UIControlStateNormal];
    _scoreLable.textColor = [UIColor colorWithRed:87/255.0 green:224/255.0 blue:192/255.0 alpha:1];
    [_exerciseBookBtn setAdjustsImageWhenHighlighted:NO];
    [_scoreButton setAdjustsImageWhenHighlighted:NO];
    
    // 闯关按钮
    NSInteger part_scrollView_Y = 250.0/667*kScreenHeight;
    NSInteger part_scrollView_W = 245.0/375.0*kScreentWidth;
    NSInteger part_scrollView_H = 100.0/667*kScreenHeight;
    [_partScrollView setFrame:CGRectMake((kScreentWidth-part_scrollView_W)/2, part_scrollView_Y, part_scrollView_W, part_scrollView_H)];
    _partScrollView.contentSize = CGSizeMake(part_scrollView_W*3, part_scrollView_H);
    
    // part1-3 滚动视图 _partScrollView
    _partScrollView.delegate = self;
    _partScrollView.pagingEnabled = YES;
    
    NSArray *partTitleArray = @[@"Part-one",@"Part-two",@"Part-three"];
    // part 按钮
    CGRect partSrollViewRect = _partScrollView.bounds;
    partSrollViewRect.origin.y = 0;
    for (int i = 0; i < 3; i ++)
    {
        partSrollViewRect.origin.x = i*partSrollViewRect.size.width;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:partSrollViewRect];
        
        btn.backgroundColor = kPart_Button_Color;
        btn.tag = kPartButtonTag+i;
        btn.layer.cornerRadius = btn.frame.size.height/2;
        [btn setTitle:[partTitleArray objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startPart:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:30];
        // @"HiraKakuProN-W3"
//        btn.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-thin" size:30];
        [_partScrollView addSubview:btn];
    }
    
    // 直接模考按钮
    
    NSInteger startTest_Y = 435.0/667*kScreenHeight;
    NSInteger startTest_W = 120;
    NSInteger startTest_H = 55;
    [_startTestBtn setFrame:CGRectMake((kScreentWidth-startTest_W)/2, startTest_Y, startTest_W, startTest_H)];
    
    _startTestBtn.layer.masksToBounds= YES;
    _startTestBtn.layer.cornerRadius = _startTestBtn.frame.size.height/2;
    _startTestBtn.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [_startTestBtn setTitleColor:_pointColor forState:UIControlStateNormal];
    
    
    // 页码按钮
    
    NSInteger page_Y = 365.0/667*kScreenHeight;
    NSInteger pageSpace = 12;
    
    [_middleMarkBtn setFrame:CGRectMake((kScreentWidth-15)/2, page_Y, 15, 15)];
    
    [_leftMarkBtn setFrame:CGRectMake(_middleMarkBtn.frame.origin.x-pageSpace-15, page_Y, 15, 15)];
    [_rightMarkBtn setFrame:CGRectMake(_middleMarkBtn.frame.origin.x+pageSpace+15, page_Y, 15, 15)];

    
    _leftMarkBtn.tag = kLeftMarkButtonTag;
    _middleMarkBtn.tag = kLeftMarkButtonTag+1;
    _rightMarkBtn.tag = kLeftMarkButtonTag+2;
    [self drawPageButton:_leftMarkBtn];
    [self drawPageButton:_middleMarkBtn];
    [self drawPageButton:_rightMarkBtn];
    
    [self makePagesAloneWithButtonTag:kLeftMarkButtonTag];
}

#pragma mark -- 页码按钮设置为圆形
- (void)drawPageButton:(UIButton *)btn
{
    btn.layer.cornerRadius = _leftMarkBtn.frame.size.width/2;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = _pointColor.CGColor;
    btn.layer.borderWidth = 1;
}



#pragma mark -- 显示当前的关卡数
- (void)makePagesAloneWithButtonTag:(NSInteger)btnTag
{
    for (int i = 0; i < 3; i ++)
    {
        UIButton *newBtn = (UIButton *)[self.view viewWithTag:kLeftMarkButtonTag+i];
        if (newBtn.tag == btnTag)
        {
            newBtn.backgroundColor = _pointColor;
        }
        else
        {
            newBtn.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - 闯关
#pragma mark -- 闯关按钮被点击
- (void)startPart:(UIButton *)btn
{
    /*
        闯关之前判断当前topic的资源包是否已经缓存  是：开始闯关 否：下载后开始闯关
        zip包路径 topicResource/topicName
     */
    // 1 判断
    NSString *topicResourcePath = [NSString stringWithFormat:@"%@/temp/info.json",[self getPathWithTopic:[OralDBFuncs getCurrentTopic] IsPart:YES]];
    NSLog(@"%@",topicResourcePath);
    _markPart = (int)(btn.tag - kPartButtonTag);
    BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:topicResourcePath];
    if (ret)
    {
        // 存在
        // 开始闯关
        [self beginPointWithPointCounts:_markPart];
    }
    else
    {
        /*
            不存在 缓存
            判断网络限制
         */
        [self jugeNetStateWithSection:YES];
    }
}
#pragma mark -- 开始闯关
- (void)beginPointWithPointCounts:(int)pointCounts
{
    // 标记当前练习的partNum
    [OralDBFuncs setCurrentPart:(pointCounts+1)];
    _loading_View.hidden = YES;
    CheckFollowViewController *followVC = [[CheckFollowViewController alloc]initWithNibName:@"CheckFollowViewController" bundle:nil];
    [self.navigationController pushViewController:followVC animated:YES];
}

#pragma mark - 模考
#pragma mark -- 直接模考按钮被点击
- (IBAction)testButtonClicked:(id)sender
{
    /*
     判断模考资源是否存在 不存在 下载 存在 直接模考
     */
    NSString *jsonPath = [NSString stringWithFormat:@"%@/topicTest/temp/mockinfo.json",[self getLocalSavePath]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:jsonPath])
    {
        [self startEnterTest];
    }
    else
    {
        _requestTest_zipUrl = YES;
        [self jugeNetStateWithSection:NO];
        
    }
}

#pragma mark -- 进入模考
- (void)startEnterTest
{
    _loading_View.hidden = YES;
    CheckTestViewController *testVC = [[CheckTestViewController alloc]initWithNibName:@"CheckTestViewController" bundle:nil];
    [self.navigationController pushViewController:testVC animated:YES];
}


#pragma mark - 网络
#pragma mark -- 检测当前网络状态 （参数：part --》 yes 请求part资源信息  no test资源信息）
- (void)jugeNetStateWithSection:(BOOL)part
{
    _request_part = part;
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
            [self requestZipResourceOFPart:part];
        }
            break;
        case ReachableViaWWAN:
        {
            // 2g3g4g
            if (net_2g3g4g)
            {
                [self requestZipResourceOFPart:part];
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

#pragma mark -- 请求zip资源 （参数Part：YES ---> 请求闯关zip包  NO ---> 请求模考zip包）
- (void)requestZipResourceOFPart:(BOOL)part
{
    if (part)
    {
        [self requestTopicZipResource];
    }
    else
    {
        [self requestTestZip];
    }
}

#pragma mark -- 下载闯关资源
- (void)requestTopicZipResource
{
    _loading_View.hidden = NO;
    [self changeLoadingViewTitle:@"正在请求资源，请稍后...."];
    [self.view bringSubviewToFront:_loading_View];
    NSString *zipfileurl = [_topicDict objectForKey:@"zipfileurl"];
    NSLog(@"%@",zipfileurl);
    [NSURLConnectionRequest requestWithUrlString:zipfileurl target:self aciton:@selector(requestPartZipFinished:) andRefresh:YES];
}

#pragma mark -- 缓存闯关资源
- (void)requestPartZipFinished:(NSURLConnectionRequest *)request
{
    //zip请求成功
    if (request.downloadData)
    {
        // zip保存本地
        NSString *zipPath = [NSString stringWithFormat:@"%@/reqource.zip",[self getLocalSavePath]];
        BOOL success =  [self unZipToLocalData:request.downloadData WithPath:zipPath andFolder:@"topicResource"];
        if (success)
        {
            [self addTopicToDB];
            // 跳转页面 进入闯关
            [self beginPointWithPointCounts:_markPart];
        }
        else
        {
            // 保存失败 重新获取
            [self showFailAlert];
        }
    }
    else
    {
        // zip请求失败
        NSLog(@"zip请求失败");
        [self showFailAlert];
    }
}


#pragma mark -- 下载模考资源
- (void)requestTestZip
{
    _loading_View.hidden = NO;
    [self changeLoadingViewTitle:@"正在请求模考资源，请稍后...."];
    [self.view bringSubviewToFront:_loading_View];
    
    NSString *testZipUrl = [NSString stringWithFormat:@"%@%@?topid=%@",kBaseIPUrl,kTestUrl,[_topicDict objectForKey:@"id"]];
    NSLog(@"%@",testZipUrl);
    [NSURLConnectionRequest requestWithUrlString:testZipUrl target:self aciton:@selector(requestTestZipFinished:) andRefresh:YES];
}

#pragma mark -- 请求 test zip资源
- (void)requestTestZipFinished:(NSURLConnectionRequest *)request
{
    if (_requestTest_zipUrl)
    {
        // 请求zip路径
        _requestTest_zipUrl = NO;
        if (request.downloadData)
        {
            // 成功 ---> zip
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
            NSString *zipUrl = [dict objectForKey:@"zipfileurl"];
            [NSURLConnectionRequest requestWithUrlString:zipUrl target:self aciton:@selector(requestTestZipFinished:) andRefresh:YES];
        }
        else
        {
            // 失败
            NSLog(@"失败");
            [self showFailAlert];
        }
    }
    else
    {
        // 请求zip包
        if (request.downloadData)
        {
            // zip包下载成功
            NSString *testZip = [NSString stringWithFormat:@"%@/test.zip",[self getLocalSavePath]];
            BOOL success = [self unZipToLocalData:request.downloadData WithPath:testZip andFolder:@"topicTest"];
            if (success)
            {
                [self addTopicToDB];
                // 进入模考
                [self startEnterTest];
            }
        }
        else
        {
            // zip包下载失败
            [self showFailAlert];
        }
    }
    
}

#pragma mark -- 解压zip包
- (BOOL)unZipToLocalData:(NSData*)data WithPath:(NSString *)path andFolder:(NSString *)folderName
{
    if ([self filePathExit:[self getLocalSavePath]]==NO)
    {
        [self createPath:[self getLocalSavePath]];
    }
    BOOL saveSuccess = [data writeToFile:path atomically:YES];
    if (saveSuccess)
    {
        // 保存成功 解压
        NSString *toPath = [NSString stringWithFormat:@"%@/%@",[self getLocalSavePath],folderName];
        NSLog(@"~~~~~%@~~~~~~~",[self getLocalSavePath]);
        [ZipManager unzipFileFromPath:path ToPath:toPath];
        return YES;
    }
    else
    {
        // 保存失败
        return NO;
    }
}




#pragma mark - 警告框
#pragma mark -- 警告框 delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex == 1)
    {
        [self requestZipResourceOFPart:_request_part];
    }
}

#pragma mark -- 创建网络请求失败警告框
- (void)showFailAlert
{
    _loading_View.hidden = YES;
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}


#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger mark = (scrollView.contentOffset.x+10)/(scrollView.contentSize.width/3);
    [self makePagesAloneWithButtonTag:kLeftMarkButtonTag+mark];
}


#pragma mark - 路径
#pragma mark -- 创建路径
- (BOOL)createPath:(NSString *)path
{
    BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return ret;
}

#pragma mark -- 判断路径是否存在
- (BOOL)filePathExit:(NSString *)path
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:nil])
    {
        return YES;
    }
    return NO;
}

#pragma mark -- 获取当前topic根目录
- (NSString *)getLocalSavePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[_topicDict objectForKey:@"classtype"]];
    return path;
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

#pragma mark - 进入练习簿
- (IBAction)practiseBook:(id)sender
{
    // 练习本
    CheckPractiseBookViewController *practiseVC = [[CheckPractiseBookViewController alloc]init];
    [self.navigationController pushViewController:practiseVC animated:YES];
}

#pragma mark - 进入成绩单
- (IBAction)scoreMenu:(id)sender
{
    // 成绩单
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    scoreMenuVC.topicId = [_topicDict objectForKey:@"id"];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}

#pragma mark - 返回上一页
- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
