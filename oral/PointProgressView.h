//
//  PointProgressView.h
//  oral
//
//  Created by cocim01 on 15/6/9.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface PointProgressView : UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLAbel;
@property (strong, nonatomic) IBOutlet CustomProgressView *progressV;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;

@end
