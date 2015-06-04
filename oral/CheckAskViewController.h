//
//  CheckAskViewController.h
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
/*
  point3 -- > 问答
 */
@interface CheckAskViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *teaHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *teaQuestionLabel;
//@property (weak, nonatomic) IBOutlet UIButton *teaQuestionBtn;
@property (weak, nonatomic) IBOutlet UIView *teaQuestioBackV;

@property (weak, nonatomic) IBOutlet UIView *stuView;

@property (weak, nonatomic) IBOutlet UIImageView *stuHeadImgV;



@property (weak, nonatomic) IBOutlet UIButton *followAnswerButton;

- (IBAction)followAnswer:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *CommitLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *commitRightButton;
- (IBAction)commitButtonClicked:(id)sender;

//@property (nonatomic,assign) NSInteger currentPartCounts;// 当前part 共3部分 范围（0--2）
@property (nonatomic,assign) NSInteger currentPointCounts;// 当前关卡 ==0 跟读：0 填空：1 问答：2


@end
