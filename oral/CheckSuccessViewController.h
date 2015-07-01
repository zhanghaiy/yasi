//
//  CheckSuccessViewController.h
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
/*
    闯关成功 or 失败 过渡页
 */
@interface CheckSuccessViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UIButton *topShareButton;
@property (weak, nonatomic) IBOutlet UILabel *topDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *topScoreLabel;


@property (weak, nonatomic) IBOutlet UILabel *midTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *midTableView;


@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backToLastPage:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueNextPoint:(id)sender;



@end
