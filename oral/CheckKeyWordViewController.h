//
//  CheckKeyWordViewController.h
//  oral
//
//  Created by cocim01 on 15/5/21.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface CheckKeyWordViewController : TopicParentsViewController
/*
    关键词提示界面
 */
@property (weak, nonatomic) IBOutlet UIButton *jumpButton;

@property (weak, nonatomic) IBOutlet UIScrollView *keyScrollView;

@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *startPointButton;

@property (nonatomic,assign) NSInteger pointCounts;


@end
