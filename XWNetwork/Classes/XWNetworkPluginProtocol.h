//
//  XWPluginProtocol.h
//  Process
//
//  Created by gaoxw on 2019/7/25.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XWNetworkTarget;

@protocol XWNetworkPluginProtocol <NSObject>

@optional

/**
 即将发送请求：可以在此统一执行以下操作
 1、show loading
 2、组装公共参数，加密参数等操作

 @param target 请求体
 */
- (void)willSendRequest:(XWNetworkTarget *)target;


/**
 网络请求被取消

 @param target 请求体
 */
- (void)didCancelRequest:(XWNetworkTarget *)target;


/**
 已经接收到请求结果-开始：可以在此统一执行以下操作
 1、解密数据，将后台返回的数据组装成符合要求的数据结构
 {
    data:{},
    msg:"请求成功",
    code:"200"
 }
 
 @param result 请求结果
 @param error 错误
 @param target 请求体
 */
- (void)didReceiveResultBegin:(NSDictionary *)result
                        error:(NSError *)error
                       target:(XWNetworkTarget *)target;

/**
 已经接收到请求结果-结束：可以在此统一执行以下操作
 1、end loading
 2、show toast

 @param result 请求结果
 @param error 错误
 @param target 请求体
 */
- (void)didReceiveResultComplete:(NSDictionary *)result
                           error:(NSError *)error
                          target:(XWNetworkTarget *)target;


/**
 即将重发请求

 @param target 请求体
 */
- (void)willRetryRequest:(XWNetworkTarget *)target;

@end

