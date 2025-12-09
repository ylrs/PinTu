//
//  BackdoorViewController.m
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import "BackdoorViewController.h"

@interface BackdoorViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *toggleSwitch;
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
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped)];
    self.navigationItem.rightBarButtonItem = closeItem;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *switchIdentifier = @"BackdoorSwitchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:switchIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
            [toggle addTarget:self action:@selector(tileSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = toggle;
            self.toggleSwitch = toggle;
        }
        cell.textLabel.text = @"显示拼图块编号";
        self.toggleSwitch.on = self.showTileIndices;
        return cell;
    } else {
        static NSString *buttonIdentifier = @"BackdoorButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:buttonIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
        }
        cell.textLabel.text = @"自动还原拼图";
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        if ([self.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
            [self.delegate backdoorViewController:self didSelectAction:BackdoorActionAutoSolve];
        }
    }
}

- (void)tileSwitchChanged:(UISwitch *)sender
{
    self.showTileIndices = sender.isOn;
    if ([self.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
        [self.delegate backdoorViewController:self didSelectAction:BackdoorActionShowTileIndices];
    }
}

- (void)closeTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
