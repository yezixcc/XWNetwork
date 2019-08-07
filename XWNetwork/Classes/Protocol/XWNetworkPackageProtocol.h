//
//  XWNetworkPulbicParamsMergeProtocol.h
//  Process
//
//  Created by gaoxw on 2019/7/25.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XWNetworkPackageProtocol <NSObject>

@optional
/**
 封装公共参数

 @param params 单个接口参数
 @param path 接口名
 @return 处理完的参数
 */
- (NSDictionary *)packageParameters:(NSDictionary *)params path:(NSString *)path;


@end
