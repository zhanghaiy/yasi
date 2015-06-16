//
//  MyTeacherViewController.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"


@protocol SelectTeacherDelegate <NSObject>

- (void)selectTeacherId:(NSString *)teacherID;

@end

@interface MyTeacherViewController : TopicParentsViewController

@property (nonatomic,assign) id<SelectTeacherDelegate>delegate;

@end
