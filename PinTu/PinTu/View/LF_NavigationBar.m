//
//  LF_NavigationBar.m
//  Wenwanmi
//
//  Created by YLRS on 16/2/18.
//  Copyright © 2016年 wenwanmi. All rights reserved.
//

#import "LF_NavigationBar.h"
@interface LF_NavigationBar()

@end

@implementation LF_NavigationBar
-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initFrame];
    }
    return self;
}

-(void)initFrame
{
    self.frame = CGRectMake(0, 0, kDeviceWidth, 64);
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 20, kDeviceWidth, 44);
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    self.backView = backView;
    
    UIView *xian = [[UIView alloc] init];
    xian.frame = CGRectMake(0, 63.5, kDeviceWidth, 0.5);
    xian.backgroundColor = StandardColor8;
    [self addSubview:xian];
    self.xian = xian;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.titleLabel.font = StandardFont2;
    [leftButton setTitleColor:StandardColor7 forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"getpwd_nav_back"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"getpwd_nav_back"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:leftButton];
    self.leftButton = leftButton;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];//设置Label背景透明
    titleLabel.textColor = StandardColor7;
    titleLabel.font = StandardFont1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    WS(ws);
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(backView);
        make.left.mas_equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.top.mas_equalTo(0);
    }];
}
-(void)back
{
    if (self.backAction) {
        self.backAction();
    }
}
-(void)setTitleText:(NSString *)title
{
    self.titleLabel.text = title;
}
-(void)setTitleColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
}
-(void)setRightItemWithName:(NSString *)name target:(id)target action:(SEL)action
{
    [self.rightButton removeFromSuperview];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = StandardFont2;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.rightButton = button;
    [self.backView addSubview:button];
    
    float width = [WWMBaseTool getTextWidth:name font:15];
    CGSize size = CGSizeMake(width, 44);

    WS(ws);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.backView);
        make.right.mas_equalTo(ws.backView).offset(-10);
        make.size.mas_equalTo(size);
    }];
}

-(void)setRightItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action
{
    [self.rightButton removeFromSuperview];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = StandardFont2;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton = button;
    [self.backView addSubview:button];
    
    CGSize size = CGSizeMake(44, 44);
    
    WS(ws);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.backView);
        make.right.mas_equalTo(ws.backView).offset(0);
        make.size.mas_equalTo(size);
    }];
}
-(void)setBackAction:(BackAction)backAction
{
    _backAction = backAction;
}


@end
