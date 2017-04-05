//
//  YQPublicWebviewController.m
//  Wenwanmi
//
//  Created by tiantian on 15/4/16.
//  Copyright (c) 2015年 tiantian. All rights reserved.
//

#import "YQPublicWebviewController.h"
#import "Dialog.h"


@interface YQPublicWebviewController ()<UIWebViewDelegate,NSURLConnectionDelegate>
@property (nonatomic, strong)NSURLRequest *urlRequest;
@property (nonatomic, strong)UIView   *tabBarView;
@property (nonatomic, strong)UIButton *backButton;
@property (nonatomic, strong)UILabel  *titleLabel;
@property (nonatomic, strong)NSURLConnection *urlConnection;
@property (nonatomic, strong)NSURLRequest    *request;
@property (nonatomic, assign)BOOL   authenticated;
@property (nonatomic, strong)NSArray *menuArray;
@end

@implementation YQPublicWebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationBar.hidden = YES;
    
    NSString *urlStr = self.urlstring;
   
    [self initTabBar];
    
    NSURL * url = [NSURL URLWithString:urlStr];
        
    CGFloat tempSpace = 0;
    if (self.isTabBar) {
        tempSpace = 50;
    }
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    self.webview.frame = CGRectMake(0, 64, kDeviceWidth, KDeviceHeight-64-tempSpace);
    [self.view addSubview:self.webview];
    [self.webview loadRequest:request];
    
    [self setTitleViewText:self.titleViewTitle];
}

-(void)initTabBar
{
    self.tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0,0, kDeviceWidth, 64)];
    self.tabBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBarView];
    
    UILabel *xian = [[UILabel alloc] init];
    xian.frame = CGRectMake(0, 63.5, kDeviceWidth, 0.5);
    xian.backgroundColor = StandardColor8;
    [self.tabBarView addSubview:xian];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 20, 70, 44);
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.backButton setTitleColor:StandardColor7 forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"getpwd_nav_back"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"getpwd_nav_back"] forState:UIControlStateDisabled];
    self.backButton.titleLabel.font = StandardFont2;
    [self.backButton addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [self.tabBarView addSubview:self.backButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];//设置Label背景透明
    self.titleLabel.textColor = StandardColor7;
    self.titleLabel.font = StandardFont1;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.tabBarView addSubview:self.titleLabel];
    
    WS(ws);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.tabBarView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.top.mas_equalTo(20);
    }];

}
-(void)backBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)loadRequest
{
    NSString *urlStr = self.urlstring;
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:urlStr];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    self.urlRequest = request;
    [self.webview loadRequest:request];
    
}

#pragma mark - overwrite super methods
- (UIScrollView *)viewForRefreshing {
    return self.webview.scrollView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
#pragma mark -
#pragma mark - 跳转页面

- (void) resetNavigationBar {
   
}

- (void) setTitleViewTitle:(NSString *)titleViewTitle {
    _titleViewTitle = titleViewTitle;
    
    [self setTitleViewText:titleViewTitle];
}

#pragma mark -
#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}
-(void)setTitleViewText:(NSString *)text
{
    CGRect frame = self.titleLabel.frame;
    frame.size.width = 150;
    frame.origin.x = (kDeviceWidth-frame.size.width)/2;
    self.titleLabel.frame = frame;
    self.titleLabel.text = text;
}

@end
