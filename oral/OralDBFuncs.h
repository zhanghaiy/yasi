//
//  OralDBFuncs.h
//  DFAiengineSentObject
//
//  Created by Tiger on 15/5/28.
//  Copyright (c) 2015年 dfsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface TopicRecord : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *topicName;
@property int completion;
@property int p1_1;
@property int p1_2;
@property int p1_3;
@property int p2_1;
@property int p2_2;
@property int p2_3;
@property int p3_1;
@property int p3_2;
@property int p3_3;
@property NSTimeInterval startTimeStamp;
@property NSTimeInterval stopTimeStamp;
@end

@interface PracticeBookRecord : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *answerId;
@property NSTimeInterval timeStamp;
@property (strong, nonatomic) NSString *lastText;
@property (strong, nonatomic) NSString *referAudioName;
@property (strong, nonatomic) NSString *lastAudioName;
@property int lastScore;
@property int lastPron;
@property int lastIntegrity;
@property int lastFluency;
@end

@interface Level3Record : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *topicName;
@property (strong, nonatomic) NSString *recordId;
@property int partNum;
@property int questionNum;
@property (strong, nonatomic) NSString *userAudioName;
@property int replyFlag;
@property int score;
@property (strong, nonatomic) NSString *teacherName;
@property (strong, nonatomic) NSString *teacherReplyName;
@property NSTimeInterval teacherTimeStamp;
@end

@interface ExamRecord : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *topicName;
@property (strong, nonatomic) NSString *examId;
@property int replyFlag;
@property int score;
@property (strong, nonatomic) NSString *teacherName;
@property (strong, nonatomic) NSString *teacherReplyName;
@property NSTimeInterval teacherTimeStamp;
@end

@interface OralDBFuncs : NSObject


// 标记网络限制
+ (void)setNet_WiFi_Download:(BOOL)downLoad;
+ (void)setNet_2g3g4g_Download:(BOOL)downLoad;
+ (BOOL)getNet_WiFi_Download;
+ (BOOL)getNet_2g3g4g_Download;


// 标记当前用户 用户名 昵称
+(void)setCurrentUser:(NSString *)userName UserId:(NSString *)userid UserIconUrl:(NSString *)iconUrl;
// 删除记录
+(void)removeCurrentUserInfo;
// 获取用户头像
+(NSString *)getCurrentUserIconUrl;
// 获取用户名
+(NSString *)getCurrentUserName;
// 获取用户id
+(NSString *)getCurrentUserID;

// 标记当前topic
+(void)setCurrentTopic:(NSString *)topicName;
// 获取当前topic
+(NSString *)getCurrentTopic;

+(void)setCurrentTopicID:(NSString *)topicID;
// 获取当前topic
+(NSString *)getCurrentTopicID;

// 标记当前关卡
+(void)setCurrentPoint:(int)pointNum;
// 获取当前关卡
+(int)getCurrentPoint;
// 标记当前part
+(void)setCurrentPart:(int)partintNum;
// 获取当前part
+(int)getCurrentPart;

// 标记加入练习簿的id
+ (void)setAddPracticeTopic:(NSString *)topicName UserName:(NSString *)userName AnswerId:(NSString *)answerid AnswerText:(NSString *)answerText;
+ (NSArray *)getAddPracticeTopic:(NSString *)topicName UserName:(NSString *)userName;
+ (void)deleteAddPracticeTopic:(NSString *)topicName UserName:(NSString *)userName AnswerId:(NSString *)answerid;

// 标记关卡3是否提交
+(void)setPartLevel3Commit:(BOOL)commit withTopic:(NSString *)topicName andUserName:(NSString *)userName PartNum:(int)partNum;
+(BOOL)getPartLevel3CommitwithTopic:(NSString *)topicName andUserName:(NSString *)userName PartNum:(int)partNum;

// 标记关卡3提交次数
+ (void)setPartLevel3CommitNum:(NSInteger)commitNum Topic:(NSString *)topicName UserName:(NSString *)username PartNum:(NSInteger)partNum;
+ (NSInteger)getPartLevel3CommitNumTopic:(NSString *)topic UserName:(NSString *)userName PartNum:(NSInteger)partNum;

// -------------------- 标记关卡3  -------------------------------------
// 标记关卡3 完成次数 以及解锁等信息
+(void)setPartLevel3Finished:(BOOL)finished AddPracticeNum:(BOOL)addPraNum UnLockNum:(NSInteger)unLockNum Topic:(NSString *)topic User:(NSString *)userName PartNum:(NSInteger)partNum;
// 获取关卡3 完成次数
+ (NSInteger)getPartLevel3FinishedNumTopic:(NSString *)topic UserName:(NSString *)userName PartNum:(NSInteger)partNum;
// 获取关卡3是否完成
+(BOOL)getPartLevel3PracticeedwithTopic:(NSString *)topicName andUserName:(NSString *)userName PartNum:(NSInteger)partNum;
// 获取topic解锁关数
+ (NSInteger)getUnLockNumWithTopic:(NSString *)topic UserName:(NSString *)userName;

// -------------------- 合成zip有关  -------------------------------------
// 标记模考/闯关合成json文件所需的数组
+(void)setTopicAnswerJsonArray:(NSArray *)array  Topic:(NSString *)topicName UserName:(NSString *)userName ISPart:(BOOL)part;;
+(NSArray *)getTopicAnswerJsonArrayWithTopic:(NSString *)topicName UserName:(NSString *)userName ISPart:(BOOL)part;

// 标记模考/闯关合成zip文件所需的数组
+(void)setTopicAnswerZipArray:(NSArray *)array  Topic:(NSString *)topicName UserName:(NSString *)userName ISPart:(BOOL)part;
+(NSArray *)getTopicAnswerZipArrayWithTopic:(NSString *)topicName UserName:(NSString *)userName ISPart:(BOOL)part;

// --------------------  模考  -------------------------------------
//标记模考音频总时间 用于成绩单 界面 模考部分
+(void)setTestPartDuration:(float)duration andPart:(int)partNum Topic:(NSString *)topic Username:(NSString *)username;
+(float)getTestPartDurationWithPart:(int)partNum Topic:(NSString *)topic Username:(NSString *)username;

// 标记模考是否提交
+(void)setTestCommit:(BOOL)commit withTopic:(NSString *)topicName andUserName:(NSString *)userName;
+(BOOL)getTestCommitTopic:(NSString *)topicName andUserName:(NSString *)userName;
// 标记模考是否完成
+ (void)setTestFinished:(BOOL)finished Topic:(NSString *)topic UserName:(NSString *)userName;
+ (BOOL)getTestFinishedWithTopic:(NSString *)topic UserName:(NSString *)userName;

// 标记模考提交次数
+ (void)markTestCommitedNumberTopic:(NSString*)topic User:(NSString *)userName;
+ (NSInteger)getTestCommitedNumberTopic:(NSString*)topic User:(NSString *)userName;


// 标记 默认老师
+ (void)setDefaultTeacherID:(NSString *)teacherId UserName:(NSString *)userName;
+ (NSString *)getDefaultTeacherIDForUserName:(NSString *)userName;

// 标记练习id （时间戳合成）
+(void)setCurrentRecordId:(NSString *)recordId;
// 获取练习id
+(NSString *)getCurrentRecordId;

// 初始化数据库
+(BOOL)initializeDb;
// 执行 数据库语句 参数为语句
+(BOOL)performCmd:(NSString *)cmd;

// 数据库里增加用户 （注册是增加）
+(BOOL)addUser:(NSString *)userName;
// 数据库里删除用户
+(BOOL)deleteUser:(NSString *)userName;
// 更新用户登录时间
+(void)updateUserLastLoginTimeStamp:(NSString *)userName;

// 数据库增加topic
+(BOOL)addTopicRecordFor:(NSString *)userName with:(NSString *)topicName;

// 标记闯关每一关卡的总得分
+(void)updateTopicRecordFor:(NSString *)userName with:(NSString *)topicName part:(int)part level:(int)level andScore:(int)score;

// 获取闯关每一关卡的总得分
+(TopicRecord *)getTopicRecordFor:(NSString *)userName withTopic:(NSString *)topicName;


// 判断练习簿里是否存在该题 （根据AnswerId）
+(BOOL)isInPracticeBook:(NSString *)userName withAnswerId:(NSString *)answer_id;
// 练习簿增加一条记录（总记录 具体内容根据AnswerId查询）
//+(BOOL)addPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andReferAudioName:(NSString *)referAudioName;

// 更新加入练习簿功能 （避免存数据时 出现某些字段为空）
+(BOOL)addPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andReferAudioName:(NSString *)referAudioName andLastAUdioName:(NSString *)lastAudioName andLastText:(NSString *)lastText andLastScore:(int)score Pron:(int)pron Integrity:(int)interity fluency:(int)fluency;
// 删除记录
+(BOOL)deletePracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId;

// 标记练习结果
+(void)updatePracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andResultText:(NSString *)lastText score:(int)score pron:(int)pron integrity:(int)interity fluency:(int)fluency andLastAudioName:(NSString *)lastAudioName;
// 获取练习结果
+(PracticeBookRecord *)getPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId;


// 增加练习时间
+(void)addPracticeTime:(long)seconds ForUser:(NSString *)userName;
// 增加闯关时间
+(void)addPlayTime:(long)seconds ForUser:(NSString *)userName;
// 增加模考时间
+(void)addExamTime:(long)seconds ForUser:(NSString *)userName;

// 替换闯关每一句的回答情况
+(BOOL)replaceLastRecordFor:(NSString *)userName TopicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum levelNum:(int)levelNum withRecordId:(NSString *)recordId lastText:(NSString *)lastText lastScore:(int)lastScore lastPron:(int)lastPron lastIntegrity:(int)lastIntegrity lastFluency:(int)lastFluency lastAudioName:(NSString *)lastAudioName;
// 获取到闯关成绩
+(PracticeBookRecord *)getLastRecordFor:(NSString *)userName topicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum andLevelNum:(int)levelNum;
+(BOOL)isInLastBook:(NSString *)userName withAnswerId:(NSString *)answer_id;

// 标记关卡3的成绩
+(BOOL)replaceLevel3RecordFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum questionNum:(int)questionNum withUserAudioName:(NSString *)userAudioName recordId:(NSString *)recordId replyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName;

// 获取用户 关卡3的成绩
+(NSArray *)getAllLevel3RecordsFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum;

// 更新模考成绩
+(BOOL)replaceExamRecordFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId withReplyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName;
// 获取模考成绩
+(NSArray *)getAllExamRecordsFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId;

@end
