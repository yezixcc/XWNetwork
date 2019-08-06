//
//  XWNetworkHistoryViewController.m
//  Process
//
//  Created by gaoxw on 2019/8/5.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkRequestHistory.h"
#import "XWNetworkDevTool.h"

@interface XWNetworkRequestHistory ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation XWNetworkRequestHistory

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络请求历史";
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
    self.navigationItem.rightBarButtonItem = right;
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)delete {
    [XWNetworkDevTool removeAllRequestsHistory];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    if (indexPath.row < self.data.count) {
        NSDictionary *dict = self.data[indexPath.row];
        NSString *str = [self textLabelTextWithDict:dict];
        cell.textLabel.text = str;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.data[indexPath.row];
    NSString *str = [self textLabelTextWithDict:dict];
    NSDictionary *attrs = @{NSFontAttributeName :[UIFont systemFontOfSize:15]};
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.view.bounds)-30, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [str boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    return size.height;
}

- (NSString *)textLabelTextWithDict:(NSDictionary *)dict {
    NSString *url = dict[@"url"];
    NSString *path = dict[@"path"];
    NSString *time = dict[@"time"];
    NSDictionary *paramDic = dict[@"params"];
    NSString *params = @"";
    for (NSString *key in paramDic.allKeys) {
        NSString *str = [NSString stringWithFormat:@"%@ = %@\n", key, paramDic[key]];
        params = [NSString stringWithFormat:@"%@%@", params, str];
    }
    if (params.length > 0) {
        params = [params substringToIndex:params.length-1];
    }
    NSString *str = [NSString stringWithFormat:@"时间：%@\n地址：%@\n接口：%@\n参数：\n%@", time, url, path, params];
    return str;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)dealloc {
    
}

@end
