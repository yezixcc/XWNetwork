//
//  XWLogPlugin.m
//  Process
//
//  Created by gaoxw on 2019/7/30.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#import <objc/runtime.h>

#pragma mark - 方法交换

static inline void sq_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma mark - NSObject分类

@implementation NSObject (XWLogPlugin)

/**
 obj 转 NSString
 */
- (NSString *)convertToJsonString {
    if (![NSJSONSerialization isValidJSONObject:self])  return nil;
    NSError *error = nil;
    NSJSONWritingOptions jsonOptions = NSJSONWritingPrettyPrinted;
    if (@available(iOS 11.0, *)) {
        jsonOptions = NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys ;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted  error:&error];
    if (error || !jsonData) return nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end


#pragma mark - NSDictionary分类

@implementation NSDictionary (XWLogPlugin)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        sq_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(printlog_descriptionWithLocale:));
        sq_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(printlog_descriptionWithLocale:indent:));
        sq_swizzleSelector(class, @selector(debugDescription), @selector(printlog_debugDescription));
    });
}

- (NSString *)printlog_descriptionWithLocale:(id)locale{
    NSString *result = [self convertToJsonString];
    if (!result) {
        result = [self printlog_descriptionWithLocale:locale];
        return result;
    }
    return result;
}

- (NSString *)printlog_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSString *result = [self convertToJsonString];
    if (!result) {
        result = [self printlog_descriptionWithLocale:locale indent:level];
        return result;
    }
    return result;
}
- (NSString *)printlog_debugDescription{
    NSString *result = [self convertToJsonString];
    if (!result) return [self printlog_debugDescription];
    return result;
}

@end


#pragma mark - NSArray分类

@implementation NSArray (XWLogPlugin)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        sq_swizzleSelector(class, @selector(descriptionWithLocale:), @selector(printlog_descriptionWithLocale:));
        sq_swizzleSelector(class, @selector(descriptionWithLocale:indent:), @selector(printlog_descriptionWithLocale:indent:));
        sq_swizzleSelector(class, @selector(debugDescription), @selector(printlog_debugDescription));
    });
}

- (NSString *)printlog_descriptionWithLocale:(id)locale{
    NSString *result = [self convertToJsonString];
    if (!result) {
        result = [self printlog_descriptionWithLocale:locale];
        return result;
    }
    return result;
}

- (NSString *)printlog_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSString *result = [self convertToJsonString];
    if (!result) {
        result = [self printlog_descriptionWithLocale:locale indent:level];//如果无法转换，就使用原先的格式
        return result;
    }
    return result;
}

- (NSString *)printlog_debugDescription{
    NSString *result = [self convertToJsonString];
    if (!result) return [self printlog_debugDescription];
    return result;
}

@end

#endif
