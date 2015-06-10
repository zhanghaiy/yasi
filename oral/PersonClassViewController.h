//
//  PersonClassViewController.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface PersonClassViewController : TopicParentsViewController

@property (nonatomic,strong) NSArray *classListArray;

@property (nonatomic,copy) NSString *teacherId;
@property (nonatomic,copy) NSString *userId;

@end
