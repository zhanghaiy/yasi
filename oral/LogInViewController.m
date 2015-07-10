//
//  LogInViewController.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "LogInViewController.h"
#import "TopicMainViewController.h"
#import "RegisterViewController.h"
#import "NSURLConnectionRequest.h"
#import "OralDBFuncs.h"


@interface LogInViewController ()<UITextFieldDelegate>

@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 修改frame
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiConfig];
    _backV.frame = self.view.bounds;
    [self.view sendSubviewToBack:_backV];
}


- (void)uiConfig
{
    
    NSInteger logo_y = 55.0/667*kScreenHeight;
    NSInteger logo_h = 170.0/667*kScreenHeight;
    _logoImgV.frame = CGRectMake((kScreentWidth-logo_h-1)/2, logo_y, logo_h-1, logo_h);
    
    NSInteger control_H = 40.0/667*kScreenHeight;
    NSInteger space_H = 30.0/667*kScreenHeight;
    
    NSInteger nameTextFie_Y = 240.0/667*kScreenHeight;
    _userNameTextFiled.frame = CGRectMake((kScreentWidth-240)/2, nameTextFie_Y, 240, control_H);
    
    NSInteger passwordTextFie_Y = 325.0/667*kScreenHeight;
    _passWordTextField.frame = CGRectMake((kScreentWidth-240)/2, passwordTextFie_Y, 240, control_H);
    
    
    float logBack_Y = 408.0/667.0*kScreenHeight;
    _loginBackView.frame = CGRectMake(0, logBack_Y, kScreentWidth, space_H);
    _loginBackView.backgroundColor = [UIColor clearColor];
    [_logInButton setFrame:CGRectMake(0, 0, kScreentWidth/2, space_H)];
    _logInButton.backgroundColor =[UIColor clearColor];
    _registerButton.backgroundColor =[UIColor clearColor];
    [_registerButton setFrame:CGRectMake(kScreentWidth/2, 0, kScreentWidth/2, space_H)];
    
    _userNameTextFiled.backgroundColor = [UIColor whiteColor];
    _userNameTextFiled.layer.masksToBounds = YES;
    _userNameTextFiled.layer.cornerRadius = _userNameTextFiled.frame.size.height/2;
    _userNameTextFiled.layer.borderWidth = 1;
    _userNameTextFiled.layer.borderColor = kPart_Button_Color.CGColor;
    _userNameTextFiled.textColor = kPart_Button_Color;
    _userNameTextFiled.delegate = self;
    
    _passWordTextField.delegate = self;
    _passWordTextField.backgroundColor = [UIColor whiteColor];
    _passWordTextField.layer.masksToBounds = YES;
    _passWordTextField.layer.cornerRadius = _passWordTextField.frame.size.height/2;
    _passWordTextField.layer.borderWidth = 1;
    _passWordTextField.layer.borderColor = kPart_Button_Color.CGColor;
    _passWordTextField.textColor = kPart_Button_Color;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userNameTextFiled resignFirstResponder];
    [_passWordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (IBAction)loginButtonClicked:(id)sender
{
    if ([_userNameTextFiled.text length]>0&&[_passWordTextField.text length]>0)
    {
        NSString *paramStr = [NSString stringWithFormat:@"accountname=%@&password=%@",_userNameTextFiled.text,_passWordTextField.text] ;
        NSString *logInUrlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kLogInUrl];
        [NSURLConnectionRequest requestPOSTUrlString:logInUrlStr andParamStr:paramStr target:self action:@selector(requestFinished:) andRefresh:YES];
    }
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSLog(@"%@",dict);
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            // 登陆成功 保存个人信息
            NSString *userid = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"studentid"];
            NSLog(@"%@",dict);
            NSString *userName = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"studentname"];
            [OralDBFuncs setCurrentUser:userName UserId:userid UserIconUrl:[dict objectForKey:@"icon"]];
            [OralDBFuncs addUser:userName];
            //更新登录时间 (待殷总确定 此处是否需要)
            [OralDBFuncs updateUserLastLoginTimeStamp:userName];
            // 跳转页面
            [self enterTopic];
        }
        else
        {
           // 打印失败码
            NSLog(@"登陆失败码：%@\n登录失败信息：%@",[dict objectForKey:@"respCode"],[dict objectForKey:@"remark"]);
            [self createFailAlert:@"登陆失败"];
        }
    }
    else
    {
       // 网络问题
        [self createFailAlert:@"网络错误"];
    }
}

- (void)createFailAlert:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

- (void)enterTopic
{
    TopicMainViewController *topicVC = [[TopicMainViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:topicVC];
    nvc.navigationBarHidden = YES;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)registerButtonClicked:(id)sender
{
    RegisterViewController *registerVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:registerVC animated:YES completion:nil];
}
@end
