//
//  XWNetworkDevTool.h
//  Process
//
//  Created by gaoxw on 2019/8/5.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XWNetworkDevTool : NSObject

+ (void)start;
+ (void)addRequestUrl:(NSString *)url path:(NSString *)path params:(NSDictionary *)params;
+ (void)removeAllRequestsHistory;

@end
