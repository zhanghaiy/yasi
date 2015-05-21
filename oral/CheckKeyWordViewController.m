//
//  CheckKeyWordViewController.m
//  oral
//
//  Created by cocim01 on 15/5/21.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckKeyWordViewController.h"

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
    
    _jumpButton.layer.masksToBounds = YES;
    _jumpButton.layer.cornerRadius = _jumpButton.frame.size.height/2;
    _jumpButton.layer.borderWidth = 1;
    _jumpButton.layer.borderColor = [UIColor colorWithRed:71/255.0 green:223/255.0 blue:187/255.0 alpha:1].CGColor;
    _jumpButton.backgroundColor = [UIColor whiteColor];
    [_jumpButton setTitleColor:[UIColor colorWithRed:71/255.0 green:223/255.0 blue:187/255.0 alpha:1] forState:UIControlStateNormal];


    CGRect rect = _keyScrollView.bounds;
    _keyScrollView.contentSize = CGSizeMake(rect.size.width*(keyWordArray.count+1), rect.size.height);
    _keyScrollView.pagingEnabled = YES;
    _keyScrollView.delegate = self;
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:rect];
    tipLabel.font = [UIFont systemFontOfSize:20];
    tipLabel.text = @"欢迎来到\n关键词学习阶段";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 2;
    tipLabel.textColor = [UIColor colorWithRed:71/255.0 green:223/255.0 blue:187/255.0 alpha:1];
    [_keyScrollView addSubview:tipLabel];
    
    for (int i = 0; i < keyWordArray.count; i ++)
    {
        CGRect newRect = rect;
        newRect.origin.x = (i+1)*rect.size.width;
        UILabel *keyLabel = [[UILabel alloc]initWithFrame:newRect];
        keyLabel.font = [UIFont systemFontOfSize:30];
        keyLabel.text = [keyWordArray objectAtIndex:i];
        keyLabel.textAlignment = NSTextAlignmentCenter;
        keyLabel.textColor = [UIColor colorWithRed:71/255.0 green:223/255.0 blue:187/255.0 alpha:1];
        [_keyScrollView addSubview:keyLabel];
    }
    
    _startPointButton.layer.masksToBounds = YES;
    _startPointButton.layer.cornerRadius = _startPointButton.frame.size.height/2;
    _startPointButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:223/255.0 blue:187/255.0 alpha:1];
    _startPointButton.titleLabel.textColor = [UIColor whiteColor];
    _startPointButton.titleLabel.font = [UIFont systemFontOfSize:KOneFontSize];
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
            
        }
            break;
        default:
            break;
    }
    
    [self changeKeyWord];
}

- (void)changeKeyWord
{
    _keyScrollView.contentOffset = CGPointMake(_keyScrollView.frame.size.width*_currentPage, 0);
    [self changButtonBack];
}


@end
