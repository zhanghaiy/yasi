//
//  ClassCell.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *classImageButton;
@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *classTeacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *classDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@end
