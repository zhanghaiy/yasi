//
//  TeacherPersonCenterViewController.h
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"

@interface TeacherPersonCenterViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIScrollView *topScrollV;



@property (nonatomic,copy) NSString *teacherId;
//@property (nonatomic,strong) NSDictionary *teacherDic;

@end
