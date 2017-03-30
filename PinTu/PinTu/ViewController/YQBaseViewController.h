//
//  YQBaseViewController.h
//  Wenwanmi
//
//  Created by tiantian on 15/3/12.
//  Copyright (c) 2015年 tiantian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LF_NavigationBar.h"
@import InMobiSDK.IMBanner;
@import InMobiSDK.IMBannerDelegate;

@interface YQBaseViewController : UIViewController

@property (nonatomic,weak)LF_NavigationBar *navigationBar;
@property (nonatomic,strong)NSString *navigationTitle;
@property (nonatomic,assign)BOOL  isFirstRefresh;
@property (nonatomic,assign)BOOL  isDismiss;

/**	是否自动调整scrollview等得insets，调用该
 *  方法后，UIViewController中用到子视图坐标
 *  系是从导航栏左下角开始的，否则是从屏幕左上角开始的
 */
- (void) configAdjustsScrollViewInsets;

/**
 * titleView的文本
 */

- (void)setTitleViewText:(NSString *)text;

- (void)setTitleViewTextColor:(UIColor *)color;

- (void)backAction;

- (void)showDefaultView;

- (void)hiddenDefaultView;

- (void)refreshAction;
@end
