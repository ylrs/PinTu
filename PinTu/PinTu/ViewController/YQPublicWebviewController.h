//
//  YQPublicWebviewController.h
//  Wenwanmi
//
//  Created by tiantian on 15/4/16.
//  Copyright (c) 2015年 tiantian. All rights reserved.
//

#import "YQBaseViewController.h"
#import "PinTuConst.h"
#import "YQPublicWebviewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
@interface YQPublicWebviewController : YQBaseViewController
@property (nonatomic, strong) NSString  * urlstring;
@property (nonatomic, strong) NSString  * titleViewTitle;
@property (nonatomic, strong) JSContext * jsContext;
@property (nonatomic, strong) UIWebView * webview;
@property (nonatomic,   copy) void(^WebFinishBlock)(NSString *url);
//@property (nonatomic, strong) WKWebView * wkWebView;
@property (nonatomic, assign) BOOL   isTabBar;
-(void)loadRequest;
@end
