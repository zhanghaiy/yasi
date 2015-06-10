//
//  ApplyClassViewController.h
//  oral
//
//  Created by cocim01 on 15/6/10.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface ApplyClassViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *codeView;
@property (strong, nonatomic) IBOutlet UILabel *codeTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *codeDeleteButton;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UILabel *codeLineLabel;

@property (strong, nonatomic) IBOutlet UIButton *codeAddButton;
- (IBAction)codeAddButtonClicked:(id)sender;
- (IBAction)codeDeleteButtonClicked:(id)sender;




@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *infoDeleteButton;
@property (strong, nonatomic) IBOutlet UITextField *infoTextField;
@property (strong, nonatomic) IBOutlet UILabel *infoLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *infoAddButton;
- (IBAction)infoAddButtonClicked:(id)sender;
- (IBAction)infoDeleteButtonClicked:(id)sender;

@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *classId;

@end
