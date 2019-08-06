//
//  XWNetworkManager.h
//  Process
//
//  Created by gaoxw on 2019/7/24.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWNetwork.h"


@interface XWNetworkManager : NSObject

/**
 网络请求管理器
 */
+ (instancetype)shareInstance;


/**
 统一配置网络请求

 @param config 配置
 */
+ (void)configNetworkManager:(id<XWNetworkConfigProtocol>)config;


/**
 发送请求：默认POST请求，不缓存，失败重发，不同步

 @param params 参数字典
 @param path 接口名
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestParams:(NSDictionary *)params
                 path:(NSString *)path
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;

/**
 发送请求：默认POST请求

 @param params 参数字典
 @param path 接口名
 @param needCache 是否需要缓存
 @param needSync 是否需要同步请求
 @param needRetryFailed 是否失败重发
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestParams:(NSDictionary *)params
                 path:(NSString *)path
            needCache:(BOOL)needCache
             needSync:(BOOL)needSync
      needRetryFailed:(BOOL)needRetryFailed
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;


/**
 发送请求：默认POST请求，请求方式各参数自定义

 @param target 请求目标
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestTarget:(id<XWNetworkTargetProtocol>)target
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;


/**
 上传图片

 @param images 图片数组
 @param params 参数
 @param path 接口名
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)upLoadImages:(NSArray<UIImage *> *)images
              params:(NSDictionary *)params
                path:(NSString *)path
            progress:(void(^)(NSProgress *))uploadProgress
             success:(SuccessBlock)success
             failure:(FailureBlock)failure;


/**
 上传图片

 @param images 图片数组
 @param target 请求体
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)upLoadImages:(NSArray<UIImage *> *)images
              target:(id<XWNetworkTargetProtocol>)target
            progress:(void(^)(NSProgress *))uploadProgress
             success:(SuccessBlock)success
             failure:(FailureBlock)failure;

/**
 下载文件

 @param url 文件下载地址
 @param savePath 文件保存地址
 @param progressBlock 下载进度
 @param blockRelust 完成回调
 */
+ (void)downLoadFile:(NSString *)url
          saveToPath:(NSString *)savePath
      updateProgress:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))progressBlock
 downLoadRelustBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))blockRelust;


/**
 取消所有网络请求
 */
+ (void)cancelAllRequest;


/**
 取消某个网络请求

 @param method 请求的方式：POST, GET
 @param baseUrl 请求的地址
 @param path 请求的接口名
 */
+ (void)cancelRequest:(NSString *)method baseUrl:(NSString *)baseUrl path:(NSString *)path;


@end

