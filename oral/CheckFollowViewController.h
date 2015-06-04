//
//  CheckFollowViewController.h
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
/*
   point1 --> 跟读界面
 */
@interface CheckFollowViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *questionCountsView;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *teacherHeadImgView;
@property (weak, nonatomic) IBOutlet UIView *teacherQueationBackView;
@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;


@property (weak, nonatomic) IBOutlet UIView *studentView;
@property (weak, nonatomic) IBOutlet UILabel *stuTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stuAnswerCountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (weak, nonatomic) IBOutlet UILabel *answerTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeProgressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stuImageView;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;

@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *addPracticeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)answerButtonClicked:(id)sender;

- (IBAction)addPractiseBook:(id)sender;
- (IBAction)addPractiseBookTouchDown:(id)sender;

- (IBAction)nextQuestion:(id)sender;
- (IBAction)nextQuestionTouchDown:(id)sender;



//@property (nonatomic,assign) NSInteger currentPartCounts;// 当前part 共3部分 范围（0--2）
@property (nonatomic,assign) NSInteger currentPointCounts;// 当前关卡 ==0 跟读：0 填空：1 问答：2


@end
