//
//  HeadFile.h
//  oral
//
//  Created by cocim01 on 15/5/18.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#ifndef oral_HeadFile_h
#define oral_HeadFile_h

#define kScreentWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kCurrentNetStatus ([DetectionNetWorkState netStatus])


#define kTitleFontSize_17 (kScreenHeight<600?15:17)
#define kFontSize_17 (kScreenHeight<600?15:17)
#define kFontSize_16 (kScreenHeight<600?14:16)

#define kFontSize_15 (kScreenHeight<600?13:15)
#define kFontSize_14 (kScreenHeight<600?12:14)
#define kFontSize_13 (kScreenHeight<600?11:13)
#define kFontSize_12 (kScreenHeight<600?10:12)
#define kFontSize_11 (kScreenHeight<600?9:11)
#define kFontSize_10 (kScreenHeight<600?8:10)
#define kFontSize_8 (kScreenHeight<600?6:8)

// 练习簿界面
#define kPract_Listen_self_Button_Tag 4000
#define kPract_Play_answer_Button_Tag 1000
#define kPract_Follow_Button_Tag 2000
#define kPract_Delete_Button_Tag 3000

// 回答时间
// 思必驰
#define KAnswerSumTime 30
#define kLevel_3_time 60

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

// 提交闯关给老师 参数 uploadfile 接受zip
#define kPartCommitUrl @"/yasi/clearance/insertStudentClearance.do"
// 提交模考
#define kTestCommitUrl @"/yasi/mockanswer/insertMockAnswer.do"

// 选择老师 userId teacherName change
#define kChooseTeacherUrl @"/yasi/teacher/selectTeacherToChoose.do"

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

#define kAlterPersonInfo @"/yasi/student/insertStudentInfo.do"

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

// 查询班级最新公告信息 参数 ： classId
#define kSelectClassNewNoticeUrl @"/yasi/classbulletin/selectClassNewBulletin.do"

/*
 // 学生申请加班
 用户ID	userId	M
 班级ID	classId	M
 申请信息	memo	O
 邀请码	inviteCode	O
 
 */
#define kApplyClassUrl @"/yasi/studentJoinApply/insertJoinApply.do"

// 查询学生最新提交给老师的已处理待办事项 参数  userId
#define kSelectNewWatingEvent @"/yasi/waiting/selectNewWaitingByStudentId.do"
// 查询已处理待办事项 参数 waitingid
#define kReviewWatingEvent @"/yasi/waiting/selectWaitingByUserId.do"

#endif
