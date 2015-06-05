//
//  ClassDetailCell.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassDetailCell.h"

@implementation ClassDetailCell

- (void)awakeFromNib
{
    // Initialization code
    
    _stuHeadImageView.layer.masksToBounds = YES;
    _stuHeadImageView.layer.cornerRadius = _stuHeadImageView.frame.size.height/2;
    _stuHeadImageView.layer.borderWidth = 1;
    _stuHeadImageView.layer.borderColor = [UIColor colorWithRed:225/255.0 green:235/255.0 blue:236/255.0 alpha:1].CGColor;
    
    _stuNameLabel.textColor = [UIColor colorWithWhite:115/255.0 alpha:1];
    _stuPassLabel.textColor = [UIColor colorWithWhite:135/255.0 alpha:1];
    _stuPassCountLabel.textColor = kPart_Button_Color;
    
    _stuPassProgressView.progress = 0.8;
    _stuPassProgressView.color = kPart_Button_Color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
