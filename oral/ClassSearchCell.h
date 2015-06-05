//
//  ClassSearchCell.h
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassSearchCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *leftBackView;
@property (strong, nonatomic) IBOutlet UIButton *classHeadButton;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *classCountsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classTeacherLabel;
@property (strong, nonatomic) IBOutlet UILabel *classDesLabel;
@property (strong, nonatomic) IBOutlet UIButton *addClassButton;

@end
