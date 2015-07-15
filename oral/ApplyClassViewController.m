//
//  ApplyClassViewController.m
//  oral
//
//  Created by cocim01 on 15/6/10.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ApplyClassViewController.h"
#import "NSURLConnectionRequest.h"


@interface ApplyClassViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    CGRect _upRect;
    CGRect _downRect;
    BOOL _commitSucess;
}
@end

@implementation ApplyClassViewController
#define kInfoTextTag 200
#define kCodeTextTag 201


#pragma mark - 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:@"申请加班"];
    
    _commitSucess = NO;
    self.view.backgroundColor = _backgroundViewColor;
    
    _userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    NSInteger height = (kScreentWidth-20)*40/71;
    _upRect = CGRectMake(10, 90, kScreentWidth-20, height);
    
    _downRect = CGRectMake(10, 110+height, kScreentWidth-20, height);
    
    _codeView.frame = _upRect;
    _infoView.frame = _downRect;
    
    
    _infoAddButton.layer.masksToBounds = YES;
    _infoAddButton.layer.cornerRadius = _infoAddButton.frame.size.height/2;
    _codeAddButton.layer.masksToBounds = YES;
    _codeAddButton.layer.cornerRadius = _codeAddButton.frame.size.height/2;
    
    _codeTitleLabel.textColor = kPart_Button_Color;
    _infoTitleLabel.textColor = kPart_Button_Color;
    _codeTextField.textColor = kPart_Button_Color;
    _infoTextField.textColor = kPart_Button_Color;
    _codeLineLabel.backgroundColor = kPart_Button_Color;
    _infoLineLabel.backgroundColor = kPart_Button_Color;
    
    _infoTextField.delegate = self;
    _codeTextField.delegate = self;
    _infoTextField.tag = kInfoTextTag;
    _codeTextField.tag = kCodeTextTag;
    
}

#pragma mark - 视图已经出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _codeView.frame = _upRect;
    _infoView.frame = _downRect;
}

#pragma mark - 触空白收键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_codeTextField resignFirstResponder];
    [_infoTextField resignFirstResponder];
}

#pragma mark - return 收键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:1 animations:^{
        self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
        
    }];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 正在输入
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == kCodeTextTag)// 有码申请
    {
        [UIView animateWithDuration:1 animations:^{
            self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);

        }];
    }
    else// 无码申请
    {
        [UIView animateWithDuration:1 animations:^{
            self.view.frame = CGRectMake(0, -216, kScreentWidth, kScreenHeight);
        }];
    }
    return YES;
}

#pragma mark - 申请加班
- (void)applyToAddClassPostParams:(NSString *)paramStr
{
    _loading_View.hidden = NO;
    [self.view bringSubviewToFront:_loading_View];
    NSString *url = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kApplyClassUrl];
    [NSURLConnectionRequest requestPOSTUrlString:url andParamStr:paramStr target:self action:@selector(requestFinished:) andRefresh:YES];
}

#pragma mark - 申请加班回调
- (void)requestFinished:(NSURLConnectionRequest *)request
{
    _loading_View.hidden = YES;
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] intValue] == 1000)
        {
            _commitSucess = YES;
        }
        NSString *remark = [dict objectForKey:@"remark"];
        [self showAlertWithMessage:remark];
    }
    else
    {
        [self showAlertWithMessage:@"网络错误"];
    }
}

#pragma mark - 展示警告框
- (void)showAlertWithMessage:(NSString *)remark
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:remark delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_commitSucess)
    {
        // 返回上一页
        [self backToPrePage];
    }
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

#pragma mark - 加入班级按钮点击事件 无码
- (IBAction)infoAddButtonClicked:(id)sender
{
    NSString *paramSTR;
    if (_infoTextField.text.length)
    {
        paramSTR = [NSString stringWithFormat:@"userId=%@&classId=%@&memo=%@",_userId,_classId,_infoTextField.text];
    }
    else
    {
        paramSTR = [NSString stringWithFormat:@"userId=%@&classId=%@",_userId,_classId];
    }
    [self applyToAddClassPostParams:paramSTR];
}

- (IBAction)infoDeleteButtonClicked:(id)sender
{
    _infoView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^
    {
        _codeView.frame = _upRect;
        _infoView.frame = _downRect;
    }];
}

#pragma mark - 加入班级按钮点击事件 有码申请
- (IBAction)codeAddButtonClicked:(id)sender
{
    NSString *paramSTR;
    if (_codeTextField.text.length)
    {
        paramSTR = [NSString stringWithFormat:@"userId=%@&classId=%@&inviteCode=%@",_userId,_classId,_codeTextField.text];
    }
    else
    {
        paramSTR = [NSString stringWithFormat:@"userId=%@&classId=%@",_userId,_classId];
    }
    [self applyToAddClassPostParams:paramSTR];
}

- (IBAction)codeDeleteButtonClicked:(id)sender
{
    _codeView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _codeView.frame = _downRect;
        _infoView.frame = _upRect;
    }];
}

@end
