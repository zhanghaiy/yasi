//
//  TeacherPersonCenterViewController.h
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface TeacherPersonCenterViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIScrollView *topScrollV;
@property (strong, nonatomic) IBOutlet UIView *tea_Class_BackView;
@property (strong, nonatomic) IBOutlet UIImageView *tea_class_head_imageV;
@property (strong, nonatomic) IBOutlet UILabel *tea_class_name_Label;
@property (strong, nonatomic) IBOutlet UILabel *tea_class_des_Label;


@property (strong, nonatomic) IBOutlet UIView *teach_Characteristic_View;
@property (strong, nonatomic) IBOutlet UILabel *teach_Characteristic_title_label;
@property (strong, nonatomic) IBOutlet UILabel *teach_Characteristic_des_label;


@property (strong, nonatomic) IBOutlet UIView *teach_Resume_View;
@property (strong, nonatomic) IBOutlet UILabel *teach_resume_title_LAbel;

@property (strong, nonatomic) IBOutlet UILabel *teach_resume_des_label;


@property (strong, nonatomic) IBOutlet UIButton *class_list_Button;
- (IBAction)class_list_button_clicked:(id)sender;

@end
