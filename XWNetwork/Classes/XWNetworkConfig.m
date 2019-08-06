//
//  XWNetworkConfig.m
//  Process
//
//  Created by gaoxw on 2019/7/25.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkConfig.h"

@implementation XWNetworkConfig

/// 基地址
- (NSString *)baseURL {
    return nil;
}

/// 请求方式
- (XWRequestMethod)method {
    return XWRequestMethodPOST;
}

/// 请求头
- (NSDictionary *)headers {
    return nil;
}

/// 是否需要缓存接口数据
- (NSNumber *)needCache {
    return [NSNumber numberWithBool:NO];
}

/// 是否需要同步请求
- (BOOL)needSync {
    return NO;
}

/// 是否需要失败重发请求
- (NSNumber *)needRetryFailed {
    return [NSNumber numberWithBool:YES];
}

/// 网络错误提示
- (NSString *)networkErrorMessage {
    return @"网络不给力，请稍后再试";
}

/// 服务器错误提示
- (NSString *)serverErrorMessage {
    return @"哎呀，加载出错了〜";
}

/// 请求成功code
- (NSInteger)successCode {
    return 200;
}

/// 超时时间
- (NSInteger)timeoutInterval {
    return 30;
}

/// 提示信息的取值key
- (NSString *)msgKey {
    return @"msg";
}

/// 请求code的取值key
- (NSString *)codeKey {
    return @"code";
}

/// 返回数据的取值key
- (NSString *)dataKey {
    return @"data";
}

/// 网络请求处理插件
- (id<XWNetworkPluginProtocol>)plugin {
    return nil;
}

/// 公共参数处理插件
- (id<XWNetworkPackageProtocol>)package {
    return nil;
}

/// 开发环境服务器地址
- (NSString *)serverURL_dev {
    return nil;
}

/// 测试环境服务器地址
- (NSString *)serverURL_test {
    return nil;
}

/// 预发布环境地址
- (NSString *)serverURL_prepare {
    return nil;
}

/// 生产环境地址
- (NSArray<NSString *> *)serverURLs_release {
    return nil;
}

@end
