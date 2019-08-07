//
//  XWDomainManager.m
//  Process
//
//  Created by gaoxw on 2019/8/1.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWDomainManager.h"
#import "XWNetworkDevTool.h"

/// 当前服务器类型取值key
NSString *const key_serverType = @"key_serverType";
/// 当前服务器地址取值key
NSString *const key_serverURL = @"key_serverURL";
/// 生产环境
NSString * serverURL_product = nil;
/// 开发环境
NSString * serverURL_dev = nil;
/// 测试环境
NSString * serverURL_test = nil;
/// 预发布环境
NSString * serverURL_prepare = nil;
/// 生产环境(请求失败自动切换服务器)
NSArray<NSString *> *serverURLs_release = nil;


@implementation XWDomainManager


+ (void)configServerURLs:(NSString *)dev
                    test:(NSString *)test
                 prepare:(NSString *)prepare
                releases:(NSArray<NSString *> *)releases {
    serverURL_dev = dev;
    serverURL_test = test;
    serverURL_prepare = prepare;
    serverURLs_release = releases;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    serverURL_product = [userDefaults objectForKey:key_serverURL];
    if (!serverURL_product && releases.count) {
        serverURL_product = releases.firstObject;
    }
    [XWNetworkDevTool start];
}

+ (void)setCurrentServerType:(XWServerType)type {
    /// 只在debug下支持环境切换
#ifdef DEBUG
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(type) forKey:key_serverType];
    [userDefaults synchronize];
#endif
}

+ (XWServerType)currenServerType {
    /// 只在debug下支持环境切换
#ifdef DEBUG
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    XWServerType server = [[userDefaults objectForKey:key_serverType] integerValue];
    return server;
#else
    return XWServerTypeProduct;
#endif
}

+ (NSString *)domain {
    return [self serverURL:[XWDomainManager currenServerType]];
}

+ (NSString *)serverURL:(XWServerType)serverType {
    switch (serverType) {
        case XWServerTypeDevelop:
            return serverURL_dev;
            break;
        case XWServerTypeTest:
            return serverURL_test;
            break;
        case XWServerTypePrepare:
            return serverURL_prepare;
            break;
        case XWServerTypeProduct:
            return serverURL_product;
            break;
        default:
            break;
    }
    return nil;
}

+ (void)autoChangeDomain:(XWNetworkTarget *)target {
    /// 只在生产环境下支持域名切换
    if ([XWDomainManager currenServerType] != XWServerTypeProduct) {
        return ;
    }
    if (serverURL_product.length == 0) {
        NSLog(@"error : serverURL_product 为空");
        return;
    }
    /// 说明已被其他接口执行切换操作，不再执行切换操作
    if ([target.url rangeOfString:serverURL_product].location == NSNotFound) {
        return ;
    }
    
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    for (int i=0; i<serverURLs_release.count; i++) {
        if ([serverURL_product isEqualToString:serverURLs_release[i]]) {
            if (i == serverURLs_release.count - 1) {
                i = 0;
            }else {
                i = i+1;
            }
            serverURL_product = serverURLs_release[i];
            break;
        }
    }
    target.url = serverURL_product;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:serverURL_product forKey:key_serverURL];
    [userDefaults synchronize];
    [lock unlock];
}

@end
