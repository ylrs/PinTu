//
//  BackdoorViewController.m
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import "BackdoorViewController.h"

NSString * const BackdoorShowTileIndicesPreferenceKey = @"BackdoorShowTileIndicesEnabled";

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
    return 3;
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
    } else if (indexPath.row == 1) {
        static NSString *difficultyIdentifier = @"BackdoorDifficultyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:difficultyIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:difficultyIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.32f green:0.45f blue:0.86f alpha:1.0f];
        }
        cell.textLabel.text = @"打乱复杂度";
        cell.detailTextLabel.text = [PinTuView displayNameForDifficulty:self.selectedDifficulty];
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
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self presentDifficultyOptionsFromCell:cell];
    } else if (indexPath.row == 2) {
        if ([self.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
            [self.delegate backdoorViewController:self didSelectAction:BackdoorActionAutoSolve];
        }
    }
}

- (void)tileSwitchChanged:(UISwitch *)sender
{
    self.showTileIndices = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:self.showTileIndices
                                            forKey:BackdoorShowTileIndicesPreferenceKey];
    if ([self.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
        [self.delegate backdoorViewController:self didSelectAction:BackdoorActionShowTileIndices];
    }
}

- (void)presentDifficultyOptionsFromCell:(UITableViewCell *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择难度"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    void (^addAction)(PinTuShuffleDifficulty) = ^(PinTuShuffleDifficulty difficulty) {
        NSString *title = [PinTuView displayNameForDifficulty:difficulty];
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull _) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.selectedDifficulty = difficulty;
            NSIndexPath *difficultyIndex = [NSIndexPath indexPathForRow:1 inSection:0];
            [strongSelf.tableView reloadRowsAtIndexPaths:@[difficultyIndex] withRowAnimation:UITableViewRowAnimationNone];
            if ([strongSelf.delegate respondsToSelector:@selector(backdoorViewController:didSelectAction:)]) {
                [strongSelf.delegate backdoorViewController:strongSelf didSelectAction:BackdoorActionChangeDifficulty];
            }
        }];
        [alert addAction:action];
    };
    addAction(PinTuShuffleDifficultySimple);
    addAction(PinTuShuffleDifficultyHard);
    addAction(PinTuShuffleDifficultyHell);
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    UIPopoverPresentationController *popover = alert.popoverPresentationController;
    if (popover) {
        popover.sourceView = cell ?: self.view;
        popover.sourceRect = cell ? cell.bounds : self.view.bounds;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
