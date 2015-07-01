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
@property (strong, nonatomic) IBOutlet UIView *questionCountsView;
@property (strong, nonatomic) IBOutlet UIImageView *teacherHeadImgView;
@property (strong, nonatomic) IBOutlet UILabel *questionTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *questionTextBackImgV;


@property (strong, nonatomic) IBOutlet UIView *studentView;
@property (strong, nonatomic) IBOutlet UILabel *stuTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *stuAnswerCountsLabel;
@property (strong, nonatomic) IBOutlet UILabel *lineLabel;

@property (strong, nonatomic) IBOutlet UIWebView *answerTextWebView;
@property (strong, nonatomic) IBOutlet UILabel *timeProgressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stuImageView;
@property (strong, nonatomic) IBOutlet UIButton *scoreButton;

@property (strong, nonatomic) IBOutlet UIButton *answerButton;
@property (strong, nonatomic) IBOutlet UIButton *addPracticeButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)answerButtonClicked:(id)sender;

- (IBAction)addPractiseBook:(id)sender;

- (IBAction)nextQuestion:(id)sender;



//@property (nonatomic,assign) NSInteger currentPartCounts;// 当前part 共3部分 范围（0--2）
//@property (nonatomic,assign) int currentPointCounts;// 当前关卡 ==0 跟读：0 填空：1 问答：2


@end
