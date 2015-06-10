//
//  RegisterViewController.h
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backToLastPage:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *upLineLabel;
@property (strong, nonatomic) IBOutlet UILabel *downLineLabel;
@property (strong, nonatomic) IBOutlet UIImageView *registerImgV;
@property (strong, nonatomic) IBOutlet UIImageView *backImgV;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerButtonClicked:(id)sender;

@end
