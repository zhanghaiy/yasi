//
//  PractiseCell.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PractiseCell.h"

@implementation PractiseCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
//    NSString *strHTML = [NSString stringWithFormat:@"<a href='http://my.oschina.net/duxinfeng'>%@</a> 测试富文本 %@",@"The Ansewr is The Ansewr is The Ansewr is The Ansewr is ",@"2015-05-27"];
//     [_textWebView loadHTMLString:strHTML baseURL:nil];
    
    _scoreButton.layer.masksToBounds = YES;
    _scoreButton.layer.cornerRadius = _scoreButton.frame.size.height/2;
    
    _lineLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:249/255.0 blue:250/255.0 alpha:1];
}

- (void)setCellIndex:(NSInteger)cellIndex
{
    _cellIndex = cellIndex;
    _play_self_Button.tag = kPract_Listen_self_Button_Tag + _cellIndex;
    _play_answer_Button.tag = kPract_Play_answer_Button_Tag + _cellIndex;
    _followButton.tag = kPract_Follow_Button_Tag + _cellIndex;
    _deleteButton.tag = kPract_Delete_Button_Tag + _cellIndex;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRecive_score:(NSInteger)recive_score
{
    _recive_score = recive_score;
    UIColor *backColor = (_recive_score<60)?kBad_Score_Color:((_recive_score<80)?kGood_Score_Color:kPer_Score_Color);
    [_scoreButton setBackgroundColor:backColor];
    [_scoreButton setTitle:[NSString stringWithFormat:@"%ld",_recive_score] forState:UIControlStateNormal];
}

- (IBAction)buttonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:self.action])
    {
        _buttonIndex = ((UIButton *)sender).tag;
        [self.delegate performSelector:self.action withObject:self afterDelay:NO];
    }
}
@end
