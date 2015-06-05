//
//  ClassDetailViewController.h
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface ClassDetailViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *classBackView;
@property (strong, nonatomic) IBOutlet UILabel *noticeLable;
@property (strong, nonatomic) IBOutlet UILabel *noticeDesLabel;
@property (strong, nonatomic) IBOutlet UIButton *noticeOpenButton;
@property (strong, nonatomic) IBOutlet UIView *teaBackView;
@property (strong, nonatomic) IBOutlet UIButton *teaHeadImageBtn;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *teaCateLabel;
@property (strong, nonatomic) IBOutlet UILabel *teaDesLabel;

@end
