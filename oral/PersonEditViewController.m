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


@interface PersonEditViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITableView *_person_edit_tableV;
    NSArray *_edit_Menu_Array;
    NSArray *_edit_Info_Array;

    NSString *_sexString;
    
    NSString *_birthStr;
    NSString *_constellation;
    
    NSString *_nameStr;
    
    NSString *_signiture;
    NSString *_hobbies;
}
@end

@implementation PersonEditViewController
#define kHeadButtonTag 55
#define kActionSheet_sex_Tag 66
#define kActionSheet_headImage_Tag 67

- (void)makeUpDataArray
{
    _edit_Menu_Array = @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];
    NSString *icon;
    if ([_personInfoDict objectForKey:@"icon"])
    {
        icon = [_personInfoDict objectForKey:@"icon"];
    }
    else
    {
        icon = @"未填写";
    }
    
    NSString *nickname;
    if ([_personInfoDict objectForKey:@"nickname"])
    {
        nickname = [_personInfoDict objectForKey:@"nickname"];
    }
    else
    {
        nickname = @"未填写";
    }
    NSString *sex;
    if ([_personInfoDict objectForKey:@"sex"])
    {
        sex = [_personInfoDict objectForKey:@"sex"];
    }
    else
    {
        sex = @"未填写";
    }
    
    
    NSString *birthday;
    if ([_personInfoDict objectForKey:@"birthday"])
    {
        birthday = [_personInfoDict objectForKey:@"birthday"];
    }
    else
    {
       birthday = @"未填写";
    }
    
    NSString *constellation;
    if ([[_personInfoDict objectForKey:@"constellation"] length]<=2)
    {
        NSLog(@"~~~~~~~~~~~");
        if ([birthday length]>4)
        {
            NSArray *comArr = [birthday componentsSeparatedByString:@"."];
            constellation = [ConstellationManager getAstroWithMonth:[[comArr objectAtIndex:1] intValue] day:[[comArr objectAtIndex:2] intValue]];
        }
        else
        {
           constellation = @"未填写";
        }
    }
    else
    {
        constellation = [_personInfoDict objectForKey:@"constellation"];
    }
    
    NSString *hobbies;
    if ([_personInfoDict objectForKey:@"hobbies"])
    {
        hobbies = [_personInfoDict objectForKey:@"hobbies"];
    }
    else
    {
        hobbies = @"未填写";
    }
    
    
    NSString *signiture;
    
    if ([_personInfoDict objectForKey:@"signiture"])
    {
        signiture = [_personInfoDict objectForKey:@"signiture"];
    }
    else
    {
        signiture = @"未填写";
    }
    
    _edit_Info_Array = @[nickname,sex,birthday,constellation,hobbies,signiture];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = _backgroundViewColor;
    //    _edit_Menu_Array = @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];
    //    _edit_Info_Array = [[NSMutableArray alloc]initWithObjects:@"小花",@"女：",@"1998.12.05：",@"射手座",@"听音乐", nil];
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitleWithTitle:@"My Travel"];
    [self makeUpDataArray];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setFrame:CGRectMake(kScreentWidth-60, 29, 50, 30)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:kPart_Button_Color forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
    [finishBtn addTarget:self action:@selector(finishAlter:) forControlEvents:UIControlEventTouchUpInside];
    [self.navTopView addSubview:finishBtn];
    

    UIView *_table_Header_View = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 80)];
    _table_Header_View.backgroundColor = [UIColor whiteColor];
    
    UIButton *_personImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_personImageButton setFrame:CGRectMake(0, 0, 60, 60)];
    [_personImageButton setBackgroundImage:[UIImage imageNamed:@"person_head_image"] forState:UIControlStateNormal];
    _personImageButton.layer.masksToBounds = YES;
    _personImageButton.layer.cornerRadius = _personImageButton.frame.size.height/2;
    _personImageButton.center = _table_Header_View.center;
    [_personImageButton addTarget:self action:@selector(alterStuHeadImage:) forControlEvents:UIControlEventTouchUpInside];
    _personImageButton.tag = kHeadButtonTag;
    [_table_Header_View addSubview:_personImageButton];
    
    _person_edit_tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _person_edit_tableV.dataSource = self;
    _person_edit_tableV.delegate = self;
    _person_edit_tableV.backgroundColor = [UIColor clearColor];
    _person_edit_tableV.separatorColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:_person_edit_tableV];
    _person_edit_tableV.tableHeaderView = _table_Header_View;
    
}

- (void)finishAlter:(UIButton *)btn
{
    // 提交修改资料
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
    cell.desTextField.text = [_edit_Info_Array objectAtIndex:indexPath.row];
    switch (indexPath.row)
    {
        case 0:
        {
           // 昵称
            cell.desTextField.userInteractionEnabled = YES;
            cell.desTextField.text = _nameStr;
        }
            break;
        case 1:
        {
            //性别
            cell.desTextField.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.desTextField.text = _sexString;
        }
            break;
        case 2:
        {
            //出生日期
            cell.desTextField.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.desTextField.text = _birthStr;
        }
            break;
        case 3:
        {
            //星座
            cell.desTextField.userInteractionEnabled = NO;
            cell.desTextField.text = _constellation;
        }
            break;
        case 4:
        {
            //兴趣爱好
            cell.desTextField.userInteractionEnabled = YES;
            cell.desTextField.text = _hobbies;
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
            UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:										  @"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
            actionSheet.delegate = self;
            actionSheet.tag = kActionSheet_sex_Tag;
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


- (void)alterStuHeadImage:(UIButton *)btn
{
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册获取图片", nil];
    chooseImageSheet.tag = kActionSheet_headImage_Tag;
    [chooseImageSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews)
    {
        if ([subViwe isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:[UIColor colorWithRed:72/255.0 green:163/255.0 blue:239/255.0 alpha:1] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }
}

#pragma mark UIActionSheetDelegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (actionSheet.tag == kActionSheet_sex_Tag)
    {
        if (buttonIndex == 0)
        {
            // 男
            _sexString = @"男";
        }
        else if (buttonIndex == 1)
        {
            // 女
            _sexString = @"女";
        }
        [_person_edit_tableV reloadData];
    }
    else if (actionSheet.tag == kActionSheet_headImage_Tag)
    {
        switch (buttonIndex) {
            case 0://Take picture
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                }
                else
                {
                    
                }
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            case 1://From album
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            default:
            {
                break;
            }
        }

    }
}

#pragma 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSData *data;
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //图片压缩，因为原图都是很大的，不必要传原图
        UIImage *scaleImage = [self scaleImage:originImage toScale:0.8];
        
        //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
        if (UIImagePNGRepresentation(scaleImage) == nil) {
            //将图片转换为JPG格式的二进制数据
            data = UIImageJPEGRepresentation(scaleImage, 1);
        } else {
            //将图片转换为PNG格式的二进制数据
            data = UIImagePNGRepresentation(scaleImage);
        }
        
        //将二进制数据生成UIImage
        UIImage *image = [UIImage imageWithData:data];
        UIButton *btn = (UIButton *)[self.view viewWithTag:kHeadButtonTag];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        
    }
}

-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}



#pragma mark - UIDatePickerView 日期选择
- (void)createPickerView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-216, kScreentWidth, 216)];
    view.tag = 66666;
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    view.layer.cornerRadius = 2;
    [self.view addSubview:view];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(kScreentWidth-50, 5, 40, 15)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:kPart_Button_Color forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    // 初始化UIDatePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, kScreentWidth, 216)];
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
    _birthStr = [ConstellationManager transformNSStringWithDate:date];
    
    // 转换的星座
    NSArray *arr = [_birthStr componentsSeparatedByString:@"."];
    int month = [[arr objectAtIndex:1] intValue];
    int day = [[arr lastObject] intValue];
    _constellation = [ConstellationManager getAstroWithMonth:month day:day];
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
