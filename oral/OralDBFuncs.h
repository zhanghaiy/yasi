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

+(void)setCurrentUser:(NSString *)userName;
+(NSString *)getCurrentUser;
+(void)setCurrentTopic:(NSString *)topicName;
+(NSString *)getCurrentTopic;
+(void)setCurrentPoint:(int)pointNum;
+(int)getCurrentPoint;
+(void)setCurrentRecordId:(NSString *)recordId;
+(NSString *)getCurrentRecordId;

+(BOOL)initializeDb;
+(BOOL)performCmd:(NSString *)cmd;

+(BOOL)addUser:(NSString *)userName;
+(BOOL)deleteUser:(NSString *)userName;
+(void)updateUserLastLoginTimeStamp:(NSString *)userName;

+(BOOL)addTopicRecordFor:(NSString *)userName with:(NSString *)topicName;
+(void)updateTopicRecordFor:(NSString *)userName with:(NSString *)topicName part:(int)part level:(int)level andScore:(int)score;
+(TopicRecord *)getTopicRecordFor:(NSString *)userName withTopic:(NSString *)topicName;

+(BOOL)addPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andReferAudioName:(NSString *)referAudioName;
+(void)updatePracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andResultText:(NSString *)lastText score:(int)score pron:(int)pron integrity:(int)interity fluency:(int)fluency andLastAudioName:(NSString *)lastAudioName;
+(PracticeBookRecord *)getPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId;

+(void)addPracticeTime:(long)seconds ForUser:(NSString *)userName;
+(void)addPlayTime:(long)seconds ForUser:(NSString *)userName;
+(void)addExamTime:(long)seconds ForUser:(NSString *)userName;

+(BOOL)replaceLastRecordFor:(NSString *)userName TopicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum levelNum:(int)levelNum withRecordId:(NSString *)recordId lastText:(NSString *)lastText lastScore:(int)lastScore lastPron:(int)lastPron lastIntegrity:(int)lastIntegrity lastFluency:(int)lastFluency lastAudioName:(NSString *)lastAudioName;
+(PracticeBookRecord *)getLastRecordFor:(NSString *)userName topicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum andLevelNum:(int)levelNum;

+(BOOL)replaceLevel3RecordFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum questionNum:(int)questionNum withUserAudioName:(NSString *)userAudioName recordId:(NSString *)recordId replyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName;
+(NSArray *)getAllLevel3RecordsFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum;

+(BOOL)replaceExamRecordFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId withReplyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName;
+(NSArray *)getAllExamRecordsFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId;

@end
