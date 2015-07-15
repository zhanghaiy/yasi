//
//  SuccessCell.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "SuccessCell.h"
#import "DeviceManager.h"

@implementation SuccessCell

- (void)awakeFromNib
{
    // Initialization code
    
    _scoreButton.layer.masksToBounds = YES;
    _scoreButton.layer.cornerRadius = _scoreButton.bounds.size.height/2;
    _lineLabel.backgroundColor = [UIColor colorWithWhite:230/255.0 alpha:1];
    _scoreButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize_normal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
