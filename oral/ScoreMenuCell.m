//
//  ScoreMenuCell.m
//  oral
//
//  Created by cocim01 on 15/5/26.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreMenuCell.h"

@implementation ScoreMenuCell

- (void)awakeFromNib
{
    // Initialization code
    
    _lineLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    _scoreButton.layer.cornerRadius = _scoreButton.bounds.size.height/2;
    
//    NSString *strHTML = @"<p>你好</p><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;这是一个例子，请显示</p><p>外加一个table</p><table><tbody><tr class=\"firstRow\"><td valign=\"top\" width=\"200\">aaaa</td><td valign=\"top\" width=\"200\">bbbb</td><td valign=\"top\" width=\"200\">cccc</td></tr></tbody></table><p></p>";
    NSString *strHTML = [NSString stringWithFormat:@"<a href='http://my.oschina.net/duxinfeng'>%@</a> 测试时间 %@",@"新风作浪",@"2015-05-27"];
    
    [_textWebView loadHTMLString:strHTML baseURL:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
