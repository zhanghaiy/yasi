//
//  ClassIntroduceViewController.h
//  oral
//
//  Created by cocim01 on 15/5/25.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface ClassIntroduceViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *classBaseView;
@property (strong, nonatomic) IBOutlet UIImageView *baseImgV;
@property (strong, nonatomic) IBOutlet UIImageView *classImgV;
@property (strong, nonatomic) IBOutlet UILabel *classCountsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classCreateTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
- (IBAction)joinButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *classTeacherView;
@property (strong, nonatomic) IBOutlet UIButton *teaHeadImageButton;
@property (strong, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *teaDetailLabel;
@property (strong, nonatomic) IBOutlet UIView *classInfoView;
@property (strong, nonatomic) IBOutlet UILabel *classTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *classDesLabel;
- (IBAction)enter_Teacher_person_center:(id)sender;

@property (nonatomic,copy) NSString *classId;

@end
