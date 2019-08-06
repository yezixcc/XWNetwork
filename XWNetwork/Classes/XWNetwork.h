//
//  XWNetwork.h
//  Process
//
//  Created by gaoxw on 2019/8/2.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 请求回调
typedef void(^SuccessBlock)(NSDictionary *result, NSString *msg);
typedef void(^FailureBlock)(NSError *error);


/// 请求方式
typedef NS_ENUM(NSInteger, XWRequestMethod) {
    XWRequestMethodPOST,
    XWRequestMethodGET,
};


/// 服务器环境
typedef NS_ENUM(NSInteger, XWServerType) {
    XWServerTypeDevelop = 0,  // 开发环境
    XWServerTypeTest,     // 测试环境
    XWServerTypePrepare,  // 预发布环境
    XWServerTypeProduct,  // 生产环境
};


/// 依赖
#import "XWNetworkPluginProtocol.h"
#import "XWNetworkPackageProtocol.h"
#import "XWNetworkTargetProtocol.h"
#import "XWNetworkTarget.h"
#import "XWNetworkConfigProtocol.h"
#import "XWNetworkManager.h"
#import "XWDomainManager.h"
