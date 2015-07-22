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
{
    NSString *_currentName;
    NSString *_curretnUid;
    BOOL _log_dsf;
    NSInteger _type_DSF;
}
@end

@implementation LogInViewController

#define kQQButtonTag 50
#define kWechatTag 51
#define KSinaWeiboTag 52
#define kRenrenTag 53

#pragma mark - 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 修改frame
    self.view.frame = CGRectMake(0, 0, kScreentWidth, kScreenHeight);
    [self uiConfig];
    _log_dsf = NO;
    _type_DSF = 0;
    _backV.frame = self.view.bounds;
    [self.view sendSubviewToBack:_backV];
}

#pragma mark - UI配置
- (void)uiConfig
{
    NSInteger logo_y = 100.0/667*kScreenHeight;
    NSInteger logo_h = 65.0/667*kScreenHeight;
    NSInteger logo_W = 67.0/667*kScreenHeight;
    _logoImgV.frame = CGRectMake((kScreentWidth-logo_W)/2, logo_y, logo_W, logo_h);
    
    NSInteger control_H = 40.0/667*kScreenHeight;
    NSInteger space_H = 30.0/667*kScreenHeight;
    
    NSInteger nameTextFie_Y = 250.0/667*kScreenHeight;
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
    [_passWordTextField setValue:kPart_Button_Color forKeyPath:@"_placeholderLabel.textColor"];
    [_userNameTextFiled setValue:kPart_Button_Color forKeyPath:@"_placeholderLabel.textColor"];
    
    
    
    NSInteger thidPart_Y = 536.0/667*kScreenHeight;
    NSInteger thirdPart_W = 53.0/375*kScreentWidth;
    NSInteger thirdPart_H = 29.0/667*kScreenHeight;
    NSInteger spaceToLeft = 29.0/375*kScreentWidth;

    [_qq_button setFrame:CGRectMake(spaceToLeft, thidPart_Y, thirdPart_W, thirdPart_H)];
    
    [_wechat_button setFrame:CGRectMake(spaceToLeft*2+thirdPart_W, thidPart_Y, thirdPart_W, thirdPart_H)];
    
    [_sina_button setFrame:CGRectMake(spaceToLeft*3+thirdPart_W*2, thidPart_Y, thirdPart_W, thirdPart_H)];
    
    [_renren_button setFrame:CGRectMake(spaceToLeft*4+thirdPart_W*3, thidPart_Y, thirdPart_W, thirdPart_H)];

    
    _qq_button.tag = kQQButtonTag;
    _wechat_button.tag = kWechatTag;
    _sina_button.tag = KSinaWeiboTag;
    _renren_button.tag = kRenrenTag;
    
}

#pragma mark - 收键盘
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

#pragma mark - 登陆按钮点击事件
- (IBAction)loginButtonClicked:(id)sender
{
    if ([_userNameTextFiled.text length]>0&&[_passWordTextField.text length]>0)
    {
        NSString *paramStr = [NSString stringWithFormat:@"accountname=%@&password=%@",_userNameTextFiled.text,_passWordTextField.text] ;
        NSString *logInUrlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kLogInUrl];
        [NSURLConnectionRequest requestPOSTUrlString:logInUrlStr andParamStr:paramStr target:self action:@selector(loginBack:) andRefresh:YES];
    }
}

#pragma mark - 网络
- (void)loginBack:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            // 登陆成功 保存个人信息
            NSString *userid = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"studentid"];
            NSString *userName = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"studentname"];
            [OralDBFuncs setCurrentUser:userName UserId:userid UserIconUrl:[dict objectForKey:@"icon"]];
            [OralDBFuncs addUser:userName];
            [OralDBFuncs setCuurentIsDSFLogin:_log_dsf andDSFType:_type_DSF];
            //更新登录时间
            [OralDBFuncs updateUserLastLoginTimeStamp:userName];
            // 跳转页面
            [self enterTopic];
        }
        else
        {
            [self createFailAlert:[dict objectForKey:@"remark"]];
        }
    }
    else
    {
       // 网络问题
        [self createFailAlert:@"网络错误"];
    }
}

#pragma mark - 警告框
- (void)createFailAlert:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertV show];
}

#pragma mark - 进入主页
- (void)enterTopic
{
    TopicMainViewController *topicVC = [[TopicMainViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:topicVC];
    nvc.navigationBarHidden = YES;
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - 注册
- (IBAction)registerButtonClicked:(id)sender
{
    RegisterViewController *registerVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:registerVC animated:YES completion:nil];
}


#pragma mark - 第三方登陆
- (IBAction)loginOfThirdPart:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag)
    {
        case kQQButtonTag:// QQ
        {
            _type_DSF = ShareTypeQQSpace;
            [ShareSDK getUserInfoWithType:ShareTypeQQSpace authOptions:nil result:^(BOOL result,id<ISSPlatformUser> userInfo,id<ICMErrorInfo> error) {
                if (result) {
                    NSLog(@"登录成功");
                    //打印输出用户uid：
                    NSLog(@"uid = %@",[userInfo uid]);
                    //打印输出用户昵称：
                    NSLog(@"name = %@",[userInfo nickname]);
                    //打印输出用户头像地址：
                    NSLog(@"icon = %@",[userInfo profileImage]);
                    [self commitToOralSeverWithName:[userInfo nickname] UID:[userInfo uid]];
                }
                else{
                    
//                    NSLog(@"授权失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                    [self createFailAlert:@"授权失败"];
                }
            }];
        }
            break;
        case kWechatTag:// 微信
        {
            _type_DSF = ShareTypeWeixiSession;
            [ShareSDK getUserInfoWithType:ShareTypeWeixiSession authOptions:nil result:^(BOOL result,id<ISSPlatformUser> userInfo,id<ICMErrorInfo> error) {
                if (result) {

                    NSLog(@"登录成功");
                    [self commitToOralSeverWithName:[userInfo nickname] UID:[userInfo uid]];
                    //成功登录后，判断该用户的ID是否在自己的数据库中。
                    //如果有直接登录，没有就将该用户的ID和相关资料在数据库中创建新用户。
                    //            [self reloadStateWithType:ShareTypeSinaWeibo];
                }
                else
                {
                    [self createFailAlert:@"授权失败"];
                }
            }];
        }
            break;
        case KSinaWeiboTag:// 新浪微博
        {
            _type_DSF = ShareTypeSinaWeibo;
            [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error)
             {
                 if (result)
                 {
                     [userInfo uid];
                     [userInfo nickname];
                     [userInfo profileImage];
                     NSLog(@"%@",[userInfo sourceData]);
                     [self commitToOralSeverWithName:[userInfo nickname] UID:[userInfo uid]];
                 }
                 else
                 {
                     [self createFailAlert:@"授权失败"];
                 }
             }];
        }
            break;
        case kRenrenTag:// 人人
        {
            _type_DSF = ShareTypeRenren;
            [ShareSDK getUserInfoWithType:ShareTypeRenren authOptions:nil result:^(BOOL result,id<ISSPlatformUser> userInfo,id<ICMErrorInfo> error) {
                if (result)
                {
                    [self commitToOralSeverWithName:[userInfo nickname] UID:[userInfo uid]];
                }
                else
                {
                    [self createFailAlert:@"登陆失败"];
                }
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 第三方登陆后台验证
- (void)commitToOralSeverWithName:(NSString *)name UID:(NSString *)uid
{
    _currentName = name;
    _curretnUid = uid;
    NSString *urlString = [NSString stringWithFormat:@"%@%@?accountname=%@&password=111111&dsf=1&nickname=%@",kBaseIPUrl,kRegisterUrl,uid,name];
    [NSURLConnectionRequest requestWithUrlString:urlString target:self aciton:@selector(dsfRegister:) andRefresh:YES];
}

- (void)dsfRegister:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            NSString *userid = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"id"];
            NSString *userName = [[[dict objectForKey:@"studentInfos"] lastObject] objectForKey:@"name"];
            [OralDBFuncs setCurrentUser:userName UserId:userid UserIconUrl:[dict objectForKey:@"icon"]];
            [OralDBFuncs addUser:userName];
            [OralDBFuncs setCuurentIsDSFLogin:YES andDSFType:_type_DSF];
            //更新登录时间 
            [OralDBFuncs updateUserLastLoginTimeStamp:userName];
            // 跳转页面
            [self enterTopic];
        }
        else if ([[dict objectForKey:@"respCode"] integerValue] == 9002)
        {
            // 用户已存在  重新登录
            _log_dsf = YES;
            NSString *paramStr = [NSString stringWithFormat:@"accountname=%@&password=111111&dsf=1&nickname=%@",_curretnUid,_currentName];
            NSString *logInUrlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kLogInUrl];
            [NSURLConnectionRequest requestPOSTUrlString:logInUrlStr andParamStr:paramStr target:self action:@selector(loginBack:) andRefresh:YES];
        }
        else
        {
            [self createFailAlert:[dict objectForKey:@"remark"]];
        }
    }
    else
    {
        [self createFailAlert:@"检查网络"];
    }
}


@end
