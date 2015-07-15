//
//  Point_3_Review_Cell.m
//  oral
//
//  Created by cocim01 on 15/7/2.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Point_3_Review_Cell.h"

@implementation Point_3_Review_Cell

- (void)awakeFromNib
{
    // Initialization code
    
    self.backgroundColor = [UIColor whiteColor];
    [_tea_head_imgV setImage:[UIImage imageNamed:@"33.jpg"]];
    [_stu_head_imgV setImage:[UIImage imageNamed:@"33.jpg"]];
    
    _tea_spot_imgV.layer.masksToBounds = YES;
    _tea_spot_imgV.layer.cornerRadius = _tea_spot_imgV.frame.size.height/2.0;
    _tea_spot_imgV.backgroundColor = kPart_Button_Color;
    
    _spotImgV.layer.masksToBounds = YES;
    _spotImgV.layer.cornerRadius = _spotImgV.frame.size.height/2.0;
    _spotImgV.backgroundColor = kPart_Button_Color;
    
    _tea_review_button.layer.masksToBounds = YES;
    _tea_review_button.layer.cornerRadius = _tea_review_button.frame.size.height/2.0;
    _tea_review_button.backgroundColor = kPart_Button_Color;
    _tea_review_button.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];

    _player_button.layer.masksToBounds = YES;
    _player_button.layer.cornerRadius = _player_button.frame.size.height/2.0;
    _player_button.backgroundColor = kPart_Button_Color;
    _player_button.titleLabel.font = [UIFont systemFontOfSize:kFontSize_14];
    
    _player_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _player_button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10);
    
    _player_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _player_button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10);
    
    
    _tea_head_imgV.layer.masksToBounds = YES;
    _tea_head_imgV.layer.cornerRadius = _tea_head_imgV.frame.size.height/2.0;
    _stu_head_imgV.layer.masksToBounds = YES;
    _stu_head_imgV.layer.cornerRadius = _stu_head_imgV.frame.size.height/2.0;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
