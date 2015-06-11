//
//  LogInViewController.h
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *backV;
@property (strong, nonatomic) IBOutlet UIImageView *logoImgV;

@property (strong, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;

@property (strong, nonatomic) IBOutlet UIView *loginBackView;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;

@end
