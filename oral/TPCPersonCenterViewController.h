//
//  TPCPersonCenterViewController.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface TPCPersonCenterViewController : TopicParentsViewController
@property (weak, nonatomic) IBOutlet UIView *personInfoBackView;
@property (weak, nonatomic) IBOutlet UIImageView *personBackImgV;
@property (weak, nonatomic) IBOutlet UIButton *personHeadButton;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UIButton *ConstellationButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;

@property (weak, nonatomic) IBOutlet UIView *classView;

@property (weak, nonatomic) IBOutlet UILabel *myClassLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightClassImgV;
@property (weak, nonatomic) IBOutlet UIButton *enterClassButton;

@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightProgressImgV;
@property (weak, nonatomic) IBOutlet UIButton *enterProgressButton;
- (IBAction)enterButtonClicked:(id)sender;

@end
