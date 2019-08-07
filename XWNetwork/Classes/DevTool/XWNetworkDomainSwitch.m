//
//  XWNetworkDomainSwitch.m
//  Process
//
//  Created by gaoxw on 2019/8/5.
//  Copyright © 2019 gaoxw. All rights reserved.
//

#import "XWNetworkDomainSwitch.h"
#import "XWNetwork.h"

@interface XWNetworkDomainSwitchCell : UITableViewCell

@property (nonatomic, strong) UITextView *textField;

@end

@implementation XWNetworkDomainSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.textField];
        self.detailTextLabel.text = @" ";
    }
    return self;
}

- (UITextView *)textField {
    if (!_textField) {
        CGRect rect = CGRectMake(10, 25, CGRectGetWidth([UIScreen mainScreen].bounds)-60, 40);
        _textField = [[UITextView alloc] initWithFrame:rect];
        _textField.font = [UIFont systemFontOfSize:10];
        _textField.textColor = self.detailTextLabel.textColor;
        _textField.scrollEnabled = NO;
    }
    return _textField;
}

@end

@interface XWNetworkDomainSwitch ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation XWNetworkDomainSwitch

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"配置环境";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.selectIndex = [XWDomainManager currenServerType];
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        _selectIndex = selectIndex;
        [XWDomainManager setCurrentServerType:_selectIndex];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    XWNetworkDomainSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[XWNetworkDomainSwitchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < self.data.count) {
        NSDictionary *dict = self.data[indexPath.row];
        cell.textLabel.text = dict[@"name"];
        cell.textField.text = dict[@"url"];
    }
    cell.accessoryType = self.selectIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textField.userInteractionEnabled = indexPath.row == 0;
    cell.textField.delegate = indexPath.row == 0 ? self : nil;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.row;
    [self.tableView reloadData];
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

- (NSArray *)data {
    _data = @[@{@"name": @"开发环境", @"url": [XWDomainManager serverURL:XWServerTypeDevelop] ? : @"未配置"},
              @{@"name": @"测试环境", @"url": [XWDomainManager serverURL:XWServerTypeTest] ? : @"未配置"},
              @{@"name": @"预生产环境", @"url": [XWDomainManager serverURL:XWServerTypePrepare] ? : @"未配置"},
              @{@"name": @"生产环境", @"url": [XWDomainManager serverURL:XWServerTypeProduct] ? : @"未配置"}];
    return _data;
}

- (void)textViewDidChange:(UITextView *)textView {
    serverURL_dev = textView.text;
}

- (void)dealloc {
    
}

@end
