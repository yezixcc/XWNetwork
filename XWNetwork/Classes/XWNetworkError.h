//
//  XWNetworkError.h
//  Process
//
//  Created by gaoxw on 2019/7/26.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XWNetworkTarget;

@interface XWNetworkError : NSObject

/**
 错误本地化处理

 @param error 错误
 @param target 网络请求体
 @return 是否处理
 */
+ (BOOL)localizationError:(NSError **)error target:(XWNetworkTarget *)target;


/**
 自定义错误

 @param errorCode 错误码
 @param description 错误描述
 @param domain 域名
 @return 错误
 */
+ (NSError *)errorWithErrorCode:(NSInteger)errorCode
                    description:(NSString *)description
                         domain:(NSString *)domain;

@end

