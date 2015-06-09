//
//  RegisterViewController.m
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "RegisterViewController.h"
#import "TopicMainViewController.h"
#import "NSURLConnectionRequest.h"


@interface RegisterViewController ()<UITextFieldDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _nameTextField.backgroundColor = [UIColor whiteColor];
    _nameTextField.layer.masksToBounds = YES;
    _nameTextField.layer.cornerRadius = _nameTextField.frame.size.height/2;
    _nameTextField.layer.borderWidth = 1;
    _nameTextField.layer.borderColor = kPart_Button_Color.CGColor;
    _nameTextField.textColor = kPart_Button_Color;
    _nameTextField.delegate = self;
    
    _passwordTextField.delegate = self;
    _passwordTextField.backgroundColor = [UIColor whiteColor];
    _passwordTextField.layer.masksToBounds = YES;
    _passwordTextField.layer.cornerRadius = _passwordTextField.frame.size.height/2;
    _passwordTextField.layer.borderWidth = 1;
    _passwordTextField.layer.borderColor = kPart_Button_Color.CGColor;
    _passwordTextField.textColor = kPart_Button_Color;
    
    _registerButton.backgroundColor = kPart_Button_Color;
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_nameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
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

- (IBAction)registerButtonClicked:(id)sender
{
    if ((_nameTextField.text.length>0)&&(_passwordTextField.text.length>0))
    {
        NSString *paramsStr = [NSString stringWithFormat:@"accountname=%@&password=%@",_nameTextField.text,_passwordTextField.text];
        NSString *registerStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kRegisterUrl];
        [NSURLConnectionRequest requestPOSTUrlString:registerStr andParamStr:paramsStr target:self action:@selector(requestFinished:) andRefresh:YES];
    }
    
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    NSLog(@"请求结束");
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        NSLog(@"%@",dict);
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            [self enterTopicPage];
        }
    }
}

- (void)enterTopicPage
{
    TopicMainViewController *topicVC = [[TopicMainViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:topicVC];
    nvc.navigationBarHidden = YES;
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
