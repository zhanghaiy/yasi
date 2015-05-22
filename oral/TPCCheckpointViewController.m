//
//  TPCCheckpointViewController.m
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TPCCheckpointViewController.h"
#import "CheckFollowViewController.h"  // 跟读 part--->point1 关卡1
#import "CheckBlankViewController.h"   // 填空 part--->point2 关卡2
#import "CheckAskViewController.h"     // 问答 part--->point3 关卡3

#import "CheckKeyWordViewController.h"

@interface TPCCheckpointViewController ()<UIScrollViewDelegate>

@end

@implementation TPCCheckpointViewController

#define kLeftMarkButtonTag 1234
#define kPartButtonTag 222


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    // part1-3 滚动视图 _partScrollView
    NSInteger partHeight = _partBackView.frame.size.height-50;
    NSInteger partWidth = partHeight*12/5;
    CGRect rect = _partScrollView.frame;
    rect.size.width = partWidth;
    rect.size.height = partHeight;
    _partScrollView.frame = rect;
    _partScrollView.contentSize = CGSizeMake(_partScrollView.bounds.size.width*3, _partScrollView.bounds.size.height);
    _partScrollView.delegate = self;
    NSArray *partTitleArray = @[@"Part-one",@"Part-two",@"Part-three"];
    // part 按钮
    for (int i = 0; i < 3; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        rect.origin.x = i*rect.size.width;
        rect.origin.y = 0;
        [btn setFrame:rect];
        btn.backgroundColor = _pointColor;
        btn.tag = kPartButtonTag+i;
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        btn.layer.cornerRadius = btn.frame.size.height/2;
        [btn setTitle:[partTitleArray objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startPart:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:30];
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

#pragma mark - 开始闯关
- (void)startPart:(UIButton *)btn
{
    switch (btn.tag-kPartButtonTag)
    {
        case 0:
        {
            // 跟读
            CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
            keyVC.pointCounts = 1;
            [self.navigationController pushViewController:keyVC animated:YES];

//            CheckFollowViewController *followVC = [[CheckFollowViewController alloc]initWithNibName:@"CheckFollowViewController" bundle:nil];
//            [self.navigationController pushViewController:followVC animated:YES];
        }
            break;
        case 1:
        {
            // 填空
            CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
            keyVC.pointCounts = 2;
            [self.navigationController pushViewController:keyVC animated:YES];

//            CheckBlankViewController *blankVC = [[CheckBlankViewController alloc]initWithNibName:@"CheckBlankViewController" bundle:nil];
//            [self.navigationController pushViewController:blankVC animated:YES];
        }
            break;
        case 2:
        {
            // 问答
            
            CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
            keyVC.pointCounts = 3;
            [self.navigationController pushViewController:keyVC animated:YES];
            
//            CheckAskViewController *askVC = [[CheckAskViewController alloc]initWithNibName:@"CheckAskViewController" bundle:nil];
//            [self.navigationController pushViewController:askVC animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self makePagesAloneWithButtonTag:(int)(scrollView.contentOffset.x/scrollView.frame.size.width)+kLeftMarkButtonTag];
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
    
}

- (void)backToPrePage
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
