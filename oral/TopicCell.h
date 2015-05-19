//
//  TopicCell.h
//  IELTS
//
//  Created by cocim01 on 15/5/13.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface TopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *topicButton;
@property (retain, nonatomic) IBOutlet CustomProgressView *topicProgressV;
@property (weak, nonatomic) IBOutlet UILabel *topicTitle;
@property (nonatomic,strong) UIColor *progressColor;


@end
