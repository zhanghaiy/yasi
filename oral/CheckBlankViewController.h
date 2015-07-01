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
@property (strong, nonatomic) IBOutlet UIView *topQuestionCountView;

@property (strong, nonatomic) IBOutlet UIImageView *teaHeadImgView;

@property (strong, nonatomic) IBOutlet UILabel *teaQuestionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *teaQuestionBackImgV;


@property (strong, nonatomic) IBOutlet UIView *studentView;
@property (strong, nonatomic) IBOutlet UILabel *stuFollowLabel;
@property (strong, nonatomic) IBOutlet UILabel *stuCountLabel;

@property (strong, nonatomic) IBOutlet UILabel *stuLineLabel;
@property (strong, nonatomic) IBOutlet UIWebView *StuAnswerWebView;

@property (strong, nonatomic) IBOutlet UILabel *stuTimeProgressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stuHeadImgView;

@property (strong, nonatomic) IBOutlet UIButton *stuScoreButton;

@property (strong, nonatomic) IBOutlet UIButton *followAnswerButton;

@property (strong, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueButtonClicked:(id)sender;
- (IBAction)followAnswerButtonClicked:(id)sender;


//@property (nonatomic,assign) NSInteger currentPartCounts;// 当前part 共3部分 范围（0--2）
@property (nonatomic,assign) int currentPointCounts;// 当前关卡 ==0 跟读：0 填空：1 问答：2


@end
