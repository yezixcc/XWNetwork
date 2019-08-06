//
//  XWFileManager.m
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWFileManager.h"

@implementation XWFileManager

/**
 根据传进来的路径先判断有没有改路径,没有则创建
 
 @param tempSavePath 保存路径
 @return 是否保存
 */
+ (BOOL)getSavePath:(NSString *)tempSavePath {
    BOOL canSave = NO;
    if (tempSavePath) {
        //要保存的文件夹名字
        NSString *fileName = [tempSavePath lastPathComponent];
        
        if (fileName.length>0) {
            
            NSString *directoryPath = [[tempSavePath componentsSeparatedByString:fileName] firstObject];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:directoryPath]){
                canSave = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            } else {
                canSave = YES;
            }
        }
        
        return canSave;
    }
    return canSave;
}

@end
