//
//  MyTeacherCell.m
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "MyTeacherCell.h"

@implementation MyTeacherCell

- (void)awakeFromNib
{
    // Initialization code
    
    _teacherDesLabel.textColor = [UIColor colorWithWhite:185/255.0 alpha:1];
    _teaHeadImgV.layer.masksToBounds = YES;
    _teaHeadImgV.layer.cornerRadius = _teaHeadImgV.bounds.size.height/2;
    _teaHeadImgV.layer.borderColor = [UIColor colorWithWhite:235/255.0 alpha:1].CGColor;
    _teaHeadImgV.layer.borderWidth = 1;
    
    _selectButton.layer.masksToBounds = YES;
    _selectButton.layer.cornerRadius = _selectButton.frame.size.height/2;
    _selectButton.layer.borderColor = kPart_Button_Color.CGColor;
    _selectButton.layer.borderWidth = 1;
    
    
    _lineLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
