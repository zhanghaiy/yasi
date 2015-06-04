//
//  TPCPersonCenterViewController.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface TPCPersonCenterViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *personInfoBackView;
@property (strong, nonatomic) IBOutlet UIImageView *personBackImgV;
@property (strong, nonatomic) IBOutlet UIButton *personHeadButton;
@property (strong, nonatomic) IBOutlet UIButton *sexButton;
@property (strong, nonatomic) IBOutlet UIButton *ConstellationButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *signatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *loveLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UIButton *enterClassButton;

@property (strong, nonatomic) IBOutlet UIButton *pointProgressButton;

- (IBAction)enterButtonClicked:(id)sender;
- (IBAction)editButtonClicked:(id)sender;

@end
