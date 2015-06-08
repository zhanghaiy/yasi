//
//  PersonProgressViewController.h
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
#import "CustomProgressView.h"

@interface PersonProgressViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIView *topBackView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLAbel;
@property (strong, nonatomic) IBOutlet CustomProgressView *progressV;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;


@end
