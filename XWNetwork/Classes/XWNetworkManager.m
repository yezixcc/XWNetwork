//
//  XWNetworkManager.m
//  Process
//
//  Created by gaoxw on 2019/7/24.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkManager.h"
#import "XWNetworkTarget.h"
#import "XWNetworkError.h"
#import "XWFMDBManager.h"
#import "XWFileManager.h"
#import "XWNetworkConfig.h"
#import "XWDomainManager.h"
#import "XWNetworkDevTool.h"
#import <AFNetworking/AFNetworking.h>

#define ISLocalDataKey      @"ISLocalData"     //是否是本地缓存数据标识
@interface XWNetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) id<XWNetworkConfigProtocol> config;

@end

@implementation XWNetworkManager

#pragma mark - 实例

+ (instancetype)shareInstance {
    static XWNetworkManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XWNetworkManager alloc] init];
        _instance.config = [[XWNetworkConfig alloc] init];
    });
    return _instance;
}

+ (void)configNetworkManager:(id<XWNetworkConfigProtocol>)config {
    XWNetworkManager *manager = [XWNetworkManager shareInstance];
    manager.config = config;
    [XWDomainManager configServerURLs:[manager configSEL:@selector(serverURL_dev)]
                                 test:[manager configSEL:@selector(serverURL_test)]
                              prepare:[manager configSEL:@selector(serverURL_prepare)]
                             releases:[manager configSEL:@selector(serverURLs_release)]];
}

#pragma mark - 发送请求

+ (void)requestParams:(NSDictionary *)params
                 path:(NSString *)path
              success:(SuccessBlock)success
              failure:(FailureBlock)failure; {
    id<XWNetworkTargetProtocol> target = [[XWNetworkTarget alloc] init];
    [target setParams:params];
    [target setPath:path];
    [self requestTarget:target success:success failure:failure];
}

+ (void)requestParams:(NSDictionary *)params
                 path:(NSString *)path
            needCache:(BOOL)needCache
             needSync:(BOOL)needSync
      needRetryFailed:(BOOL)needRetryFailed
              success:(SuccessBlock)success
              failure:(FailureBlock)failure {
    id<XWNetworkTargetProtocol> target = [[XWNetworkTarget alloc] init];
    [target setParams:params];
    [target setPath:path];
    [target setNeedCache:[NSNumber numberWithBool:needCache]];
    [target setNeedSync:needSync];
    [target setNeedRetryFailed:[NSNumber numberWithBool:needRetryFailed]];
    [self requestTarget:target success:success failure:failure];
}

+ (void)requestTarget:(id<XWNetworkTargetProtocol>)target
              success:(SuccessBlock)success
              failure:(FailureBlock)failure {
    XWNetworkManager *manager = [XWNetworkManager shareInstance];
    if (![manager setRequest:target]) return;
    [manager getCacheDataByTarget:target success:success];
    [manager sendRequestTarget:target success:success failure:failure];
}


#pragma mark - 上传图片

+ (void)upLoadImages:(NSArray<UIImage *> *)images
              params:(NSDictionary *)params
                path:(NSString *)path
            progress:(void(^)(NSProgress *))uploadProgress
             success:(SuccessBlock)success
             failure:(FailureBlock)failure {
    XWNetworkTarget *target = [[XWNetworkTarget alloc] init];
    [target setParams:params];
    [target setPath:path];
    [self upLoadImages:images target:target progress:uploadProgress success:success failure:failure];
}

+ (void)upLoadImages:(NSArray<UIImage *> *)images
              target:(id<XWNetworkTargetProtocol>)target
            progress:(void(^)(NSProgress *))uploadProgress
             success:(SuccessBlock)success
             failure:(FailureBlock)failure {
    XWNetworkManager *manager = [XWNetworkManager shareInstance];
    if (![manager setRequest:target]) return;
    NSString *url = [NSString stringWithFormat:@"%@/%@",target.url, target.path];
    __weak typeof(manager) weakManager = manager;
    [manager.sessionManager POST:url parameters:target.params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (UIImage *image in images) {
            if (!image) { continue; }
            NSData *data = UIImageJPEGRepresentation(image, 0.5);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[formatter stringFromDate:[NSDate date]]];
            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
        }
    } progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakManager requestResponse:responseObject target:target success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakManager requestError:error target:target success:success failure:failure];
    }];
}


#pragma mark - 下载文件

+ (void)downLoadFile:(NSString *)url
          saveToPath:(NSString *)savePath
      updateProgress:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))progressBlock
 downLoadRelustBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))blockRelust {
    if (![XWFileManager getSavePath:savePath]) {
        NSLog(@"error -- : 保存的文件路径不正确！！！");
        return ;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        NSLog(@"%@", [NSString stringWithFormat:@"error -- : 文件已经下载过==%@！！！", savePath]);
        if (blockRelust) {
            blockRelust(nil, [NSURL fileURLWithPath:savePath], nil);
        }
        return ;
    }
    NSURL *URL = [NSURL URLWithString:url];
    if (!URL) { return ; }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:300];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:savePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@", [NSString stringWithFormat:@"下载文件完成放入目录地址: %@", [filePath path]]);
        if (blockRelust) {
            blockRelust(response, filePath, error);
        }
    }];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        if (progressBlock) {
            progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }
    }];
    
    [downloadTask resume];
}


#pragma mark - 取消请求

+ (void)cancelAllRequest {
    NSArray *tasks = [XWNetworkManager shareInstance].sessionManager.tasks;
    if (tasks.count > 0) {
        [tasks makeObjectsPerformSelector:@selector(cancel)];
    }
}

+ (void)cancelRequest:(NSString *)method baseUrl:(NSString *)baseUrl path:(NSString *)path; {
    if (!baseUrl.length) return;
    NSError *error;
    AFHTTPSessionManager *sessionManager = [XWNetworkManager shareInstance].sessionManager;
    NSString *url = path.length ? [NSString stringWithFormat:@"%@/%@", baseUrl, path] : baseUrl;
    NSString *URL = [[[sessionManager.requestSerializer requestWithMethod:method URLString:url parameters:nil error:&error] URL] path];
    for (NSURLSessionTask *task in sessionManager.tasks) {
        if ([task isKindOfClass:[NSURLSessionTask class]]) {
            BOOL hasMatchRequestType = [method isEqualToString:[[(NSURLSessionTask *)task currentRequest] HTTPMethod]];
            BOOL hasMatchRequestUrlString = [URL isEqualToString:[[[(NSURLSessionTask *)task currentRequest] URL] path]];
            if (hasMatchRequestType && hasMatchRequestUrlString) {
                [task cancel];
            }
        }
    }
}


#pragma mark - 私有

/**
 获取接口缓存数据
 */
- (void)getCacheDataByTarget:(id<XWNetworkTargetProtocol>)target
                     success:(SuccessBlock)success {
    if ([target.needCache boolValue]) {
        NSString *key = [self getCacheKeyByTarget:target];
        NSData *cacheData = [XWFMDBManager getJsonDataFromDB:key];
        
        if (cacheData && [cacheData isKindOfClass:[NSData class]]) {
            NSDictionary * cacheInfo = [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingAllowFragments error:nil];
            if (cacheInfo) {
                NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:cacheInfo];
                dataDic[ISLocalDataKey] = [NSNumber numberWithBool:YES];
                success(dataDic, nil);
            }
        }
    }
}

/**
 缓存接口数据
 */
- (void)saveResponse:(id)response target:(id<XWNetworkTargetProtocol>)target {
    if ([target.needCache boolValue]) {
        NSString *key = [self getCacheKeyByTarget:target];
        NSData *cacheData = [NSJSONSerialization dataWithJSONObject:response
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
        [XWFMDBManager saveJsonDataToDB:cacheData byKey:key];
    }
}

/**
 包装每个接口缓存数据的key
 */
- (NSString *)getCacheKeyByTarget:(id<XWNetworkTargetProtocol>)target {
    NSString *key = @"";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", target.url, target.path];
    NSDictionary *parameter = target.params;
    if (urlString && [urlString isKindOfClass:[NSString class]]) {
        key = urlString;
    }
    if (parameter && [parameter isKindOfClass:[NSDictionary class]]) {
        NSArray * dickeys = [parameter allKeys];
        for (NSString * dickey in dickeys) {
            NSString * valus = [parameter objectForKey:dickey];
            key = [NSString stringWithFormat:@"%@%@%@",key,dickey,valus];
        }
    }
    return key;
}

/**
 发送请求前配置
 */
- (BOOL)setRequest:(id<XWNetworkTargetProtocol>)target {
    [self setConfigParameters:target];
    if (!target.url.length) {
        NSLog(@"error -- : 请求url不能为空！！！");
        return NO;
    }
    [self willSendRequest:target];
    [self setSessionManagerTarget:target];
    return YES;
}

/**
 设置配置参数
 */
- (void)setConfigParameters:(id<XWNetworkTargetProtocol>)target {
    target.headers = target.headers ? : [self configSEL:@selector(headers)];
    target.msgKey = target.msgKey ? : [self configSEL:@selector(msgKey)];
    target.codeKey = target.codeKey ? : [self configSEL:@selector(codeKey)];
    target.dataKey = target.dataKey ? : [self configSEL:@selector(dataKey)];
    target.successCode = target.successCode ? : [self configIntSEL:@selector(successCode)];
    target.plugin = target.plugin ? : [self configSEL:@selector(plugin)];
    target.package = target.package ? : [self configSEL:@selector(package)];
    target.needCache = target.needCache ? : [self configSEL:@selector(needCache)];
    target.needSync = target.needSync ? : (BOOL)[self configSEL:@selector(needSync)];
    target.needRetryFailed = target.needRetryFailed ? : [self configSEL:@selector(needRetryFailed)];
    target.timeoutInterval = target.timeoutInterval ? : [self configIntSEL:@selector(timeoutInterval)];
    target.networkErrorMessage = target.networkErrorMessage ? : [self configSEL:@selector(networkErrorMessage)];
    target.serverErrorMessage = target.serverErrorMessage ? : [self configSEL:@selector(serverErrorMessage)];
    target.url = target.url ? : [XWDomainManager domain];
}

- (id)configSEL:(SEL)sel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.config respondsToSelector:sel]) {
        return [self.config performSelector:sel];
    }
    XWNetworkConfig *config = [[XWNetworkConfig alloc] init];
    return [config performSelector:sel];
#pragma clang diagnostic pop
}

- (NSInteger)configIntSEL:(SEL)sel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.config respondsToSelector:sel]) {
        return (NSInteger)[self.config performSelector:sel];
    }
    XWNetworkConfig *config = [[XWNetworkConfig alloc] init];
    return (NSInteger)[config performSelector:sel];
#pragma clang diagnostic pop
}

/**
 设置请求头，公共参数
 */
- (void)setSessionManagerTarget:(id<XWNetworkTargetProtocol>)target {
    AFHTTPRequestSerializer *requestSerializer = self.sessionManager.requestSerializer;
    requestSerializer.timeoutInterval = target.timeoutInterval;
    for (NSString *key in target.headers.allKeys) {
        NSString *value = [target.headers objectForKey:key];
        [requestSerializer setValue:value forHTTPHeaderField:key];
    }
    if (!target.package) { return; }
    if (![target.package respondsToSelector: @selector(packageParameters:path:)]) {
        return;
    }
    target.params = [target.package packageParameters:target.params path:target.path] ? : target.params;
}

/**
 发送请求
 */
- (void)sendRequestTarget:(id<XWNetworkTargetProtocol>)target
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure {
    [XWNetworkDevTool addRequestUrl:target.url path:target.path params:target.params];
    if (target.method == XWRequestMethodPOST) {
        [self POSTTarget:target success:success failure:failure];
    }else if(target.method == XWRequestMethodGET) {
        [self GETTarget:target success:success failure:failure];
    }else {
        NSLog(@"error -- : 请求method不能为空！！！");
        NSError *error = [XWNetworkError errorWithErrorCode:10000
                                                description:target.serverErrorMessage
                                                     domain:target.url];
        [self didReceiveResultComplete:nil error:error target:target];
    }
}

/**
 发送POST请求
 */
- (void)POSTTarget:(id<XWNetworkTargetProtocol>)target
           success:(SuccessBlock)success
           failure:(FailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    NSString *url = target.url;
    if (target.path.length) {
        url = [NSString stringWithFormat:@"%@/%@",target.url, target.path];
    }
    // 异步请求
    if (!target.needSync) {
        [self.sessionManager POST:url parameters:target.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf requestResponse:responseObject target:target success:success failure:failure];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf requestError:error target:target success:success failure:failure];
        }];
        return ;
    }
    
    // 同步请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("synchRequest", NULL);
    __block id _responseObject = nil;
    __block NSError *_error = nil;
    [self.sessionManager setCompletionQueue:queue];
    [self.sessionManager POST:url parameters:target.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _responseObject = responseObject;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (_responseObject) {
        [self requestResponse:_responseObject target:target success:success failure:failure];
    }else {
        [self requestError:_error target:target success:success failure:failure];
    }
}

/**
 发送GET请求
 */
- (void)GETTarget:(id<XWNetworkTargetProtocol>)target
          success:(SuccessBlock)success
          failure:(FailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    NSString *url = target.url;
    if (target.path.length) {
        url = [NSString stringWithFormat:@"%@/%@",target.url, target.path];
    }
    // 异步请求
    if (!target.needSync) {
        [self.sessionManager GET:url parameters:target.params progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [weakSelf requestResponse:responseObject target:target success:success failure:failure];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [weakSelf requestError:error target:target success:success failure:failure];
         }];
        return ;
    }
    
    // 同步请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("synchRequest", NULL);
    __block id _responseObject = nil;
    __block NSError *_error = nil;
    [self.sessionManager setCompletionQueue:queue];
    [self.sessionManager GET:url parameters:target.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _responseObject = responseObject;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (_responseObject) {
        [self requestResponse:_responseObject target:target success:success failure:failure];
    }else {
        [self requestError:_error target:target success:success failure:failure];
    }
}

/**
 请求成功处理
 */
- (void)requestResponse:(id)response
                 target:(id<XWNetworkTargetProtocol>)target
                success:(SuccessBlock)success
                failure:(FailureBlock)failure {
    if (!response || ![response isKindOfClass:[NSDictionary class]]) {
        NSLog(@"error -- : 请求method不能为空！！！");
        NSError *error = [XWNetworkError errorWithErrorCode:10000 description:target.serverErrorMessage domain:target.url];
        [self requestError:error target:target success:success failure:failure];
        return ;
    }
    [self didReceiveResultBegin:response error:nil target:target];
    NSString *msg = response[target.msgKey] ? : @"";
    NSInteger code = [response[target.codeKey] integerValue];
    NSDictionary *data = response[target.dataKey];
    if (code != target.successCode || !data) {
        msg = response[target.msgKey] ? : target.serverErrorMessage;
        NSError *error = [XWNetworkError errorWithErrorCode:code description:msg domain:target.url];
        [self requestError:error target:target success:success failure:failure];
        return ;
    }
    [self saveResponse:data target:target];
    [self didReceiveResultComplete:response error:nil target:target];
    if (success) {
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:data];
        dataDic[ISLocalDataKey] = [NSNumber numberWithBool:NO];
        success(dataDic, msg);
    }
}

/**
 请求错误处理
 */
- (void)requestError:(NSError *)error
              target:(id<XWNetworkTargetProtocol>)target
             success:(SuccessBlock)success
             failure:(FailureBlock)failure {
    if (error.code == NSURLErrorCancelled) {
        [self didCancelRequest:target];
    }else if ([target.needRetryFailed boolValue]) {
        [XWDomainManager autoChangeDomain:target];
        [self willRetryRequest:target];
        [target setNeedRetryFailed:[NSNumber numberWithBool:NO]];
        [self sendRequestTarget:target success:success failure:failure];
    }else {
        [XWDomainManager autoChangeDomain:target];
        [XWNetworkError localizationError:&error target:target];
        [self didReceiveResultComplete:nil error:error target:target];
        if (failure) {
            failure(error);
        }
    }
}

/**
 即将发送请求
 */
- (void)willSendRequest:(id<XWNetworkTargetProtocol>)target {
    if (target.plugin && [target.plugin respondsToSelector:@selector(willSendRequest:)]) {
        [target.plugin willSendRequest:target];
    }
}

/**
 取消了网络请求
 */
- (void)didCancelRequest:(id<XWNetworkTargetProtocol>)target {
    if (target.plugin && [target.plugin respondsToSelector:@selector(didCancelRequest:)]) {
        [target.plugin didCancelRequest:target];
    }
}

/**
 开始请求结果处理
 */
- (void)didReceiveResultBegin:(NSDictionary *)result
                        error:(NSError *)error
                       target:(id<XWNetworkTargetProtocol>)target {
    if (target.plugin && [target.plugin respondsToSelector:@selector(didReceiveResultBegin:error:target:)]) {
        [target.plugin didReceiveResultBegin:result error:error target:target];
    }
}

/**
 结束请求结果处理
 */
- (void)didReceiveResultComplete:(NSDictionary *)result
                           error:(NSError *)error
                          target:(id<XWNetworkTargetProtocol>)target {
    NSLog(@"\n请求地址：%@\n请求接口：%@\n请求参数：\n%@", target.url, target.path, target.params);
    if (result) {
        NSLog(@"\n%@\n", result);
    }else {
        NSLog(@"\n请求失败：%@\n", error.localizedDescription);
    }
    if (target.plugin && [target.plugin respondsToSelector:@selector(didReceiveResultComplete:error:target:)]) {
        [target.plugin didReceiveResultComplete:result error:error target:target];
    }
}

/**
 即将重新发送请求
 */
- (void)willRetryRequest:(id<XWNetworkTargetProtocol>)target {
    if (target.plugin && [target.plugin respondsToSelector:@selector(willRetryRequest:)]) {
        [target.plugin willRetryRequest:target];
    }
}

/**
 请求管理器
 */
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] init];
        NSSet *contentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        [_sessionManager.responseSerializer setAcceptableContentTypes:contentTypes];
        _sessionManager.responseSerializer = response;
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _sessionManager;
}


@end
