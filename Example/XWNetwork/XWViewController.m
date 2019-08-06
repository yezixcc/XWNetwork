//
//  XWViewController.m
//  XWNetwork
//
//  Created by gaoxw on 08/06/2019.
//  Copyright (c) 2019 gaoxw. All rights reserved.
//

#import "XWViewController.h"
#import "XWNetworkConfigManager.h"

@interface XWViewController ()

@end

@implementation XWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [XWNetworkManager requestParams:@{@"fdaf": @"rreaf", @"fdaf1": @"rreaf"} path:@"mock" success:^(NSDictionary *result, NSString *msg) {
        NSLog(@"===== 请求成功 =====");
    } failure:^(NSError *error) {
        NSLog(@"请求失败：%@", error.localizedDescription);
    }];
    
//    XWNetworkTarget *target = [[XWNetworkTarget alloc] init];
//    target.path = @"mock";
//    target.needCache = @(NO);
//    target.params = @{@"fdaf": @"rreaf", @"fdaf1": @"rreaf"};
//    [XWNetworkManager requestTarget:target success:^(NSDictionary *result, NSString *msg) {
//        NSLog(@"---------- 第二次请求结果");
//    } failure:^(NSError *error) {
//
//    }];
}

@end
