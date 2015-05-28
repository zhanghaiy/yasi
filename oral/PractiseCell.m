//
//  PractiseCell.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PractiseCell.h"

@implementation PractiseCell

- (void)awakeFromNib
{
    // Initialization code
    
   

     NSString *strHTML = [NSString stringWithFormat:@"<a href='http://my.oschina.net/duxinfeng'>%@</a> 测试富文本 %@",@"暂时用这个例子",@"2015-05-27"];
     [_textWebView loadHTMLString:strHTML baseURL:nil];
    
    _questionButton.layer.masksToBounds = YES;
    _questionButton.layer.masksToBounds = _questionButton.frame.size.height/2;
    
    _answerButton.layer.masksToBounds = YES;
    _answerButton.layer.masksToBounds = _answerButton.frame.size.height/2;
    
    _followButton.layer.masksToBounds = YES;
    _followButton.layer.masksToBounds = _followButton.frame.size.height/2;
    
    self.deleteButton.layer.masksToBounds = YES;
    self.deleteButton.layer.masksToBounds = _deleteButton.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
