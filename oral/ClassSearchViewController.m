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
#import "NSURLConnectionRequest.h"
#import "UIButton+WebCache.h"
#import "ApplyClassViewController.h"

@interface ClassSearchViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_searchListArray;
    UILabel *_tipLabel;
    UITableView *_search_Table_View;
    BOOL _notSearch;
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
    
    _notSearch = NO;
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"搜索"];
    self.view.backgroundColor = _backgroundViewColor;
    
    [self uiconfig];
    
    _search_Table_View = [[UITableView alloc]initWithFrame:CGRectMake(0, KNavTopViewHeight+55, kScreentWidth, kScreenHeight-KNavTopViewHeight-55) style:UITableViewStylePlain];
    _search_Table_View.delegate = self;
    _search_Table_View.dataSource = self;
    _search_Table_View.backgroundColor = _backgroundViewColor;
    _search_Table_View.separatorColor = _backgroundViewColor;
    _search_Table_View.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_search_Table_View];
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = kPart_Button_Color;
    label.font = [UIFont systemFontOfSize:kFontSize_14];
    label.backgroundColor = _backgroundViewColor;
    
    if (_searchListArray.count == 0)
    {
        if (_notSearch)
        {
            label.text = @"找不到结果~~~";
        }
        else
        {
            label.text = @"";
        }
    }
    else
    {
        label.text = [NSString stringWithFormat:@"搜索到%ld条数据",_searchListArray.count];
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchListArray.count;
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
    
    NSDictionary *dic = [_searchListArray objectAtIndex:indexPath.row];
    [cell.classHeadButton setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"iocn"]] placeholderImage:[UIImage imageNamed:@"class_more"]];
    [cell.classHeadButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    cell.classNameLabel.text = [dic objectForKey:@"classname"];
    cell.classCountsLabel.text = [NSString stringWithFormat:@"%d/%d",[[dic objectForKey:@"nowNumber"] intValue],[[dic objectForKey:@"maxNumber"] intValue]];
    cell.classDesLabel.text = [dic objectForKey:@"memo"];
    cell.classTeacherLabel.text = [dic objectForKey:@"teacherName"];
    
    cell.addClassButton.tag = kAddClassButtonTag+indexPath.row;
    [cell.addClassButton addTarget:self action:@selector(addClass:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)addClass:(UIButton *)btn
{
    // 申请 加入班级 ----> 待完善
    NSInteger index = btn.tag - kAddClassButtonTag;
    NSDictionary *dict = [_searchListArray objectAtIndex:index];
    NSString *classId = [dict objectForKey:@"classid"];
    ApplyClassViewController *addClassVC = [[ApplyClassViewController alloc]initWithNibName:@"ApplyClassViewController" bundle:nil];
    addClassVC.classId = classId;
    [self.navigationController pushViewController:addClassVC animated:YES];

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
    // 班级介绍 传入班级id
    NSString *classId = [[_searchListArray objectAtIndex:indexPath.row] objectForKey:@"classid"];
    ClassIntroduceViewController *classIntroduceVC = [[ClassIntroduceViewController alloc]initWithNibName:@"ClassIntroduceViewController" bundle:nil];
    classIntroduceVC.classId = classId;
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

- (IBAction)searchButtonClicked:(id)sender
{
    _notSearch = YES;
    // 搜索
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kUserNotAddClassUrl];
    NSString *paramsStr;
    if ([_textFiled.text length]>0)
    {
        paramsStr = [NSString stringWithFormat:@"userId=%@&serachClassName=%@",userId,_textFiled.text];
    }
    else
    {
        paramsStr = [NSString stringWithFormat:@"userId=%@",userId];
    }
    [NSURLConnectionRequest requestPOSTUrlString:urlStr andParamStr:paramsStr target:self action:@selector(requestFinished:) andRefresh:YES];
}

- (void)requestFinished:(NSURLConnectionRequest *)request
{
    if ([request.downloadData length]>0)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dict objectForKey:@"respCode"] integerValue] == 1000)
        {
            // 成功
            _searchListArray = [dict objectForKey:@"classlist"];
            [_search_Table_View reloadData];
        }
    }
}

@end
