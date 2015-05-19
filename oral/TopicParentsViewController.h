//
//  TopicParentsViewController.h
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicParentsViewController : UIViewController

@property (nonatomic,strong) UIView *navTopView;
// 返回按钮
- (void)addBackButtonWithImageName:(NSString *)imageName;
// titleLabel
- (void)addTitleLabelWithTitleWithTitle:(NSString *)title;
@property (nonatomic,strong) UILabel *titleLab;

@end
