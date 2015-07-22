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
#import "OralDBFuncs.h"

@interface RegisterViewController ()<UITextFieldDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 确定frame
    
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiconfig];
}

- (void)uiconfig
{
    _backImgV.frame = self.view.bounds;
    float backButton_Y = 40.0/667.0*kScreenHeight;
    [_backButton setFrame:CGRectMake(30, backButton_Y, 30, 30)];
    _backButton.layer.masksToBounds = YES;
    _backButton.layer.cornerRadius = _backButton.frame.size.height/2;
    _backButton.layer.borderWidth = 1;
    _backButton.layer.borderColor = kPart_Button_Color.CGColor;
    
    
    float regBack_Y = 32.0/667*kScreenHeight;
    [_registerImgV setFrame:CGRectMake(20, regBack_Y, kScreentWidth-40, kScreenHeight-2*regBack_Y)];
    _registerImgV.layer.masksToBounds = YES;
    _registerImgV.layer.cornerRadius = 5;
    _registerImgV.layer.borderColor = kPart_Button_Color.CGColor;
    _registerImgV.layer.borderWidth = 1;
    _registerImgV.alpha = 0.5;
    _registerImgV.backgroundColor = [UIColor whiteColor];
    
    float upLine_Y = 121.0/667.0*kScreenHeight;
    float upLine_x = 65.0/375.0*kScreentWidth;
    [_upLineLabel setFrame:CGRectMake(upLine_x, upLine_Y, kScreentWidth-2*upLine_x, 1)];
    [_upLineLabel setBackgroundColor:kPart_Button_Color];
    _nameTextField.frame = CGRectMake(upLine_x, upLine_Y-30, kScreentWidth-2*upLine_x, 30);
    
    float downLine_Y = 184.0/667.0*kScreenHeight;
    [_downLineLabel setFrame:CGRectMake(upLine_x, downLine_Y, kScreentWidth-2*upLine_x, 1)];
    [_downLineLabel setBackgroundColor:kPart_Button_Color];
    _passwordTextField.frame = CGRectMake(upLine_x, downLine_Y-30, kScreentWidth-2*upLine_x, 30);
    
    _nameTextField.backgroundColor = [UIColor clearColor];
    _nameTextField.textColor = kPart_Button_Color;
    _nameTextField.delegate = self;
    
    _passwordTextField.delegate = self;
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.textColor = kPart_Button_Color;
    
    _passwordTextField.tintColor = kPart_Button_Color;
    
    
    [_passwordTextField setValue:kPart_Button_Color forKeyPath:@"_placeholderLabel.textColor"];
    [_nameTextField setValue:kPart_Button_Color forKeyPath:@"_placeholderLabel.textColor"];

    
    
    float regButton_Y = 310.0/667*kScreenHeight;
    [_registerButton setFrame:CGRectMake((kScreentWidth-85)/2, regButton_Y, 85, 40)];
    
    _registerButton.backgroundColor = kPart_Button_Color;
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _registerButton.layer.masksToBounds = YES;
    _registerButton.layer.cornerRadius = _registerButton.frame.size.height/2;
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
        NSString *paramsStr = [NSString stringWithFormat:@"accountname=%@&password=%@&nickname=%@",_nameTextField.text,_passwordTextField.text,_nameTextField.text];
        NSString *registerStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kRegisterUrl];
        [NSURLConnectionRequest requestPOSTUrlString:registerStr andParamStr:paramsStr target:self action:@selector(requestFinished:) andRefresh:YES];
    }
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            NSString *userid = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"id"];
            NSString *userName = _nameTextField.text;
            [OralDBFuncs setCurrentUser:userName UserId:userid UserIconUrl:[dict objectForKey:@"icon"]];
            [OralDBFuncs addUser:userName];
            [OralDBFuncs setCuurentIsDSFLogin:NO andDSFType:0];
            [self enterTopicPage];
        }
        else
        {
            [self createFailAlert:[dict objectForKey:@"remark"]];
        }
    }
    else
    {
        [self createFailAlert:@"请检查网络"];
    }
}

- (void)createFailAlert:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}


- (void)enterTopicPage
{
    TopicMainViewController *topicVC = [[TopicMainViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:topicVC];
    nvc.navigationBarHidden = YES;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)backToLastPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
