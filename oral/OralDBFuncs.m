//
//  OralDBFuncs.m
//  DFAiengineSentObject
//
//  Created by Tiger on 15/5/28.
//  Copyright (c) 2015年 dfsc. All rights reserved.
//

#import "OralDBFuncs.h"

#define KEY_CONTEXT_USERNAME    @"df_oral_username"
#define KEY_CONTEXT_TOPICNAME   @"df_oral_topicname"
#define KEY_CONTEXT_CUR_LEVEL   @"df_oral_level"
#define KEY_CONTEXT_RECORDID    @"df_oral_recordid"

NSString *const DATABASE_FILE_NAME = @"df_oral.db";
NSString *const DATABASE_RESOURCE_NAME = @"df_oral";
NSString *const DATABASE_RESOURCE_TYPE = @"db";

@implementation OralDBFuncs

#pragma mark -- DB static methods

+ (NSString *)getDbFilePath
{
    NSArray *searchPaths =
    NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    NSString *dbFilePath = [documentFolderPath stringByAppendingPathComponent:
                            DATABASE_FILE_NAME];
    return dbFilePath;
}

+ (BOOL) initializeDb
{
    NSLog (@"initializeDB");
    // 如果是第一次运行，则将初始数据库文件拷贝到可读写位置。
    NSArray *searchPaths =
    NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    NSString *dbFilePath = [documentFolderPath stringByAppendingPathComponent:
                            DATABASE_FILE_NAME];
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath: dbFilePath])
    {
        // didn't find db, need to copy
        NSString *backupDbPath = [[NSBundle mainBundle]
                                  pathForResource:DATABASE_RESOURCE_NAME
                                  ofType:DATABASE_RESOURCE_TYPE];
        if (backupDbPath == nil)
        {
            // couldn't find backup db to copy, bail
            NSLog(@"Can't find backup db?!");
            return NO;
        }
        else
        {
            BOOL copiedBackupDb = [[NSFileManager defaultManager]
                                   copyItemAtPath:backupDbPath
                                   toPath:dbFilePath
                                   error:nil];
            if (! copiedBackupDb)
            {
                // copying backup db failed, bail
                NSLog(@"Copy backup db failed!");
                return NO;
            }
        }
    }
    return YES;
}

+(BOOL)performCmd:(NSString *)cmd
{
    sqlite3 *db;
    int dbrc; // database return code
    NSString *dbPath = [OralDBFuncs getDbFilePath];
    const char* dbFilePathUTF8 = [dbPath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:%@", dbPath);
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    const char *updateStatement = [cmd UTF8String];
    dbrc = sqlite3_prepare_v2 (db, updateStatement, -1, &dbps, NULL);
    dbrc = sqlite3_step (dbps);
    
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

#pragma mark -- 用户纪录

+(BOOL)addUser:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"replace into user_lists (user_name) values('%@')", userName];
    [OralDBFuncs performCmd:statement];
    
    statement = [NSString stringWithFormat:@"replace into record_time (user_name) values('%@')", userName];
    return [OralDBFuncs performCmd:statement];
}

+(BOOL)deleteUser:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"delete from record_time where user_name='%@'", userName];
    [OralDBFuncs performCmd:statement];
    
    statement = [NSString stringWithFormat:@"delete from user_lists where user_name='%@'", userName];
    return [OralDBFuncs performCmd:statement];
}

+(void)updateUserLastLoginTimeStamp:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"update user_lists set last_login_timestamp=datetime('now','localtime') where user_name='%@'", userName];
    [OralDBFuncs performCmd:statement];
}

#pragma mark -- 主题的闯关纪录
/*
 * 每次下载并解压完一个topic时，执行本方法在数据库中新建一条记录。
 * 之后，每次用户进行学习的时候，可以将每部分的每个关卡的评分纪录，纪录在这个表格中。
 * 每条记录对应当前用户的当前topic，只记录最后一次的评分。
 */
+(BOOL)addTopicRecordFor:(NSString *)userName with:(NSString *)topicName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    NSString *saveStatementNS = @"replace into topic_records(user_name,topic_name) values(?,?);";
    
    const char *saveStatement = [saveStatementNS UTF8String];
    
    dbrc = sqlite3_prepare_v2(db, saveStatement, -1, &dbps, NULL);
    sqlite3_bind_text(dbps, 1, [userName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 2, [topicName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(dbps))
    {
        NSLog(@"Save topic record to db failed!");
        sqlite3_finalize(dbps);
        sqlite3_close(db);
        return NO;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

+(void)updateTopicRecordFor:(NSString *)userName with:(NSString *)topicName part:(int)part level:(int)level andScore:(int)score
{
    if(part < 1 || part > 3 || level < 1 || level > 3)
        return;
    
    int completion = (part - 1) * 3 + level;  // 完成度从0～9，每part有三关，每topic有三part
    
    NSString *subStatementStart = @",start_timestamp=datetime('now','localtime') ";
    NSString *subStatementStop = @",stop_timestamp=datetime('now','localtime') ";
    NSString *statement = [NSString stringWithFormat:@"update topic_records set completion='%d',p%d_%d='%d' ", completion, part, level, score];
    if(completion == 1)
        statement = [statement stringByAppendingString:subStatementStart];
    if(completion == 9)
        statement = [statement stringByAppendingString:subStatementStop];
    NSString *tailString = [NSString stringWithFormat:@"where user_name='%@' and topic_name='%@'", userName, topicName];
    statement = [statement stringByAppendingString:tailString];
    
    NSLog(@"%@", statement);
    
    [OralDBFuncs performCmd:statement];
}

+(TopicRecord *)getTopicRecordFor:(NSString *)userName withTopic:(NSString *)topicName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return nil;
    }
    
    // select stuff
    sqlite3_stmt *dbps; // database prepared statement
    NSString *queryStatementNS = [NSString stringWithFormat:@"select * from topic_records where user_name='%@' and topic_name='%@'", userName, topicName];
    const char *queryStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, queryStatement, -1, &dbps, NULL);
    
    TopicRecord *oneRecord = nil;
    if ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW)
    {
        oneRecord = [[TopicRecord alloc] init];
        
        oneRecord.userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 0)];
        oneRecord.topicName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 1)];
        oneRecord.completion = sqlite3_column_int(dbps, 2);
        oneRecord.p1_1 = sqlite3_column_int(dbps, 3);
        oneRecord.p1_2 = sqlite3_column_int(dbps, 4);
        oneRecord.p1_3 = sqlite3_column_int(dbps, 5);
        oneRecord.p2_1 = sqlite3_column_int(dbps, 6);
        oneRecord.p2_2 = sqlite3_column_int(dbps, 7);
        oneRecord.p2_3 = sqlite3_column_int(dbps, 8);
        oneRecord.p3_1 = sqlite3_column_int(dbps, 9);
        oneRecord.p3_2 = sqlite3_column_int(dbps, 10);
        oneRecord.p3_3 = sqlite3_column_int(dbps, 11);
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *date=[formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 12)]];
        oneRecord.startTimeStamp = date.timeIntervalSince1970;
        
        date = [formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 13)]];
        oneRecord.stopTimeStamp = date.timeIntervalSince1970;
    }
    
    // done with the db.  finalize the statement and close
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return oneRecord;
}

#pragma mark -- 练习簿方法
/*
 * 每次保存一个练习簿的时候，增加一条记录。初始化相关字段。
 * 当用户每次练习的时候，将当次练习的结果保存在这个表格中。
 * 每条练习簿项目，只记录最后一次的评分纪录。
 */
+(BOOL)addPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andReferAudioName:(NSString *)referAudioName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    NSString *saveStatementNS = @"replace into practice_book(user_name,answer_id,refer_audio_name) values(?,?,?);";
    
    const char *saveStatement = [saveStatementNS UTF8String];
    
    dbrc = sqlite3_prepare_v2(db, saveStatement, -1, &dbps, NULL);
    sqlite3_bind_text(dbps, 1, [userName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 2, [answerId cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 3, [referAudioName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(dbps))
    {
        NSLog(@"Save topic record to db failed!");
        sqlite3_finalize(dbps);
        sqlite3_close(db);
        return NO;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

+(void)updatePracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId andResultText:(NSString *)lastText score:(int)score pron:(int)pron integrity:(int)interity fluency:(int)fluency andLastAudioName:(NSString *)lastAudioName
{
    NSString *statement = [NSString stringWithFormat:@"update practice_book set timestamp=datetime('now','localtime'), last_text='%@', last_audio_name='%@', last_score='%d', last_pron='%d', last_integrity='%d', last_fluency='%d' where user_name='%@' and answer_id='%@'",
                           lastText, lastAudioName, score, pron, interity, fluency,
                           userName, answerId];
    
    NSLog(@"%@", statement);
    
    [OralDBFuncs performCmd:statement];
}

+(PracticeBookRecord *)getPracticeBookRecordFor:(NSString *)userName withAnswerId:(NSString *)answerId
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return nil;
    }
    
    // select stuff
    sqlite3_stmt *dbps; // database prepared statement
    NSString *queryStatementNS = [NSString stringWithFormat:@"select * from practice_book where user_name='%@' and answer_id='%@'", userName, answerId];
    const char *queryStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, queryStatement, -1, &dbps, NULL);
    
    PracticeBookRecord *oneRecord = nil;
    if ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW)
    {
        oneRecord = [[PracticeBookRecord alloc] init];
        
        oneRecord.userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 0)];
        oneRecord.answerId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 1)];

        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *date=[formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 2)]];
        oneRecord.timeStamp = date.timeIntervalSince1970;
        
        oneRecord.lastText = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 3)];
        oneRecord.referAudioName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 4)];
        oneRecord.lastAudioName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 5)];

        oneRecord.lastScore = sqlite3_column_int(dbps, 6);
        oneRecord.lastPron = sqlite3_column_int(dbps, 7);
        oneRecord.lastIntegrity = sqlite3_column_int(dbps, 8);
        oneRecord.lastFluency = sqlite3_column_int(dbps, 9);
    }
    
    // done with the db.  finalize the statement and close
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return oneRecord;
}

#pragma mark -- 累加录音时长方法

+(void)addPracticeTime:(long)seconds ForUser:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"update record_time set practice_time=practice_time+%ld where user_name='%@'", seconds, userName];
    [OralDBFuncs performCmd:statement];
}

+(void)addPlayTime:(long)seconds ForUser:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"update record_time set play_time=play_time+%ld where user_name='%@'", seconds, userName];
    [OralDBFuncs performCmd:statement];
}

+(void)addExamTime:(long)seconds ForUser:(NSString *)userName
{
    NSString *statement = [NSString stringWithFormat:@"update record_time set exam_time=exam_time+%ld where user_name='%@'", seconds, userName];
    [OralDBFuncs performCmd:statement];
}

#pragma mark -- 每一题的最后一次测试的纪录

+(BOOL)replaceLastRecordFor:(NSString *)userName TopicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum levelNum:(int)levelNum withRecordId:(NSString *)recordId lastText:(NSString *)lastText lastScore:(int)lastScore lastPron:(int)lastPron lastIntegrity:(int)lastIntegrity lastFluency:(int)lastFluency lastAudioName:(NSString *)lastAudioName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    NSString *saveStatementNS = @"replace into last_record(user_name,topic_name,record_id,answer_id,part_num,level_num,last_text,last_score,last_pron, last_integrity,last_fluency,last_audio_name,timestamp) values(?,?,?,?,?,?,?,?,?,?,?,?,datetime('now', 'localtime'));";
    
    const char *saveStatement = [saveStatementNS UTF8String];
    
    dbrc = sqlite3_prepare_v2(db, saveStatement, -1, &dbps, NULL);
    sqlite3_bind_text(dbps, 1, [userName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 2, [topicName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 3, [recordId cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 4, [answerId cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(dbps, 5, partNum);
    sqlite3_bind_int(dbps, 6, levelNum);
    sqlite3_bind_text(dbps, 7, [lastText cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(dbps, 8, lastScore);
    sqlite3_bind_int(dbps, 9, lastPron);
    sqlite3_bind_int(dbps, 10, lastIntegrity);
    sqlite3_bind_int(dbps, 11, lastFluency);
    sqlite3_bind_text(dbps, 12, [lastAudioName cStringUsingEncoding:NSUTF8StringEncoding],-1, SQLITE_TRANSIENT);

    if(SQLITE_DONE != sqlite3_step(dbps))
    {
        NSLog(@"Save topic record to db failed!");
        sqlite3_finalize(dbps);
        sqlite3_close(db);
        return NO;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

+(PracticeBookRecord *)getLastRecordFor:(NSString *)userName topicName:(NSString *)topicName answerId:(NSString *)answerId partNum:(int)partNum andLevelNum:(int)levelNum
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return nil;
    }
    
    // select stuff
    sqlite3_stmt *dbps; // database prepared statement
    NSString *queryStatementNS = [NSString stringWithFormat:@"select timestamp, record_id,last_text,last_score,last_pron,last_integrity,last_fluency,last_audio_name from last_record where user_name='%@' and topic_name='%@' and answer_id='%@' and part_num='%d' and level_num='%d'", userName, topicName, answerId, partNum, levelNum];
    const char *queryStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, queryStatement, -1, &dbps, NULL);
    
    PracticeBookRecord *oneRecord = nil;
    if ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW)
    {
        oneRecord = [[PracticeBookRecord alloc] init];
        
        oneRecord.userName = userName;
        oneRecord.answerId = answerId;
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *date=[formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 0)]];
        oneRecord.timeStamp = date.timeIntervalSince1970;
        
        /* referAudioName此时当作recordId来使用，调用者需要清楚这个事实。*/
        oneRecord.referAudioName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 1)];
        oneRecord.lastText = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 2)];
        oneRecord.lastScore = sqlite3_column_int(dbps, 3);
        oneRecord.lastPron = sqlite3_column_int(dbps, 4);
        oneRecord.lastIntegrity = sqlite3_column_int(dbps, 5);
        oneRecord.lastFluency = sqlite3_column_int(dbps, 6);
        oneRecord.lastAudioName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 7)];
    }
    
    // done with the db.  finalize the statement and close
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return oneRecord;
}

#pragma mark -- 各part的第三关的闯关纪录

+(BOOL)replaceLevel3RecordFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum questionNum:(int)questionNum withUserAudioName:(NSString *)userAudioName recordId:(NSString *)recordId replyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    NSString *saveStatementNS = @"replace into level3_records(user_name,topic_name,record_id,part_num,question_num,user_audio_name,reply_flag,score, teacher_name, teacher_reply_name, teacher_ts) values(?,?,?,?,?,?,?,?,?,?,datetime('now', 'localtime');";
    
    const char *saveStatement = [saveStatementNS UTF8String];
    
    dbrc = sqlite3_prepare_v2(db, saveStatement, -1, &dbps, NULL);
    sqlite3_bind_text(dbps, 1, [userName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 2, [topicName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 3, [recordId cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(dbps, 4, partNum);
    sqlite3_bind_int(dbps, 5, questionNum); // 第partN的第几个问题
    sqlite3_bind_text(dbps, 6, [userAudioName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(dbps, 7, replyFlag);
    sqlite3_bind_int(dbps, 8, score);
    sqlite3_bind_text(dbps, 9, [teacherName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 10, [teacherReplyName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(dbps))
    {
        NSLog(@"Save level3 record to db failed!");
        sqlite3_finalize(dbps);
        sqlite3_close(db);
        return NO;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

+(NSArray *)getAllLevel3RecordsFor:(NSString *)userName topicName:(NSString *)topicName partNum:(int)partNum
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return nil;
    }
    
    // select stuff
    sqlite3_stmt *dbps; // database prepared statement
    NSString *queryStatementNS = [NSString stringWithFormat:@"select * from level3_records where user_name='%@' and topic_name='%@' and part_num=%d order by record_id desc", userName, topicName, partNum];
    const char *queryStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, queryStatement, -1, &dbps, NULL);
    
    NSMutableArray *recordsArray = [[NSMutableArray alloc] init];
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW)
    {
        Level3Record *oneRecord = [[Level3Record alloc] init];
        
        oneRecord.userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 0)];
        oneRecord.topicName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 1)];
        oneRecord.recordId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 2)];
        oneRecord.partNum = sqlite3_column_int(dbps, 3);
        oneRecord.questionNum = sqlite3_column_int(dbps, 4);
        oneRecord.userAudioName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 5)];
        oneRecord.replyFlag = sqlite3_column_int(dbps, 6);
        oneRecord.score = sqlite3_column_int(dbps, 7);
        oneRecord.teacherName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 8)];
        oneRecord.teacherReplyName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 9)];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *date=[formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 10)]];
        oneRecord.teacherTimeStamp = date.timeIntervalSince1970;

        [recordsArray addObject:oneRecord];
    }
    
    // done with the db.  finalize the statement and close
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return recordsArray;
}

#pragma mark -- 模考纪录

+(BOOL)replaceExamRecordFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId withReplyFlag:(int)replyFlag score:(int)score teacherName:(NSString *)teacherName teacherReplyName:(NSString *)teacherReplyName
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return NO;
    }
    
    sqlite3_stmt *dbps; // database prepared statement
    NSString *saveStatementNS = @"replace into exam_records(user_name,topic_name,exam_id,reply_flag,score, teacher_name, teacher_reply_name, teacher_ts) values(?,?,?,?,?,?,?,datetime('now', 'localtime');";
    
    const char *saveStatement = [saveStatementNS UTF8String];
    
    dbrc = sqlite3_prepare_v2(db, saveStatement, -1, &dbps, NULL);
    sqlite3_bind_text(dbps, 1, [userName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 2, [topicName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 3, [examId cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(dbps, 4, replyFlag);
    sqlite3_bind_int(dbps, 5, score);
    sqlite3_bind_text(dbps, 6, [teacherName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(dbps, 7, [teacherReplyName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(dbps))
    {
        NSLog(@"Save exam record to db failed!");
        sqlite3_finalize(dbps);
        sqlite3_close(db);
        return NO;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return YES;
}

+(NSArray *)getAllExamRecordsFor:(NSString *)userName topicName:(NSString *)topicName examId:(NSString *)examId
{
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [[OralDBFuncs getDbFilePath] UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog (@"couldn't open db:");
        return nil;
    }
    
    // select stuff
    sqlite3_stmt *dbps; // database prepared statement
    NSString *queryStatementNS = [NSString stringWithFormat:@"select * from exam_records where user_name='%@' and topic_name='%@' and exam_id='%@' order by exam_id desc", userName, topicName, examId];
    const char *queryStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, queryStatement, -1, &dbps, NULL);
    
    NSMutableArray *recordsArray = [[NSMutableArray alloc] init];
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW)
    {
        ExamRecord *oneRecord = [[ExamRecord alloc] init];
        
        oneRecord.userName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 0)];
        oneRecord.topicName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 1)];
        oneRecord.examId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 2)];
        oneRecord.replyFlag = sqlite3_column_int(dbps, 3);
        oneRecord.score = sqlite3_column_int(dbps, 4);
        oneRecord.teacherName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 5)];
        oneRecord.teacherReplyName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 6)];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *date=[formatter dateFromString:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(dbps, 7)]];
        oneRecord.teacherTimeStamp = date.timeIntervalSince1970;
        
        [recordsArray addObject:oneRecord];
    }
    
    // done with the db.  finalize the statement and close
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return recordsArray;
}

#pragma mark -- Global application context

+(void)setCurrentUser:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:KEY_CONTEXT_USERNAME];
}

+(NSString *)getCurrentUser
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONTEXT_USERNAME];
    return userName;
}

+(void)setCurrentTopic:(NSString *)topicName
{
    [[NSUserDefaults standardUserDefaults] setObject:topicName forKey:KEY_CONTEXT_TOPICNAME];
}

+(NSString *)getCurrentTopic
{
    NSString *topicName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONTEXT_TOPICNAME];
    return topicName;
}

+(void)setCurrentPoint:(int)pointNum
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:pointNum] forKey:KEY_CONTEXT_CUR_LEVEL];
}

+(int)getCurrentPoint
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONTEXT_CUR_LEVEL];
    return [number intValue];
}

+(void)setCurrentRecordId:(NSString *)recordId
{
    [[NSUserDefaults standardUserDefaults]setObject:recordId forKey:KEY_CONTEXT_RECORDID];
}

+(NSString *)getCurrentRecordId
{
    NSString *recordId = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CONTEXT_RECORDID];
    return recordId;
}

@end

#pragma mark -- user defined classes

@implementation TopicRecord

@synthesize userName, topicName, completion, p1_1, p1_2, p1_3, p2_1, p2_2, p2_3, p3_1, p3_2, p3_3, startTimeStamp, stopTimeStamp;

@end

@implementation PracticeBookRecord

@synthesize userName, answerId, timeStamp, lastAudioName, lastFluency, lastIntegrity, lastPron, lastScore, lastText, referAudioName;

@end

@implementation Level3Record

@synthesize userAudioName, userName, topicName, replyFlag, recordId, partNum, questionNum, score, teacherReplyName, teacherName, teacherTimeStamp;

@end

@implementation ExamRecord

@synthesize userName, topicName, examId, replyFlag, score, teacherTimeStamp, teacherReplyName, teacherName;

@end


