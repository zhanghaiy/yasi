//
//  ScorePoint_3_Cell.h
//  oral
//
//  Created by cocim01 on 15/5/27.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScorePoint_3_Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *studentHeadButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIImageView *spotImgV;

@property (nonatomic,strong) UIColor *controlsColor;

@end
