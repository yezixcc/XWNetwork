//
//  XWFMDBManager.h
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWFMDBManager : NSObject

/**
 *  获取 "JsonData_Table" 表中的json数据表的数据
 */
+ (NSData *)getJsonDataFromDB:(NSString *)key;


/**
 *  保存 "JsonData_Table" 数据到数据库
 *
 *  @param jsonDic 接口请求返回的json数据
 *  @param key     接口拼接的key
 */
+ (void)saveJsonDataToDB:(NSData *)jsonDic byKey:(NSString *)key;


/**
 *  插入之前先删除 "JsonData_Table" 数据库中之前的旧数据
 *
 *  @param key 接口拼接的key
 */
+ (void)removeJsonDataByKey:(NSString *)key;

@end
