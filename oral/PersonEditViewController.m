//
//  PersonEditViewController.m
//  oral
//
//  Created by cocim01 on 15/6/8.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "PersonEditViewController.h"
#import "PersonEditCell.h"
#import "ConstellationManager.h"

@interface PersonEditViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    UITableView *_person_edit_tableV;
    NSArray *_edit_Menu_Array;
    NSMutableArray *_edit_Info_Array;
}
@end

@implementation PersonEditViewController

//- (void)makeUpDataArray
//{
//    

//    _dataArray = [[NSMutableArray alloc]init];
//    NSArray *titleArr = @[@"头像:",@"昵称:",@"性别:",@"生日:",@"星座:",@"兴趣爱好:",@"个性签名:"];
//    NSString *icon = [_personInfoDict objectForKey:@"icon"];
//    NSString *nickname = [_personInfoDict objectForKey:@"nickname"];
//    NSString *sex = [_personInfoDict objectForKey:@"sex"];
//    NSString *birthday = [_personInfoDict objectForKey:@"birthday"];
//    NSString *constellation;
//    if ([[_personInfoDict objectForKey:@"constellation"] length]<=2)
//    {
//        NSLog(@"~~~~~~~~~~~");
//        NSArray *comArr = [birthday componentsSeparatedByString:@"-"];
//        constellation = [ConstellationManager getAstroWithMonth:[[comArr objectAtIndex:1] integerValue] day:[[comArr objectAtIndex:2] integerValue]];
//    }
//    else
//    {
//        constellation = [_personInfoDict objectForKey:@"constellation"];
//    }
//    NSString *hobbies = [_personInfoDict objectForKey:@"hobbies"];
//    NSString *signiture = [_personInfoDict objectForKey:@"signiture"];
//    
//    NSArray *infoArr = @[icon,nickname,sex,birthday,constellation,hobbies,signiture];
//    for (int i = 0; i < 7; i ++)
//    {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//        [dict setObject:[titleArr objectAtIndex:i] forKey:@"title"];
//        [dict setObject:[infoArr objectAtIndex:i] forKey:@"detailTitle"];
//        [_dataArray addObject:dict];
//    }
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = _backgroundViewColor;
    _edit_Menu_Array = @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];
    _edit_Info_Array = [[NSMutableArray alloc]initWithObjects:@"小花",@"女：",@"1998.12.05：",@"射手座",@"听音乐", nil];
    
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
    
    cell.desTextField.text = [_edit_Info_Array objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            // 昵称
            
        }
            break;
        case 1:
        {
            //性别
            UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:										  @"取消" destructiveButtonTitle:@"女" otherButtonTitles:@"男", nil];
            actionSheet.delegate = self;
            [actionSheet showInView:self.view];
        }
            break;
        case 2:
        {
            //出生日期
            [self createPickerView];
        }
            break;
        case 3:
        {
            //星座
            
        }
            break;
        case 4:
        {
            //兴趣爱好
            
        }
            break;
        default:
            break;
    }

}

#pragma mark - UIDatePickerView 日期选择
- (void)createPickerView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-216, 320, 216)];
    view.tag = 66666;
    view.backgroundColor = [UIColor colorWithRed:81/255.0 green:194/255.0 blue:164/255.0 alpha:1];
    view.layer.cornerRadius = 2;
    [self.view addSubview:view];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(kScreentWidth-50, 5, 40, 15)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor colorWithRed:14/255.0 green:39/255.0 blue:33/255.0 alpha:1] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    // 初始化UIDatePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, 320, 216)];
    // 设置时区
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    // 设置当前显示时间
    [datePicker setDate:[NSDate date] animated:YES];
    // 设置显示最大时间（此处为当前时间）
    [datePicker setMaximumDate:[NSDate date]];
    // 设置UIDatePicker的显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // 当值发生改变的时候调用的方法
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:datePicker];
}


#pragma mark - PickerValueChanged
- (void)datePickerValueChanged:(UIDatePicker *)picker
{
    [picker setDate:[picker date] animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[picker date] forKey:@"PickerDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 日期选择完毕
- (void)dateSelected:(UIButton *)btn
{
    UIView *view = [self.view viewWithTag:66666];
    [view removeFromSuperview];
    
    // 选择的生日
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"PickerDate"];
    NSString *birthdayStr = [ConstellationManager transformNSStringWithDate:date];
    NSArray *arr = [birthdayStr componentsSeparatedByString:@"-"];
    int month = [[arr objectAtIndex:1] intValue];
    int day = [[arr lastObject] intValue];
    
    // 转换的星座
    NSString *constellation = [ConstellationManager getAstroWithMonth:month day:day];
    // 修改数据源
    [_edit_Info_Array replaceObjectAtIndex:3 withObject:constellation];
    [_person_edit_tableV reloadData];
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
