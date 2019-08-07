//
//  XWFMDBManager.m
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWFMDBManager.h"
#import "FMDB.h"

#define JsonData_Table      @"JsonDataTable"     /** 保存应用所有接口返回的json数据表*/
@implementation XWFMDBManager

static FMDatabase *_db;

/**
 *  初始化数据库
 */
+ (void)initialize {
    // 1.打开数据库
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"XWDB.sqlite"];
    
    _db = [FMDatabase databaseWithPath:file];
    if (![_db open]) return;
    
    // 2.创建json数据表
    [_db executeUpdate:@"create table if not exists JsonDataTable (id integer PRIMARY KEY,jsonkey text NOT NULL,jsonData blob  NOT NULL)"];
}


/**
 *  获取 "JsonData_Table" 表中的json数据表的数据
 */
+ (NSData *)getJsonDataFromDB:(NSString *)key {
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM JsonDataTable WHERE jsonKey = ? ", key];
    
    //只有一行数据就用 if, 否则用 while
    if ([set next]) {
        NSData *data = [set dataForColumn:@"jsonData"];
        return data;
    }
    return nil;
}


/**
 *  保存 "JsonData_Table" 数据到数据库
 *
 *  @param jsonData 接口请求返回的json数据
 *  @param key     接口拼接的key
 */
+ (void)saveJsonDataToDB:(NSData *)jsonData byKey:(NSString *)key {
    if (!jsonData) {
        NSLog(@"待保存的 jsonData 不存在");
        return;
    }
    [self removeJsonDataByKey:key];
    BOOL isOK = [_db executeUpdate:@"insert into JsonDataTable (jsonkey,jsonData) values (?,?)", key, jsonData];
    if (isOK) {
        NSLog(@"保存 JsonData_Table 数据到数据库 成功");
    }else {
        NSLog(@"保存 JsonData_Table 数据到数据库 失败");
    }
    
}


/**
 *  插入之前先删除 "JsonData_Table" 数据库中之前的旧数据
 *
 *  @param key 接口拼接的key
 */
+ (void)removeJsonDataByKey:(NSString *)key {
    [_db executeUpdate:@"DELETE FROM JsonDataTable WHERE jsonKey = ?",key];
}

@end
