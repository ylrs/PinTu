//
//  YQBaseViewController.m
//  Wenwanmi
//
//  Created by tiantian on 15/3/12.
//  Copyright (c) 2015年 tiantian. All rights reserved.
//

#import "YQBaseViewController.h"
#import "WWM_Const.h"
#import "Dialog.h"
#import "AFNetworkReachabilityManager.h"
#import "YQMessageCountParam.h"
#import "YQMessageTool.h"
#import "YQMessageCountResult.h"
#import "YQBadgeItem.h"
#import "UMMobClick/MobClick.h"

@interface YQBaseViewController ()

@end

@implementation YQBaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = StandardColor10;
    
    self.isFirstRefresh = YES;
    
    LF_DefaultView *failView = [[LF_DefaultView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    failView.hidden = YES;
    [self.view addSubview:failView];
    self.failView = failView;
    
    WS(ws);
    failView.RefreshBlock = ^(){
        [ws refreshAction];
    };
    
    LF_NavigationBar *navigationBar = [[LF_NavigationBar alloc] init];
    
    navigationBar.backAction = ^(void){
        [ws backAction];
    };
    [self.view addSubview:navigationBar];
    self.navigationBar = navigationBar;

    self.navigationController.navigationBarHidden = YES;
}

-(void)showDefaultView
{
    self.failView.hidden = NO;
    [self.view insertSubview:self.failView belowSubview:self.navigationBar];
}

-(void)hiddenDefaultView
{
    self.failView.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Dialog hideGifHudInWindow];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkNetState];
    
    UILabel * label = self.navigationBar.titleLabel;
    if (label.text.length>0) {
        [MobClick beginLogPageView:label.text];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadData {
    
}

#pragma mark - 网络监测
- (void) checkNetState {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self performSelector:@selector(netStatus) withObject:nil afterDelay:0.5];
}
- (void) netStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable) {
            [Dialog toastCenter:@"请检查网络"];
        }
    }];
}

#pragma mark -
- (void) configAdjustsScrollViewInsets {
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setTitleViewText:(NSString *)text {
    
    [self.navigationBar setTitleText:text];
    
    UILabel * label = (UILabel *)self.navigationItem.titleView;
    [label removeFromSuperview];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];//设置Label背景透明
    titleLabel.textColor = StandardColor7;
    titleLabel.font = StandardFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = text;
    self.navigationItem.titleView = titleLabel;    
}

- (void)setTitleViewTextColor:(UIColor *)color {
    
    [self.navigationBar setTitleColor:color];
}
- (void)backAction
{
    if (self.isDismiss) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)refreshAction
{
}
@end
