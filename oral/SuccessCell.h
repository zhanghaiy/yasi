//
//  SuccessCell.h
//  oral
//
//  Created by cocim01 on 15/5/23.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuccessCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIWebView *htmlWebView;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@end
