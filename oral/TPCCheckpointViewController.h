//
//  TPCCheckpointViewController.h
//  oral
//
//  Created by cocim01 on 15/5/15.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "TopicParentsViewController.h"
 /*
    闯关入口页
  */
@interface TPCCheckpointViewController : TopicParentsViewController
@property (strong, nonatomic) IBOutlet UIButton *exerciseBookBtn;
@property (strong, nonatomic) IBOutlet UILabel *exeLable;
@property (strong, nonatomic) IBOutlet UIButton *scoreButton;
@property (strong, nonatomic) IBOutlet UILabel *scoreLable;
@property (strong, nonatomic) IBOutlet UIButton *leftMarkBtn;
@property (strong, nonatomic) IBOutlet UIButton *middleMarkBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightMarkBtn;
@property (strong, nonatomic) IBOutlet UIButton *startTestBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *partScrollView;
- (IBAction)testButtonClicked:(id)sender;
- (IBAction)practiseBook:(id)sender;
- (IBAction)scoreMenu:(id)sender;

@property (nonatomic,strong) NSDictionary *topicDict;

@end
