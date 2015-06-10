//
//  HeadFile.h
//  oral
//
//  Created by cocim01 on 15/5/18.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#ifndef oral_HeadFile_h
#define oral_HeadFile_h

#define kScreentWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define KOneFontSize 15
#define KSecondFontSize 14
#define KThidFontSize 13
#define KFourFontSize 12

#define kTitleFontSize 16
#define kFontSize1 14
#define kFontSize2 12
#define kFontSize3 10
#define kFontSize4 8

// 练习簿界面
#define kPract_Listen_self_Button_Tag 4000
#define kPract_Play_answer_Button_Tag 1000
#define kPract_Follow_Button_Tag 2000
#define kPract_Delete_Button_Tag 3000

// 80~~100
#define kPer_Score_Color [UIColor colorWithRed:0 green:231/255.0 blue:136/255.0 alpha:1]
// 60~~80
#define kGood_Score_Color [UIColor colorWithRed:250/255.0 green:220/255.0 blue:18/255.0 alpha:1]
// 0~~60
#define kBad_Score_Color [UIColor colorWithRed:255/255.0 green:63/255.0 blue:37/255.0 alpha:1]

// 闯关 part按钮颜色
#define kPart_Button_Color [UIColor colorWithRed:35/255.0 green:222/255.0 blue:191/255.0 alpha:1]
// 闯关流程 底色
#define kPart_Back_Color [UIColor colorWithRed:128/255.0 green:230/255.0 blue:209/255.0 alpha:1]

// 文本颜色
#define kText_Color [UIColor colorWithWhite:135/255.0 alpha:1]

// 阿里云
#define kBaseIPUrl @"http://114.215.172.72:80"
// 主页 topic 信息
#define kTopicListUrl @"/yasi/examtheme/queryClassTypeInfo.do"
// 模考 参数 topid 
#define kTestUrl @"/yasi/mockquestion/getMockQuestion.do"
// 注册 accountname  password
#define kRegisterUrl @"/yasi/student/registeredStudent.do"
// 登陆
#define kLogInUrl @"/yasi/student/validationStudent.do"
// 查询学生个人信息 userId
#define kPersonInfoUrl @"/yasi/student/selectUserInfo.do"
// 查询用户信息 userId
#define kUserInfoUrl @"/yasi/student/selectStudentByUserId.do"

/*
 // 用户未加入的班级
 用户ID	userId	M
 查询的班级名称	serachClassName	O
 查询老师ID	serachTeacherId	O
 */
#define kUserNotAddClassUrl @"/yasi/class/selectNotClassInfoByUserId.do"
// 用户已经加入的班级  userId userId=B9CD53E6B65B4A8DA2C3410604357F0A
#define kUserAddClassUrl @"/yasi/class/selectClassInfoByUserId.do"
// 查询班级介绍信息 参数 classId
#define kSelectClassInfoUrl @"/yasi/class/selectClassInfoById.do"
// 查询班级详情信息 带学员信息 参数 classId teacherId
#define kSelectClassMemoUrl @"/yasi/class/selectClassMemberByClassId.do"
// 查询老师个人风采  老师ID	teacherId	M
#define kSelectTeacherUrl @"/yasi/teacher/selectTeacherInfoById.do"

// 查询老师班级 teacherId
#define kTeacherClassUrl @"/yasi/class/selectAllClassByTeacherId.do"
// 学生退出本班
#define kStuOutClassUrlString @"/yasi/class/deleteClassMemberByStudentId.do"

#endif
