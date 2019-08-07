//
//  XWNetworkError.m
//  Process
//
//  Created by gaoxw on 2019/7/26.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkError.h"
#import "XWNetworkTarget.h"

@implementation XWNetworkError

+ (BOOL)localizationError:(NSError **)error target:(XWNetworkTarget *)target {
    if (error == NULL) {
        return NO;
    }
    NSError *er = *error;
    NSErrorDomain errorDomain = er.domain;
    NSInteger errorCode = er.code;
    if ([errorDomain isEqualToString:NSURLErrorDomain]) {
        switch (errorCode) {
            case NSURLErrorCancelled: ///-999
                er = [self errorWithErrorCode:errorCode
                             description:target.networkErrorMessage
                                  domain:target.url];
                break;
            case NSURLErrorTimedOut: ///-1001
                er = [self errorWithErrorCode:errorCode
                                  description:target.networkErrorMessage
                                       domain:target.url];
                break;
            case NSURLErrorNotConnectedToInternet: ///-1009
                er = [self errorWithErrorCode:errorCode
                                  description:target.networkErrorMessage
                                       domain:target.url];
                break;
            case NSURLErrorUserCancelledAuthentication: ///-1012
                er = [self errorWithErrorCode:errorCode
                                  description:target.networkErrorMessage
                                       domain:target.url];
                break;
            case NSURLErrorUserAuthenticationRequired: ///-1013
                er = [self errorWithErrorCode:errorCode
                                  description:target.networkErrorMessage
                                       domain:target.url];
                break;
            case NSURLErrorBadURL: ///-1000
            case NSURLErrorUnsupportedURL: ///-1002
            case NSURLErrorCannotFindHost: ///-1003
            case NSURLErrorCannotConnectToHost: ///-1004
            case NSURLErrorNetworkConnectionLost: ///-1005
            case NSURLErrorDNSLookupFailed: ///-1006
            case NSURLErrorHTTPTooManyRedirects: ///-1007
            case NSURLErrorResourceUnavailable: ///-1008
            case NSURLErrorRedirectToNonExistentLocation: ///-1010
            case NSURLErrorBadServerResponse: ///-1011
            case NSURLErrorZeroByteResource: ///-1014
            case NSURLErrorCannotDecodeRawData: ///-1015
            case NSURLErrorCannotDecodeContentData: ///-1016
            case NSURLErrorCannotParseResponse: ///-1017
                er = [self errorWithErrorCode:errorCode
                                  description:target.networkErrorMessage
                                       domain:target.url];
                break;
            default:
                break;
        }
    }
    *error = er;
    return YES;
}

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode
                    description:(NSString *)description
                         domain:(NSString *)domain {
    NSString *msg = description ? : @"";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : msg};
    return [NSError errorWithDomain:domain code:errorCode userInfo:userInfo];
}

@end
