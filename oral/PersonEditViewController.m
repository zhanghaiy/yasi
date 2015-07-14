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
#import "OralDBFuncs.h"
#import "NSURLConnectionRequest.h"
#import "AFNetworking/AFHTTPRequestOperationManager.h"


@interface PersonEditViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    UIView *_picker_Back_view;
    UITableView *_person_edit_tableV;
    NSArray *_edit_Menu_Array;

    NSString *_iconUrl;// 头像
    UIImage *_selectIconImg;// 本地选取的
    NSData *_imgData;// 选取的图片data
    
    NSString *_nameStr;// 昵称
    NSString *_sexString;// 性别
    NSString *_birthStr;// 生日
    NSString *_constellation;// 星座
    NSString *_signiture;// 个性签名
    NSString *_hobbies;// 爱好
    
    UITextView *footerTextV;
}
@end

@implementation PersonEditViewController
#define kHeadButtonTag 55
#define kSignitureTextViewTag 77
#define kPickerBackViewTag 78
#define kActionSheet_sex_Tag 66
#define kActionSheet_headImage_Tag 67

#define kPickerViewHeight 250

#define kDesTextFieldTag 88

#pragma mark - 配置个人信息
- (void)makeUpDataArray
{
    _edit_Menu_Array = @[@"昵称：",@"性别：",@"出生日期：",@"星座：",@"兴趣爱好："];
    
    if ([_personInfoDict objectForKey:@"icon"])
    {
        _iconUrl = [_personInfoDict objectForKey:@"icon"];
    }
    
    if ([_personInfoDict objectForKey:@"nickname"])
    {
        _nameStr = [_personInfoDict objectForKey:@"nickname"];
    }
    else
    {
        _nameStr = @"未填写";
    }
    
    if ([_personInfoDict objectForKey:@"sex"])
    {
        _sexString = [_personInfoDict objectForKey:@"sex"];
    }
    else
    {
        _sexString = @"未填写";
    }

    
    if ([_personInfoDict objectForKey:@"birthday"])
    {
        _birthStr = [_personInfoDict objectForKey:@"birthday"];
    }
    else
    {
       _birthStr = @"未填写";
    }
    
    if ([_personInfoDict objectForKey:@"constellation"])
    {
        _constellation = [_personInfoDict objectForKey:@"constellation"];
    }
    else
    {
        if ([_personInfoDict objectForKey:@"birthday"])
        {
            NSArray *comArr = [_birthStr componentsSeparatedByString:@"-"];
            _constellation = [ConstellationManager getAstroWithMonth:[[comArr objectAtIndex:1] intValue] day:[[comArr objectAtIndex:2] intValue]];
        }
        else
        {
            _constellation = @"未填写";
        }
    }
    
    if ([_personInfoDict objectForKey:@"hobbies"])
    {
        _hobbies = [_personInfoDict objectForKey:@"hobbies"];
    }
    else
    {
        _hobbies = @"未填写";
    }
    
    if ([_personInfoDict objectForKey:@"signiture"])
    {
        _signiture = [_personInfoDict objectForKey:@"signiture"];
    }
    else
    {
        _signiture = @"未填写";
    }
    
}

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = _backgroundViewColor;
    
    // 返回按钮
    [self addBackButtonWithImageName:@"back-Blue"];
    [self addTitleLabelWithTitle:@"My Travel"];
    [self makeUpDataArray];
    [self createPickerView];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setFrame:CGRectMake(kScreentWidth-60, 29, 50, 30)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:kPart_Button_Color forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize_17];
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
    
    
    UIView *_table_footer_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 90)];
    _table_footer_view.backgroundColor = [UIColor whiteColor];
    
    UILabel *_footer_title_label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 200, 20)];
    _footer_title_label.text = @"个性签名:";
    _footer_title_label.textAlignment = NSTextAlignmentLeft;
    _footer_title_label.textColor = kText_Color;
    _footer_title_label.font = [UIFont systemFontOfSize:kFontSize_14];
    [_table_footer_view addSubview:_footer_title_label];
    
    UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreentWidth, 1)];
    lineLab.backgroundColor = _backgroundViewColor;
    [_table_footer_view addSubview:lineLab];
    
    
    footerTextV = [[UITextView alloc]initWithFrame:CGRectMake(15, 30, kScreentWidth-30, 50)];
    footerTextV.keyboardType = UIKeyboardTypeNamePhonePad;
    footerTextV.delegate = self;
    footerTextV.textColor = kText_Color;
    footerTextV.font = [UIFont systemFontOfSize:kFontSize_12];
    footerTextV.tag = kSignitureTextViewTag;
    footerTextV.text = _signiture;
    [_table_footer_view addSubview:footerTextV];
    
    
    _person_edit_tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, kScreentWidth, kScreenHeight-65) style:UITableViewStylePlain];
    _person_edit_tableV.dataSource = self;
    _person_edit_tableV.delegate = self;
    _person_edit_tableV.backgroundColor = [UIColor clearColor];
    _person_edit_tableV.separatorColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:_person_edit_tableV];
    _person_edit_tableV.tableHeaderView = _table_Header_View;
    _person_edit_tableV.tableFooterView = _table_footer_view;
    
}

#pragma mark - 完成修改
- (void)finishAlter:(UIButton *)btn
{
    // 提交修改资料
    _signiture = footerTextV.text;
    NSString *userID = [OralDBFuncs getCurrentUserID];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kAlterPersonInfo];
    NSString *params = [NSString stringWithFormat:@"userId=%@&nickname=%@&sex=%@&constellation=%@&birthday=%@&hobbies=%@&signiture=%@",userID,_nameStr,_sexString,_constellation,_birthStr,_hobbies,_signiture];;
    _loading_View.hidden = NO;
    [self.view bringSubviewToFront:_loading_View];
    [self changeLoadingViewTitle:@"正在提交资料，请稍后~~~~"];
    [NSURLConnectionRequest requestPOSTUrlString:urlStr andParamStr:params target:self action:@selector(alterFinished:) andRefresh:YES];
}

- (void)upLoadImage
{
//    [self upImage_post];
    _loading_View.hidden = NO;
    [self.view bringSubviewToFront:_loading_View];
    [self changeLoadingViewTitle:@"正在上传头像~~~~~"];
    NSString *userID = [OralDBFuncs getCurrentUserID];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kAlterPersonInfo];
    
    NSString *imgPath = [NSString stringWithFormat:@"%@/Documents/img.png",NSHomeDirectory()];
    [_imgData writeToFile:imgPath atomically:NO];
    NSData *newImgData = [NSData dataWithContentsOfFile:imgPath];
    
    NSString *params = [NSString stringWithFormat:@"userId=%@&icon=%@",userID,newImgData];
    [NSURLConnectionRequest requestPOSTUrlString:urlStr andParamStr:params target:self action:@selector(uploadImageFinished:) andRefresh:YES];
}

- (void)upImage_post
{
    // 提交给老师
    NSString *userID = [OralDBFuncs getCurrentUserID];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kBaseIPUrl,kAlterPersonInfo];
    
    NSString *imgPath = [NSString stringWithFormat:@"%@/Documents/img.png",NSHomeDirectory()];
    [_imgData writeToFile:imgPath atomically:NO];
    NSData *newImgData = [NSData dataWithContentsOfFile:imgPath];
    // 网络提交 uploadfile
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"img" forKey:@"icon"];
    [parameters setObject:userID forKey:@"userId"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (newImgData)
         {
             [formData appendPartWithFileData:newImgData name:@"icon" fileName:@"img.png" mimeType:@"image/png"];
         }
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         _loading_View.hidden = YES;
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
         if ([[dic objectForKey:@"respCode"] intValue] == 1000)
         {
             // 标记 关卡3已经提交
         }
         else
         {
             NSLog(@"提交失败");
             NSLog(@"%@",[dic objectForKey:@"remark"]);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         _loading_View.hidden = YES;
         NSLog(@"%@",error.localizedFailureReason);
         NSLog(@"失败乃");
     }];
}

- (void)uploadImageFinished:(NSURLConnectionRequest *)request
{
    _loading_View.hidden = YES;
    if (request.downloadData)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dic objectForKey:@"respCode"] intValue] == 1000)
        {
            // 成功
            NSLog(@"%@",[dic objectForKey:@"remark"]);
            [self  finishBack];
        }
        NSLog(@"%@",[dic objectForKey:@"remark"]);
    }
}

- (void)alterFinished:(NSURLConnectionRequest *)request
{
    if (request.downloadData)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.downloadData options:0 error:nil];
        if ([[dic objectForKey:@"respCode"] intValue] == 1000)
        {
//            if (_imgData)
//            {
//                // 上传头像
//                [self upLoadImage];
//            }
//            else
//            {
//                _loading_View.hidden = YES;
//               [self  finishBack];
//            }
            _loading_View.hidden = YES;
            [self  finishBack];
        }
        else
        {
            _loading_View.hidden = YES;
            [self createAlertView:[dic objectForKey:@"remark"]];
        }
    }
    else
    {
        _loading_View.hidden = YES;
        NSLog(@"失败");
        [self createAlertView:@"保存失败\n请检查网络"];
    }
}

- (void)finishBack
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate editSuccess];
}

#pragma mark - 创建警告框
- (void)createAlertView:(NSString *)message
{
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertV show];
}


#pragma mark - UITableViewDelegate
#pragma mark -- section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark -- cell 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _edit_Menu_Array.count;
}

#pragma mark -- 绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PersonEditCell";
    PersonEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PersonEditCell" owner:self options:0] lastObject];
    }
    cell.titleLabel.textColor = kText_Color;
    cell.desTextField.textColor = kText_Color;
    cell.desTextField.delegate = self;
    cell.desTextField.tag = indexPath.row + kDesTextFieldTag;

    cell.titleLabel.text = [_edit_Menu_Array objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

#pragma mark -- 选中cell
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
            [self.view bringSubviewToFront:_picker_Back_view];
            [UIView animateWithDuration:1 animations:^{
                [_picker_Back_view setFrame:CGRectMake(1, kScreenHeight-kPickerViewHeight, kScreentWidth-2, kPickerViewHeight)];
            }];
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

#pragma mark - 修改头像
#pragma mark -- 选取图片
- (void)alterStuHeadImage:(UIButton *)btn
{
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册获取图片", nil];
    chooseImageSheet.tag = kActionSheet_headImage_Tag;
    [chooseImageSheet showInView:self.view];
}

#pragma mark -- UIActionSheetDelegate 
// 修改颜色 --- 不必须
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

#pragma mark -- UIActionSheetDelegate Method
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
        // 选取图片
        switch (buttonIndex) {
//            case 0://Take picture 照相
//            {
//                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//                {
//                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//                }
//                else
//                {
//                    
//                }
//                [self presentViewController:picker animated:YES completion:nil];
//                break;
//            }
            case 0://From album 相册
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

#pragma mark - 选好图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
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
        
        _imgData = data;
        //将二进制数据生成UIImage
        UIImage *image = [UIImage imageWithData:data];
        UIButton *btn = (UIButton *)[self.view viewWithTag:kHeadButtonTag];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
    }
}

#pragma mark -- 压缩图片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}



#pragma mark - UIDatePickerView 日期选择
#pragma mark -- 选取器View
- (void)createPickerView
{
    _picker_Back_view = [[UIView alloc]initWithFrame:CGRectMake(1, kScreenHeight, kScreentWidth-2, kPickerViewHeight)];
    _picker_Back_view.tag = kPickerBackViewTag;
    _picker_Back_view.backgroundColor = [UIColor colorWithWhite:245/255.0 alpha:0.7];
    _picker_Back_view.layer.cornerRadius = 5;
    [self.view addSubview:_picker_Back_view];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(kScreentWidth-70, 5, 50, 25)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:kPart_Button_Color forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.cornerRadius = btn.frame.size.height/2;
    [btn addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_picker_Back_view addSubview:btn];
    
    // 初始化UIDatePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kPickerViewHeight-216, kScreentWidth, 216)];
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
    [_picker_Back_view addSubview:datePicker];
}


#pragma mark -- PickerValueChanged
- (void)datePickerValueChanged:(UIDatePicker *)picker
{
    [picker setDate:[picker date] animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[picker date] forKey:@"PickerDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- 日期选择完毕
- (void)dateSelected:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^{
        [_picker_Back_view setFrame:CGRectMake(1, kScreenHeight, kScreentWidth-2, kPickerViewHeight)];
    }];
    // 选择的生日
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"PickerDate"];
    _birthStr = [ConstellationManager transformNSStringWithDate:date];
    
    // 转换的星座
    NSArray *arr = [_birthStr componentsSeparatedByString:@"-"];
    int month = [[arr objectAtIndex:1] intValue];
    int day = [[arr lastObject] intValue];
    _constellation = [ConstellationManager getAstroWithMonth:month day:day];
    [_person_edit_tableV reloadData];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
    NSLog(@"%ld",textField.tag);
    switch (textField.tag)
    {
        case kDesTextFieldTag:
        {
            // 昵称
            _nameStr = textField.text;
        }
            break;
        case kDesTextFieldTag+4:
        {
            // 兴趣爱好
            _hobbies = textField.text;
        }
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
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
