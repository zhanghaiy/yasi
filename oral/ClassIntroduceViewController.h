//
//  ClassIntroduceViewController.h
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface ClassIntroduceViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *classBaseView;
@property (weak, nonatomic) IBOutlet UIImageView *baseImgV;
@property (weak, nonatomic) IBOutlet UIImageView *classImgV;
@property (weak, nonatomic) IBOutlet UILabel *classCountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *classCreateTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)joinButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *classTeacherView;
@property (weak, nonatomic) IBOutlet UIButton *teaHeadImageButton;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *teaDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherDesLabel;
@property (weak, nonatomic) IBOutlet UIView *classInfoView;
@property (weak, nonatomic) IBOutlet UILabel *classTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *classDesLabel;
- (IBAction)enter_Teacher_person_center:(id)sender;

@end
