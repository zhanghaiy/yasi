//
//  FooterView.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
- (IBAction)selectButtonClicked:(id)sender;

@end
