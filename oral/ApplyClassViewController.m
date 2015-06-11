//
//  ApplyClassViewController.m
//  oral
//
//  Created by cocim01 on 15/6/10.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ApplyClassViewController.h"
#import "NSURLConnectionRequest.h"


@interface ApplyClassViewController ()<UITextFieldDelegate>
{
    CGRect _upRect;
    CGRect _downRect;
}
@end

@implementation ApplyClassViewController
#define kInfoTextTag 200
#define kCodeTextTag 201



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreentWidth);
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"申请加班"];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _codeView.frame = _upRect;
    _infoView.frame = _downRect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_codeTextField resignFirstResponder];
    [_infoTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == kCodeTextTag)
    {
        [UIView animateWithDuration:1 animations:^{
            [_codeView setFrame:_upRect];
            [_infoView setFrame:_downRect];
        }];
    }
    else
    {
        [UIView animateWithDuration:1 animations:^{
            [_infoView setFrame:_upRect];
            [_codeView setFrame:_downRect];

            NSLog(@"%f",_upRect.origin.y);
        }];
    }
    return YES;
}


- (void)applyToAddClassPostParams:(NSString *)paramStr
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kApplyClassUrl];
    [NSURLConnectionRequest requestPOSTUrlString:url andParamStr:paramStr target:self action:@selector(requestFinished:) andRefresh:YES];
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSString *remark = [dict objectForKey:@"remark"];
        NSLog(@"%@",remark);
        NSLog(@"%@",dict);
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
        NSLog(@"%f",_downRect.origin.y);
        NSLog(@"%f",_upRect.origin.y);
    }];
}

@end
