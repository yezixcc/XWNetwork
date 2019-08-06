//
//  XWNetworkConfigManager.m
//  XWNetwork
//
//  Created by jqq on 2019/8/6.
//  Copyright © 2019 g.ly@foxmail.com. All rights reserved.
//

#import "XWNetworkConfigManager.h"

@implementation XWNetworkConfigManager

#pragma mark - 必须实现

/// 取状态码key
- (NSString *)codeKey {
    return @"success";
}

/// 取返回数据key
- (NSString *)dataKey {
    return @"data";
}

/// 取提示信息key
- (NSString *)msgKey {
    return @"msg";
}

/// 成功码
- (NSInteger)successCode {
    return 1;
}

/// 开发环境地址
- (NSString *)serverURL_dev {
    return @"https://www.easy-mock.com/mock/5d3fe3b78ea1187752eefa13/example";
}

/// 生产环境地址
- (NSArray<NSString *> *)serverURLs_release {
    return @[@"https://www.easy-mock.com/mock/5d3fe3b78ea1187752eefa13/example1",
             @"https://www.easy-mock.com/mock/5d3fe3b78ea1187752eefa13/example2",
             @"https://www.easy-mock.com/mock/5d3fe3b78ea1187752eefa13/example3",
             @"https://www.easy-mock.com/mock/5d3fe3b78ea1187752eefa13/example"];
}

#pragma mark - 可选实现

/// 请求方式
- (XWRequestMethod)method {
    return XWRequestMethodPOST;
}

/// 请求头
- (NSDictionary *)headers {
    return nil;
}

/// 是否需要失败重发请求
- (NSNumber *)needRetryFailed {
    return @(YES);
}

/// 是否需要缓存接口数据
- (NSNumber *)needCache {
    return @(NO);
}

/// 是否需要同步请求
- (BOOL)needSync {
    return NO;
}

/// 超时时间
- (NSInteger)timeoutInterval {
    return 30;
}

/// 网络错误提示
- (NSString *)networkErrorMessage {
    return @"网络不给力，请稍后再试";
}

/// 服务器错误提示
- (NSString *)serverErrorMessage {
    return @"哎呀，加载出错了〜";
}

/// 网络请求处理插件
- (id<XWNetworkPluginProtocol>)plugin {
    return self;
}

/// 公共参数处理插件
- (id<XWNetworkPackageProtocol>)package {
    return self;
}

/// 测试环境服务器地址
- (NSString *)serverURL_test {
    return nil;
}

/// 预发布环境地址
- (NSString *)serverURL_prepare {
    return nil;
}

#pragma mark 组装公共参数

- (NSDictionary *)packageParameters:(NSDictionary *)params path:(NSString *)path {
    return nil;
}


#pragma mark 网络请求时机

- (void)willSendRequest:(XWNetworkTarget *)target {
    NSLog(@"---- 即将发送请求 %@ ----", target.path);
}

- (void)didCancelRequest:(XWNetworkTarget *)target {
    NSLog(@"---- 取消请求 %@ ----", target.path);
}

- (void)didReceiveResultBegin:(NSDictionary *)result error:(NSError *)error target:(XWNetworkTarget *)target {
    NSLog(@"---- 请求 %@ 回调开始 ----", target.path);
}

- (void)didReceiveResultComplete:(NSDictionary *)result error:(NSError *)error target:(XWNetworkTarget *)target {
    NSLog(@"---- 请求 %@ 回调结束 ----", target.path);
}

- (void)willRetryRequest:(XWNetworkTarget *)target {
    NSLog(@"---- 即将重新发送请求 %@ ----", target.path);
}

@end
