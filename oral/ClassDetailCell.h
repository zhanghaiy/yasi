//
//  ClassDetailCell.h
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface ClassDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *stuHeadImageView;
@property (strong, nonatomic) IBOutlet UILabel *stuNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *stuPassLabel;
@property (strong, nonatomic) IBOutlet CustomProgressView *stuPassProgressView;
@property (strong, nonatomic) IBOutlet UILabel *stuPassCountLabel;

@end
