//
//  PersonProgressViewController.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonProgressViewController.h"

@interface PersonProgressViewController ()

@end

@implementation PersonProgressViewController
#define Kratio (2/5)
#define KMiddleScrollViewOrgin_Y (65+140)
#define kMiddleScrollViewHeight (kScreentWidth*Kratio)
#define KBottomScrollViewHeight (kScreenHeight-KMiddleScrollViewOrgin_Y-kMiddleScrollViewHeight)

- (void)uiConfig
{
    // 重新确定frame  5:2  375 150
    _middleScrollV.frame = CGRectMake(0, KMiddleScrollViewOrgin_Y, kScreentWidth, kMiddleScrollViewHeight);
    _bottomScrollV.frame = CGRectMake(0, KMiddleScrollViewOrgin_Y+kMiddleScrollViewHeight, kScreentWidth, KBottomScrollViewHeight);
    
    NSInteger space = 40;
    NSInteger btnWidth = (kScreentWidth-4*space)/3;
    
    for (int i = 0; i < 3; i ++)
    {
//        UIButton *topicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        topicBtn setFrame:CGRectMake(40+i*(btnWidth+40), <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
