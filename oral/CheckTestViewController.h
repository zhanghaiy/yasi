//
//  CheckTestViewController.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

#import "CircleProgressView.h"

@interface CheckTestViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *topBackView;
@property (strong, nonatomic) IBOutlet UILabel *sumTimeLabel;
@property (strong, nonatomic) IBOutlet UIView *teaBackView;
@property (strong, nonatomic) IBOutlet UIImageView *teaCircleImageView;
@property (strong, nonatomic) IBOutlet UIButton *tea_show_btn;
- (IBAction)showQuestionText:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *teaDesLabel;

@property (strong, nonatomic) IBOutlet UIImageView *teaHeadImageV;


//@property (strong, nonatomic) IBOutlet UIButton *teaHeadBtn;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UIView *stuBackView;
//@property (strong, nonatomic) IBOutlet UIButton *stuHeadBtn;
@property (strong, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
- (IBAction)followButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *stuHeadImageV;


@end
