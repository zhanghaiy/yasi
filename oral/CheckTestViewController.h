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
@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UILabel *sumTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *teaBackView;
@property (weak, nonatomic) IBOutlet UIImageView *teaCircleImageView;
@property (weak, nonatomic) IBOutlet UILabel *teaDesLabel;
@property (weak, nonatomic) IBOutlet UIButton *teaHeadBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *stuBackView;
@property (weak, nonatomic) IBOutlet UIButton *stuHeadBtn;
@property (strong, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
- (IBAction)followButtonClicked:(id)sender;

@end
