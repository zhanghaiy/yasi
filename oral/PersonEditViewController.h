//
//  PersonEditViewController.h
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"


@protocol EditDelegate <NSObject>

- (void)editSuccess;

@end

@interface PersonEditViewController : TopicParentsViewController

@property (nonatomic,strong) NSDictionary *personInfoDict;

@property (nonatomic,assign) id<EditDelegate> delegate;


@end
