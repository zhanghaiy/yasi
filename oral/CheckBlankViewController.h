//
//  CheckBlankViewController.h
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
/*
  point2 --> 填空
 */
@interface CheckBlankViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *topQuestionCountView;

@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *teaHeadImgView;

@property (strong, nonatomic) IBOutlet UIView *teaQuestionBackView;
@property (weak, nonatomic) IBOutlet UILabel *teaQuestionLabel;


@property (weak, nonatomic) IBOutlet UIView *studentView;
@property (weak, nonatomic) IBOutlet UILabel *stuFollowLabel;
@property (weak, nonatomic) IBOutlet UILabel *stuCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *stuLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *stuAnswerLabel;

@property (weak, nonatomic) IBOutlet UILabel *stuTimeProgressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stuHeadImgView;

@property (weak, nonatomic) IBOutlet UIButton *stuScoreButton;

@property (weak, nonatomic) IBOutlet UIButton *followAnswerButton;

@property (weak, nonatomic) IBOutlet UIButton *addBookButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)addBookClicked:(id)sender;
- (IBAction)continueButtonClicked:(id)sender;
- (IBAction)followAnswerButtonClicked:(id)sender;


//@property (nonatomic,assign) NSInteger currentPartCounts;// 当前part 共3部分 范围（0--2）
@property (nonatomic,assign) NSInteger currentPointCounts;// 当前关卡 ==0 跟读：0 填空：1 问答：2


@end
