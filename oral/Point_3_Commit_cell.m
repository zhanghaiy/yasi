//
//  Point_3_Commit_cell.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Point_3_Commit_cell.h"

@implementation Point_3_Commit_cell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    [_stu_head_imgV setImage:[UIImage imageNamed:@"33.jpg"]];

    _spot_imgV.layer.masksToBounds = YES;
    _spot_imgV.layer.cornerRadius = _spot_imgV.frame.size.height/2.0;
    _spot_imgV.backgroundColor = kPart_Button_Color;
    
    _stu_head_imgV.layer.masksToBounds = YES;
    _stu_head_imgV.layer.cornerRadius = _stu_head_imgV.frame.size.height/2.0;
    
    _playerButton.backgroundColor = kPart_Button_Color;
    _playerButton.layer.masksToBounds = YES;
    _playerButton.layer.cornerRadius = _playerButton.frame.size.height/2.0;
    _playerButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    _playerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _playerButton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
