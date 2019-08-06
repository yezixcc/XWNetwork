//
//  XWFileManager.h
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWFileManager : NSObject

/**
 根据传进来的路径先判断有没有改路径,没有则创建

 @param tempSavePath 保存路径
 @return 是否保存
 */
+ (BOOL)getSavePath:(NSString *)tempSavePath;

@end

