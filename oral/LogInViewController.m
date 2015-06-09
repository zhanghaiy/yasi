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

@interface LogInViewController ()<UITextFieldDelegate>

@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _appNameLabel.textColor = kPart_Button_Color;
    
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
    
    _loginBackView.backgroundColor = [UIColor whiteColor];
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
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setValue:userid forKey:@"UserID"];
            [def synchronize];
            // 跳转页面
            [self enterTopic];
        }
    }
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
