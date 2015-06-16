//
//  CheckKeyWordViewController.m
//  oral
//
//  Created by cocim01 on 15/5/21.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckKeyWordViewController.h"
#import "CheckFollowViewController.h"
#import "CheckBlankViewController.h"
#import "CheckAskViewController.h"
#import "OralDBFuncs.h"


@interface CheckKeyWordViewController ()<UIScrollViewDelegate>
{
    NSInteger _currentPage;
    NSArray *keyWordArray ;
}
@end

@implementation CheckKeyWordViewController
#define kJumpButtonTag 10
#define kPreButtonTag 11
#define kNextButtonTag 12
#define kStartPointButtonTag 13


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    keyWordArray = @[@"go outside",@"experience other cultures",@"afford to do so"];

    self.navTopView.hidden = YES;
    self.lineLab.hidden = YES;
    [self uiConfig];
}

- (void)uiConfig
{
    _jumpButton.tag = kJumpButtonTag;
    _preButton.tag = kPreButtonTag;
    _nextButton.tag = kNextButtonTag;
    _startPointButton.tag = kStartPointButtonTag;
    
    _currentPage = 0;
    [self changButtonBack];
    
    _jumpButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize3];
    _jumpButton.layer.masksToBounds = YES;
    _jumpButton.layer.cornerRadius = _jumpButton.frame.size.height/2;
    _jumpButton.layer.borderWidth = 1;
    _jumpButton.layer.borderColor = _pointColor.CGColor;
    _jumpButton.backgroundColor = [UIColor whiteColor];
    [_jumpButton setTitleColor:_pointColor forState:UIControlStateNormal];


    CGRect rect = _keyScrollView.frame;
    rect.size.width = kScreentWidth;
    rect.size.height = kScreentWidth*52/75;
    _keyScrollView.frame = rect;
    
    _keyScrollView.contentSize = CGSizeMake(rect.size.width*(keyWordArray.count+1), rect.size.height);
    _keyScrollView.pagingEnabled = YES;
    _keyScrollView.delegate = self;
    
    NSInteger x = (rect.size.width-150)/2+20;
    NSInteger y = rect.size.height/2;
    NSInteger w = 150;
    NSInteger h = 40;
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y-h, w, h)];
//    tipLabel.font = [UIFont systemFontOfSize:22];
    tipLabel.font = [UIFont fontWithName:@"MarkerFelt-thin" size:22];

    tipLabel.text = @"欢迎来到";
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.numberOfLines = 1;
    tipLabel.textColor = _pointColor;
    [_keyScrollView addSubview:tipLabel];
    
    
    UILabel *tipLabel_down = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
//    tipLabel_down.font = [UIFont systemFontOfSize:20];
    tipLabel_down.font = [UIFont fontWithName:@"MarkerFelt-thin" size:20];

    tipLabel_down.text = @"关键词学习阶段";
    tipLabel_down.textAlignment = NSTextAlignmentLeft;
    tipLabel_down.numberOfLines = 0;
    tipLabel_down.textColor = _pointColor;
    [_keyScrollView addSubview:tipLabel_down];
    
    
    for (int i = 0; i < keyWordArray.count; i ++)
    {
        CGRect newRect = rect;
        newRect.origin.x = (i+1)*rect.size.width;
        newRect.origin.y = 0;
        UILabel *keyLabel = [[UILabel alloc]initWithFrame:newRect];
//        keyLabel.font = [UIFont systemFontOfSize:30];
        // @"MarkerFelt-thin" @"STHeitiSC-Light"
        keyLabel.font = [UIFont fontWithName:@"MarkerFelt-thin" size:30];
        keyLabel.text = [keyWordArray objectAtIndex:i];
        keyLabel.textAlignment = NSTextAlignmentCenter;
        keyLabel.textColor = _pointColor;
        [_keyScrollView addSubview:keyLabel];
    }
    
    _startPointButton.layer.masksToBounds = YES;
    _startPointButton.layer.cornerRadius = _startPointButton.frame.size.height/2;
    _startPointButton.backgroundColor = _pointColor;
    _startPointButton.titleLabel.textColor = [UIColor whiteColor];
//    _startPointButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _startPointButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
    _startPointButton.hidden = YES;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentPage = scrollView.contentOffset.x/_keyScrollView.frame.size.width;
    [self changButtonBack];
}

- (void)changButtonBack
{
    if (_currentPage==0)
    {
        [_preButton setBackgroundImage:[UIImage imageNamed:@"preTip-d"] forState:UIControlStateNormal];
        _startPointButton.hidden = YES;
    }
    else if (_currentPage == keyWordArray.count)
    {
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"nextTip-d"] forState:UIControlStateNormal];
        _startPointButton.hidden = NO;
    }
    else
    {
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"nextTip"] forState:UIControlStateNormal];
        [_preButton setBackgroundImage:[UIImage imageNamed:@"preTip"] forState:UIControlStateNormal];
        _startPointButton.hidden = YES;
    }
}

- (IBAction)buttonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case kJumpButtonTag:
        {
            //
            [self enterNext];
        }
            break;
        case kPreButtonTag:
        {
            if (_currentPage>0)
            {
                _currentPage --;
            }
        }
            break;
        case kNextButtonTag:
        {
            if (_currentPage<keyWordArray.count)
            {
                _currentPage++;
            }
        }
            break;
        case kStartPointButtonTag:
        {
            [self enterNext];
        }
            break;
        default:
            break;
    }
    
    [self changeKeyWord];
}

- (void)enterNext
{
    if ([OralDBFuncs getCurrentPoint] == 1)
    {
        CheckBlankViewController *blankVC = [[CheckBlankViewController alloc]initWithNibName:@"CheckBlankViewController" bundle:nil];
        [self.navigationController pushViewController:blankVC animated:YES];
    }
    else if ([OralDBFuncs getCurrentPoint] == 2)
    {
        CheckAskViewController *askVC = [[CheckAskViewController alloc]initWithNibName:@"CheckAskViewController" bundle:nil];
        [self.navigationController pushViewController:askVC animated:YES];
    }
}

- (void)changeKeyWord
{
    _keyScrollView.contentOffset = CGPointMake(_keyScrollView.frame.size.width*_currentPage, 0);
    [self changButtonBack];
}


@end
