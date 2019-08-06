//
//  XWNetworkConfigProtocol.h
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWNetwork.h"

@protocol XWNetworkConfigProtocol <NSObject>

/// 开发环境服务器地址
- (NSString *)serverURL_dev;
/// 生产环境地址
- (NSArray<NSString *> *)serverURLs_release;
/// 提示信息的取值key
- (NSString *)msgKey;
/// 请求code的取值key
- (NSString *)codeKey;
/// 返回数据的取值key
- (NSString *)dataKey;
/// 请求成功code
- (NSInteger)successCode;


@optional
/// 请求方式
- (XWRequestMethod)method;
/// 请求头
- (NSDictionary *)headers;
/// 是否需要失败重发请求
- (NSNumber *)needRetryFailed;
/// 是否需要缓存接口数据
- (NSNumber *)needCache;
/// 是否需要同步请求
- (BOOL)needSync;
/// 超时时间
- (NSInteger)timeoutInterval;
/// 网络错误提示
- (NSString *)networkErrorMessage;
/// 服务器错误提示
- (NSString *)serverErrorMessage;
/// 网络请求处理插件
- (id<XWNetworkPluginProtocol>)plugin;
/// 公共参数处理插件
- (id<XWNetworkPackageProtocol>)package;


/// 测试环境服务器地址
- (NSString *)serverURL_test;
/// 预发布环境地址
- (NSString *)serverURL_prepare;

@end

