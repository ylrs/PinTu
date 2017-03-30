//
//  LF_NavigationBar.h
//  Wenwanmi
//
//  Created by YLRS on 16/2/18.
//  Copyright © 2016年 wenwanmi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackAction)();

@interface LF_NavigationBar : UIView
@property(nonatomic,weak)UIView   *backView;
@property(nonatomic,weak)UIView   *xian;
@property(nonatomic,weak)UIButton *leftButton;
@property(nonatomic,weak)UILabel  *titleLabel;
@property(nonatomic,strong)UIButton *rightButton;
@property(nonatomic,strong)BackAction backAction;
-(void)setTitleText:(NSString *)title;
-(void)setTitleColor:(UIColor *)color;
-(void)setRightItemWithName:(NSString *)name target:(id)target action:(SEL)action;

-(void)setRightItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;

@end
