//
//  ClassSearchViewController.m
//  oral
//
//  Created by cocim01 on 15/6/5.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "ClassSearchViewController.h"
#import "ClassSearchCell.h"
#import "ClassIntroduceViewController.h"

@interface ClassSearchViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIView *_table_header_view;
    UILabel *_tipLabel;
    UITableView *_search_Table_View;
}
@end

#define kAddClassButtonTag 400

@implementation ClassSearchViewController

- (void)uiconfig
{
    _searchBackView.backgroundColor = [UIColor whiteColor];
    _searchBackView.layer.masksToBounds = YES;
    _searchBackView.layer.cornerRadius = _searchBackView.frame.size.height/2;
    _searchBackView.layer.borderWidth = 1;
    _searchBackView.layer.borderColor = kPart_Button_Color.CGColor;
    
    _searchButton.layer.masksToBounds = YES;
    _searchButton.layer.cornerRadius = _searchButton.frame.size.height/2;
    _searchButton.layer.borderWidth = 1;
    _searchButton.layer.borderColor = kPart_Button_Color.CGColor;
    _searchButton.backgroundColor = kPart_Button_Color;
    [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _textFiled.delegate = self;
    _textFiled.keyboardType = UIKeyboardTypeNamePhonePad;
    _textFiled.clearButtonMode = UITextFieldViewModeAlways;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"搜索"];
    self.view.backgroundColor = _backgroundViewColor;
    
    [self uiconfig];
    
    _table_header_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 35)];
    _table_header_view.backgroundColor = _backgroundViewColor;
    
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 35)];
    _tipLabel.text = @"搜索到5条数据";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = _textColor;
    _tipLabel.font = [UIFont systemFontOfSize:kFontSize1];
    [_table_header_view addSubview:_tipLabel];
    
    _search_Table_View = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+55, kScreentWidth, kScreenHeight-KNavTopViewHeight-55) style:UITableViewStylePlain];
    _search_Table_View.delegate = self;
    _search_Table_View.dataSource = self;
    _search_Table_View.backgroundColor = _backgroundViewColor;
    _search_Table_View.separatorColor = _backgroundViewColor;
    [self.view addSubview:_search_Table_View];
    
    _search_Table_View.tableHeaderView = _table_header_view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"class_cell";
    ClassSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ClassSearchCell" owner:self options:0] lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.addClassButton.tag = kAddClassButtonTag+indexPath.row;
    [cell.addClassButton addTarget:self action:@selector(addClass:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)addClass:(UIButton *)btn
{
    // 加入班级
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassIntroduceViewController *classIntroduceVC = [[ClassIntroduceViewController alloc]initWithNibName:@"ClassIntroduceViewController" bundle:nil];
    [self.navigationController pushViewController:classIntroduceVC animated:YES];
}



#pragma mark - 收键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textFiled resignFirstResponder];
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
