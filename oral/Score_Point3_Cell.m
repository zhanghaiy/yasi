//
//  Score_Point3_Cell.m
//  oral
//
//  Created by cocim01 on 15/6/1.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "Score_Point3_Cell.h"

@implementation Score_Point3_Cell

- (void)awakeFromNib
{
    // Initialization code
    
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.bounds.size.height/2;
    
    _reviewBackView.backgroundColor = kPart_Button_Color;
    _reviewBackView.layer.masksToBounds = YES;
    _reviewBackView.layer.cornerRadius = _reviewBackView.frame.size.height/2;
    
    _spotImgView.layer.cornerRadius = _spotImgView.frame.size.height/2;
    _spotImgView.backgroundColor = kPart_Button_Color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
