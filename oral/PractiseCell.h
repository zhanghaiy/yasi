//
//  PractiseCell.h
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PracticeFollowButton.h"

@interface PractiseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *partLabel;
@property (weak, nonatomic) IBOutlet UIWebView *textWebView;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;
@property (weak, nonatomic) IBOutlet UIButton *play_self_Button;
@property (weak, nonatomic) IBOutlet UIButton *play_answer_Button;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
- (IBAction)buttonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet PracticeFollowButton *followButton;


@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) NSInteger buttonIndex;// 标记被点击的按钮tag值
@property (nonatomic,assign) NSInteger cellIndex;// cell索引
@property (nonatomic,assign) NSDictionary *topicResource;// 资源 暂时写字典 用于传值的

@property (nonatomic,assign) NSInteger recive_score;// 得分

@end
