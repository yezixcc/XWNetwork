//
//  XWDomainManager.h
//  Process
//
//  Created by gaoxw on 2019/8/1.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWNetwork.h"

/// 开发环境
UIKIT_EXTERN NSString * serverURL_dev;

@interface XWDomainManager : NSObject


/**
 配置各个环境的服务器地址

 @param dev 开发环境
 @param test 测试环境
 @param prepare 预发布环境
 @param releases 生产环境
 */
+ (void)configServerURLs:(NSString *)dev
                    test:(NSString *)test
                 prepare:(NSString *)prepare
                releases:(NSArray<NSString *> *)releases;

/**
 设置当前服务器环境

 @param type 类型
 */
+ (void)setCurrentServerType:(XWServerType)type;


/**
 获取当前服务器环境

 @return 当前服务器环境
 */
+ (XWServerType)currenServerType;


/**
 获取各环境地址

 @param serverType 类型
 @return 地址
 */
+ (NSString *)serverURL:(XWServerType)serverType;


/**
 服务器地址

 @return 服务器地址
 */
+ (NSString *)domain;


/**
 自动切换域名（只有在Release模式下有效）

 @param target 该次请求体
 */
+ (void)autoChangeDomain:(XWNetworkTarget *)target;


@end

