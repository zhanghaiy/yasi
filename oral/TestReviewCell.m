//
//  TestReviewCell.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TestReviewCell.h"

@implementation TestReviewCell

- (void)awakeFromNib
{
    // Initialization code
    
    _headButton.layer.masksToBounds = YES;
    _headButton.layer.cornerRadius = _headButton.bounds.size.height/2.0;
    _headButton.layer.borderWidth = 0;
    _spotImgV.layer.cornerRadius = _spotImgV.bounds.size.height/2.0;
    _scoreButton.layer.cornerRadius = _scoreButton.bounds.size.height/2.0;
    
    CGRect rect = _scoreButton.frame;
    rect.origin.x = kScreentWidth - rect.size.width-15;
    _scoreButton.frame = rect;
}

- (void)setControlsColor:(UIColor *)controlsColor
{
    _controlsColor = controlsColor;
    _spotImgV.backgroundColor = _controlsColor;
    _reviewBackView.backgroundColor = _controlsColor;
    _titleLabel.textColor = _controlsColor;
    _lineLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _lineLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
