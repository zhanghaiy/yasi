//
//  PractiseCell.h
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PractiseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *partLabel;
@property (weak, nonatomic) IBOutlet UIWebView *textWebView;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;
@property (weak, nonatomic) IBOutlet UIButton *questionButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
