//
//  ScorePoint_3_Cell.m
//  oral
//
//  Created by cocim01 on 15/5/27.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScorePoint_3_Cell.h"

@implementation ScorePoint_3_Cell

- (void)awakeFromNib
{
    // Initialization code
    
    _studentHeadButton.layer.masksToBounds = YES;
    _studentHeadButton.layer.cornerRadius = _studentHeadButton.bounds.size.height/2;
    _spotImgV.layer.cornerRadius = _spotImgV.bounds.size.height/2;
    _audioButton.layer.masksToBounds = YES;
    _audioButton.layer.cornerRadius = _audioButton.bounds.size.height/2;
}

-(void)setControlsColor:(UIColor *)controlsColor
{
    _controlsColor = controlsColor;
    _audioButton.backgroundColor = _controlsColor;
    _spotImgV.backgroundColor = _controlsColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
