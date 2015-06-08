//
//  ScoreTestMenuViewController.m
//  oral
//
//  Created by cocim01 on 15/5/28.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ScoreTestMenuViewController.h"
#import "TestReviewCell.h"


@interface ScoreTestMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_reviewTableV;
    UIView *_headerV;
    NSArray *_textArray;// 模拟
}
@end

@implementation ScoreTestMenuViewController
#define kHeaderViewHeight 105




#define kCellHeight 100
#define kTextBackBaseWIdth (kScreentWidth-100)
#define kTextBackBaseHeight 34
#define kTextBaseWIdth (kScreentWidth-120)
#define kTextBaseHeight 20
#define kCellFont 12

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    
    self.view.backgroundColor = _backgroundViewColor;
    
    _textArray = @[@"还不错呦，继续努力！！！",@"还不错，部分单词发音不够标准~~，有待加强~目前可以继续往下进行还不错，   部分单词发音不够标准~~，有待加强~目前可以继续往下进行还不错，部分单词发音不够标准~~，有待加强~目前可以继续往下进行",@"成绩不太理想，发音不够标准，流畅，需加强练习，重复练习，不易往下进行，加油~~~"];
    
    _reviewTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _reviewTableV.delegate = self;
    _reviewTableV.dataSource = self;
    _reviewTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_reviewTableV];
    
    _reviewTableV.backgroundColor = _backgroundViewColor;
    
}


- (CGRect)getCellHeightWithText:(NSString *)text andWidth:(NSInteger)width Height:(NSInteger)height Font:(NSInteger)fontSize
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return rect;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _textArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 此处+5 式界面美观 不至于有紧凑感
    CGRect rect = [self getCellHeightWithText:[_textArray objectAtIndex:indexPath.section] andWidth:kTextBaseWIdth Height:9999 Font:kCellFont];
    return (rect.size.height>kTextBaseHeight)?kCellHeight + rect.size.height-kTextBaseHeight+5:kCellHeight;
//    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"TestReviewCell";
    TestReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"TestReviewCell" owner:self options:0] lastObject];
    }
    cell.reviewLabel.numberOfLines = 0;
    if (indexPath.section == 0)
    {
        // 综合评价
        cell.titleLabel.text = @"综合评价";
        cell.scoreButton.hidden = NO;
        // 分数颜色 根据分数变化
        cell.scoreButton.backgroundColor = _perfColor;
    }
    else
    {
        cell.titleLabel.text = [NSString stringWithFormat:@"Part%ld",indexPath.section];
    }
    cell.controlsColor = _pointColor;
//    cell.reviewLabel.font = [UIFont systemFontOfSize:kCellFont];
    cell.reviewLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:12];
//    cell.reviewLabel.text = @"456\"";
    
    cell.reviewLabel.text = [_textArray objectAtIndex:indexPath.section];
   
    CGRect textRec = [self getCellHeightWithText:[_textArray objectAtIndex:indexPath.section] andWidth:kTextBaseWIdth Height:99999 Font:kCellFont];
    if (textRec.size.height>kTextBaseHeight)
    {
        CGRect reLabelRect = cell.reviewLabel.frame;
        reLabelRect.size.width = kTextBaseWIdth;
        reLabelRect.size.height = textRec.size.height+5;
        cell.reviewLabel.frame = reLabelRect;
        
        reLabelRect = cell.reviewBackView.frame;
        reLabelRect.size.width = kTextBackBaseWIdth;
        reLabelRect.size.height = textRec.size.height+15;
        cell.reviewBackView.frame = reLabelRect;
    }
    else
    {
        textRec = [self getCellHeightWithText:[_textArray objectAtIndex:indexPath.section] andWidth:9999 Height:15 Font:kCellFont];
        
        CGRect reviewRect = cell.reviewLabel.frame;
        reviewRect.size.width = textRec.size.width;
        reviewRect.size.height = kTextBaseHeight;
        cell.reviewLabel.frame = reviewRect;
        
        CGRect backRect = cell.reviewBackView.frame;
        backRect.size.width = textRec.size.width + 20;
        backRect.size.height = kTextBackBaseHeight;
        cell.reviewBackView.frame = backRect;
    }
    
    cell.reviewBackView.layer.cornerRadius = (cell.reviewBackView.frame.size.height>50)?15:cell.reviewBackView.bounds.size.height/2;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 1)];
    lineLab.backgroundColor = _backgroundViewColor;
    return lineLab;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
