//
//  XWNetworkTargetProtocol.h
//  Process
//
//  Created by gaoxw on 2019/7/29.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWNetwork.h"

@protocol XWNetworkTargetProtocol <NSObject>

@optional

/// 基地址
@property (nonatomic, copy) NSString *url;
/// 接口名
@property (nonatomic, copy) NSString *path;
/// 接口参数
@property (nonatomic, copy) NSDictionary *params;
/// 请求头
@property (nonatomic, copy) NSDictionary *headers;
/// msg取值key
@property (nonatomic, copy) NSString *msgKey;
/// code取值key
@property (nonatomic, copy) NSString *codeKey;
/// data取值key
@property (nonatomic, copy) NSString *dataKey;
/// 网络错误默认提示
@property (nonatomic, copy) NSString *networkErrorMessage;
/// 服务器错误默认提示
@property (nonatomic, copy) NSString *serverErrorMessage;
/// 请求方式
@property (nonatomic, assign) XWRequestMethod method;
/// 请求失败重发
@property (nonatomic, strong) NSNumber *needRetryFailed;
/// 缓存接口数据
@property (nonatomic, strong) NSNumber *needCache;
/// 是否需要同步请求
@property (nonatomic, assign) BOOL needSync;
/// 超时时间
@property (nonatomic, assign) NSInteger timeoutInterval;
/// 服务器成功code
@property (nonatomic, assign) NSInteger successCode;
/// 网络请求处理插件
@property (nonatomic, weak) id<XWNetworkPluginProtocol>plugin;
/// 请求的公共参数处理插件
@property (nonatomic, weak) id<XWNetworkPackageProtocol>package;

@end

