//
//  BackdoorViewController.m
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import "BackdoorViewController.h"

@interface BackdoorViewController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation BackdoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"后门功能";
    
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    table.dataSource = self;
    table.delegate = self;
    table.backgroundColor = [UIColor whiteColor];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = table;
    [self.view addSubview:table];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BackdoorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
        [toggle addTarget:self action:@selector(tileSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
    }
    cell.textLabel.text = @"显示拼图块编号";
    UISwitch *toggle = (UISwitch *)cell.accessoryView;
    toggle.on = self.showTileIndices;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tileSwitchChanged:(UISwitch *)sender
{
    self.showTileIndices = sender.isOn;
    if ([self.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
        [self.delegate backdoorViewController:self didSelectAction:BackdoorActionShowTileIndices];
    }
}

@end
