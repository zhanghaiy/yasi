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

#import "NetManager.h"
#import "ZipManager.h"

#import "CheckTestViewController.h"


@interface TPCCheckpointViewController ()<UIScrollViewDelegate>
{
    UIView *_loadingView;
    NSInteger _markPart;
    BOOL _requestTest_zipUrl;
}
@end

@implementation TPCCheckpointViewController

#define kLeftMarkButtonTag 1234
#define kPartButtonTag 222


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createLoadingView];
//    _loadingView.hidden = NO;
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    // 界面元素
    [self uiConfig];
}

#pragma mark - UI调整
- (void)uiConfig
{
    // 练习本  成绩单
    [_exerciseBookBtn setBackgroundImage:[UIImage imageNamed:@"exeBook"] forState:UIControlStateNormal];
    _exeLable.textColor = [UIColor colorWithRed:87/255.0 green:224/255.0 blue:192/255.0 alpha:1];

    [_scoreButton setBackgroundImage:[UIImage imageNamed:@"scoreMenu"] forState:UIControlStateNormal];
    _scoreLable.textColor = [UIColor colorWithRed:87/255.0 green:224/255.0 blue:192/255.0 alpha:1];
    
    [_exerciseBookBtn setAdjustsImageWhenHighlighted:NO];
    [_scoreButton setAdjustsImageWhenHighlighted:NO];
    
    // part1-3 滚动视图 _partScrollView
    _partScrollView.contentSize = CGSizeMake(_partScrollView.bounds.size.width*3, _partScrollView.bounds.size.height);
    _partScrollView.delegate = self;
    _partScrollView.pagingEnabled = YES;
    
    NSArray *partTitleArray = @[@"Part-one",@"Part-two",@"Part-three"];
    // part 按钮
    CGRect partSrollViewRect = _partScrollView.frame;
    partSrollViewRect.origin.y = 0;
    for (int i = 0; i < 3; i ++)
    {
        partSrollViewRect.origin.x = i*partSrollViewRect.size.width;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:partSrollViewRect];
        btn.backgroundColor = _pointColor;
        btn.tag = kPartButtonTag+i;
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        btn.layer.cornerRadius = btn.frame.size.height/2;
        [btn setTitle:[partTitleArray objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startPart:) forControlEvents:UIControlEventTouchUpInside];
//        btn.titleLabel.font = [UIFont systemFontOfSize:30];
        // @"HiraKakuProN-W3"
        btn.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-thin" size:30];

        [_partScrollView addSubview:btn];
    }
    
    // 直接模考按钮
    _startTestBtn.layer.masksToBounds= YES;
    _startTestBtn.layer.cornerRadius = _startTestBtn.frame.size.height/2;
    _startTestBtn.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [_startTestBtn setTitleColor:_pointColor forState:UIControlStateNormal];
    
    
    // 页码按钮
    _leftMarkBtn.tag = kLeftMarkButtonTag;
    _middleMarkBtn.tag = kLeftMarkButtonTag+1;
    _rightMarkBtn.tag = kLeftMarkButtonTag+2;
    [self drawPageButton:_leftMarkBtn];
    [self drawPageButton:_middleMarkBtn];
    [self drawPageButton:_rightMarkBtn];
    
    [self makePagesAloneWithButtonTag:kLeftMarkButtonTag];
    
    
}

#pragma mark - 页码按钮设置为圆形
- (void)drawPageButton:(UIButton *)btn
{
    btn.layer.cornerRadius = _leftMarkBtn.frame.size.width/2;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = _pointColor.CGColor;
    btn.layer.borderWidth = 1;
}

#pragma mark - 显示当前的关卡数
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


#pragma mark - 将要闯关
- (void)startPart:(UIButton *)btn
{
    /*
        闯关之前判断当前topic的资源包是否已经缓存  是：开始闯关 否：下载后开始闯关
        zip包路径 topicResource/topicName
     */
    // 1 判断
    NSString *topicResourcePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/topicResource/temp/info.json",[_topicDict objectForKey:@"classtype"]];
    NSLog(@"%@",topicResourcePath);
    _markPart = btn.tag - kPartButtonTag;
    BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:topicResourcePath];
    if (ret)
    {
        // 存在
        // 开始闯关
        [self beginPointWithPointCounts:btn.tag - kPartButtonTag];
    }
    else
    {
        // 不存在 缓存
        _loadingView.hidden = NO;
        [self requestTopicZipResource];
    }
}


#pragma mark - 开始闯关
- (void)beginPointWithPointCounts:(NSInteger)pointCounts
{
    _loadingView.hidden = YES;
    CheckFollowViewController *followVC = [[CheckFollowViewController alloc]initWithNibName:@"CheckFollowViewController" bundle:nil];
    followVC.currentPartCounts = pointCounts;
    followVC.topicName = [_topicDict objectForKey:@"classtype"];
    [self.navigationController pushViewController:followVC animated:YES];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger mark = (scrollView.contentOffset.x+10)/(scrollView.contentSize.width/3);
    NSLog(@"%ld",mark);
     NSLog(@"++++++++%f++++++++++",scrollView.contentOffset.x);
    [self makePagesAloneWithButtonTag:kLeftMarkButtonTag+mark];
}




#pragma mark - 网络请求
#pragma mark - 下载闯关资源
- (void)requestTopicZipResource
{
    NSString *zipfileurl = [_topicDict objectForKey:@"zipfileurl"];
    NSLog(@"%@",zipfileurl);
    [self startRequestURL:zipfileurl andCallBackAction:@selector(requestPartZipFinished:)];
}

#pragma mark - 下载模考资源
- (void)requestTestZip
{
    NSString *testZipUrl = [NSString stringWithFormat:@"%@%@?topid=%@",kBaseIPUrl,kTestUrl,[_topicDict objectForKey:@"id"]];
    NSLog(@"%@",testZipUrl);
    [self startRequestURL:testZipUrl andCallBackAction:@selector(requestTestZipFinished:)];
}



#pragma mark - 开始请求
- (void)startRequestURL:(NSString *)urlString andCallBackAction:(SEL)action
{
    NetManager *netManager = [[NetManager alloc]init];
    netManager.target = self;
    netManager.action = action;
    [netManager netGetUrl:urlString];
}

#pragma mark - 缓存闯关资源
- (void)requestPartZipFinished:(NetManager *)netManager
{
    if (netManager.success)
    {
        //zip请求成功
        if (netManager.downLoadData)
        {
            // zip保存本地
            NSString *zipPath = [NSString stringWithFormat:@"%@/reqource.zip",[self getLocalSavePath]];
           BOOL success =  [self unZipToLocalData:netManager.downLoadData WithPath:zipPath andFolder:@"topicResource"];
            if (success)
            {
                // 跳转页面 进入闯关
                [self beginPointWithPointCounts:_markPart];
            }
            else
            {
                // 保存失败 重新获取
            }
        }
    }
    else
    {
        // zip请求失败
        NSLog(@"zip请求失败");
    }
}

#pragma mark - 解压zip包
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
#pragma mark - 请求 test zip资源
- (void)requestTestZipFinished:(NetManager *)netRequest
{
    if (_requestTest_zipUrl)
    {
        // 请求zip路径
        _requestTest_zipUrl = NO;
        
        if (netRequest.success)
        {
            // 成功 ---> zip
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:netRequest.downLoadData options:0 error:nil];
            NSString *zipUrl = [dict objectForKey:@"zipfileurl"];
            [self startRequestURL:zipUrl andCallBackAction:@selector(requestTestZipFinished:)];
        }
        else
        {
            // 失败
            NSLog(@"失败");
        }
    }
    else
    {
       // 请求zip包
        if (netRequest.success)
        {
            // zip包下载成功
            NSString *testZip = [NSString stringWithFormat:@"%@/test.zip",[self getLocalSavePath]];
            BOOL success = [self unZipToLocalData:netRequest.downLoadData WithPath:testZip andFolder:@"topicTest"];
            if (success)
            {
                // 进入模考
                [self startEnterTest];
            }
        }
        else
        {
           // zip包下载失败
        }
    }
    
}



#pragma mark - 路径是否存在
- (BOOL)filePathExit:(NSString *)path
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:nil])
    {
        return YES;
    }
    return NO;
}

#pragma mark - 创建路径
- (BOOL)createPath:(NSString *)path
{
    BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return ret;
}

#pragma mark - 获取当前topic根目录
- (NSString *)getLocalSavePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[_topicDict objectForKey:@"classtype"]];
    return path;
}

- (void)createLoadingView
{
    _loadingView = [[UIView alloc]initWithFrame:self.view.bounds];
    _loadingView.hidden = YES;
    _loadingView.backgroundColor = [UIColor colorWithWhite:100/255.0 alpha:0.2];
    
    UIView *actionView = [[UIView alloc]initWithFrame:CGRectMake((kScreentWidth-200)/2, kScreenHeight/2-100, 200, 80)];
    actionView.layer.masksToBounds = YES;
    actionView.layer.cornerRadius = 5;
    actionView.layer.borderWidth = 1;
    actionView.layer.borderColor = _pointColor.CGColor;
    
    actionView.backgroundColor = [UIColor whiteColor];

    UIActivityIndicatorView *action = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((actionView.frame.size.width-50)/2, 5, 50, 50)];
    action.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [actionView addSubview:action];
    [action startAnimating];
//    [activity stopAnimating]
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake((actionView.frame.size.width-150)/2, 60, 150, 15)];
    lab.text = @"正在加载资源文件...";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = _pointColor;
    lab.font = [UIFont systemFontOfSize:kFontSize4];
    [actionView addSubview:lab];
    
    actionView.center = _loadingView.center;
    
    [_loadingView addSubview:actionView];
    [self.view addSubview:_loadingView];
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

#pragma mark - 直接模考
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
        _loadingView.hidden = NO;
        _requestTest_zipUrl = YES;
        [self requestTestZip];
    }
    
}

- (void)startEnterTest
{
    _loadingView.hidden = YES;
    CheckTestViewController *testVC = [[CheckTestViewController alloc]initWithNibName:@"CheckTestViewController" bundle:nil];
    testVC.topicName = [_topicDict objectForKey:@"classtype"];
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)practiseBook:(id)sender
{
    // 练习本
    CheckPractiseBookViewController *practiseVC = [[CheckPractiseBookViewController alloc]init];
    [self.navigationController pushViewController:practiseVC animated:YES];
}

- (IBAction)scoreMenu:(id)sender
{
    // 成绩单
    CheckScoreViewController *scoreMenuVC = [[CheckScoreViewController alloc]initWithNibName:@"CheckScoreViewController" bundle:nil];
    [self.navigationController pushViewController:scoreMenuVC animated:YES];
}

- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
