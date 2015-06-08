//
//  PersonEditViewController.m
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonEditViewController.h"
#import "PersonEditCell.h"


@interface PersonEditViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_person_edit_tableV;
    NSArray *_edit_Menu_Array;
}
@end

@implementation PersonEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = _backgroundViewColor;
    _edit_Menu_Array = @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];
    
    
    UIView *_table_Header_View = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 80)];
    _table_Header_View.backgroundColor = [UIColor whiteColor];
    
    UIButton *_personImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_personImageButton setFrame:CGRectMake(0, 0, 60, 60)];
    [_personImageButton setBackgroundImage:[UIImage imageNamed:@"person_head_image"] forState:UIControlStateNormal];
    _personImageButton.layer.masksToBounds = YES;
    _personImageButton.layer.cornerRadius = _personImageButton.frame.size.height/2;
    _personImageButton.center = _table_Header_View.center;
    [_personImageButton addTarget:self action:@selector(alterStuHeadImage:) forControlEvents:UIControlEventTouchUpInside];
    [_table_Header_View addSubview:_personImageButton];
    
    _person_edit_tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _person_edit_tableV.dataSource = self;
    _person_edit_tableV.delegate = self;
    _person_edit_tableV.backgroundColor = [UIColor clearColor];
    _person_edit_tableV.separatorColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:_person_edit_tableV];
    _person_edit_tableV.tableHeaderView = _table_Header_View;
    
}

- (void)alterStuHeadImage:(UIButton *)btn
{
   
}

#pragma mark - section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _edit_Menu_Array.count;
}

#pragma mark - 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PersonEditCell";
    PersonEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PersonEditCell" owner:self options:0] lastObject];
    }
    cell.titleLabel.text = [_edit_Menu_Array objectAtIndex:indexPath.row];
    // @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];

    switch (indexPath.row)
    {
        case 0:
        {
           // 昵称
            cell.desTextField.userInteractionEnabled = YES;

        }
            break;
        case 1:
        {
            //性别
            cell.desTextField.userInteractionEnabled = NO;

        }
            break;
        case 2:
        {
            //出生日期
            cell.desTextField.userInteractionEnabled = NO;
        }
            break;
        case 3:
        {
            //星座
            cell.desTextField.userInteractionEnabled = NO;

        }
            break;
        case 4:
        {
            //兴趣爱好
            cell.desTextField.userInteractionEnabled = YES;

        }
            break;
        default:
            break;
    }
    return cell;
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
