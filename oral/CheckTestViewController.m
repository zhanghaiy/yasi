//
//  CheckTestViewController.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckTestViewController.h"

@interface CheckTestViewController ()
{
    CGRect _tea_head_big_frame;// 中心 放大后的
    CGRect _tea_head_small_frame;// 中心 缩小的
    CGRect _tea_head_small_frame_left;// 左侧位置
    
    CGRect _stu_head_big_frame;
    CGRect _stu_head_small_frame;
}
@end

@implementation CheckTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addTitleLabelWithTitleWithTitle:@"直接模考"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self uiConfig];

}

- (void)createTopCountProgressButtonWithArray:(NSArray *)array
{
    for (int i = 0; i < 3; i ++)
    {
        for (int j = 0; j < 5; j ++)
        {
            UIButton *spotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTest) userInfo:nil repeats:NO];
}

- (void)startTest
{
    [UIView animateWithDuration:2 animations:^{
        [_teaHeadBtn setFrame:_tea_head_big_frame];
    }];
    
//    NSLog(@"%f  %f",_teaHeadBtn.frame.size.height,_tea_head_big_frame.size.height);
//    _teaHeadBtn.alpha = 1;
//    _tipLabel.text = @"考试即将开始，请注意";
}

- (void)enlarge
{
    CGRect bigRect = _teaHeadBtn.bounds;
    bigRect.size.height += 20;
    bigRect.size.width += 20;
    bigRect.origin.x -= (kScreentWidth - bigRect.size.width)/2;
    bigRect.origin.y -= 10;
    [_teaHeadBtn setFrame:bigRect];
}

- (void)narrow
{
    CGRect bigRect = _teaHeadBtn.frame;
    bigRect.size.height -= 20;
    bigRect.size.width -= 20;
    bigRect.origin.x += 10;
    bigRect.origin.y += 10;
    [_teaHeadBtn setFrame:bigRect];
    _teaHeadBtn.layer.cornerRadius = bigRect.size.width/2;
}

- (void)left
{
    CGRect bigRect = _teaHeadBtn.frame;
    bigRect.origin.x = 15;
    [_teaHeadBtn setFrame:bigRect];
    _teaHeadBtn.layer.cornerRadius = bigRect.size.width/2;
}

- (void)uiConfig
{
    // 调整背景颜色
    _teaBackView.backgroundColor = [UIColor clearColor];
    _stuBackView.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.backgroundColor = [UIColor clearColor];
    _sumTimeLabel.textColor = [UIColor colorWithRed:139/255.0 green:185/255.0 blue:200/255.0 alpha:1];
    _tipLabel.textColor = [UIColor colorWithRed:1/255.0 green:196/255.0 blue:255.0/255.0 alpha:1];
    _tipLabel.backgroundColor = [UIColor clearColor];
    
    // 调整位置 记录大小
    // 提问界面
    float tea_back_View_height = _teaBackView.frame.size.height;
    _teaBackView.frame = CGRectMake(0, 131, kScreentWidth, tea_back_View_height);
    
//    CGRect tea_rect = _teaHeadBtn.frame;
    // 中心 缩小后的frame
    _tea_head_small_frame = CGRectMake((kScreentWidth-45)/2, (tea_back_View_height-45)/2, 45, 45);
    // 中心 放大后的frame
    _tea_head_small_frame = CGRectMake((kScreentWidth-65)/2, (tea_back_View_height-65)/2, 65, 65);//_tea_head_big_frame;
    _tea_head_small_frame.origin.x +=10;
    _tea_head_small_frame.origin.y += 10;
    _tea_head_small_frame.size.width -=20;
    _tea_head_small_frame.size.height -=20;
    
    // 左边 缩小后的frame
    _tea_head_small_frame_left =_tea_head_small_frame;
    _tea_head_small_frame_left.origin.x = 15;
    
    // 设置初始位置 中心 缩小的 （然后放大）
    [_teaHeadBtn setFrame:_tea_head_small_frame];
    
    // 学生界面
    CGRect stu_middle_rect = _stuHeadBtn.frame;
    // 缩小时的frame
    _stu_head_small_frame = stu_middle_rect;
    _stu_head_small_frame.origin.x = (kScreentWidth-_stu_head_small_frame.size.width)/2;
    // 放大时的frame
    _stu_head_big_frame = _stu_head_small_frame;
    _stu_head_big_frame.origin.x -= 10;
    _stu_head_big_frame.origin.y -= 10;
    _stu_head_big_frame.size.width += 20;
    _stu_head_big_frame.size.height += 20;
    
    
    // 设置圆角半径
//    _teaHeadBtn.layer.masksToBounds = YES;
//    _teaHeadBtn.layer.cornerRadius = _teaHeadBtn.frame.size.height/2;
    
    _followBtn.layer.masksToBounds = YES;
    _followBtn.layer.cornerRadius = _followBtn.frame.size.height/2;
    
    _stuHeadBtn.layer.masksToBounds = YES;
    _stuHeadBtn.layer.cornerRadius = _stuHeadBtn.frame.size.height/2;
    
    // 设置初始界面元素 隐藏特定的控件
    _teaCircleImageView.hidden = YES;// 仿声波动画控件
    _teaDesLabel.hidden = YES;// 关键词提示控件
    _followBtn.hidden = YES;// 跟读按钮
    
    // 设置文字
    _tipLabel.text = @"";
    
    _teaHeadBtn.alpha = 0.5;
    _stuHeadBtn.alpha = 0.5;
    
    
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
