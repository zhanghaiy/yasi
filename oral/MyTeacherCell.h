//
//  MyTeacherCell.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTeacherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *teaHeadImgV;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *teacherDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@end
