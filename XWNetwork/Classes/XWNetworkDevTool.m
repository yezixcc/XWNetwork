//
//  XWNetworkDevTool.m
//  Process
//
//  Created by gaoxw on 2019/8/5.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkDevTool.h"
#import "XWDomainManager.h"
#import "XWNetworkRequestHistory.h"
#import "XWNetworkDomainSwitch.h"

@interface XWNetworkDevListViewController: UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@interface XWNetworkDevTool ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) NSMutableArray *requests;

@end

@implementation XWNetworkDevTool

+ (XWNetworkDevTool *)shareInstance {
    static XWNetworkDevTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XWNetworkDevTool alloc] init];
    });
    return instance;
}

+ (void)start {
#ifdef DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XWNetworkDevTool *tool = [XWNetworkDevTool shareInstance];
        [tool performSelector:@selector(start) withObject:nil afterDelay:0];
    });
#endif
}

+ (void)addRequestUrl:(NSString *)url path:(NSString *)path params:(NSDictionary *)params {
#ifdef DEBUG
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    XWNetworkDevTool *tool = [XWNetworkDevTool shareInstance];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"url"] = url;
    dict[@"path"] = path;
    dict[@"params"] = params;
    dict[@"time"] = [format stringFromDate:date];
    if (tool.requests.count) {
        [tool.requests insertObject:dict atIndex:0];
        if (tool.requests.count > 15) {
            [tool.requests removeLastObject];
        }
    }else {
        [tool.requests addObject:dict];
    }
#endif
}

+ (void)removeAllRequestsHistory {
    XWNetworkDevTool *tool = [XWNetworkDevTool shareInstance];
    [tool.requests removeAllObjects];
}

- (void)start {
    UIViewController *vc = [[XWNetworkDevListViewController alloc] init];
    _nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [[UIApplication sharedApplication].delegate.window addSubview:self.button];
    [self setButtonTitle];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.button addGestureRecognizer:pan];
}

- (void)setButtonTitle {
    switch ([XWDomainManager currenServerType]) {
        case XWServerTypeDevelop:
            [self.button setTitle:@"Dev" forState:UIControlStateNormal];
            break;
        case XWServerTypeTest:
            [self.button setTitle:@"Test" forState:UIControlStateNormal];
            break;
        case XWServerTypePrepare:
            [self.button setTitle:@"Pre" forState:UIControlStateNormal];
            break;
        case XWServerTypeProduct:
            [self.button setTitle:@"Pro" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (!pan.view) {
        return;
    }
    CGPoint point = [pan translationInView:pan.view];
    CGFloat margin = 0;
    CGFloat centerX = pan.view.center.x + point.x;
    CGFloat centerY = pan.view.center.y + point.y;
    CGFloat viewW = pan.view.frame.size.width * 0.5 + margin;
    CGFloat viewH = pan.view.frame.size.height * 0.5 + margin;
    if (centerX - viewW < 0) {
        centerX = viewW;
    }
    if (centerX + viewW > CGRectGetWidth([UIScreen mainScreen].bounds)) {
        centerX = CGRectGetWidth([UIScreen mainScreen].bounds) - viewW;
    }
    if (centerY - viewH < 0) {
        centerY = viewH;
    }
    if (centerY + viewH > CGRectGetHeight([UIScreen mainScreen].bounds)) {
        centerY = CGRectGetHeight([UIScreen mainScreen].bounds) - viewH;
    }
    pan.view.center = CGPointMake(centerX, centerY);
    [pan setTranslation:CGPointZero inView:self.button.superview];
}


- (void)buttonClicked:(UIButton *)sender {
    if (sender.isSelected) {
        sender.selected = NO;
        [_nav popToRootViewControllerAnimated:NO];
        [_nav dismissViewControllerAnimated:YES completion:nil];
    }else{
        sender.selected = YES;
        UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:_nav animated:YES completion:^{
            [[UIApplication sharedApplication].delegate.window bringSubviewToFront:sender];
        }];
    }
}


- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        _button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-100, 20, 44, 44);
        _button.backgroundColor = [UIColor redColor];
        _button.layer.cornerRadius = 22;
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (NSMutableArray *)requests {
    if (!_requests) {
        _requests = [[NSMutableArray alloc] init];
    }
    return _requests;
}

@end


@implementation XWNetworkDevListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络工具";
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    if (indexPath.row < self.dataSource.count) {
        cell.textLabel.text = self.dataSource[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        XWNetworkDomainSwitch *domain = [[XWNetworkDomainSwitch alloc] init];
        [self.navigationController pushViewController:domain animated:YES];
    }else if(indexPath.row == 1) {
        XWNetworkRequestHistory *history = [[XWNetworkRequestHistory alloc] init];
        history.data = [XWNetworkDevTool shareInstance].requests;
        [self.navigationController pushViewController:history animated:YES];
    }
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"配置环境", @"查看网络请求历史"];
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
